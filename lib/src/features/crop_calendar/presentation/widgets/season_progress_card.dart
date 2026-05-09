import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/crop_calendar_models.dart';
import '../utils/crop_calendar_visuals.dart';

/// At-a-glance summary card showing where the user's crop is in the
/// season — current stage, percent through season, and a progress bar.
///
/// Renders an "off-season" state when [currentStageIndex] is `-1`.
class SeasonProgressCard extends StatelessWidget {
  const SeasonProgressCard({
    super.key,
    required this.plan,
    required this.currentStageIndex,
    required this.seasonProgress,
  });

  final CropCalendarPlan plan;
  final int currentStageIndex;
  final double seasonProgress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final percent = (seasonProgress * 100).round();
    final inSeason = currentStageIndex >= 0;

    final stage = inSeason ? plan.activities[currentStageIndex] : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.softSurfaceGreen,
            scheme.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  CropCalendarVisuals.iconForCrop(plan.crop),
                  color: AppColors.primaryGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.t(CropCalendarVisuals.cropLabelKey(plan.crop)),
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: scheme.onSurface,
                              ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${l10n.t('cropCalAreaLabel')}: '
                      '${l10n.t(CropCalendarVisuals.areaLabelKey(plan.area))}',
                      style:
                          Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: AppColors.primaryGreen,
                                fontWeight: FontWeight.w700,
                              ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: inSeason
                      ? AppColors.primaryGreen
                      : AppColors.mutedText,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  inSeason
                      ? l10n.t(
                          'cropCalProgressLabel',
                          params: {'percent': percent},
                        )
                      : l10n.t('cropCalOffSeason'),
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: inSeason ? seasonProgress : 0,
              minHeight: 8,
              backgroundColor: AppColors.paleGreen,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
            ),
          ),
          const SizedBox(height: 14),
          if (stage != null)
            _StageBadge(
              label: l10n.t('cropCalCurrentStage'),
              value: l10n.t(CropCalendarVisuals.stageLabelKey(stage.stage)),
              icon: CropCalendarVisuals.iconForStage(stage.stage),
              color: CropCalendarVisuals.colorForStage(stage.stage),
            )
          else
            Text(
              l10n.t('cropCalNoStageActive'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
        ],
      ),
    );
  }
}

class _StageBadge extends StatelessWidget {
  const _StageBadge({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurface,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
