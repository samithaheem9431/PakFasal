// Presentation-layer mappers for the crop calendar feature.
//
// Keeps icon / color choices and localization key lookups out of the
// domain layer. Widgets call these helpers so the same crop or stage
// renders consistently everywhere.

import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/crop_calendar_models.dart';

class CropCalendarVisuals {
  const CropCalendarVisuals._();

  static IconData iconForCrop(CropType crop) {
    return switch (crop) {
      CropType.wheat => Icons.grass_rounded,
      CropType.rice => Icons.rice_bowl_rounded,
      CropType.cotton => Icons.filter_vintage_rounded,
    };
  }

  static String cropLabelKey(CropType crop) {
    return switch (crop) {
      CropType.wheat => 'cropWheat',
      CropType.rice => 'cropRice',
      CropType.cotton => 'cropCotton',
    };
  }

  static String areaLabelKey(CropArea area) {
    return switch (area) {
      CropArea.multan => 'cropCalAreaMultan',
      CropArea.lahore => 'cropCalAreaLahore',
    };
  }

  static IconData iconForStage(CropStage stage) {
    return switch (stage) {
      CropStage.sowing => Icons.spa_rounded,
      CropStage.irrigation => Icons.water_drop_rounded,
      CropStage.fertilizer => Icons.eco_rounded,
      CropStage.pestControl => Icons.bug_report_rounded,
      CropStage.harvest => Icons.agriculture_rounded,
    };
  }

  static Color colorForStage(CropStage stage) {
    return switch (stage) {
      CropStage.sowing => AppColors.primaryGreen,
      CropStage.irrigation => AppColors.weatherBlue,
      CropStage.fertilizer => AppColors.lightGreen,
      CropStage.pestControl => AppColors.error,
      CropStage.harvest => AppColors.warning,
    };
  }

  static String stageLabelKey(CropStage stage) {
    return switch (stage) {
      CropStage.sowing => 'cropCalStageSowing',
      CropStage.irrigation => 'cropCalStageIrrigation',
      CropStage.fertilizer => 'cropCalStageFertilizer',
      CropStage.pestControl => 'cropCalStagePestControl',
      CropStage.harvest => 'cropCalStageHarvest',
    };
  }

  /// Renders a [MonthRange] as a localized "Oct – Nov" / "اکتوبر – نومبر"
  /// string. Single-month ranges return just one label.
  static String formatMonthRange(AppLocalizations l10n, MonthRange range) {
    final start = l10n.t('cropCalMonth${range.startMonth}');
    if (range.startMonth == range.endMonth) return start;
    final end = l10n.t('cropCalMonth${range.endMonth}');
    return '$start – $end';
  }
}
