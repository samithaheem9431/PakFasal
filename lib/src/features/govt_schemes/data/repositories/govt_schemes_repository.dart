import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

import '../../domain/entities/govt_scheme.dart';

/// Loads government schemes from Firestore (managed by the admin website).
///
/// Firestore shape (`govt_schemes/{autoId}`):
/// ```
/// titleEn, titleUr
/// descriptionEn, descriptionUr
/// categoryEn, categoryUr
/// departmentEn, departmentUr
/// province: string
/// eligibilityEn, eligibilityUr: array<string>
/// benefitsEn, benefitsUr: array<string>
/// deadline: YYYY-MM-DD | ""
/// status: active | inactive | closed
/// applyUrl, website, imageUrl
/// featured: bool
/// order: number
/// ```
///
/// Both languages are kept on [GovtScheme] so locale switches do not refetch.
/// Results are cached in Hive for offline use after the first successful load.
class GovtSchemesRepository {
  GovtSchemesRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const collection = 'govt_schemes';
  static const _cacheBox = 'govt_schemes_cache';
  static const _cacheKey = 'govt_schemes_v1';

  Future<List<GovtScheme>> fetchSchemes({bool forceRefresh = false}) async {
    final box = Hive.box(_cacheBox);

    if (!forceRefresh) {
      final cached = _readCache(box);
      if (cached != null) return cached;
    }

    try {
      final snap = await _firestore.collection(collection).get();
      final schemes = snap.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return GovtScheme.fromJson(data);
      }).toList()
        ..sort((a, b) => a.order.compareTo(b.order));

      // Prefer active schemes for the farmer app; still cache full list so
      // inactive docs do not wipe a previously good offline snapshot if empty.
      final active = schemes.where((s) => s.isActive).toList();
      final toCache = active.isNotEmpty ? active : schemes;
      if (toCache.isNotEmpty) {
        box.put(
          _cacheKey,
          jsonEncode(toCache.map((e) => e.toJson()).toList()),
        );
      }
      return active;
    } catch (_) {
      final cached = _readCache(box);
      if (cached != null) return cached;
      rethrow;
    }
  }

  List<GovtScheme>? _readCache(Box box) {
    final raw = box.get(_cacheKey) as String?;
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => GovtScheme.fromJson(e as Map<String, dynamic>))
          .where((s) => s.isActive)
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));
    } catch (_) {
      return null;
    }
  }
}
