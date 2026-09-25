import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/layout/responsive.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/pakfasal_scaffold.dart';
import '../providers/profit_calculator_provider.dart';
import '../widgets/expense_field.dart';
import '../widgets/profit_summary_card.dart';
import '../widgets/saved_season_tile.dart';

class ProfitCalculatorScreen extends StatelessWidget {
  const ProfitCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfitCalculatorProvider(),
      child: const _ProfitCalculatorView(),
    );
  }
}

class _ProfitCalculatorView extends StatefulWidget {
  const _ProfitCalculatorView();

  @override
  State<_ProfitCalculatorView> createState() => _ProfitCalculatorViewState();
}

class _ProfitCalculatorViewState extends State<_ProfitCalculatorView> {
  final _cropController = TextEditingController();
  bool _syncingCrop = false;

  @override
  void dispose() {
    _cropController.dispose();
    super.dispose();
  }

  void _syncCropFromProvider(ProfitCalculatorProvider provider) {
    if (_syncingCrop) return;
    if (_cropController.text == provider.cropName) return;
    _syncingCrop = true;
    _cropController.text = provider.cropName;
    _syncingCrop = false;
  }

  Future<void> _save(ProfitCalculatorProvider provider) async {
    final l10n = AppLocalizations.of(context);
    // Ensure latest crop text is in the provider before validating/saving.
    provider.setCropName(_cropController.text);

    final ok = await provider.saveSeason();
    if (!mounted) return;

    final error = provider.lastError;
    final message = error != null
        ? l10n.t('seasonSaveFailed')
        : (ok ? l10n.t('seasonSaved') : l10n.t('seasonSaveNeedCrop'));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _confirmDelete(
    ProfitCalculatorProvider provider,
    String id,
  ) async {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.t('deleteSeason')),
          content: Text(l10n.t('deleteSeasonConfirm')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.t('no')),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: scheme.error),
              child: Text(l10n.t('yes')),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      await provider.deleteSeason(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<ProfitCalculatorProvider>();
    _syncCropFromProvider(provider);

    final hPad = context.isCompact ? 12.0 : 16.0;
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PakFasalScaffold(
      title: l10n.t('profitCalculator'),
      child: ListView(
        padding: PakFasalFloatingBottomBar.scrollPadding(
          context,
          left: hPad,
          top: 16,
          right: hPad,
          bottom: 24,
        ),
        children: [
          Text(
            l10n.t('profitCalculatorHint'),
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _cropController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: l10n.t('cropName'),
              border: const OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: provider.setCropName,
          ),
          const SizedBox(height: 12),
          ExpenseField(
            label: l10n.t('areaAcres'),
            value: provider.areaAcres,
            syncToken: provider.formSyncToken,
            prefixText: null,
            onChanged: provider.setAreaAcres,
          ),
          const SizedBox(height: 20),
          Text(
            l10n.t('expensesSection'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isDark ? scheme.onSurface : AppColors.primaryGreen,
                ),
          ),
          const SizedBox(height: 10),
          ExpenseField(
            label: l10n.t('expenseSeed'),
            value: provider.seedCost,
            syncToken: provider.formSyncToken,
            onChanged: provider.setSeedCost,
          ),
          const SizedBox(height: 10),
          ExpenseField(
            label: l10n.t('expenseFertilizer'),
            value: provider.fertilizerCost,
            syncToken: provider.formSyncToken,
            onChanged: provider.setFertilizerCost,
          ),
          const SizedBox(height: 10),
          ExpenseField(
            label: l10n.t('expensePesticide'),
            value: provider.pesticideCost,
            syncToken: provider.formSyncToken,
            onChanged: provider.setPesticideCost,
          ),
          const SizedBox(height: 10),
          ExpenseField(
            label: l10n.t('expenseLabour'),
            value: provider.labourCost,
            syncToken: provider.formSyncToken,
            onChanged: provider.setLabourCost,
          ),
          const SizedBox(height: 10),
          ExpenseField(
            label: l10n.t('expenseIrrigation'),
            value: provider.irrigationCost,
            syncToken: provider.formSyncToken,
            onChanged: provider.setIrrigationCost,
          ),
          const SizedBox(height: 10),
          ExpenseField(
            label: l10n.t('expenseTransport'),
            value: provider.transportCost,
            syncToken: provider.formSyncToken,
            onChanged: provider.setTransportCost,
          ),
          const SizedBox(height: 10),
          ExpenseField(
            label: l10n.t('expenseOther'),
            value: provider.otherCost,
            syncToken: provider.formSyncToken,
            onChanged: provider.setOtherCost,
          ),
          const SizedBox(height: 20),
          Text(
            l10n.t('incomeSection'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isDark ? scheme.onSurface : AppColors.primaryGreen,
                ),
          ),
          const SizedBox(height: 8),
          SegmentedButton<IncomeMode>(
            segments: [
              ButtonSegment(
                value: IncomeMode.totalSale,
                label: Text(l10n.t('incomeTotalSale')),
                icon: const Icon(Icons.payments_outlined, size: 18),
              ),
              ButtonSegment(
                value: IncomeMode.yieldTimesRate,
                label: Text(l10n.t('incomeYieldRate')),
                icon: const Icon(Icons.calculate_outlined, size: 18),
              ),
            ],
            selected: {provider.incomeMode},
            onSelectionChanged: (set) {
              provider.setIncomeMode(set.first);
            },
          ),
          const SizedBox(height: 12),
          if (provider.incomeMode == IncomeMode.totalSale)
            ExpenseField(
              label: l10n.t('totalIncome'),
              value: provider.incomeTotal,
              syncToken: provider.formSyncToken,
              onChanged: provider.setIncomeTotal,
            )
          else ...[
            ExpenseField(
              label: l10n.t('yieldAmount'),
              value: provider.yieldAmount,
              syncToken: provider.formSyncToken,
              prefixText: null,
              onChanged: provider.setYieldAmount,
            ),
            const SizedBox(height: 10),
            ExpenseField(
              label: l10n.t('marketRate'),
              value: provider.marketRate,
              syncToken: provider.formSyncToken,
              onChanged: provider.setMarketRate,
            ),
          ],
          const SizedBox(height: 20),
          ProfitSummaryCard(
            totalExpense: provider.totalExpense,
            income: provider.effectiveIncome,
            profit: provider.profit,
            profitPerAcre: provider.profitPerAcre,
            marginPercent: provider.marginPercent,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    provider.clearForm();
                    _cropController.clear();
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 48),
                  ),
                  child: Text(l10n.t('clearForm')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: provider.isSaving
                      ? null
                      : () => _save(provider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: AppColors.white,
                    minimumSize: const Size(0, 48),
                  ),
                  child: provider.isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: AppColors.white,
                          ),
                        )
                      : Text(l10n.t('saveSeason')),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            l10n.t('savedSeasons'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isDark ? scheme.onSurface : AppColors.primaryGreen,
                ),
          ),
          const SizedBox(height: 10),
          if (provider.savedSeasons.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? scheme.surfaceContainerHighest
                    : AppColors.paleGreen,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                l10n.t('noSavedSeasons'),
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            )
          else
            ...provider.savedSeasons.map(
              (season) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SavedSeasonTile(
                  season: season,
                  onTap: () {
                    provider.loadSeason(season);
                    _cropController.text = season.cropName;
                  },
                  onDelete: () => _confirmDelete(provider, season.id),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
