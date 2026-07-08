"""
PakFASAL - DSS Machine Learning trainer.

Purpose
-------
The sensor module used to give recommendations with a simple rule-based
(if/else threshold) engine. This script trains real Machine Learning models
(Random Forest classifiers) that learn the mapping:

    (soil moisture, pH, rain chance, crop)  ->  DSS decision

Three classifiers are trained:
  1. irrigation_action : irrigate_now | hold_for_rain | reduce_irrigation | maintain
  2. soil_action       : apply_lime  | apply_gypsum  | balanced
  3. priority          : LOW | MEDIUM | HIGH

Because we do not yet have a large hand-labelled field dataset, we generate a
synthetic dataset from Pakistani agronomy knowledge (same crop thresholds the
app already ships with) and add realistic noise. The Random Forest then learns
smooth, generalised decision boundaries instead of hard thresholds.

The trained forests are exported to a compact JSON file that the Flutter app
loads at runtime and runs on-device (pure Dart inference, no native ML plugin).

Run:
    python ml/train_dss_model.py
"""

from __future__ import annotations

import json
import os
from dataclasses import dataclass

import numpy as np
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix
from sklearn.model_selection import train_test_split

# --------------------------------------------------------------------------- #
# Configuration
# --------------------------------------------------------------------------- #

RANDOM_SEED = 42
N_SAMPLES = 9000
LABEL_NOISE = 0.04  # fraction of rows given a wrong label (real-world messiness)

CROPS = ["Wheat", "Rice", "Cotton"]
FEATURE_NAMES = [
    "moisture",
    "ph",
    "rainChance",
    "crop_Wheat",
    "crop_Rice",
    "crop_Cotton",
]

IRRIGATION_CLASSES = ["irrigate_now", "hold_for_rain", "reduce_irrigation", "maintain"]
SOIL_CLASSES = ["apply_lime", "apply_gypsum", "balanced"]
PRIORITY_CLASSES = ["LOW", "MEDIUM", "HIGH"]

OUT_DIR = os.path.join(os.path.dirname(__file__), "..", "assets", "ml")
OUT_MODEL = os.path.join(OUT_DIR, "dss_model.json")
OUT_REPORT = os.path.join(os.path.dirname(__file__), "model_report.txt")


@dataclass(frozen=True)
class CropThreshold:
    moisture_low: float
    moisture_high: float
    ph_low: float
    ph_high: float
    rain_threshold: float


# Same agronomy defaults the Flutter app ships with (SensorRuleSet.fallback()).
CROP_THRESHOLDS = {
    "Wheat": CropThreshold(40, 70, 6.0, 7.5, 50),
    "Rice": CropThreshold(70, 95, 5.5, 7.0, 60),
    "Cotton": CropThreshold(35, 65, 6.0, 8.0, 45),
}


# --------------------------------------------------------------------------- #
# Synthetic dataset generation
# --------------------------------------------------------------------------- #


def _label_irrigation(moisture: float, rain: float, t: CropThreshold) -> str:
    if moisture < t.moisture_low and rain >= t.rain_threshold:
        return "hold_for_rain"
    if moisture < t.moisture_low:
        return "irrigate_now"
    if moisture > t.moisture_high:
        return "reduce_irrigation"
    return "maintain"


def _label_soil(ph: float, t: CropThreshold) -> str:
    if ph < t.ph_low:
        return "apply_lime"
    if ph > t.ph_high:
        return "apply_gypsum"
    return "balanced"


def _label_priority(moisture: float, ph: float, rain: float, t: CropThreshold) -> str:
    """Continuous urgency score -> LOW/MEDIUM/HIGH (richer than the old rules)."""
    score = 0.0

    # Moisture distance from the healthy band.
    if moisture < t.moisture_low:
        score += (t.moisture_low - moisture) / 10.0
    elif moisture > t.moisture_high:
        score += (moisture - t.moisture_high) / 10.0

    # pH distance from the healthy band.
    if ph < t.ph_low:
        score += (t.ph_low - ph) / 0.6
    elif ph > t.ph_high:
        score += (ph - t.ph_high) / 0.6

    # Dry soil + no rain expected is extra urgent.
    if moisture < t.moisture_low and rain < t.rain_threshold:
        score += 1.2

    if score >= 3.0:
        return "HIGH"
    if score >= 1.3:
        return "MEDIUM"
    return "LOW"


def generate_dataset(rng: np.random.Generator):
    x_rows = []
    irrigation, soil, priority = [], [], []

    for _ in range(N_SAMPLES):
        crop = CROPS[rng.integers(0, len(CROPS))]
        t = CROP_THRESHOLDS[crop]

        moisture = float(np.clip(rng.normal(55, 22), 0, 100))
        ph = float(np.clip(rng.normal(6.8, 1.1), 3.5, 9.5))
        rain = float(np.clip(rng.normal(45, 28), 0, 100))

        y_irr = _label_irrigation(moisture, rain, t)
        y_soil = _label_soil(ph, t)
        y_pri = _label_priority(moisture, ph, rain, t)

        # Inject a little label noise so the model must generalise.
        if rng.random() < LABEL_NOISE:
            y_irr = IRRIGATION_CLASSES[rng.integers(0, len(IRRIGATION_CLASSES))]
        if rng.random() < LABEL_NOISE:
            y_pri = PRIORITY_CLASSES[rng.integers(0, len(PRIORITY_CLASSES))]

        x_rows.append(
            [
                moisture,
                ph,
                rain,
                1.0 if crop == "Wheat" else 0.0,
                1.0 if crop == "Rice" else 0.0,
                1.0 if crop == "Cotton" else 0.0,
            ]
        )
        irrigation.append(y_irr)
        soil.append(y_soil)
        priority.append(y_pri)

    return (
        np.array(x_rows, dtype=float),
        np.array(irrigation),
        np.array(soil),
        np.array(priority),
    )


