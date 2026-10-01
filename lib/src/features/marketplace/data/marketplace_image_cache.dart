import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../domain/entities/product.dart';

/// Disk cache + Cloudinary thumbnails for marketplace product images.
class MarketplaceImageCache {
  MarketplaceImageCache._();

  static const _cacheKey = 'marketplace_product_images';

  static final CacheManager manager = CacheManager(
    Config(
      _cacheKey,
      stalePeriod: const Duration(days: 30),
      maxNrOfCacheObjects: 400,
    ),
  );

  static bool _prefetchInFlight = false;

  /// Returns a smaller Cloudinary derivative for list cards when possible.
  /// Non-Cloudinary URLs are returned unchanged.
  static String thumbUrl(String url, {int width = 240}) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return trimmed;

    const marker = '/upload/';
    final index = trimmed.indexOf(marker);
    if (index < 0) return trimmed;

    final insertAt = index + marker.length;
    final after = trimmed.substring(insertAt);
    // Already has a transformation segment — leave original alone.
    if (RegExp(r'^[a-z]+_').hasMatch(after)) return trimmed;

    return '${trimmed.substring(0, insertAt)}'
        'w_$width,c_fill,f_auto,q_auto/'
        '${trimmed.substring(insertAt)}';
  }

  /// Detail / gallery size — still compressed, but larger than list thumbs.
  static String detailUrl(String url, {int width = 900}) {
    return thumbUrl(url, width: width);
  }

  static Future<void> prefetchProducts(List<Product> products) async {
    if (products.isEmpty || _prefetchInFlight) return;
    _prefetchInFlight = true;
    try {
      final urls = <String>{};
      for (final product in products) {
        final url = product.imageUrl.trim();
        if (url.isEmpty) continue;
        urls.add(thumbUrl(url));
      }
      if (urls.isEmpty) return;

      await Future.wait(
        urls.map((url) async {
          try {
            await manager.downloadFile(url);
          } catch (_) {
            // One failed URL must not block the rest.
          }
        }),
      );
    } finally {
      _prefetchInFlight = false;
    }
  }
}
