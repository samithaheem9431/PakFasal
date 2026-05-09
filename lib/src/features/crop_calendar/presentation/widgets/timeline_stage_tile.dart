import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../domain/entities/crop_calendar_models.dart';
import '../utils/crop_calendar_visuals.dart';

/// One node in the season timeline.
///
/// Renders the stage icon + connector line on the leading edge and a
/// localized card describing the stage on the trailing edge. The
/// [status] tweaks the visual weight so the user can scan the season
/// at a glance — completed stages are dimmed, the active stage is
/// highlighted, upcoming stages are neutral.
enum StageStatus { completed, active, upcoming }

class TimelineStageTile extends StatelessWidget {
  const TimelineStageTile({
    super.key,
    required this.activity,
    required this.areaLabel,
    required this.status,
    required this.isLast,
  });

  final CropActivity activity;
  final String areaLabel;
  final StageStatus status;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final stageColor = CropCalendarVisuals.colorForStage(activity.stage);

    final isActive = status == StageStatus.active;
    final isCompleted = status == StageStatus.completed;
    final cardOpacity = isCompleted ? 0.65 : 1.0;
    final borderColor = isActive
        ? stageColor.withValues(alpha: 0.65)
        : scheme.outlineVariant.withValues(alpha: 0.5);

    final statusKey = switch (status) {
      StageStatus.completed => 'cropCalCompleted',
      StageStatus.active => 'cropCalCurrentStage',
      StageStatus.upcoming => 'cropCalUpcoming',
    };
    final statusBackground = switch (status) {
      StageStatus.completed => scheme.surfaceContainerHighest,
      StageStatus.active => stageColor.withValues(alpha: 0.15),
      StageStatus.upcoming => scheme.primaryContainer,
    };
    final statusForeground = switch (status) {
      StageStatus.completed => scheme.onSurfaceVariant,
      StageStatus.active => stageColor,
      StageStatus.upcoming => scheme.onPrimaryContainer,
    };

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: stageColor.withValues(
                      alpha: isCompleted ? 0.1 : 0.18,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: stageColor.withValues(
                        alpha: isActive ? 0.85 : 0.4,
                      ),
                      width: isActive ? 2 : 1,
                    ),
                  ),
                  child: Icon(
                    CropCalendarVisuals.iconForStage(activity.stage),
                    size: 18,
                    color: stageColor,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: scheme.outlineVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Opacity(
                opacity: cardOpacity,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: stageColor.withValues(alpha: 0.18),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.t(CropCalendarVisuals.stageLabelKey(
                                  activity.stage)),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: scheme.onSurface,
                                  ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: scheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              CropCalendarVisuals.formatMonthRange(
                                  l10n, activity.months),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: scheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: statusBackground,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              l10n.t(statusKey),
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: statusForeground,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              '${l10n.t('cropCalAreaLabel')}: $areaLabel',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: scheme.primary,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.t(activity.descriptionKey),
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
          ),
        ],
      ),
    );
  }
}
