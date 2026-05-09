// In-memory catalog of crop calendar plans for Pakistani Punjab.
//
// Month windows reflect typical extension-service guidance:
//   * Multan (south Punjab) — warmer, drier; sowing/harvest shifts earlier.
//   * Lahore (central Punjab) — milder; standard windows.
//
// Description keys point into [AppLocalizations] so the data layer never
// owns user-facing text. Adding a new crop or area is a pure data change:
// extend [CropType]/[CropArea] in domain, then add the entry below and the
// matching localization keys.

import '../domain/entities/crop_calendar_models.dart';

/// Static catalog of crop plans keyed by (crop, area).
class CropCalendarCatalog {
  const CropCalendarCatalog._();

  static const Map<CropType, Map<CropArea, CropCalendarPlan>> _plans = {
    // ── Wheat (Rabi) ────────────────────────────────────────────────────
    CropType.wheat: {
      CropArea.multan: CropCalendarPlan(
        crop: CropType.wheat,
        area: CropArea.multan,
        areaNoteKey: 'cropCalNoteWheatMultan',
        activities: [
          CropActivity(
            stage: CropStage.sowing,
            months: MonthRange(10, 11),
            descriptionKey: 'cropCalWheatSowingDesc',
          ),
          CropActivity(
            stage: CropStage.irrigation,
            months: MonthRange(11, 1),
            descriptionKey: 'cropCalWheatIrrigationDesc',
          ),
          CropActivity(
            stage: CropStage.fertilizer,
            months: MonthRange(1, 2),
            descriptionKey: 'cropCalWheatFertilizerDesc',
          ),
          CropActivity(
            stage: CropStage.harvest,
            months: MonthRange(3, 4),
            descriptionKey: 'cropCalWheatHarvestDesc',
          ),
        ],
      ),
      CropArea.lahore: CropCalendarPlan(
        crop: CropType.wheat,
        area: CropArea.lahore,
        areaNoteKey: 'cropCalNoteWheatLahore',
        activities: [
          CropActivity(
            stage: CropStage.sowing,
            months: MonthRange(10, 11),
            descriptionKey: 'cropCalWheatSowingDesc',
          ),
          CropActivity(
            stage: CropStage.irrigation,
            months: MonthRange(12, 1),
            descriptionKey: 'cropCalWheatIrrigationDesc',
          ),
          CropActivity(
            stage: CropStage.fertilizer,
            months: MonthRange(2, 2),
            descriptionKey: 'cropCalWheatFertilizerDesc',
          ),
          CropActivity(
            stage: CropStage.harvest,
            months: MonthRange(4, 5),
            descriptionKey: 'cropCalWheatHarvestDesc',
          ),
        ],
      ),
    },

    // ── Rice (Kharif) ───────────────────────────────────────────────────
    CropType.rice: {
      CropArea.multan: CropCalendarPlan(
        crop: CropType.rice,
        area: CropArea.multan,
        areaNoteKey: 'cropCalNoteRiceMultan',
        activities: [
          CropActivity(
            stage: CropStage.sowing,
            months: MonthRange(5, 6),
            descriptionKey: 'cropCalRiceSowingDesc',
          ),
          CropActivity(
            stage: CropStage.irrigation,
            months: MonthRange(6, 8),
            descriptionKey: 'cropCalRiceIrrigationDesc',
          ),
          CropActivity(
            stage: CropStage.pestControl,
            months: MonthRange(7, 8),
            descriptionKey: 'cropCalRicePestControlDesc',
          ),
          CropActivity(
            stage: CropStage.harvest,
            months: MonthRange(9, 10),
            descriptionKey: 'cropCalRiceHarvestDesc',
          ),
        ],
      ),
      CropArea.lahore: CropCalendarPlan(
        crop: CropType.rice,
        area: CropArea.lahore,
        areaNoteKey: 'cropCalNoteRiceLahore',
        activities: [
          CropActivity(
            stage: CropStage.sowing,
            months: MonthRange(6, 7),
            descriptionKey: 'cropCalRiceSowingDesc',
          ),
          CropActivity(
            stage: CropStage.irrigation,
            months: MonthRange(7, 9),
            descriptionKey: 'cropCalRiceIrrigationDesc',
          ),
          CropActivity(
            stage: CropStage.pestControl,
            months: MonthRange(8, 9),
            descriptionKey: 'cropCalRicePestControlDesc',
          ),
          CropActivity(
            stage: CropStage.harvest,
            months: MonthRange(10, 11),
            descriptionKey: 'cropCalRiceHarvestDesc',
          ),
        ],
      ),
    },

    // ── Cotton (Kharif) ─────────────────────────────────────────────────
    CropType.cotton: {
      CropArea.multan: CropCalendarPlan(
        crop: CropType.cotton,
        area: CropArea.multan,
        areaNoteKey: 'cropCalNoteCottonMultan',
        activities: [
          CropActivity(
            stage: CropStage.sowing,
            months: MonthRange(3, 4),
            descriptionKey: 'cropCalCottonSowingDesc',
          ),
          CropActivity(
            stage: CropStage.irrigation,
            months: MonthRange(5, 7),
            descriptionKey: 'cropCalCottonIrrigationDesc',
          ),
          CropActivity(
            stage: CropStage.pestControl,
            months: MonthRange(6, 8),
            descriptionKey: 'cropCalCottonPestControlDesc',
          ),
          CropActivity(
            stage: CropStage.harvest,
            months: MonthRange(8, 10),
            descriptionKey: 'cropCalCottonHarvestDesc',
          ),
        ],
      ),
      CropArea.lahore: CropCalendarPlan(
        crop: CropType.cotton,
        area: CropArea.lahore,
        areaNoteKey: 'cropCalNoteCottonLahore',
        activities: [
          CropActivity(
            stage: CropStage.sowing,
            months: MonthRange(4, 5),
            descriptionKey: 'cropCalCottonSowingDesc',
          ),
          CropActivity(
            stage: CropStage.irrigation,
            months: MonthRange(6, 8),
            descriptionKey: 'cropCalCottonIrrigationDesc',
          ),
          CropActivity(
            stage: CropStage.pestControl,
            months: MonthRange(7, 9),
            descriptionKey: 'cropCalCottonPestControlDesc',
          ),
          CropActivity(
            stage: CropStage.harvest,
            months: MonthRange(9, 11),
            descriptionKey: 'cropCalCottonHarvestDesc',
          ),
        ],
      ),
    },
  };

  /// All crops the catalog can serve.
  static List<CropType> get supportedCrops => _plans.keys.toList(growable: false);

  /// All areas the catalog can serve.
  static List<CropArea> get supportedAreas =>
      const [CropArea.multan, CropArea.lahore];

  /// Returns the plan for [crop] at [area], or `null` if no entry exists.
  static CropCalendarPlan? planFor(CropType crop, CropArea area) {
    return _plans[crop]?[area];
  }
}
