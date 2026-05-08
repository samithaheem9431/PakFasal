import 'package:flutter/material.dart';

import '../domain/entities/crop_calendar_models.dart';

/// Static, build-time catalog of the supported crops and their season
/// plans. Stage offsets are based on standard Pakistani agronomy guidance
/// (PARC / NARC / Punjab Agriculture Department recommendations) and are
/// intentionally generous — the user's actual sowing date drives every
/// computed start/end via [CropStage.startDate].
class CropCalendarCatalog {
  CropCalendarCatalog._();

  static const List<CropCalendar> _crops = [
    _wheat,
    _rice,
    _cotton,
    _sugarcane,
    _maize,
  ];

  static List<CropCalendar> get all => _crops;

  static List<String> get cropIds => _crops.map((c) => c.id).toList();

  static CropCalendar byId(String id) {
    return _crops.firstWhere(
      (c) => c.id == id,
      orElse: () => _crops.first,
    );
  }

  // ── Wheat (Rabi, ~150 days) ────────────────────────────────────────────
  static const _wheat = CropCalendar(
    id: 'wheat',
    nameKey: 'cropWheat',
    icon: Icons.grass_rounded,
    totalDays: 155,
    recommendedSowingMonths: [10, 11],
    regionalNoteKeys: {
      CropRegion.lahore: 'wheatLahoreNote',
      CropRegion.multan: 'wheatMultanNote',
    },
    stages: [
      CropStage(
        id: 'wheat_land_prep',
        kind: CropStageKind.prep,
        nameKey: 'stageLandPrep',
        descKey: 'wheatLandPrepDesc',
        dayOffset: -10,
        durationDays: 10,
      ),
      CropStage(
        id: 'wheat_sowing',
        kind: CropStageKind.sowing,
        nameKey: 'stageSowing',
        descKey: 'wheatSowingDesc',
        dayOffset: 0,
        durationDays: 14,
      ),
      CropStage(
        id: 'wheat_irrigation_1',
        kind: CropStageKind.irrigation,
        nameKey: 'stageIrrigation1',
        descKey: 'wheatIrrigation1Desc',
        dayOffset: 22,
        durationDays: 6,
      ),
      CropStage(
        id: 'wheat_fertilizer_1',
        kind: CropStageKind.fertilizer,
        nameKey: 'stageFertilizer1',
        descKey: 'wheatFertilizer1Desc',
        dayOffset: 32,
        durationDays: 4,
      ),
      CropStage(
        id: 'wheat_irrigation_2',
        kind: CropStageKind.irrigation,
        nameKey: 'stageIrrigation2',
        descKey: 'wheatIrrigation2Desc',
        dayOffset: 60,
        durationDays: 6,
      ),
      CropStage(
        id: 'wheat_irrigation_3',
        kind: CropStageKind.irrigation,
        nameKey: 'stageIrrigation3',
        descKey: 'wheatIrrigation3Desc',
        dayOffset: 100,
        durationDays: 6,
      ),
      CropStage(
        id: 'wheat_harvest',
        kind: CropStageKind.harvest,
        nameKey: 'stageHarvest',
        descKey: 'wheatHarvestDesc',
        dayOffset: 145,
        durationDays: 14,
      ),
    ],
  );

  // ── Rice (Kharif, ~155 days end-to-end) ────────────────────────────────
  static const _rice = CropCalendar(
    id: 'rice',
    nameKey: 'cropRice',
    icon: Icons.rice_bowl_rounded,
    totalDays: 155,
    recommendedSowingMonths: [5, 6, 7],
    regionalNoteKeys: {
      CropRegion.lahore: 'riceLahoreNote',
      CropRegion.multan: 'riceMultanNote',
    },
    stages: [
      CropStage(
        id: 'rice_nursery',
        kind: CropStageKind.nursery,
        nameKey: 'stageNursery',
        descKey: 'riceNurseryDesc',
        dayOffset: -25,
        durationDays: 25,
      ),
      CropStage(
        id: 'rice_land_prep',
        kind: CropStageKind.prep,
        nameKey: 'stageLandPrep',
        descKey: 'riceLandPrepDesc',
        dayOffset: -5,
        durationDays: 5,
      ),
      CropStage(
        id: 'rice_transplanting',
        kind: CropStageKind.transplanting,
        nameKey: 'stageTransplanting',
        descKey: 'riceTransplantingDesc',
        dayOffset: 0,
        durationDays: 7,
      ),
      CropStage(
        id: 'rice_fertilizer_1',
        kind: CropStageKind.fertilizer,
        nameKey: 'stageFertilizer1',
        descKey: 'riceFertilizer1Desc',
        dayOffset: 7,
        durationDays: 3,
      ),
      CropStage(
        id: 'rice_irrigation_1',
        kind: CropStageKind.irrigation,
        nameKey: 'stageIrrigation1',
        descKey: 'riceIrrigation1Desc',
        dayOffset: 7,
        durationDays: 70,
      ),
      CropStage(
        id: 'rice_fertilizer_2',
        kind: CropStageKind.fertilizer,
        nameKey: 'stageFertilizer2',
        descKey: 'riceFertilizer2Desc',
        dayOffset: 45,
        durationDays: 3,
      ),
      CropStage(
        id: 'rice_pest_control',
        kind: CropStageKind.pestControl,
        nameKey: 'stagePestControl',
        descKey: 'ricePestControlDesc',
        dayOffset: 60,
        durationDays: 21,
      ),
      CropStage(
        id: 'rice_harvest',
        kind: CropStageKind.harvest,
        nameKey: 'stageHarvest',
        descKey: 'riceHarvestDesc',
        dayOffset: 130,
        durationDays: 14,
      ),
    ],
  );

