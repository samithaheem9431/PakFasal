import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/localization_controller.dart';
import '../../../../core/widgets/common_states.dart';
import '../../../../core/widgets/pakfasal_scaffold.dart';
import '../../data/repositories/crop_diseases_repository.dart';
import '../../domain/entities/crop_disease_models.dart';
import '../widgets/learning_widgets.dart';
import 'crop_disease_detail_screen.dart';

/// Grid of crops for "Keera aur Bimariyaan" — tap a crop to see diseases.
/// Content is fetched live from Firestore (managed by the admin website).
/// Both languages are fetched once; switching the app's language re-renders
/// instantly without a re-fetch.
class CropSelectionScreen extends StatefulWidget {
  const CropSelectionScreen({super.key});

  @override
  State<CropSelectionScreen> createState() => _CropSelectionScreenState();
}

class _CropSelectionScreenState extends State<CropSelectionScreen> {
  final CropDiseasesRepository _repository = CropDiseasesRepository();
  late Future<List<ResolvedCropWithDiseases>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repository.fetchCropDiseases();
  }

  Future<void> _onRefresh() async {
    setState(() {
      _future = _repository.fetchCropDiseases(forceRefresh: true);
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final languageCode =
        context.watch<LocalizationController>().locale.languageCode;

    return PakFasalScaffold(
      title: l10n.t('learningOptionPests'),
      child: RefreshIndicator(
        onRefresh: _onRefresh,
        child: FutureBuilder<List<ResolvedCropWithDiseases>>(
          future: _future,
          builder: (context, snapshot) {
            final isLoading = snapshot.connectionState == ConnectionState.waiting;
            final crops = snapshot.data ?? const <ResolvedCropWithDiseases>[];

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                LearningIntro(
                  title: l10n.t('cropDiseasePickCrop'),
                  hint: l10n.t('cropDiseasePickCropHint'),
                ),
                const SizedBox(height: 20),
                if (isLoading)
                  const LearningGridSkeleton()
                else if (snapshot.hasError)
                  ErrorStateCard(onRetry: _onRefresh)
                else if (crops.isEmpty)
                  LearningEmptyCard(message: l10n.t('cropDiseaseEmpty'))
                else ...[
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.92,
                    ),
                    itemCount: crops.length,
                    itemBuilder: (context, index) {
                      final crop = crops[index];
                      return _CropCard(
                        l10n: l10n,
                        crop: crop,
                        languageCode: languageCode,
                        onTap: () {
                          Navigator.push<void>(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => CropDiseaseDetailScreen(crop: crop),
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
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CropCard extends StatelessWidget {
  const _CropCard({
    required this.l10n,
    required this.crop,
    required this.languageCode,
    required this.onTap,
  });

  final AppLocalizations l10n;
  final ResolvedCropWithDiseases crop;
  final String languageCode;
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
                scheme.primaryContainer.withValues(alpha: 0.55),
                scheme.surfaceContainerHighest,
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: scheme.primary.withValues(alpha: 0.35),
            ),
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withValues(alpha: 0.12),
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
                    color: scheme.primary,
                  ),
                ),
                const Spacer(),
                Text(
                  crop.name(languageCode),
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scheme.primary,
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
