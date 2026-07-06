import 'package:flutter/material.dart';

import '../../data/learning_icons.dart';
import 'crop_disease_models.dart' show pickText;

/// One heading + paragraph inside an article. Carries both languages so the
/// UI can react instantly to an app-wide language switch without
/// re-fetching from Firestore — call [heading]/[body] with the current
/// locale's language code at render time.
class ArticleSectionEntry {
  const ArticleSectionEntry({
    required this.headingEn,
    required this.headingUr,
    required this.bodyEn,
    required this.bodyUr,
  });

  final String headingEn;
  final String headingUr;
  final String bodyEn;
  final String bodyUr;

  String heading(String languageCode) =>
      pickText(headingEn, headingUr, languageCode);

  String body(String languageCode) => pickText(bodyEn, bodyUr, languageCode);

  Map<String, dynamic> toJson() => {
    'headingEn': headingEn,
    'headingUr': headingUr,
    'bodyEn': bodyEn,
    'bodyUr': bodyUr,
  };

  factory ArticleSectionEntry.fromJson(Map<String, dynamic> json) {
    return ArticleSectionEntry(
      headingEn: json['headingEn'] as String? ?? '',
      headingUr: json['headingUr'] as String? ?? '',
      bodyEn: json['bodyEn'] as String? ?? '',
      bodyUr: json['bodyUr'] as String? ?? '',
    );
  }
}

/// A learning article, fetched from Firestore. Bilingual, same reasoning as
/// [ArticleSectionEntry].
class LearningArticleEntry {
  const LearningArticleEntry({
    required this.id,
    required this.categoryEn,
    required this.categoryUr,
    required this.titleEn,
    required this.titleUr,
    required this.summaryEn,
    required this.summaryUr,
    required this.readTimeMinutes,
    required this.iconKey,
    required this.sections,
  });

  final String id;
  final String categoryEn;
  final String categoryUr;
  final String titleEn;
  final String titleUr;
  final String summaryEn;
  final String summaryUr;
  final int readTimeMinutes;
  final String iconKey;
  final List<ArticleSectionEntry> sections;

  String category(String languageCode) =>
      pickText(categoryEn, categoryUr, languageCode);

  String title(String languageCode) =>
      pickText(titleEn, titleUr, languageCode);

  String summary(String languageCode) =>
      pickText(summaryEn, summaryUr, languageCode);

  IconData get icon => LearningIcons.resolve(iconKey);

  Map<String, dynamic> toJson() => {
    'id': id,
    'categoryEn': categoryEn,
    'categoryUr': categoryUr,
    'titleEn': titleEn,
    'titleUr': titleUr,
    'summaryEn': summaryEn,
    'summaryUr': summaryUr,
    'readTimeMinutes': readTimeMinutes,
    'iconKey': iconKey,
    'sections': sections.map((s) => s.toJson()).toList(),
  };

  factory LearningArticleEntry.fromJson(Map<String, dynamic> json) {
    return LearningArticleEntry(
      id: json['id'] as String? ?? '',
      categoryEn: json['categoryEn'] as String? ?? '',
      categoryUr: json['categoryUr'] as String? ?? '',
      titleEn: json['titleEn'] as String? ?? '',
      titleUr: json['titleUr'] as String? ?? '',
      summaryEn: json['summaryEn'] as String? ?? '',
      summaryUr: json['summaryUr'] as String? ?? '',
      readTimeMinutes: (json['readTimeMinutes'] as num?)?.toInt() ?? 3,
      iconKey: json['iconKey'] as String? ?? '',
      sections: (json['sections'] as List<dynamic>? ?? [])
          .map((e) => ArticleSectionEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