  // ── Cotton (Kharif, ~180 days) ─────────────────────────────────────────
  static const _cotton = CropCalendar(
    id: 'cotton',
    nameKey: 'cropCotton',
    icon: Icons.filter_vintage_rounded,
    totalDays: 180,
    recommendedSowingMonths: [4, 5],
    regionalNoteKeys: {
      CropRegion.lahore: 'cottonLahoreNote',
      CropRegion.multan: 'cottonMultanNote',
    },
    stages: [
      CropStage(
        id: 'cotton_land_prep',
        kind: CropStageKind.prep,
        nameKey: 'stageLandPrep',
        descKey: 'cottonLandPrepDesc',
        dayOffset: -10,
        durationDays: 10,
      ),
      CropStage(
        id: 'cotton_sowing',
        kind: CropStageKind.sowing,
        nameKey: 'stageSowing',
        descKey: 'cottonSowingDesc',
        dayOffset: 0,
        durationDays: 14,
      ),
      CropStage(
        id: 'cotton_irrigation_1',
        kind: CropStageKind.irrigation,
        nameKey: 'stageIrrigation1',
        descKey: 'cottonIrrigation1Desc',
        dayOffset: 25,
        durationDays: 6,
      ),
      CropStage(
        id: 'cotton_weeding',
        kind: CropStageKind.weeding,
        nameKey: 'stageWeeding',
        descKey: 'cottonWeedingDesc',
        dayOffset: 30,
        durationDays: 10,
      ),
      CropStage(
        id: 'cotton_fertilizer_1',
        kind: CropStageKind.fertilizer,
        nameKey: 'stageFertilizer1',
        descKey: 'cottonFertilizer1Desc',
        dayOffset: 35,
        durationDays: 4,
      ),
      CropStage(
        id: 'cotton_pest_control',
        kind: CropStageKind.pestControl,
        nameKey: 'stagePestControl',
        descKey: 'cottonPestControlDesc',
        dayOffset: 55,
        durationDays: 70,
      ),
      CropStage(
        id: 'cotton_fertilizer_2',
        kind: CropStageKind.fertilizer,
        nameKey: 'stageFertilizer2',
        descKey: 'cottonFertilizer2Desc',
        dayOffset: 70,
        durationDays: 4,
      ),
      CropStage(
        id: 'cotton_picking_1',
        kind: CropStageKind.picking,
        nameKey: 'stagePicking1',
        descKey: 'cottonPicking1Desc',
        dayOffset: 130,
        durationDays: 14,
      ),
      CropStage(
        id: 'cotton_picking_2',
        kind: CropStageKind.picking,
        nameKey: 'stagePicking2',
        descKey: 'cottonPicking2Desc',
        dayOffset: 160,
        durationDays: 21,
      ),
    ],
  );

