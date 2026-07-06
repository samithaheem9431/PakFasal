import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

import '../../domain/entities/learning_article_models.dart';

/// Loads the "Learning Articles" content from Firestore.
///
/// Firestore shape (managed by the admin website):
/// ```
/// learning_articles/{autoId}
///   categoryEn, categoryUr: string
///   titleEn, titleUr, summaryEn, summaryUr: string
///   readTimeMinutes: number
///   icon: string (see LearningIcons.keys)
///   order: number
///
/// learning_article_sections/{autoId}
///   articleId: string  -> references learning_articles/{autoId}
///   order: number
///   headingEn, headingUr, bodyEn, bodyUr: string
/// ```
///
/// Both languages are kept on the resolved models (see
/// [LearningArticleEntry]) so switching the app's language re-renders
/// instantly without a re-fetch. Results are cached in Hive so the module
/// still works offline after the first successful load.
class LearningArticlesRepository {
  LearningArticlesRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const _articlesCollection = 'learning_articles';
  static const _sectionsCollection = 'learning_article_sections';
  static const _cacheKey = 'learning_articles_v2';

  Future<List<LearningArticleEntry>> fetchArticles({
    bool forceRefresh = false,
  }) async {
    final box = Hive.box('learning_cache');

    if (!forceRefresh) {
      final cached = _readCache(box);
      if (cached != null) return cached;
    }

    try {
      final articlesSnap =
          await _firestore.collection(_articlesCollection).get();
      final sectionsSnap =
          await _firestore.collection(_sectionsCollection).get();

      final sectionsByArticle =
          <String, List<QueryDocumentSnapshot<Map<String, dynamic>>>>{};
      for (final doc in sectionsSnap.docs) {
        final articleId = doc.data()['articleId'] as String? ?? '';
        if (articleId.isEmpty) continue;
        sectionsByArticle.putIfAbsent(articleId, () => []).add(doc);
      }

      final articles = articlesSnap.docs.toList()
        ..sort((a, b) => _orderOf(a.data()).compareTo(_orderOf(b.data())));

      final result = <LearningArticleEntry>[];
      for (final articleDoc in articles) {
        final data = articleDoc.data();
        final sectionDocs =
            (sectionsByArticle[articleDoc.id] ?? const []).toList()
              ..sort(
                (a, b) => _orderOf(a.data()).compareTo(_orderOf(b.data())),
              );

        result.add(
          LearningArticleEntry(
            id: articleDoc.id,
            categoryEn: (data['categoryEn'] as String?) ?? '',
            categoryUr: (data['categoryUr'] as String?) ?? '',
            titleEn: (data['titleEn'] as String?) ?? '',
            titleUr: (data['titleUr'] as String?) ?? '',
            summaryEn: (data['summaryEn'] as String?) ?? '',
            summaryUr: (data['summaryUr'] as String?) ?? '',
            readTimeMinutes: (data['readTimeMinutes'] as num?)?.toInt() ?? 3,
            iconKey: (data['icon'] as String?) ?? 'article',
            sections: sectionDocs.map((s) {
              final sectionData = s.data();
              return ArticleSectionEntry(
                headingEn: (sectionData['headingEn'] as String?) ?? '',
                headingUr: (sectionData['headingUr'] as String?) ?? '',
                bodyEn: (sectionData['bodyEn'] as String?) ?? '',
                bodyUr: (sectionData['bodyUr'] as String?) ?? '',
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

  List<LearningArticleEntry>? _readCache(Box box) {
    final raw = box.get(_cacheKey) as String?;
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => LearningArticleEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  num _orderOf(Map<String, dynamic> data) => (data['order'] as num?) ?? 0;
}
