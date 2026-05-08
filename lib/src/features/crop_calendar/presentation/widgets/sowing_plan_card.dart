import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/crop_calendar_models.dart';

/// "Personalize your calendar" card.
///
/// * If [plan] is `null`, shows an empty-state CTA prompting the user to pick
///   a sowing date.
/// * If [plan] is set, shows the sowing date, estimated harvest, region,
///   reminder toggle, and a reset action.
class SowingPlanCard extends StatelessWidget {
  const SowingPlanCard({
    super.key,
    required this.calendar,
    required this.plan,
    required this.region,
    required this.onPickDate,
    required this.onChangeDate,
    required this.onRegionChanged,
    required this.onRemindersChanged,
    required this.onReset,
  });

  final CropCalendar calendar;
  final UserCropPlan? plan;
  final CropRegion region;
  final VoidCallback onPickDate;
  final VoidCallback onChangeDate;
  final ValueChanged<CropRegion> onRegionChanged;
  final ValueChanged<bool> onRemindersChanged;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat.yMMMd('en_US');

    final hasPlan = plan != null;
    final harvestDate =
        hasPlan ? calendar.harvestDate(plan!.sowingDate) : null;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: hasPlan
              ? [
                  scheme.primary.withValues(alpha: 0.08),
                  scheme.primary.withValues(alpha: 0.02),
                ]
              : [
                  AppColors.softYellow,
                  AppColors.softYellow.withValues(alpha: 0.4),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasPlan
              ? scheme.primary.withValues(alpha: 0.25)
              : AppColors.warning.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: hasPlan
                      ? scheme.primary.withValues(alpha: 0.14)
                      : AppColors.warning.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  hasPlan
                      ? Icons.event_available_rounded
                      : Icons.event_note_rounded,
                  color:
                      hasPlan ? scheme.primary : AppColors.warning,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  hasPlan
                      ? l10n.t('cropCalendarSowingDateLabel')
                      : l10n.t('cropCalendarNoSowingTitle'),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: scheme.onSurface,
                      ),
                ),
              ),
              if (hasPlan)
                IconButton(
                  tooltip: l10n.t('cropCalendarReset'),
                  onPressed: onReset,
                  icon: const Icon(Icons.delete_outline_rounded),
                  color: scheme.onSurfaceVariant,
                ),
            ],
          ),
          const SizedBox(height: 8),

          if (hasPlan) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _MetaTile(
                    label: l10n.t('cropCalendarSowingDateLabel'),
                    value: dateFormat.format(plan!.sowingDate),
                    icon: Icons.spa_rounded,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetaTile(
                    label: l10n.t('cropCalendarHarvestEta'),
                    value: dateFormat.format(harvestDate!),
                    icon: Icons.agriculture_rounded,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onChangeDate,
              icon: const Icon(Icons.edit_calendar_rounded, size: 18),
              label: Text(l10n.t('cropCalendarChangeSowingDate')),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(
                  color: scheme.primary.withValues(alpha: 0.5),
                ),
                foregroundColor: scheme.primary,
              ),
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 14),
              child: Text(
                l10n.t('cropCalendarNoSowingHint'),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: scheme.onSurfaceVariant, height: 1.4),
              ),
            ),
            FilledButton.icon(
              onPressed: onPickDate,
              icon: const Icon(Icons.event_rounded, size: 20),
              label: Text(l10n.t('cropCalendarSetSowingDate')),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                backgroundColor: AppColors.primaryGreen,
              ),
            ),
          ],

          const SizedBox(height: 16),
          Divider(
            color: scheme.outlineVariant.withValues(alpha: 0.5),
            height: 1,
          ),
          const SizedBox(height: 14),

          // Region selector
          _RegionSelector(
            region: region,
            onChanged: onRegionChanged,
          ),

          const SizedBox(height: 12),
          _RegionalNote(noteKey: calendar.regionalNoteKeyFor(region)),

          if (hasPlan) ...[
            const SizedBox(height: 14),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: plan!.remindersEnabled,
              onChanged: onRemindersChanged,
              activeColor: AppColors.primaryGreen,
              title: Text(
                l10n.t('cropCalendarReminderToggle'),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  l10n.t('cropCalendarReminderHint'),
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetaTile extends StatelessWidget {
  const _MetaTile({
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _RegionSelector extends StatelessWidget {
  const _RegionSelector({
    required this.region,
    required this.onChanged,
  });

  final CropRegion region;
  final ValueChanged<CropRegion> onChanged;

  String _labelKey(CropRegion r) => switch (r) {
        CropRegion.lahore => 'cropCalendarRegionLahore',
        CropRegion.multan => 'cropCalendarRegionMultan',
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 18,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              l10n.t('cropCalendarRegion'),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: CropRegion.values.map((r) {
            final selected = r == region;
            return ChoiceChip(
              label: Text(l10n.t(_labelKey(r))),
              selected: selected,
              onSelected: (_) => onChanged(r),
              showCheckmark: false,
              labelStyle: TextStyle(
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.white : AppColors.darkText,
                fontSize: 12,
              ),
              selectedColor: AppColors.primaryGreen,
              backgroundColor: AppColors.paleGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: selected
                      ? AppColors.primaryGreen
                      : AppColors.divider,
                ),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _RegionalNote extends StatelessWidget {
  const _RegionalNote({required this.noteKey});

  final String noteKey;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.softBlue.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.weatherBlue.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.tips_and_updates_outlined,
            size: 18,
            color: AppColors.weatherBlue,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.t('cropCalendarRegionalNote'),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.weatherBlue,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.t(noteKey),
                  style: TextStyle(
                    fontSize: 12.5,
                    color: scheme.onSurface,
                    height: 1.35,
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
