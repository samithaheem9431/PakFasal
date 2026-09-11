import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../domain/entities/crop_calendar_models.dart';
import '../utils/crop_calendar_visuals.dart';

class MyPlantingCard extends StatelessWidget {
  const MyPlantingCard({
    super.key,
    required this.planting,
    required this.isSelected,
    required this.seasonProgress,
    required this.checklistProgress,
    required this.onTap,
    required this.onDelete,
    required this.onToggleReminders,
  });

  final CropPlanting planting;
  final bool isSelected;
  final double seasonProgress;
  final double checklistProgress;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final ValueChanged<bool> onToggleReminders;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final cropLabel = l10n.t(CropCalendarVisuals.cropLabelKey(planting.crop));
    final areaLabel = l10n.t(CropCalendarVisuals.areaLabelKey(planting.area));
    final title = planting.fieldLabel.trim().isEmpty
        ? cropLabel
        : planting.fieldLabel.trim();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? scheme.primary.withValues(alpha: 0.7)
                    : scheme.outlineVariant.withValues(alpha: 0.5),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      CropCalendarVisuals.iconForCrop(planting.crop),
                      color: scheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          Text(
                            '$cropLabel · $areaLabel',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.t('cropCalDeletePlanting'),
                      onPressed: onDelete,
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: scheme.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  l10n
                      .t('cropCalSownOn')
                      .replaceAll(
                        '{date}',
                        '${planting.sowingDate.day.toString().padLeft(2, '0')}/'
                            '${planting.sowingDate.month.toString().padLeft(2, '0')}/'
                            '${planting.sowingDate.year}',
                      ),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.t('cropCalSeasonProgress'),
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: seasonProgress.clamp(0.0, 1.0),
                  minHeight: 7,
                  borderRadius: BorderRadius.circular(8),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n
                      .t('cropCalChecklistProgress')
                      .replaceAll(
                        '{percent}',
                        (checklistProgress * 100).round().toString(),
                      ),
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: checklistProgress.clamp(0.0, 1.0),
                  minHeight: 7,
                  borderRadius: BorderRadius.circular(8),
                  color: scheme.tertiary,
                ),
                const SizedBox(height: 8),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(
                    l10n.t('cropCalReminders'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  value: planting.remindersEnabled,
                  onChanged: onToggleReminders,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
