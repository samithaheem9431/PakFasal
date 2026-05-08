import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/crop_calendar_models.dart';

/// Season progress card — only rendered when the user has a sowing plan.
class SeasonProgressCard extends StatelessWidget {
  const SeasonProgressCard({
    super.key,
    required this.calendar,
    required this.plan,
    required this.today,
  });

  final CropCalendar calendar;
  final UserCropPlan plan;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    final progress = calendar.progressOn(today, plan.sowingDate);
    final daysSinceSowing = _dateOnly(today)
        .difference(_dateOnly(plan.sowingDate))
        .inDays;
    final daysToHarvest = calendar.totalDays - daysSinceSowing;
    final currentStage = calendar.currentStageOn(today, plan.sowingDate);

    final isBeforeSowing = daysSinceSowing < 0;
    final isAfterHarvest = daysSinceSowing > calendar.totalDays;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.timeline_rounded,
                color: AppColors.primaryGreen,
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.t('cropCalendarSeasonProgress'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: scheme.onSurface,
                      ),
                ),
              ),
              _ProgressBadge(progress: progress),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor:
                  scheme.outlineVariant.withValues(alpha: 0.4),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primaryGreen,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ProgressMetric(
                  label: l10n.t('cropCalendarDaysSinceSowing'),
                  value: isBeforeSowing
                      ? '0'
                      : daysSinceSowing.toString(),
                  unit: l10n.t('cropCalendarDaysShort'),
                  color: AppColors.primaryGreen,
                ),
              ),
              Container(
                width: 1,
                height: 36,
                color: scheme.outlineVariant.withValues(alpha: 0.6),
              ),
              Expanded(
                child: _ProgressMetric(
                  label: l10n.t('cropCalendarDaysToHarvest'),
                  value: daysToHarvest <= 0
                      ? '0'
                      : daysToHarvest.toString(),
                  unit: l10n.t('cropCalendarDaysShort'),
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (isBeforeSowing)
            _StageBanner(
              icon: Icons.hourglass_top_rounded,
              text: l10n.t('cropCalendarBeforeSowing'),
              color: AppColors.weatherBlue,
            )
          else if (isAfterHarvest)
            _StageBanner(
              icon: Icons.check_circle_rounded,
              text: l10n.t('cropCalendarAfterHarvest'),
              color: AppColors.success,
            )
          else if (currentStage != null)
            _StageBanner(
              icon: currentStage.icon,
              text:
                  '${l10n.t('cropCalendarStatusCurrent')} · ${l10n.t(currentStage.nameKey)}',
              color: currentStage.color,
            ),
        ],
      ),
    );
  }
}

class _ProgressBadge extends StatelessWidget {
  const _ProgressBadge({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).round();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '$percent%',
        style: const TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _ProgressMetric extends StatelessWidget {
  const _ProgressMetric({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  final String label;
  final String value;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              unit,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _StageBanner extends StatelessWidget {
  const _StageBanner({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
