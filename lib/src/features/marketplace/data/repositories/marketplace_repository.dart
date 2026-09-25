import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

import '../../domain/entities/product.dart';

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
/// Results are cached in Hive for offline use after the first successful load.
class MarketplaceRepository {
  MarketplaceRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const collection = 'products';
  static const cacheBoxName = 'marketplace_cache';
  static const _cacheKey = 'marketplace_products_v1';

  Future<List<Product>> fetchProducts({bool forceRefresh = false}) async {
    final box = Hive.box(cacheBoxName);

    if (!forceRefresh) {
      final cached = _readCache(box);
      if (cached != null) return cached;
    }

    try {
      final snap = await _firestore.collection(collection).get();
      final products = snap.docs
          .where((doc) {
            final data = doc.data();
            return data['isDeleted'] != true && data['isActive'] != false;
          })
          .map((doc) {
            final data = Map<String, dynamic>.from(doc.data());
            data['id'] = doc.id;
            return Product.fromJson(data);
          })
          .toList()
        ..sort(
          (a, b) => a.titleEn.toLowerCase().compareTo(b.titleEn.toLowerCase()),
        );

      if (products.isNotEmpty) {
        box.put(
          _cacheKey,
          jsonEncode(products.map((e) => e.toJson()).toList()),
        );
      }
      return products;
    } catch (_) {
      final cached = _readCache(box);
      if (cached != null) return cached;
      rethrow;
    }
  }

  List<Product>? _readCache(Box box) {
    final raw = box.get(_cacheKey) as String?;
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .where((p) => p.isActive)
          .toList()
        ..sort(
          (a, b) => a.titleEn.toLowerCase().compareTo(b.titleEn.toLowerCase()),
        );
    } catch (_) {
      return null;
    }
  }
}
