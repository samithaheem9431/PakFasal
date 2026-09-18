import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/season_calculation.dart';

class SavedSeasonTile extends StatelessWidget {
  const SavedSeasonTile({
    super.key,
    required this.season,
    required this.onTap,
    required this.onDelete,
  });

  final SeasonCalculation season;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isProfit = season.profit >= 0;
    final accent = isProfit ? AppColors.success : AppColors.error;
    final date = season.createdAt;
    final dateLabel =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

    return Dismissible(
      key: ValueKey(season.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      child: Material(
        color: isDark
            ? scheme.surfaceContainerHighest
            : AppColors.softSurfaceGreen,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isProfit
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    color: accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        season.cropName,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? scheme.onSurface
                              : AppColors.primaryGreen,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${l10n.t('areaAcres')}: ${season.areaAcres.toStringAsFixed(season.areaAcres == season.areaAcres.roundToDouble() ? 0 : 1)} · $dateLabel',
                        style: TextStyle(
                          fontSize: 12,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isProfit ? '+' : '-'} PKR ${season.profit.abs().toStringAsFixed(0)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: accent,
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.t('deleteSeason'),
                      visualDensity: VisualDensity.compact,
                      onPressed: onDelete,
                      icon: Icon(
                        Icons.delete_outline,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
