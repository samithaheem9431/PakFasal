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

/// User-owned planting saved in Firestore (`crop_plantings`).
class CropPlanting {
  const CropPlanting({
    required this.id,
    required this.ownerId,
    required this.crop,
    required this.area,
    required this.sowingDate,
    required this.completedStages,
    required this.remindersEnabled,
    this.fieldLabel = '',
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String ownerId;
  final CropType crop;
  final CropArea area;
  final DateTime sowingDate;
  final List<CropStage> completedStages;
  final bool remindersEnabled;
  final String fieldLabel;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool isStageCompleted(CropStage stage) => completedStages.contains(stage);

  CropPlanting copyWith({
    String? id,
    String? ownerId,
    CropType? crop,
    CropArea? area,
    DateTime? sowingDate,
    List<CropStage>? completedStages,
    bool? remindersEnabled,
    String? fieldLabel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CropPlanting(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      crop: crop ?? this.crop,
      area: area ?? this.area,
      sowingDate: sowingDate ?? this.sowingDate,
      completedStages: completedStages ?? this.completedStages,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      fieldLabel: fieldLabel ?? this.fieldLabel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static String stageToKey(CropStage stage) => stage.name;

  static CropStage? stageFromKey(String key) {
    for (final stage in CropStage.values) {
      if (stage.name == key) return stage;
    }
    return null;
  }

  static CropType? cropFromKey(String key) {
    for (final crop in CropType.values) {
      if (crop.name == key) return crop;
    }
    return null;
  }

  static CropArea? areaFromKey(String key) {
    for (final area in CropArea.values) {
      if (area.name == key) return area;
    }
    return null;
  }
}

/// A catalog activity projected onto concrete dates from a sowing date.
class DatedStageWindow {
  const DatedStageWindow({
    required this.stage,
    required this.start,
    required this.end,
    required this.descriptionKey,
  });

  final CropStage stage;
  final DateTime start;
  final DateTime end;
  final String descriptionKey;

  bool contains(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day);
    return !d.isBefore(s) && !d.isAfter(e);
  }
}

/// Maps catalog month windows onto dates relative to [sowingDate].
class PlantingSchedule {
  const PlantingSchedule._();

  static int monthOffset(int fromMonth, int toMonth) {
    if (toMonth >= fromMonth) return toMonth - fromMonth;
    return (12 - fromMonth) + toMonth;
  }

  static DateTime addMonths(DateTime date, int months) {
    final target = DateTime(date.year, date.month + months, 1);
    final lastDay = DateTime(target.year, target.month + 1, 0).day;
    final day = date.day.clamp(1, lastDay);
    return DateTime(target.year, target.month, day);
  }

  /// Builds dated stage windows from [plan] anchored at [sowingDate].
  static List<DatedStageWindow> windowsFor(
    CropCalendarPlan plan,
    DateTime sowingDate,
  ) {
    final sowingActivity = plan.activities.cast<CropActivity?>().firstWhere(
          (a) => a?.stage == CropStage.sowing,
          orElse: () => null,
        );
    final baseMonth = sowingActivity?.months.startMonth ?? sowingDate.month;

    return plan.activities.map((activity) {
      final startOffset = monthOffset(baseMonth, activity.months.startMonth);
      final endOffset = monthOffset(baseMonth, activity.months.endMonth);
      final start = activity.stage == CropStage.sowing
          ? DateTime(sowingDate.year, sowingDate.month, sowingDate.day)
          : addMonths(sowingDate, startOffset);
      final endMonthStart = addMonths(sowingDate, endOffset);
      final end = DateTime(
        endMonthStart.year,
        endMonthStart.month + 1,
        0,
      );
      return DatedStageWindow(
        stage: activity.stage,
        start: start,
        end: end.isBefore(start) ? start : end,
        descriptionKey: activity.descriptionKey,
      );
    }).toList();
  }

  /// Index of the window covering [now], or `-1` if outside the season.
  static int currentStageIndex(List<DatedStageWindow> windows, DateTime now) {
    for (var i = 0; i < windows.length; i++) {
      if (windows[i].contains(now)) return i;
    }
    return -1;
  }

  /// Fractional progress from first stage start to last stage end.
  static double seasonProgress(List<DatedStageWindow> windows, DateTime now) {
    if (windows.isEmpty) return 0;
    final start = windows.first.start;
    final end = windows.last.end;
    final total = end.difference(start).inDays;
    if (total <= 0) return now.isAfter(end) ? 1 : 0;
    final elapsed = now.difference(start).inDays;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  /// Checklist completion ratio (independent of calendar date).
  static double checklistProgress(
    CropCalendarPlan plan,
    CropPlanting planting,
  ) {
    if (plan.activities.isEmpty) return 0;
    final done = plan.activities
        .where((a) => planting.isStageCompleted(a.stage))
        .length;
    return done / plan.activities.length;
  }
}
