import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';

class ProfitSummaryCard extends StatelessWidget {
  const ProfitSummaryCard({
    super.key,
    required this.totalExpense,
    required this.income,
    required this.profit,
    required this.profitPerAcre,
    required this.marginPercent,
  });

  final double totalExpense;
  final double income;
  final double profit;
  final double? profitPerAcre;
  final double? marginPercent;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isProfit = profit >= 0;
    final accent = isProfit ? AppColors.success : AppColors.error;

    final bg = isDark
        ? Color.alphaBlend(
            accent.withValues(alpha: 0.18),
            scheme.surfaceContainerHighest,
          )
        : accent.withValues(alpha: 0.08);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.t('profitSummary'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isDark ? scheme.onSurface : AppColors.primaryGreen,
                ),
          ),
          const SizedBox(height: 12),
          _row(l10n.t('totalExpense'), _pkr(totalExpense), scheme.onSurface),
          const SizedBox(height: 6),
          _row(l10n.t('totalIncome'), _pkr(income), scheme.onSurface),
          const Divider(height: 20),
          _row(
            isProfit ? l10n.t('profit') : l10n.t('loss'),
            _pkr(profit.abs()),
            accent,
            bold: true,
          ),
          if (profitPerAcre != null) ...[
            const SizedBox(height: 6),
            _row(
              l10n.t('profitPerAcre'),
              _pkr(profitPerAcre!),
              scheme.onSurfaceVariant,
            ),
          ],
          if (marginPercent != null) ...[
            const SizedBox(height: 6),
            _row(
              l10n.t('profitMargin'),
              '${marginPercent!.toStringAsFixed(1)}%',
              scheme.onSurfaceVariant,
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(String label, String value, Color color, {bool bold = false}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
          ),
        ),
      ],
    );
  }

  static String _pkr(double amount) {
    final sign = amount < 0 ? '-' : '';
    return '$sign PKR ${amount.abs().toStringAsFixed(0)}';
  }
}
