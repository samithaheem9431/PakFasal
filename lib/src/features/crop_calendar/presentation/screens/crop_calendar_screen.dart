import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/pakfasal_scaffold.dart';
import '../../domain/entities/crop_calendar_models.dart';
import '../providers/crop_calendar_provider.dart';
import '../widgets/crop_chip_selector.dart';
import '../widgets/season_progress_card.dart';
import '../widgets/sowing_plan_card.dart';
import '../widgets/timeline_stage_tile.dart';

/// Personalised, sowing-date-aware crop calendar.
///
/// Composition:
///   1. [CropChipSelector]  — pick crop (Wheat / Rice / Cotton / Sugarcane / Maize)
///   2. [SowingPlanCard]    — date picker + region selector + reminder toggle
///   3. [SeasonProgressCard]— %-progress, days-since-sowing, days-to-harvest
///   4. Animated timeline of [TimelineStageTile]s with past/current/upcoming
///      visual treatments.
///
/// State is owned by [CropCalendarProvider] (Hive-backed). The screen itself
/// is purely presentational.
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
      context.read<CropCalendarProvider>().ensureLoaded();
    });
  }

  Future<void> _pickSowingDate(
    BuildContext context,
    CropCalendarProvider provider,
  ) async {
    final today = DateTime.now();
    final initial = provider.activePlan?.sowingDate ?? today;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(today.year - 1),
      lastDate: DateTime(today.year + 1, 12, 31),
      helpText:
          AppLocalizations.of(context).t('cropCalendarSetSowingDate'),
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: Theme.of(ctx).colorScheme.copyWith(
                  primary: AppColors.primaryGreen,
                ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (picked != null) {
      await provider.setSowingDate(picked);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).t('cropCalendarPlanSaved'),
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _confirmReset(
    BuildContext context,
    CropCalendarProvider provider,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.t('cropCalendarResetConfirmTitle')),
        content: Text(l10n.t('cropCalendarResetConfirmBody')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.t('cropCalendarCancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text(l10n.t('cropCalendarConfirm')),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await provider.clearPlan();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.t('cropCalendarPlanCleared')),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Consumer<CropCalendarProvider>(
      builder: (context, provider, _) {
        final calendar = provider.selectedCalendar;
        final plan = provider.activePlan;
        final today = DateTime.now();

        return PakFasalScaffold(
          title: l10n.t('cropCalendar'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header: Crop selector ────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  border: Border(
                    bottom: BorderSide(
                      color:
                          scheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.t('selectCrop'),
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: scheme.onSurface,
                          ),
                    ),
                    const SizedBox(height: 14),
                    CropChipSelector(
                      selectedCropId: provider.selectedCropId,
                      onCropSelected: provider.selectCrop,
                    ),
                  ],
                ),
              ),

              // ── Body: scrollable plan + progress + timeline ─────────
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 320),
                  switchInCurve: Curves.easeOutCubic,
                  child: ListView(
                    key: ValueKey(provider.selectedCropId),
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
                    children: [
                      _FadeSlideIn(
                        delayMs: 0,
                        child: SowingPlanCard(
                          calendar: calendar,
                          plan: plan,
                          region: provider.region,
                          onPickDate: () =>
                              _pickSowingDate(context, provider),
                          onChangeDate: () =>
                              _pickSowingDate(context, provider),
                          onRegionChanged: provider.setRegion,
                          onRemindersChanged:
                              provider.setRemindersEnabled,
                          onReset: () =>
                              _confirmReset(context, provider),
                        ),
                      ),
                      if (plan != null) ...[
                        const SizedBox(height: 14),
                        _FadeSlideIn(
                          delayMs: 80,
                          child: SeasonProgressCard(
                            calendar: calendar,
                            plan: plan,
                            today: today,
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      ..._buildTimeline(
                        calendar: calendar,
                        plan: plan,
                        today: today,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildTimeline({
    required CropCalendar calendar,
    required UserCropPlan? plan,
    required DateTime today,
  }) {
    final tiles = <Widget>[];
    for (var i = 0; i < calendar.stages.length; i++) {
      final stage = calendar.stages[i];
      tiles.add(
        _FadeSlideIn(
          delayMs: 120 + i * 60,
          child: TimelineStageTile(
            stage: stage,
            plan: plan,
            today: today,
            isFirst: i == 0,
            isLast: i == calendar.stages.length - 1,
            previewMode: plan == null,
          ),
        ),
      );
    }
    return tiles;
  }
}

/// Lightweight fade + slide-in wrapper used for the timeline. Kept here
/// because it is purely presentational and only meaningful in this screen.
class _FadeSlideIn extends StatelessWidget {
  const _FadeSlideIn({
    required this.child,
    this.delayMs = 0,
  });

  final Widget child;
  final int delayMs;

  @override
  Widget build(BuildContext context) {
    final delayFactor = (delayMs / 800).clamp(0.0, 0.7);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final delayed =
            ((value - delayFactor) / (1 - delayFactor)).clamp(0.0, 1.0);
        return Opacity(
          opacity: delayed,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - delayed)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
