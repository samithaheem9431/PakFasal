import 'package:flutter/material.dart';

/// Maps a small, fixed set of admin-selectable icon keys to Flutter
/// [IconData]. Firestore documents store the string key (e.g. `'grass'`);
/// this keeps the database free of platform-specific values and gives the
/// admin website a safe, closed dropdown of options that can never break
/// the app if a key is missing or misspelled (falls back to [fallback]).
abstract final class LearningIcons {
  LearningIcons._();

  static const IconData fallback = Icons.eco_rounded;

  static const Map<String, IconData> _byKey = {
    'grass': Icons.grass_rounded,
    'grass_outlined': Icons.grass_outlined,
    'rice_bowl': Icons.rice_bowl_rounded,
    'cotton': Icons.filter_vintage_rounded,
    'spa': Icons.spa_rounded,
    'eco': Icons.eco_rounded,
    'terrain': Icons.terrain_rounded,
    'science': Icons.science_rounded,
    'water_drop': Icons.water_drop_rounded,
    'cloud': Icons.cloud_rounded,
    'storefront': Icons.storefront_rounded,
    'account_balance': Icons.account_balance_rounded,
    'bug_report': Icons.bug_report_rounded,
    'agriculture': Icons.agriculture_rounded,
    'article': Icons.article_rounded,
  };

  /// All valid keys, in the order the admin dropdown should present them.
  static const List<String> keys = [
    'grass',
    'rice_bowl',
    'cotton',
    'spa',
    'grass_outlined',
    'eco',
    'terrain',
    'science',
    'water_drop',
    'cloud',
    'storefront',
    'account_balance',
    'bug_report',
    'agriculture',
    'article',
  ];

  static IconData resolve(String? key) {
    if (key == null) return fallback;
    return _byKey[key] ?? fallback;
  }
}
