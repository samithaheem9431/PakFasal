// Domain entities for the crop calendar feature.
//
// Plain immutable Dart classes (no codegen) to keep the FYP project
// approachable and free of build-runner overhead. Each model is UI-agnostic;
// presentation concerns (icons / colours) live next to the screen, and any
// human-readable strings are referenced by localization key only.

/// The major crops modelled by the catalog. Extend by adding a new value
/// and providing a corresponding entry in [CropCalendarCatalog].
enum CropType { wheat, rice, cotton }

/// Punjab regions covered by the catalog. Each crop has area-specific
/// month windows reflecting climate differences between south (Multan)
/// and central (Lahore) Punjab.
enum CropArea { multan, lahore }

/// Lifecycle stages of a crop in field order. Used both for ordering and
/// for choosing icons / colours in the timeline.
enum CropStage { sowing, irrigation, fertilizer, pestControl, harvest }

/// Inclusive month range, 1-12. Supports ranges that wrap the calendar
/// year (e.g. wheat is sown in Oct and harvested in Apr; `MonthRange(10, 4)`).
class MonthRange {
  const MonthRange(this.startMonth, this.endMonth)
      : assert(startMonth >= 1 && startMonth <= 12),
        assert(endMonth >= 1 && endMonth <= 12);

  final int startMonth;
  final int endMonth;

  /// Whether [month] (1-12) falls inside this range, accounting for wrap.
  bool contains(int month) {
    if (startMonth <= endMonth) {
      return month >= startMonth && month <= endMonth;
    }
    return month >= startMonth || month <= endMonth;
  }

  /// Length of the range in months (inclusive).
  int get spanMonths {
    if (startMonth <= endMonth) return endMonth - startMonth + 1;
    return (12 - startMonth) + endMonth + 1;
  }
}

/// One scheduled activity in a crop's season (sowing, irrigation, etc.).
///
/// Localization keys are stored instead of literal text so the same
/// activity renders correctly in English and Urdu.
class CropActivity {
  const CropActivity({
    required this.stage,
    required this.months,
    required this.descriptionKey,
  });

  final CropStage stage;
  final MonthRange months;
  final String descriptionKey;
}

/// Concrete plan for a (crop, area) pair: the ordered list of activities
/// plus a free-form area note (e.g. "South Punjab — sow earlier").
class CropCalendarPlan {
  const CropCalendarPlan({
    required this.crop,
    required this.area,
    required this.activities,
    required this.areaNoteKey,
  });

  final CropType crop;
  final CropArea area;
  final List<CropActivity> activities;
  final String areaNoteKey;

  /// The sowing window for this plan, or `null` if no sowing activity is
  /// defined (shouldn't happen for catalog-backed plans).
  MonthRange? get sowingWindow => activities
      .cast<CropActivity?>()
      .firstWhere(
        (a) => a?.stage == CropStage.sowing,
        orElse: () => null,
      )
      ?.months;

  /// The harvest window for this plan, or `null` if missing.
  MonthRange? get harvestWindow => activities
      .cast<CropActivity?>()
      .firstWhere(
        (a) => a?.stage == CropStage.harvest,
        orElse: () => null,
      )
      ?.months;

  /// Index of the activity covering [now]'s month, or `-1` if [now] falls
  /// outside the season entirely (off-season).
  int currentStageIndex(DateTime now) {
    for (var i = 0; i < activities.length; i++) {
      if (activities[i].months.contains(now.month)) return i;
    }
    return -1;
  }

  /// Fractional progress through the season from sowing start to harvest end,
  /// clamped to `[0.0, 1.0]`. Returns `0` when off-season.
  double seasonProgress(DateTime now) {
    final sowing = sowingWindow;
    final harvest = harvestWindow;
    if (sowing == null || harvest == null) return 0;

    final start = sowing.startMonth;
    final end = harvest.endMonth;

    final span = end >= start ? (end - start + 1) : (12 - start + end + 1);
    int position;
    if (end >= start) {
      if (now.month < start) return 0;
      if (now.month > end) return 1;
      position = now.month - start + 1;
    } else {
      if (now.month >= start) {
        position = now.month - start + 1;
      } else if (now.month <= end) {
        position = (12 - start) + now.month + 1;
      } else {
        return 0;
      }
    }
    final monthFraction = (now.day - 1) / 30.0;
    return ((position - 1 + monthFraction) / span).clamp(0.0, 1.0);
  }
}
