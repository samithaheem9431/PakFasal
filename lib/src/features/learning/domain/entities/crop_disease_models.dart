import 'package:flutter/material.dart';

import '../../data/learning_icons.dart';

/// One pest/disease. Carries both languages so the UI can react instantly
/// to an app-wide language switch without re-fetching from Firestore —
/// call [name]/[description]/[symptoms]/[solutions] with the current
/// locale's language code at render time.
class CropDiseaseEntry {
  const CropDiseaseEntry({
    required this.nameEn,
    required this.nameUr,
    required this.descriptionEn,
    required this.descriptionUr,
    required this.symptomsEn,
    required this.symptomsUr,
    required this.solutionsEn,
    required this.solutionsUr,
  });

  final String nameEn;
  final String nameUr;
  final String descriptionEn;
  final String descriptionUr;
  final List<String> symptomsEn;
  final List<String> symptomsUr;
  final List<String> solutionsEn;
  final List<String> solutionsUr;

  String name(String languageCode) => pickText(nameEn, nameUr, languageCode);

  String description(String languageCode) =>
      pickText(descriptionEn, descriptionUr, languageCode);

  List<String> symptoms(String languageCode) =>
      pickList(symptomsEn, symptomsUr, languageCode);

  List<String> solutions(String languageCode) =>
      pickList(solutionsEn, solutionsUr, languageCode);

  Map<String, dynamic> toJson() => {
    'nameEn': nameEn,
    'nameUr': nameUr,
    'descriptionEn': descriptionEn,
    'descriptionUr': descriptionUr,
    'symptomsEn': symptomsEn,
    'symptomsUr': symptomsUr,
    'solutionsEn': solutionsEn,
    'solutionsUr': solutionsUr,
  };

  factory CropDiseaseEntry.fromJson(Map<String, dynamic> json) {
    return CropDiseaseEntry(
      nameEn: json['nameEn'] as String? ?? '',
      nameUr: json['nameUr'] as String? ?? '',
      descriptionEn: json['descriptionEn'] as String? ?? '',
      descriptionUr: json['descriptionUr'] as String? ?? '',
      symptomsEn: stringListOf(json['symptomsEn']),
      symptomsUr: stringListOf(json['symptomsUr']),
      solutionsEn: stringListOf(json['solutionsEn']),
      solutionsUr: stringListOf(json['solutionsUr']),
    );
  }
}

/// A crop with its known diseases, fetched from Firestore. Bilingual, same
/// reasoning as [CropDiseaseEntry].
class ResolvedCropWithDiseases {
  const ResolvedCropWithDiseases({
    required this.id,
    required this.nameEn,
    required this.nameUr,
    required this.iconKey,
    required this.diseases,
  });

  final String id;
  final String nameEn;
  final String nameUr;
  final String iconKey;
  final List<CropDiseaseEntry> diseases;

  String name(String languageCode) => pickText(nameEn, nameUr, languageCode);

  IconData get icon => LearningIcons.resolve(iconKey);

  Map<String, dynamic> toJson() => {
    'id': id,
    'nameEn': nameEn,
    'nameUr': nameUr,
    'iconKey': iconKey,
    'diseases': diseases.map((d) => d.toJson()).toList(),
  };

  factory ResolvedCropWithDiseases.fromJson(Map<String, dynamic> json) {
    return ResolvedCropWithDiseases(
      id: json['id'] as String? ?? '',
      nameEn: json['nameEn'] as String? ?? '',
      nameUr: json['nameUr'] as String? ?? '',
      iconKey: json['iconKey'] as String? ?? '',
      diseases: (json['diseases'] as List<dynamic>? ?? [])
          .map((e) => CropDiseaseEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Picks the Urdu variant when the app is in Urdu and it's non-empty,
/// otherwise falls back to English. Shared by all bilingual learning models.
String pickText(String en, String ur, String languageCode) {
  if (languageCode == 'ur' && ur.trim().isNotEmpty) return ur;
  return en;
}

List<String> pickList(List<String> en, List<String> ur, String languageCode) {
  if (languageCode == 'ur' && ur.isNotEmpty) return ur;
  return en;
}

List<String> stringListOf(dynamic raw) =>
    (raw as List<dynamic>? ?? const []).map((e) => e.toString()).toList();
