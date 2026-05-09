import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/crop_calendar_models.dart';

/// Compact card highlighting the best sowing window for the active plan
/// plus a one-line area-specific tip from the catalog.
class SowingPlanCard extends StatelessWidget {
  const SowingPlanCard({super.key, required this.plan});

  final CropCalendarPlan plan;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final sowing = plan.sowingWindow;
    final start = sowing == null
        ? '—'
        : l10n.t('cropCalMonth${sowing.startMonth}');
    final end = sowing == null
        ? '—'
        : l10n.t('cropCalMonth${sowing.endMonth}');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.paleGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.event_available_rounded,
              color: AppColors.primaryGreen,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.t('cropCalSowingWindow'),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkGreen,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.t(
                    'cropCalSowingFromTo',
                    params: {'start': start, 'end': end},
                  ),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.t(plan.areaNoteKey),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
