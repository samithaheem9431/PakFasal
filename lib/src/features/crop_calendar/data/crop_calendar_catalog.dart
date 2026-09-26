// In-memory catalog of crop calendar plans for Pakistani Punjab.
//
// Month windows follow verified city-level guidance:
//   * Wheat — sow Nov 1–20 (prefer 1–15 south/central); official CRS
//     harvest window 1 Apr–5 May; DAS irrigation + NPK rates in l10n.
//   * Rice / cotton — May–Jun / Apr–May sowing; season through Sep–Nov.
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
    // Official irrigated Punjab profile: sow 1–20 Nov; CRS cut 1 Apr–5 May.
    CropType.wheat: {
      CropArea.multan: CropCalendarPlan(
        crop: CropType.wheat,
        area: CropArea.multan,
        areaNoteKey: 'cropCalNoteWheatMultan',
        activities: [
          CropActivity(
            stage: CropStage.sowing,
            months: MonthRange(11, 11),
            descriptionKey: 'cropCalWheatSowingDesc',
          ),
          CropActivity(
            stage: CropStage.irrigation,
            months: MonthRange(11, 3),
            descriptionKey: 'cropCalWheatIrrigationDesc',
          ),
          CropActivity(
            stage: CropStage.fertilizer,
            months: MonthRange(11, 3),
            descriptionKey: 'cropCalWheatFertilizerDesc',
          ),
          CropActivity(
            stage: CropStage.pestControl,
            months: MonthRange(1, 3),
            descriptionKey: 'cropCalWheatPestControlDesc',
          ),
          CropActivity(
            stage: CropStage.harvest,
            months: MonthRange(4, 5),
            descriptionKey: 'cropCalWheatHarvestDesc',
          ),
        ],
      ),
      CropArea.faisalabad: CropCalendarPlan(
        crop: CropType.wheat,
        area: CropArea.faisalabad,
        areaNoteKey: 'cropCalNoteWheatFaisalabad',
        activities: [
          CropActivity(
            stage: CropStage.sowing,
            months: MonthRange(11, 11),
            descriptionKey: 'cropCalWheatSowingDesc',
          ),
          CropActivity(
            stage: CropStage.irrigation,
            months: MonthRange(11, 3),
            descriptionKey: 'cropCalWheatIrrigationDesc',
          ),
          CropActivity(
            stage: CropStage.fertilizer,
            months: MonthRange(11, 3),
            descriptionKey: 'cropCalWheatFertilizerDesc',
          ),
          CropActivity(
            stage: CropStage.pestControl,
            months: MonthRange(1, 3),
            descriptionKey: 'cropCalWheatPestControlDesc',
          ),
          CropActivity(
            stage: CropStage.harvest,
            months: MonthRange(4, 4),
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
            months: MonthRange(11, 11),
            descriptionKey: 'cropCalWheatSowingDesc',
          ),
          CropActivity(
            stage: CropStage.irrigation,
            months: MonthRange(11, 3),
            descriptionKey: 'cropCalWheatIrrigationRiceWheatDesc',
          ),
          CropActivity(
            stage: CropStage.fertilizer,
            months: MonthRange(11, 3),
            descriptionKey: 'cropCalWheatFertilizerDesc',
          ),
          CropActivity(
            stage: CropStage.pestControl,
            months: MonthRange(1, 3),
            descriptionKey: 'cropCalWheatPestControlDesc',
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
    // Coarse (KSK-706-type): nursery 20 May–7 Jun, transplant ~15 Jun–15 Jul.
    // Basmati (Lahore): nursery 1–25 Jun; CRS harvest window 15 Sep–25 Nov.
    CropType.rice: {
      CropArea.multan: CropCalendarPlan(
        crop: CropType.rice,
        area: CropArea.multan,
        areaNoteKey: 'cropCalNoteRiceMultan',
        activities: [
          CropActivity(
            stage: CropStage.sowing,
            months: MonthRange(5, 7),
            descriptionKey: 'cropCalRiceSowingCoarseDesc',
          ),
          CropActivity(
            stage: CropStage.irrigation,
            months: MonthRange(6, 9),
            descriptionKey: 'cropCalRiceIrrigationDesc',
          ),
          CropActivity(
            stage: CropStage.fertilizer,
            months: MonthRange(6, 8),
            descriptionKey: 'cropCalRiceFertilizerCoarseDesc',
          ),
          CropActivity(
            stage: CropStage.pestControl,
            months: MonthRange(7, 10),
            descriptionKey: 'cropCalRicePestControlDesc',
          ),
          CropActivity(
            stage: CropStage.harvest,
            months: MonthRange(9, 11),
            descriptionKey: 'cropCalRiceHarvestDesc',
          ),
        ],
      ),
      CropArea.faisalabad: CropCalendarPlan(
        crop: CropType.rice,
        area: CropArea.faisalabad,
        areaNoteKey: 'cropCalNoteRiceFaisalabad',
        activities: [
          CropActivity(
            stage: CropStage.sowing,
            months: MonthRange(5, 7),
            descriptionKey: 'cropCalRiceSowingCoarseDesc',
          ),
          CropActivity(
            stage: CropStage.irrigation,
            months: MonthRange(6, 9),
            descriptionKey: 'cropCalRiceIrrigationDesc',
          ),
          CropActivity(
            stage: CropStage.fertilizer,
            months: MonthRange(6, 8),
            descriptionKey: 'cropCalRiceFertilizerCoarseDesc',
          ),
          CropActivity(
            stage: CropStage.pestControl,
            months: MonthRange(7, 10),
            descriptionKey: 'cropCalRicePestControlDesc',
          ),
          CropActivity(
            stage: CropStage.harvest,
            months: MonthRange(9, 11),
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
            descriptionKey: 'cropCalRiceSowingBasmatiDesc',
          ),
          CropActivity(
            stage: CropStage.irrigation,
            months: MonthRange(6, 10),
            descriptionKey: 'cropCalRiceIrrigationDesc',
          ),
          CropActivity(
            stage: CropStage.fertilizer,
            months: MonthRange(6, 8),
            descriptionKey: 'cropCalRiceFertilizerBasmatiDesc',
          ),
          CropActivity(
            stage: CropStage.pestControl,
            months: MonthRange(7, 10),
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
    // Official variety window 1 Apr–31 May (prefer by ~15 May).
    // CRS picking / YES window 1 Sep–30 Nov. Lahore is non-core cotton.
    CropType.cotton: {
      CropArea.multan: CropCalendarPlan(
        crop: CropType.cotton,
        area: CropArea.multan,
        areaNoteKey: 'cropCalNoteCottonMultan',
        activities: [
          CropActivity(
            stage: CropStage.sowing,
            months: MonthRange(4, 5),
            descriptionKey: 'cropCalCottonSowingDesc',
          ),
          CropActivity(
            stage: CropStage.irrigation,
            months: MonthRange(4, 9),
            descriptionKey: 'cropCalCottonIrrigationDesc',
          ),
          CropActivity(
            stage: CropStage.fertilizer,
            months: MonthRange(4, 7),
            descriptionKey: 'cropCalCottonFertilizerSouthDesc',
          ),
          CropActivity(
            stage: CropStage.pestControl,
            months: MonthRange(5, 9),
            descriptionKey: 'cropCalCottonPestControlSouthDesc',
          ),
          CropActivity(
            stage: CropStage.harvest,
            months: MonthRange(9, 11),
            descriptionKey: 'cropCalCottonHarvestDesc',
          ),
        ],
      ),
      CropArea.faisalabad: CropCalendarPlan(
        crop: CropType.cotton,
        area: CropArea.faisalabad,
        areaNoteKey: 'cropCalNoteCottonFaisalabad',
        activities: [
          CropActivity(
            stage: CropStage.sowing,
            months: MonthRange(4, 5),
            descriptionKey: 'cropCalCottonSowingDesc',
          ),
          CropActivity(
            stage: CropStage.irrigation,
            months: MonthRange(4, 9),
            descriptionKey: 'cropCalCottonIrrigationDesc',
          ),
          CropActivity(
            stage: CropStage.fertilizer,
            months: MonthRange(4, 7),
            descriptionKey: 'cropCalCottonFertilizerCentralDesc',
          ),
          CropActivity(
            stage: CropStage.pestControl,
            months: MonthRange(5, 9),
            descriptionKey: 'cropCalCottonPestControlDesc',
          ),
          CropActivity(
            stage: CropStage.harvest,
            months: MonthRange(9, 11),
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
            months: MonthRange(4, 9),
            descriptionKey: 'cropCalCottonIrrigationDesc',
          ),
          CropActivity(
            stage: CropStage.fertilizer,
            months: MonthRange(4, 7),
            descriptionKey: 'cropCalCottonFertilizerLahoreDesc',
          ),
          CropActivity(
            stage: CropStage.pestControl,
            months: MonthRange(5, 9),
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
      const [CropArea.multan, CropArea.faisalabad, CropArea.lahore];

  /// Returns the plan for [crop] at [area], or `null` if no entry exists.
  static CropCalendarPlan? planFor(CropType crop, CropArea area) {
    return _plans[crop]?[area];
  }
}
