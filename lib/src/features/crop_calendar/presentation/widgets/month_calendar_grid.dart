import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../domain/entities/crop_calendar_models.dart';
import '../utils/crop_calendar_visuals.dart';

class MonthCalendarGrid extends StatelessWidget {
  const MonthCalendarGrid({
    super.key,
    required this.visibleMonth,
    required this.windows,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
  });

  final DateTime visibleMonth;
  final List<DatedStageWindow> windows;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final year = visibleMonth.year;
    final month = visibleMonth.month;
    final first = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    // Monday-based: weekday 1..7 → offset 0..6
    final leading = (first.weekday + 6) % 7;
    final today = DateTime.now();
    final monthTitle =
        '${l10n.t('cropCalMonth$month')} $year';

    final cells = <Widget>[];
    for (var i = 0; i < leading; i++) {
      cells.add(const SizedBox.shrink());
    }
    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final stages = windows.where((w) => w.contains(date)).toList();
      final isToday = date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;

      cells.add(
        Container(
          decoration: BoxDecoration(
            color: isToday
                ? scheme.primaryContainer.withValues(alpha: 0.45)
                : null,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.35),
            ),
          ),
          padding: const EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$day',
                style: TextStyle(
                  fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                  fontSize: 12,
                  color: isToday ? scheme.primary : scheme.onSurface,
                ),
              ),
              const Spacer(),
              Wrap(
                spacing: 2,
                runSpacing: 2,
                children: stages.take(3).map((w) {
                  return Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: CropCalendarVisuals.colorForStage(w.stage),
                      shape: BoxShape.circle,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      );
    }

    final weekdayKeys = const [
      'cropCalWeekMon',
      'cropCalWeekTue',
      'cropCalWeekWed',
      'cropCalWeekThu',
      'cropCalWeekFri',
      'cropCalWeekSat',
      'cropCalWeekSun',
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onPrevious,
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Expanded(
                child: Text(
                  monthTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              TextButton(
                onPressed: onToday,
                child: Text(l10n.t('cropCalToday')),
              ),
              IconButton(
                onPressed: onNext,
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: weekdayKeys.map((key) {
              return Expanded(
                child: Text(
                  l10n.t(key),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 6),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            childAspectRatio: 0.78,
            children: cells,
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.t('cropCalMonthLegend'),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          const SizedBox(height: 8),
          ..._uniqueStages(windows).map((stage) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: CropCalendarVisuals.colorForStage(stage),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.t(CropCalendarVisuals.stageLabelKey(stage)),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  List<CropStage> _uniqueStages(List<DatedStageWindow> windows) {
    final seen = <CropStage>{};
    final out = <CropStage>[];
    for (final w in windows) {
      if (seen.add(w.stage)) out.add(w.stage);
    }
    return out;
  }
}
