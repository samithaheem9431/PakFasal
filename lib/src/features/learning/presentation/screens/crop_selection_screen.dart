import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/pakfasal_scaffold.dart';
import '../../data/crop_diseases_catalog.dart';
import 'crop_disease_detail_screen.dart';

/// Grid of crops for "Keera aur Bimariyaan" — tap a crop to see diseases.
class CropSelectionScreen extends StatelessWidget {
  const CropSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return PakFasalScaffold(
      title: l10n.t('learningOptionPests'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.t('cropDiseasePickCrop'),
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.t('cropDiseasePickCropHint'),
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.92,
              ),
              itemCount: CropDiseasesCatalog.crops.length,
                itemBuilder: (context, index) {
                final crop = CropDiseasesCatalog.crops[index];
                return _CropCard(
                  l10n: l10n,
                  crop: crop,
                  onTap: () {
                    Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            CropDiseaseDetailScreen(crop: crop),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              l10n.t('cropDiseaseMoreCropsSoon'),
              textAlign: TextAlign.center,
              style: textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CropCard extends StatelessWidget {
  const _CropCard({
    required this.l10n,
    required this.crop,
    required this.onTap,
  });

  final AppLocalizations l10n;
  final CropWithDiseases crop;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.softSurfaceGreen,
                AppColors.paleGreen.withValues(alpha: 0.65),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.mintGreen.withValues(alpha: 0.9),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGreen.withValues(alpha: 0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: scheme.surface.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    crop.icon,
                    size: 28,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const Spacer(),
                Text(
                  l10n.t(crop.nameKey),
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${crop.diseases.length} ${l10n.t('cropDiseaseTopicsShort')}',
                  style: textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
