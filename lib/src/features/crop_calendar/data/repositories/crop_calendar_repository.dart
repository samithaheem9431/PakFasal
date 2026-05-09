// Repository layer for the crop calendar feature.
//
// Today the calendar is fully offline (static catalog), so this repository
// is a thin facade. Keeping it separate from [CropCalendarCatalog] means a
// future swap to a server-driven catalog (Firestore, REST, etc.) is a
// drop-in change without touching the presentation layer.

import '../../domain/entities/crop_calendar_models.dart';
import '../crop_calendar_catalog.dart';

class CropCalendarRepository {
  const CropCalendarRepository();

  /// All crops this repository can plan for.
  List<CropType> get supportedCrops => CropCalendarCatalog.supportedCrops;

  /// All areas this repository can plan for.
  List<CropArea> get supportedAreas => CropCalendarCatalog.supportedAreas;

  /// Loads the plan for [crop] at [area], falling back to the default
  /// area for [crop] if the requested combination has no entry.
  CropCalendarPlan? loadPlan({
    required CropType crop,
    required CropArea area,
  }) {
    final exact = CropCalendarCatalog.planFor(crop, area);
    if (exact != null) return exact;
    for (final fallbackArea in supportedAreas) {
      final plan = CropCalendarCatalog.planFor(crop, fallbackArea);
      if (plan != null) return plan;
    }
    return null;
  }
}
