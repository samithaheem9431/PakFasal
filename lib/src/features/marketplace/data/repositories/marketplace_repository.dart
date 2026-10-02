import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

import '../../domain/entities/product.dart';

/// Result of a marketplace product fetch (network or Hive cache).
class MarketplaceFetchResult {
  const MarketplaceFetchResult({
    required this.products,
    required this.fromCache,
    required this.isStale,
  });

  final List<Product> products;
  final bool fromCache;

  /// Cache exists but is older than [MarketplaceRepository.cacheTtl].
  /// Callers should show data immediately and refresh in the background.
  final bool isStale;
}

class _CachedProducts {
  const _CachedProducts({required this.products, required this.cachedAt});

  final List<Product> products;
  final DateTime cachedAt;
}

/// Loads marketplace products from Firestore (managed by the admin website).
///
/// Firestore shape (`products/{autoId}`):
/// ```
/// title: { en, ur }
/// description: { en, ur }
/// price: number
/// currency: "PKR"
/// crop: string          // wheat | rice | cotton | custom
/// category: string      // fungicides | herbicides | ...
/// company: string
/// images: array<string> // Cloudinary HTTPS URLs
/// phones: array<string>
/// sku: string
/// isActive: bool
/// isDeleted: bool
/// ```
///
/// Reads are paged (never an unbounded collection `.get()`). Results are
/// cached in Hive with a TTL so the module works offline and stale data is
/// refreshed in the background.
class MarketplaceRepository {
  MarketplaceRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const collection = 'products';
  static const cacheBoxName = 'marketplace_cache';
  static const _cacheKey = 'marketplace_products_v2';
  static const _legacyCacheKey = 'marketplace_products_v1';

  /// Max documents per Firestore page.
  static const int pageSize = 50;

  /// Safety cap so a runaway collection cannot hang the app.
  static const int maxPages = 40;

  /// Hive cache is considered fresh for this long.
  static const Duration cacheTtl = Duration(hours: 6);

  Future<MarketplaceFetchResult> fetchProducts({
    bool forceRefresh = false,
  }) async {
    final box = Hive.box(cacheBoxName);
    final cached = _readCache(box);

    if (!forceRefresh && cached != null) {
      final fresh =
          DateTime.now().difference(cached.cachedAt) < cacheTtl;
      return MarketplaceFetchResult(
        products: cached.products,
        fromCache: true,
        isStale: !fresh,
      );
    }

    try {
      final products = await _fetchAllPaged();
      _writeCache(box, products);
      return MarketplaceFetchResult(
        products: products,
        fromCache: false,
        isStale: false,
      );
    } catch (_) {
      if (cached != null) {
        return MarketplaceFetchResult(
          products: cached.products,
          fromCache: true,
          isStale: true,
        );
      }
      rethrow;
    }
  }

  /// Fetches one page. Used by progressive UI load-more if needed.
  Future<({List<Product> products, DocumentSnapshot? lastDoc, bool hasMore})>
      fetchProductsPage({
    DocumentSnapshot? startAfter,
    int limit = pageSize,
  }) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection(collection)
        .orderBy(FieldPath.documentId)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snap = await query.get();
    final products = <Product>[];
    for (final doc in snap.docs) {
      final product = _productFromDoc(doc);
      if (product != null) products.add(product);
    }
    products.sort(_byTitle);

    final lastDoc = snap.docs.isEmpty ? null : snap.docs.last;
    final hasMore = snap.docs.length >= limit;
    return (products: products, lastDoc: lastDoc, hasMore: hasMore);
  }

  Future<List<Product>> _fetchAllPaged() async {
    final all = <Product>[];
    DocumentSnapshot? cursor;

    for (var page = 0; page < maxPages; page++) {
      final result = await fetchProductsPage(
        startAfter: cursor,
        limit: pageSize,
      );
      all.addAll(result.products);
      cursor = result.lastDoc;
      if (!result.hasMore || cursor == null) break;
    }

    all.sort(_byTitle);
    return all;
  }

  Product? _productFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data['isDeleted'] == true || data['isActive'] == false) {
      return null;
    }
    final mapped = Map<String, dynamic>.from(data);
    mapped['id'] = doc.id;
    return Product.fromJson(mapped);
  }

  void _writeCache(Box box, List<Product> products) {
    box.put(
      _cacheKey,
      jsonEncode({
        'cachedAt': DateTime.now().millisecondsSinceEpoch,
        'products': products.map((e) => e.toJson()).toList(),
      }),
    );
    // Drop legacy payload so we don't keep two copies forever.
    box.delete(_legacyCacheKey);
  }

  _CachedProducts? _readCache(Box box) {
    final raw = box.get(_cacheKey) as String?;
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          final list = decoded['products'] as List<dynamic>? ?? const [];
          final cachedAtMs =
              (decoded['cachedAt'] as num?)?.toInt() ?? 0;
          final products = _decodeProductList(list);
          if (products == null) return null;
          return _CachedProducts(
            products: products,
            cachedAt: cachedAtMs > 0
                ? DateTime.fromMillisecondsSinceEpoch(cachedAtMs)
                : DateTime.fromMillisecondsSinceEpoch(0),
          );
        }
      } catch (_) {
        // Fall through to legacy.
      }
    }

    // Migrate v1 (bare list, no timestamp) → treat as already stale.
    final legacy = box.get(_legacyCacheKey) as String?;
    if (legacy == null) return null;
    try {
      final decoded = jsonDecode(legacy) as List<dynamic>;
      final products = _decodeProductList(decoded);
      if (products == null) return null;
      return _CachedProducts(
        products: products,
        cachedAt: DateTime.fromMillisecondsSinceEpoch(0),
      );
    } catch (_) {
      return null;
    }
  }

  List<Product>? _decodeProductList(List<dynamic> decoded) {
    try {
      return decoded
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .where((p) => p.isActive)
          .toList()
        ..sort(_byTitle);
    } catch (_) {
      return null;
    }
  }

  static int _byTitle(Product a, Product b) =>
      a.titleEn.toLowerCase().compareTo(b.titleEn.toLowerCase());
}
