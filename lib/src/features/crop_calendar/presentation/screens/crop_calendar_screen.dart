import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/pakfasal_scaffold.dart';
import '../../domain/entities/crop_calendar_models.dart';
import '../providers/crop_calendar_provider.dart';
import '../utils/crop_calendar_visuals.dart';
import '../widgets/area_chip_selector.dart';
import '../widgets/crop_chip_selector.dart';
import '../widgets/season_progress_card.dart';
import '../widgets/sowing_plan_card.dart';
import '../widgets/timeline_stage_tile.dart';

/// Crop calendar feature screen.
///
/// Renders three sections:
///   1. Crop / area selectors (state held by [CropCalendarProvider]).
///   2. Sowing window + season progress summary cards.
///   3. Vertical timeline of stage tiles for the active plan.
///
/// All user-facing strings come from [AppLocalizations.t] so the screen
/// flips cleanly between English and Urdu.
class CropCalendarScreen extends StatelessWidget {
  const CropCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final provider = context.watch<CropCalendarProvider>();
    final plan = provider.activePlan;

    return PakFasalScaffold(
      title: l10n.t('cropCalendar'),
      child: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _SelectorsSection(
                selectedCrop: provider.selectedCrop,
                supportedCrops: provider.supportedCrops,
                onCropSelected: provider.selectCrop,
                selectedArea: provider.selectedArea,
                supportedAreas: provider.supportedAreas,
                onAreaSelected: provider.selectArea,
              ),
            ),
            if (plan == null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      l10n.t('errorState'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                ),
              )
            else ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SeasonProgressCard(
                        plan: plan,
                        currentStageIndex: provider.currentStageIndex,
                        seasonProgress: provider.seasonProgress,
                      ),
                      const SizedBox(height: 12),
                      SowingPlanCard(plan: plan),
                      const SizedBox(height: 18),
                      Text(
                        l10n.t('cropCalActivities'),
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: scheme.onSurface,
                                ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                sliver: SliverList.builder(
                  itemCount: plan.activities.length,
                  itemBuilder: (context, index) {
                    final activity = plan.activities[index];
                    final status = _statusFor(
                      index: index,
                      currentIndex: provider.currentStageIndex,
                    );
                    return TimelineStageTile(
                      activity: activity,
                      areaLabel: l10n.t(
                        CropCalendarVisuals.areaLabelKey(plan.area),
                      ),
                      status: status,
                      isLast: index == plan.activities.length - 1,
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  StageStatus _statusFor({required int index, required int currentIndex}) {
    if (currentIndex < 0) return StageStatus.upcoming;
    if (index < currentIndex) return StageStatus.completed;
    if (index == currentIndex) return StageStatus.active;
    return StageStatus.upcoming;
  }
}

class _SelectorsSection extends StatelessWidget {
  const _SelectorsSection({
    required this.selectedCrop,
    required this.supportedCrops,
    required this.onCropSelected,
    required this.selectedArea,
    required this.supportedAreas,
    required this.onAreaSelected,
  });

  final CropType selectedCrop;
  final List<CropType> supportedCrops;
  final ValueChanged<CropType> onCropSelected;
  final CropArea selectedArea;
  final List<CropArea> supportedAreas;
  final ValueChanged<CropArea> onAreaSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(
          bottom: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.t('selectCrop'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                ),
          ),
          const SizedBox(height: 12),
          CropChipSelector(
            crops: supportedCrops,
            selectedCrop: selectedCrop,
            onCropSelected: onCropSelected,
          ),
          const SizedBox(height: 14),
          Text(
            l10n.t('cropCalAreasTitle'),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.primary,
                ),
          ),
          const SizedBox(height: 8),
          AreaChipSelector(
            areas: supportedAreas,
            selectedArea: selectedArea,
            onAreaSelected: onAreaSelected,
          ),
        ],
      ),
    );
  }
}
