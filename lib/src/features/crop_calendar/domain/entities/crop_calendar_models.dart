import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Coarse category used to derive the icon/color for a stage and to group
/// stages in the UI. Specific stage names are localized via [CropStage.nameKey].
enum CropStageKind {
  prep,
  nursery,
  sowing,
  transplanting,
  irrigation,
  fertilizer,
  weeding,
  earthingUp,
  tying,
  pestControl,
  harvest,
  picking,
}

/// Where in the season a stage currently sits relative to today.
enum CropStageStatus { past, current, upcoming }

/// Punjab agro-climatic zone. Currently used to display a contextual note
/// next to the sowing-date picker. Stage offsets are still relative to the
/// user's actual sowing date so the timeline stays personalised — the area
/// only changes the recommended sowing-window guidance.
///
/// We deliberately scope the app to Punjab only for now (Lahore = Central
/// Punjab, Multan = South Punjab) since these two zones cover the vast
/// majority of farmers we are targeting and have noticeably different
/// optimal sowing windows.
enum CropRegion { lahore, multan }

/// One actionable stage in a crop's season (e.g. "First Irrigation").
///
/// All human-readable strings live in [AppLocalizations] under the keys
/// referenced here, so the catalog can be defined once and rendered in
/// English or Urdu without duplication.
@immutable
class CropStage {
  const CropStage({
    required this.id,
    required this.kind,
    required this.nameKey,
    required this.descKey,
    required this.dayOffset,
    required this.durationDays,
    this.dosageKey,
  });

  /// Stable id used for reminder scheduling, e.g. `"wheat_irrigation_1"`.
  final String id;
  final CropStageKind kind;
  final String nameKey;
  final String descKey;

  /// Days from the user's sowing date when this stage starts. Can be
  /// negative for pre-sowing prep (land prep, nursery).
  final int dayOffset;

  /// Window length in days. The stage is considered "current" while
  /// `today ∈ [start, start + durationDays)`.
  final int durationDays;

  /// Optional localization key for dosage / quantity hints.
  final String? dosageKey;

  IconData get icon => switch (kind) {
        CropStageKind.prep => Icons.terrain_rounded,
        CropStageKind.nursery => Icons.yard_rounded,
        CropStageKind.sowing => Icons.spa_rounded,
        CropStageKind.transplanting => Icons.move_down_rounded,
        CropStageKind.irrigation => Icons.water_drop_rounded,
        CropStageKind.fertilizer => Icons.eco_rounded,
        CropStageKind.weeding => Icons.grass_rounded,
        CropStageKind.earthingUp => Icons.landscape_rounded,
        CropStageKind.tying => Icons.link_rounded,
        CropStageKind.pestControl => Icons.bug_report_rounded,
        CropStageKind.harvest => Icons.agriculture_rounded,
        CropStageKind.picking => Icons.shopping_basket_rounded,
      };

  Color get color => switch (kind) {
        CropStageKind.prep => AppColors.soilBrown,
        CropStageKind.nursery => AppColors.lightGreen,
        CropStageKind.sowing => AppColors.primaryGreen,
        CropStageKind.transplanting => AppColors.primaryGreen,
        CropStageKind.irrigation => AppColors.weatherBlue,
        CropStageKind.fertilizer => AppColors.success,
        CropStageKind.weeding => AppColors.lightGreen,
        CropStageKind.earthingUp => AppColors.soilBrown,
        CropStageKind.tying => AppColors.darkGreen,
        CropStageKind.pestControl => AppColors.error,
        CropStageKind.harvest => AppColors.warning,
        CropStageKind.picking => AppColors.cropYellow,
      };

  DateTime startDate(DateTime sowing) =>
      _dateOnly(sowing).add(Duration(days: dayOffset));

  DateTime endDate(DateTime sowing) =>
      _dateOnly(sowing).add(Duration(days: dayOffset + durationDays));

  /// Resolve the stage status for [today] given the user's [sowing] date.
  CropStageStatus statusOn(DateTime today, DateTime sowing) {
    final t = _dateOnly(today);
    final s = startDate(sowing);
    final e = endDate(sowing);
    if (t.isBefore(s)) return CropStageStatus.upcoming;
    if (!t.isBefore(e)) return CropStageStatus.past;
    return CropStageStatus.current;
  }
}

/// A whole crop's seasonal plan — the catalog binds one [CropCalendar]
/// per crop id (`wheat`, `rice`, ...).
@immutable
class CropCalendar {
  const CropCalendar({
    required this.id,
    required this.nameKey,
    required this.icon,
    required this.totalDays,
    required this.recommendedSowingMonths,
    required this.regionalNoteKeys,
    required this.stages,
  });

  /// Stable lower-case id (`"wheat"`).
  final String id;

  /// Localization key for the crop name (`"cropWheat"`).
  final String nameKey;

  final IconData icon;

  /// Approximate season length used for the progress bar.
  final int totalDays;

  /// 1-indexed months when sowing is recommended (e.g. `[10, 11]` for wheat).
  final List<int> recommendedSowingMonths;

  /// Per-area localization keys for the regional note shown below the
  /// sowing-date picker. The note text differs between Lahore (cooler,
  /// Central Punjab) and Multan (hotter, South Punjab).
  final Map<CropRegion, String> regionalNoteKeys;

  final List<CropStage> stages;

  /// Resolves the regional-note l10n key for [region], with a safe fallback
  /// to whichever entry is defined first in the catalog.
  String regionalNoteKeyFor(CropRegion region) =>
      regionalNoteKeys[region] ?? regionalNoteKeys.values.first;

  DateTime harvestDate(DateTime sowing) =>
      _dateOnly(sowing).add(Duration(days: totalDays));

  /// `0.0..1.0` season progress for [today] given [sowing].
  double progressOn(DateTime today, DateTime sowing) {
    final days = _dateOnly(today).difference(_dateOnly(sowing)).inDays;
    if (days <= 0) return 0;
    if (days >= totalDays) return 1;
    return days / totalDays;
  }

  /// First currently-active stage, or `null` if today is before sowing or
  /// after harvest.
  CropStage? currentStageOn(DateTime today, DateTime sowing) {
    for (final stage in stages) {
      if (stage.statusOn(today, sowing) == CropStageStatus.current) {
        return stage;
      }
    }
    return null;
  }
}

/// User's saved sowing plan for a specific crop. Persisted in Hive.
@immutable
class UserCropPlan {
  const UserCropPlan({
    required this.cropId,
    required this.sowingDate,
    this.remindersEnabled = true,
  });

  final String cropId;
  final DateTime sowingDate;
  final bool remindersEnabled;

  UserCropPlan copyWith({
    DateTime? sowingDate,
    bool? remindersEnabled,
  }) {
    return UserCropPlan(
      cropId: cropId,
      sowingDate: sowingDate ?? this.sowingDate,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
        'cropId': cropId,
        'sowingDate': sowingDate.millisecondsSinceEpoch,
        'remindersEnabled': remindersEnabled,
      };

  factory UserCropPlan.fromJson(Map<String, dynamic> json) {
    return UserCropPlan(
      cropId: (json['cropId'] as String?) ?? 'wheat',
      sowingDate: DateTime.fromMillisecondsSinceEpoch(
        ((json['sowingDate'] as num?) ?? 0).toInt(),
      ),
      remindersEnabled: (json['remindersEnabled'] as bool?) ?? true,
    );
  }
}

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
