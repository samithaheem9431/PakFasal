import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/localization_controller.dart';
import '../../../../core/widgets/common_states.dart';
import '../../../../core/widgets/pakfasal_scaffold.dart';
import '../../data/learning_image_cache.dart';
import '../../data/repositories/crop_diseases_repository.dart';
import '../../domain/entities/crop_disease_models.dart';
import '../widgets/learning_widgets.dart';
import 'crop_disease_detail_screen.dart';

/// Grid of crops for "Pests & Diseases" — tap a crop to see diseases.
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
                  // Modern large card grid for crops
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: crops.length,
                    itemBuilder: (context, index) {
                      final crop = crops[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _ModernCropCard(
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
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
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

class _ModernCropCard extends StatefulWidget {
  const _ModernCropCard({
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
  State<_ModernCropCard> createState() => _ModernCropCardState();
}

class _ModernCropCardState extends State<_ModernCropCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AnimatedScale(
      scale: _isPressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 150),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withValues(alpha: 0.15),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Background image (full width, semi-transparent)
                Positioned.fill(
                  child: widget.crop.imageUrl.isNotEmpty
                      ? LayoutBuilder(
                          builder: (context, constraints) {
                            final dpr = MediaQuery.devicePixelRatioOf(context);
                            return CachedNetworkImage(
                              imageUrl: widget.crop.imageUrl,
                              cacheManager: LearningImageCache.manager,
                              fit: BoxFit.cover,
                              fadeInDuration: Duration.zero,
                              fadeOutDuration: Duration.zero,
                              memCacheWidth:
                                  (constraints.maxWidth * dpr).round(),
                              memCacheHeight:
                                  (constraints.maxHeight * dpr).round(),
                              color: Colors.black.withValues(alpha: 0.3),
                              colorBlendMode: BlendMode.darken,
                              placeholder: (_, __) => _ImagePlaceholder(
                                icon: widget.crop.icon,
                                scheme: scheme,
                              ),
                              errorWidget: (_, __, ___) => _ImagePlaceholder(
                                icon: widget.crop.icon,
                                scheme: scheme,
                              ),
                            );
                          },
                        )
                      : _ImagePlaceholder(
                          icon: widget.crop.icon,
                          scheme: scheme,
                        ),
                ),

                // Gradient overlay for text readability
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                        stops: const [0.3, 1.0],
                      ),
                    ),
                  ),
                ),

                // Content overlay
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge with disease count
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.bug_report,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.crop.diseases.length} ${widget.l10n.t('cropDiseaseTopicsShort')}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Crop name
                      Text(
                        widget.crop.name(widget.languageCode),
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // View details button
                      Row(
                        children: [
                          Text(
                            'View Details',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ),
                    ],
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

// Image placeholder with gradient background
class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({
    required this.icon,
    required this.scheme,
  });

  final IconData icon;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primaryContainer,
            scheme.secondaryContainer,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          icon,
          size: 80,
          color: scheme.primary.withValues(alpha: 0.5),
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
                _CropAvatar(crop: crop, scheme: scheme),
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

class _CropAvatar extends StatelessWidget {
  const _CropAvatar({
    required this.crop,
    required this.scheme,
  });

  final ResolvedCropWithDiseases crop;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
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
    );

    if (crop.imageUrl.isEmpty) return fallback;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 52,
        height: 52,
        child: CachedNetworkImage(
          imageUrl: crop.imageUrl,
          cacheManager: LearningImageCache.manager,
          fit: BoxFit.cover,
          fadeInDuration: Duration.zero,
          fadeOutDuration: Duration.zero,
          memCacheWidth: (52 * MediaQuery.devicePixelRatioOf(context)).round(),
          memCacheHeight: (52 * MediaQuery.devicePixelRatioOf(context)).round(),
          placeholder: (_, __) => fallback,
          errorWidget: (_, __, ___) => fallback,
        ),
      ),
    );
  }
}
