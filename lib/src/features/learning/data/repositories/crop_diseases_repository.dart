import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

import '../../domain/entities/crop_disease_models.dart'
    show CropDiseaseEntry, ResolvedCropWithDiseases, stringListOf;

/// Loads the "Keera aur Bimariyan" (pests & diseases) content from Firestore.
///
/// Firestore shape (managed by the admin website):
/// ```
/// learning_crops/{cropId}
///   nameEn, nameUr: string
///   icon: string (see LearningIcons.keys)
///   order: number
///   showInPests: bool
///
/// learning_crop_diseases/{autoId}
///   cropId: string  -> references learning_crops/{cropId}
///   order: number
///   nameEn, nameUr, descriptionEn, descriptionUr: string
///   symptomsEn, symptomsUr, solutionsEn, solutionsUr: array<string>
/// ```
///
/// Both languages are kept on the resolved models (see
/// [ResolvedCropWithDiseases]) so switching the app's language re-renders
/// instantly without a re-fetch. Results are cached in Hive so the module
/// still works offline after the first successful load.
class CropDiseasesRepository {
  CropDiseasesRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const _cropsCollection = 'learning_crops';
  static const _diseasesCollection = 'learning_crop_diseases';
  static const _cacheKey = 'crop_diseases_v2';

  Future<List<ResolvedCropWithDiseases>> fetchCropDiseases({
    bool forceRefresh = false,
  }) async {
    final box = Hive.box('learning_cache');

    if (!forceRefresh) {
      final cached = _readCache(box);
      if (cached != null) return cached;
    }

    try {
      final cropsSnap = await _firestore.collection(_cropsCollection).get();
      final diseasesSnap =
          await _firestore.collection(_diseasesCollection).get();

      final diseasesByCrop =
          <String, List<QueryDocumentSnapshot<Map<String, dynamic>>>>{};
      for (final doc in diseasesSnap.docs) {
        final cropId = doc.data()['cropId'] as String? ?? '';
        if (cropId.isEmpty) continue;
        diseasesByCrop.putIfAbsent(cropId, () => []).add(doc);
      }

      final crops = cropsSnap.docs.where((d) {
        final data = d.data();
        return (data['showInPests'] as bool?) ?? true;
      }).toList()
        ..sort((a, b) => _orderOf(a.data()).compareTo(_orderOf(b.data())));

      final result = <ResolvedCropWithDiseases>[];
      for (final cropDoc in crops) {
        final cropData = cropDoc.data();
        final diseaseDocs = (diseasesByCrop[cropDoc.id] ?? const [])
            .toList()
          ..sort((a, b) => _orderOf(a.data()).compareTo(_orderOf(b.data())));
        if (diseaseDocs.isEmpty) continue;

        result.add(
          ResolvedCropWithDiseases(
            id: cropDoc.id,
            nameEn: (cropData['nameEn'] as String?) ?? '',
            nameUr: (cropData['nameUr'] as String?) ?? '',
            iconKey: (cropData['icon'] as String?) ?? 'eco',
            diseases: diseaseDocs.map((d) {
              final data = d.data();
              return CropDiseaseEntry(
                nameEn: (data['nameEn'] as String?) ?? '',
                nameUr: (data['nameUr'] as String?) ?? '',
                descriptionEn: (data['descriptionEn'] as String?) ?? '',
                descriptionUr: (data['descriptionUr'] as String?) ?? '',
                symptomsEn: stringListOf(data['symptomsEn']),
                symptomsUr: stringListOf(data['symptomsUr']),
                solutionsEn: stringListOf(data['solutionsEn']),
                solutionsUr: stringListOf(data['solutionsUr']),
              );
            }).toList(),
          ),
        );
      }

      if (result.isNotEmpty) {
        box.put(_cacheKey, jsonEncode(result.map((e) => e.toJson()).toList()));
      }
      return result;
    } catch (_) {
      final cached = _readCache(box);
      if (cached != null) return cached;
      rethrow;
    }
  }

  List<ResolvedCropWithDiseases>? _readCache(Box box) {
    final raw = box.get(_cacheKey) as String?;
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => ResolvedCropWithDiseases.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  num _orderOf(Map<String, dynamic> data) => (data['order'] as num?) ?? 0;
}
