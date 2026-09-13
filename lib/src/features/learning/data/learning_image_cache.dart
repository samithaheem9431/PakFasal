import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../domain/entities/crop_disease_models.dart';

/// Persistent disk cache for Pests & Diseases crop/disease images.
///
/// Images are downloaded once and reused for [stalePeriod] so opening the
/// module again does not wait on the network.
class LearningImageCache {
  LearningImageCache._();

  static const _cacheKey = 'learning_pests_diseases_images';

  /// Shared manager used by [CachedNetworkImage] and prefetch.
  static final CacheManager manager = CacheManager(
    Config(
      _cacheKey,
      stalePeriod: const Duration(days: 365),
      maxNrOfCacheObjects: 300,
    ),
  );

  static bool _prefetchInFlight = false;

  /// Downloads every non-empty crop/disease [imageUrl] into disk cache.
  /// Safe to call repeatedly; concurrent calls are coalesced.
  static Future<void> prefetchFromCrops(
    List<ResolvedCropWithDiseases> crops,
  ) async {
    if (crops.isEmpty || _prefetchInFlight) return;
    _prefetchInFlight = true;
    try {
      final urls = <String>{};
      for (final crop in crops) {
        final cropUrl = crop.imageUrl.trim();
        if (cropUrl.isNotEmpty) urls.add(cropUrl);
        for (final disease in crop.diseases) {
          final diseaseUrl = disease.imageUrl.trim();
          if (diseaseUrl.isNotEmpty) urls.add(diseaseUrl);
        }
      }
      if (urls.isEmpty) return;

      await Future.wait(
        urls.map((url) async {
          try {
            await manager.downloadFile(url);
          } catch (_) {
            // Keep going; a single failed URL must not block the rest.
          }
        }),
      );
    } finally {
      _prefetchInFlight = false;
    }
  }
}
