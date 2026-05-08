import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/crop_calendar_models.dart';

/// One row in the season timeline. Visual treatment depends on whether the
/// stage is in the past, current, or upcoming relative to today.
///
/// When the user has not yet set a sowing date, [plan] is `null` and the
/// tile renders in a neutral preview style without dates.
class TimelineStageTile extends StatelessWidget {
  const TimelineStageTile({
    super.key,
    required this.stage,
    required this.plan,
    required this.today,
    required this.isFirst,
    required this.isLast,
    this.previewMode = false,
  });

  final CropStage stage;
  final UserCropPlan? plan;
  final DateTime today;
  final bool isFirst;
  final bool isLast;
  final bool previewMode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat.MMMd('en_US');

    final hasPlan = plan != null && !previewMode;
    final status = hasPlan
        ? stage.statusOn(today, plan!.sowingDate)
        : CropStageStatus.upcoming;
    final isPast = status == CropStageStatus.past;
    final isCurrent = status == CropStageStatus.current;

    final dotColor = !hasPlan
        ? stage.color.withValues(alpha: 0.5)
        : isPast
            ? AppColors.success
            : isCurrent
                ? stage.color
                : stage.color.withValues(alpha: 0.55);

    final cardColor = isCurrent
        ? stage.color.withValues(alpha: 0.08)
        : scheme.surface;
    final cardBorderColor = isCurrent
        ? stage.color.withValues(alpha: 0.6)
        : scheme.outlineVariant.withValues(alpha: 0.5);
    final cardBorderWidth = isCurrent ? 2.0 : 1.0;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 2,
                  height: isFirst ? 0 : 12,
                  color: scheme.outlineVariant,
                ),
                _StageDot(
                  color: dotColor,
                  icon: stage.icon,
                  isPast: hasPlan && isPast,
                  isCurrent: isCurrent,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: hasPlan && isPast
                          ? AppColors.success.withValues(alpha: 0.5)
                          : scheme.outlineVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18, top: 6),
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: cardBorderColor,
                    width: cardBorderWidth,
                  ),
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: stage.color.withValues(alpha: 0.15),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            l10n.t(stage.nameKey),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: scheme.onSurface,
                                  decoration: isPast
                                      ? TextDecoration.lineThrough
                                      : null,
                                  decorationColor:
                                      AppColors.success.withValues(
                                          alpha: 0.7),
                                  decorationThickness: 1.5,
                                ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (hasPlan)
                          _StatusBadge(status: status, color: stage.color)
                        else
                          _StageWindowBadge(
                            text:
                                '${stage.dayOffset >= 0 ? '+' : ''}${stage.dayOffset}d',
                          ),
                      ],
                    ),
                    if (hasPlan) ...[
                      const SizedBox(height: 6),
                      _DateRangeRow(
                        start: stage.startDate(plan!.sowingDate),
                        end: stage.endDate(plan!.sowingDate),
                        today: today,
                        formatter: dateFormat,
                        l10n: l10n,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      l10n.t(stage.descKey),
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StageDot extends StatelessWidget {
  const _StageDot({
    required this.color,
    required this.icon,
    required this.isPast,
    required this.isCurrent,
  });

  final Color color;
  final IconData icon;
  final bool isPast;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isCurrent ? 10 : 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withValues(alpha: 0.7),
          width: isCurrent ? 2.5 : 1.5,
        ),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.45),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Icon(
        isPast ? Icons.check_rounded : icon,
        size: isCurrent ? 22 : 18,
        color: color,
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.color});

  final CropStageStatus status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (label, badgeColor) = switch (status) {
      CropStageStatus.past => (
          l10n.t('cropCalendarStatusPast'),
          AppColors.success,
        ),
      CropStageStatus.current => (
          l10n.t('cropCalendarStatusCurrent'),
          color,
        ),
      CropStageStatus.upcoming => (
          l10n.t('cropCalendarStatusUpcoming'),
          AppColors.mutedText,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: badgeColor.withValues(alpha: 0.45)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: badgeColor,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _StageWindowBadge extends StatelessWidget {
  const _StageWindowBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.paleGreen,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryGreen,
        ),
      ),
    );
  }
}

class _DateRangeRow extends StatelessWidget {
  const _DateRangeRow({
    required this.start,
    required this.end,
    required this.today,
    required this.formatter,
    required this.l10n,
  });

  final DateTime start;
  final DateTime end;
  final DateTime today;
  final DateFormat formatter;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final t = DateTime(today.year, today.month, today.day);
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day);

    String? hintText;
    Color hintColor = scheme.onSurfaceVariant;

    if (t.isBefore(s)) {
      final daysAhead = s.difference(t).inDays;
      hintText =
          '${l10n.t('cropCalendarStartsIn')} $daysAhead ${l10n.t('cropCalendarDaysShort')}';
      hintColor = AppColors.weatherBlue;
    } else if (!t.isBefore(e)) {
      final daysAgo = t.difference(e).inDays;
      hintText =
          '${l10n.t('cropCalendarEndedAgo')} · $daysAgo ${l10n.t('cropCalendarDaysShort')}';
      hintColor = AppColors.success;
    } else {
      hintText = l10n.t('cropCalendarTodayBadge');
      hintColor = AppColors.warning;
    }

    return Row(
      children: [
        Icon(
          Icons.calendar_today_rounded,
          size: 13,
          color: scheme.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            '${formatter.format(start)} – ${formatter.format(end)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: hintColor.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            hintText,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: hintColor,
            ),
          ),
        ),
      ],
    );
  }
}