# --------------------------------------------------------------------------- #
# Tree export (sklearn -> compact JSON)
# --------------------------------------------------------------------------- #


def export_tree(tree) -> dict:
    """Recursively serialise one sklearn decision tree into nested dicts.

    Leaf node : {"p": [class probabilities]}
    Split node: {"f": feature_index, "t": threshold, "l": {...}, "r": {...}}
    """
    t = tree.tree_

    def node(i: int) -> dict:
        if t.children_left[i] == t.children_right[i]:  # leaf
            counts = t.value[i][0]
            total = float(counts.sum()) or 1.0
            return {"p": [round(float(c) / total, 5) for c in counts]}
        return {
            "f": int(t.feature[i]),
            "t": round(float(t.threshold[i]), 5),
            "l": node(int(t.children_left[i])),
            "r": node(int(t.children_right[i])),
        }

    return node(0)


def export_forest(forest: RandomForestClassifier, classes: list[str]) -> dict:
    return {
        "classes": classes,
        "trees": [export_tree(est) for est in forest.estimators_],
    }


# --------------------------------------------------------------------------- #
# Training
# --------------------------------------------------------------------------- #


def train_forest(x, y, classes: list[str]):
    forest = RandomForestClassifier(
        n_estimators=35,
        max_depth=7,
        min_samples_leaf=15,
        random_state=RANDOM_SEED,
        class_weight="balanced",
    )
    # Keep class order deterministic and aligned with our label list.
    forest.fit(x, y)
    return forest


def evaluate(name, forest, x_test, y_test, report_lines: list[str]):
    preds = forest.predict(x_test)
    acc = accuracy_score(y_test, preds)
    report_lines.append(f"\n==== {name} ====")
    report_lines.append(f"Test accuracy: {acc:.4f}")
    report_lines.append("Classification report:")
    report_lines.append(classification_report(y_test, preds, zero_division=0))
    report_lines.append("Confusion matrix:")
    report_lines.append(str(confusion_matrix(y_test, preds)))
    importances = dict(
        sorted(
            zip(FEATURE_NAMES, forest.feature_importances_),
            key=lambda kv: kv[1],
            reverse=True,
        )
    )
    report_lines.append("Feature importances:")
    report_lines.append(
        ", ".join(f"{k}={v:.3f}" for k, v in importances.items())
    )
    return acc


def main() -> None:
    rng = np.random.default_rng(RANDOM_SEED)
    x, y_irr, y_soil, y_pri = generate_dataset(rng)

    report_lines = [
        "PakFASAL DSS - Machine Learning training report",
        "================================================",
        f"Algorithm: Random Forest (scikit-learn)",
        f"Samples: {N_SAMPLES} | Features: {FEATURE_NAMES}",
        f"Label noise: {LABEL_NOISE:.0%}",
    ]

    models_json = {}
    accuracies = {}

    for name, y, classes, key in [
        ("Irrigation action", y_irr, IRRIGATION_CLASSES, "irrigation"),
        ("Soil action", y_soil, SOIL_CLASSES, "soil"),
        ("Priority", y_pri, PRIORITY_CLASSES, "priority"),
    ]:
        x_tr, x_te, y_tr, y_te = train_test_split(
            x, y, test_size=0.2, random_state=RANDOM_SEED, stratify=y
        )
        forest = train_forest(x_tr, y_tr, classes)
        acc = evaluate(name, forest, x_te, y_te, report_lines)
        accuracies[key] = round(float(acc), 4)
        # Export using the forest's own class ordering so probabilities align.
        models_json[key] = export_forest(forest, [str(c) for c in forest.classes_])

    payload = {
        "modelType": "random_forest",
        "generatedBy": "ml/train_dss_model.py",
        "featureNames": FEATURE_NAMES,
        "crops": CROPS,
        "models": models_json,
        "metrics": {"testAccuracy": accuracies},
    }

    os.makedirs(OUT_DIR, exist_ok=True)
    with open(OUT_MODEL, "w", encoding="utf-8") as f:
        json.dump(payload, f, separators=(",", ":"))

    with open(OUT_REPORT, "w", encoding="utf-8") as f:
        f.write("\n".join(report_lines) + "\n")

    size_kb = os.path.getsize(OUT_MODEL) / 1024.0
    print("\n".join(report_lines))
    print("\n------------------------------------------------")
    print(f"Model written to: {os.path.normpath(OUT_MODEL)} ({size_kb:.1f} KB)")
    print(f"Report written to: {os.path.normpath(OUT_REPORT)}")


if __name__ == "__main__":
    main()
