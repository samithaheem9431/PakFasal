import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/pakfasal_scaffold.dart';
import '../../data/crop_diseases_catalog.dart';

/// Diseases and treatments for one crop, using expandable sections per disease.
class CropDiseaseDetailScreen extends StatelessWidget {
  const CropDiseaseDetailScreen({
    super.key,
    required this.crop,
  });

  final CropWithDiseases crop;

  static const String _emojiDisease = '\u{1F9A0}'; // 🦠
  static const String _emojiSymptoms = '\u{26A0}\u{FE0F}'; // ⚠️
  static const String _emojiSolution = '\u2705'; // ✅

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return PakFasalScaffold(
      title: l10n.t(crop.nameKey),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: crop.diseases.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      crop.icon,
                      size: 28,
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.t(crop.nameKey),
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.t('cropDiseaseDetailSubtitle'),
                          style: textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          final disease = crop.diseases[index - 1].resolve(l10n);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              elevation: 2,
              shadowColor: scheme.primary.withValues(alpha: 0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: scheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                collapsedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                initiallyExpanded: index == 1,
                leading: Text(
                  _emojiDisease,
                  style: const TextStyle(fontSize: 22),
                ),
                title: Text(
                  disease.name,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    disease.shortDescription,
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ),
                children: [
                  _BulletSection(
                    emoji: _emojiSymptoms,
                    title: l10n.t('cropDiseaseSymptoms'),
                    items: disease.symptoms,
                    accent: AppColors.warning,
                  ),
                  const SizedBox(height: 14),
                  _BulletSection(
                    emoji: _emojiSolution,
                    title: l10n.t('cropDiseaseSolution'),
                    items: disease.solutions,
                    accent: AppColors.success,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BulletSection extends StatelessWidget {
  const _BulletSection({
    required this.emoji,
    required this.title,
    required this.items,
    required this.accent,
  });

  final String emoji;
  final String title;
  final List<String> items;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                title,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...items.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      line,
                      style: textTheme.bodyMedium?.copyWith(
                        height: 1.45,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
