import json
from pathlib import Path
for name in ["sih.json","avalonia2.json"]:
    d=json.loads(Path(rf"d:\pakfasal_app\assets\lottie\_candidates\{name}").read_text(encoding="utf-8"))
    print(name, "layers:", [L.get("nm") for L in d.get("layers") or []])
    for a in d.get("assets") or []:
        if "layers" in a:
            print("  precomp", a.get("id"), [L.get("nm") for L in a["layers"][:12]])
