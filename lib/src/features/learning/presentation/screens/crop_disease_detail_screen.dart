import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/localization_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/pakfasal_scaffold.dart';
import '../../domain/entities/crop_disease_models.dart';
import '../widgets/learning_widgets.dart';

/// Diseases and treatments for one crop, using expandable sections per
/// disease. [crop] carries both languages; display text is resolved live
/// from the current locale so switching language updates this screen
/// instantly, even while it's open.
class CropDiseaseDetailScreen extends StatelessWidget {
  const CropDiseaseDetailScreen({
    super.key,
    required this.crop,
  });

  final ResolvedCropWithDiseases crop;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final languageCode =
        context.watch<LocalizationController>().locale.languageCode;
    final cropName = crop.name(languageCode);

    return PakFasalScaffold(
      title: cropName,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: crop.diseases.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: LearningDetailHeader(
                icon: crop.icon,
                title: cropName,
                subtitle: Text(
                  l10n.t('cropDiseaseDetailSubtitle'),
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            );
          }

          final disease = crop.diseases[index - 1];
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
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: scheme.errorContainer.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.coronavirus_rounded,
                    size: 20,
                    color: scheme.error,
                  ),
                ),
                title: Text(
                  disease.name(languageCode),
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    disease.description(languageCode),
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ),
                children: [
                  _BulletSection(
                    icon: Icons.warning_amber_rounded,
                    title: l10n.t('cropDiseaseSymptoms'),
                    items: disease.symptoms(languageCode),
                    accent: AppColors.warning,
                  ),
                  const SizedBox(height: 14),
                  _BulletSection(
                    icon: Icons.check_circle_rounded,
                    title: l10n.t('cropDiseaseSolution'),
                    items: disease.solutions(languageCode),
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
    required this.icon,
    required this.title,
    required this.items,
    required this.accent,
  });

  final IconData icon;
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
              Icon(icon, size: 18, color: accent),
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
