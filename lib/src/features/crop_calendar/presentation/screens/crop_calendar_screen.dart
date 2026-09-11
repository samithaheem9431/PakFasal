import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/pakfasal_scaffold.dart';
import '../../domain/entities/crop_calendar_models.dart';
import '../providers/crop_calendar_provider.dart';
import '../utils/crop_calendar_visuals.dart';
import '../widgets/add_planting_sheet.dart';
import '../widgets/area_chip_selector.dart';
import '../widgets/crop_calendar_tab_bar.dart';
import '../widgets/crop_chip_selector.dart';
import '../widgets/month_calendar_grid.dart';
import '../widgets/my_planting_card.dart';
import '../widgets/season_progress_card.dart';
import '../widgets/sowing_plan_card.dart';
import '../widgets/stage_checklist_tile.dart';
import '../widgets/timeline_stage_tile.dart';

/// Crop calendar feature screen with Guide, My Crops, and Month tabs.
class CropCalendarScreen extends StatefulWidget {
  const CropCalendarScreen({super.key});

  @override
  State<CropCalendarScreen> createState() => _CropCalendarScreenState();
}

class _CropCalendarScreenState extends State<CropCalendarScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<CropCalendarProvider>();
      final l10n = AppLocalizations.of(context);
      provider.setLocalizer(l10n.t);
      provider.startWatchingPlantings();
      provider.ensureRemindersInitialized();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<CropCalendarProvider>();
    provider.setLocalizer(l10n.t);

    return PakFasalScaffold(
      title: l10n.t('cropCalendar'),
      floatingActionButton: provider.tab == CropCalendarTab.myCrops &&
              provider.canManagePlantings
          ? FloatingActionButton.extended(
              onPressed: provider.isMutating
                  ? null
                  : () => _openAddSheet(context, provider),
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.t('cropCalAddPlanting')),
            )
          : null,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            CropCalendarTabBar(
              selected: provider.tab,
              onSelected: provider.selectTab,
            ),
            Expanded(child: _buildTabBody(context, provider)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBody(BuildContext context, CropCalendarProvider provider) {
    switch (provider.tab) {
      case CropCalendarTab.guide:
        return _GuideTab(provider: provider);
      case CropCalendarTab.myCrops:
        return _MyCropsTab(provider: provider);
      case CropCalendarTab.month:
        return SingleChildScrollView(
          child: MonthCalendarGrid(
            visibleMonth: provider.visibleMonth,
            windows: provider.monthWindows,
            onPrevious: provider.goToPreviousMonth,
            onNext: provider.goToNextMonth,
            onToday: provider.goToCurrentMonth,
          ),
        );
    }
  }

  Future<void> _openAddSheet(
    BuildContext context,
    CropCalendarProvider provider,
  ) {
    return showAddPlantingSheet(
      context: context,
      crops: provider.supportedCrops,
      areas: provider.supportedAreas,
      initialCrop: provider.selectedCrop,
      initialArea: provider.selectedArea,
      onSubmit: ({
        required crop,
        required area,
        required sowingDate,
        required fieldLabel,
        required remindersEnabled,
      }) {
        return provider.addPlanting(
          crop: crop,
          area: area,
          sowingDate: sowingDate,
          fieldLabel: fieldLabel,
          remindersEnabled: remindersEnabled,
        );
      },
    );
  }
}

class _GuideTab extends StatelessWidget {
  const _GuideTab({required this.provider});

  final CropCalendarProvider provider;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final plan = provider.activePlan;

    return CustomScrollView(
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
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
    );
  }

  StageStatus _statusFor({required int index, required int currentIndex}) {
    if (currentIndex < 0) return StageStatus.upcoming;
    if (index < currentIndex) return StageStatus.completed;
    if (index == currentIndex) return StageStatus.active;
    return StageStatus.upcoming;
  }
}

class _MyCropsTab extends StatelessWidget {
  const _MyCropsTab({required this.provider});

  final CropCalendarProvider provider;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    if (provider.plantingsLoading && provider.plantings.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.plantingsError != null && provider.plantings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l10n.t('cropCalLoadFailed'),
            textAlign: TextAlign.center,
            style: TextStyle(color: scheme.error),
          ),
        ),
      );
    }

    if (provider.plantings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.agriculture_rounded, size: 48, color: scheme.primary),
              const SizedBox(height: 12),
              Text(
                l10n.t('cropCalEmptyPlantingsTitle'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.t('cropCalEmptyPlantingsBody'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    final active = provider.activePlanting;
    final windows =
        active == null ? const <DatedStageWindow>[] : provider.windowsForPlanting(active);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        Text(
          l10n.t('cropCalMyPlantings'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 10),
        ...provider.plantings.map((planting) {
          return MyPlantingCard(
            planting: planting,
            isSelected: planting.id == provider.activePlantingId,
            seasonProgress: provider.personalProgress(planting),
            checklistProgress: provider.checklistProgress(planting),
            onTap: () => provider.selectActivePlanting(planting.id),
            onDelete: () => _confirmDelete(context, provider, planting),
            onToggleReminders: (enabled) {
              provider.setRemindersEnabled(
                planting: planting,
                enabled: enabled,
              );
            },
          );
        }),
        if (active != null && windows.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            l10n.t('cropCalChecklist'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          ...windows.map((window) {
            return StageChecklistTile(
              window: window,
              completed: active.isStageCompleted(window.stage),
              enabled: !provider.isMutating,
              onToggle: () {
                provider.toggleStageCompleted(
                  planting: active,
                  stage: window.stage,
                );
              },
            );
          }),
        ],
      ],
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    CropCalendarProvider provider,
    CropPlanting planting,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(l10n.t('cropCalDeletePlanting')),
          content: Text(l10n.t('cropCalDeleteConfirm')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.t('cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.t('cropCalDeletePlanting')),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      await provider.deletePlanting(planting);
    }
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