  // ── Sugarcane (~330 days) ──────────────────────────────────────────────
  static const _sugarcane = CropCalendar(
    id: 'sugarcane',
    nameKey: 'cropSugarcane',
    icon: Icons.eco_rounded,
    totalDays: 335,
    recommendedSowingMonths: [2, 3, 9, 10],
    regionalNoteKeys: {
      CropRegion.lahore: 'sugarcaneLahoreNote',
      CropRegion.multan: 'sugarcaneMultanNote',
    },
    stages: [
      CropStage(
        id: 'sugarcane_land_prep',
        kind: CropStageKind.prep,
        nameKey: 'stageLandPrep',
        descKey: 'sugarcaneLandPrepDesc',
        dayOffset: -15,
        durationDays: 15,
      ),
      CropStage(
        id: 'sugarcane_sowing',
        kind: CropStageKind.sowing,
        nameKey: 'stageSowing',
        descKey: 'sugarcaneSowingDesc',
        dayOffset: 0,
        durationDays: 21,
      ),
      CropStage(
        id: 'sugarcane_irrigation_1',
        kind: CropStageKind.irrigation,
        nameKey: 'stageIrrigation1',
        descKey: 'sugarcaneIrrigation1Desc',
        dayOffset: 18,
        durationDays: 5,
      ),
      CropStage(
        id: 'sugarcane_fertilizer_1',
        kind: CropStageKind.fertilizer,
        nameKey: 'stageFertilizer1',
        descKey: 'sugarcaneFertilizer1Desc',
        dayOffset: 30,
        durationDays: 4,
      ),
      CropStage(
        id: 'sugarcane_weeding',
        kind: CropStageKind.weeding,
        nameKey: 'stageWeeding',
        descKey: 'sugarcaneWeedingDesc',
        dayOffset: 60,
        durationDays: 21,
      ),
      CropStage(
        id: 'sugarcane_fertilizer_2',
        kind: CropStageKind.fertilizer,
        nameKey: 'stageFertilizer2',
        descKey: 'sugarcaneFertilizer2Desc',
        dayOffset: 90,
        durationDays: 4,
      ),
      CropStage(
        id: 'sugarcane_earthing_up',
        kind: CropStageKind.earthingUp,
        nameKey: 'stageEarthingUp',
        descKey: 'sugarcaneEarthingUpDesc',
        dayOffset: 120,
        durationDays: 10,
      ),
      CropStage(
        id: 'sugarcane_tying',
        kind: CropStageKind.tying,
        nameKey: 'stageTying',
        descKey: 'sugarcaneTyingDesc',
        dayOffset: 180,
        durationDays: 10,
      ),
      CropStage(
        id: 'sugarcane_harvest',
        kind: CropStageKind.harvest,
        nameKey: 'stageHarvest',
        descKey: 'sugarcaneHarvestDesc',
        dayOffset: 320,
        durationDays: 30,
      ),
    ],
  );

  // ── Maize (~110 days) ──────────────────────────────────────────────────
  static const _maize = CropCalendar(
    id: 'maize',
    nameKey: 'cropMaize',
    icon: Icons.local_florist_rounded,
    totalDays: 115,
    recommendedSowingMonths: [2, 3, 7, 8],
    regionalNoteKeys: {
      CropRegion.lahore: 'maizeLahoreNote',
      CropRegion.multan: 'maizeMultanNote',
    },
    stages: [
      CropStage(
        id: 'maize_land_prep',
        kind: CropStageKind.prep,
        nameKey: 'stageLandPrep',
        descKey: 'maizeLandPrepDesc',
        dayOffset: -7,
        durationDays: 7,
      ),
      CropStage(
        id: 'maize_sowing',
        kind: CropStageKind.sowing,
        nameKey: 'stageSowing',
        descKey: 'maizeSowingDesc',
        dayOffset: 0,
        durationDays: 7,
      ),
      CropStage(
        id: 'maize_irrigation_1',
        kind: CropStageKind.irrigation,
        nameKey: 'stageIrrigation1',
        descKey: 'maizeIrrigation1Desc',
        dayOffset: 14,
        durationDays: 4,
      ),
      CropStage(
        id: 'maize_weeding',
        kind: CropStageKind.weeding,
        nameKey: 'stageWeeding',
        descKey: 'maizeWeedingDesc',
        dayOffset: 22,
        durationDays: 7,
      ),
      CropStage(
        id: 'maize_fertilizer_1',
        kind: CropStageKind.fertilizer,
        nameKey: 'stageFertilizer1',
        descKey: 'maizeFertilizer1Desc',
        dayOffset: 30,
        durationDays: 3,
      ),
      CropStage(
        id: 'maize_irrigation_2',
        kind: CropStageKind.irrigation,
        nameKey: 'stageIrrigation2',
        descKey: 'maizeIrrigation2Desc',
        dayOffset: 45,
        durationDays: 4,
      ),
      CropStage(
        id: 'maize_pest_control',
        kind: CropStageKind.pestControl,
        nameKey: 'stagePestControl',
        descKey: 'maizePestControlDesc',
        dayOffset: 50,
        durationDays: 14,
      ),
      CropStage(
        id: 'maize_fertilizer_2',
        kind: CropStageKind.fertilizer,
        nameKey: 'stageFertilizer2',
        descKey: 'maizeFertilizer2Desc',
        dayOffset: 60,
        durationDays: 3,
      ),
      CropStage(
        id: 'maize_harvest',
        kind: CropStageKind.harvest,
        nameKey: 'stageHarvest',
        descKey: 'maizeHarvestDesc',
        dayOffset: 105,
        durationDays: 14,
      ),
    ],
  );
}
