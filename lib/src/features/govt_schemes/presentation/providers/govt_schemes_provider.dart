import 'package:flutter/material.dart';

import '../../data/repositories/govt_schemes_repository.dart';
import '../../domain/entities/govt_scheme.dart';

class GovtSchemesProvider extends ChangeNotifier {
  GovtSchemesProvider({GovtSchemesRepository? repository})
      : _repository = repository ?? GovtSchemesRepository() {
    load();
  }

  final GovtSchemesRepository _repository;

  String _searchQuery = '';
  /// Stable English category key; `null` means "All".
  String? _selectedCategoryEn;

  List<GovtScheme> _schemes = const [];
  bool _loading = true;
  Object? _error;

  String get searchQuery => _searchQuery;
  String? get selectedCategoryEn => _selectedCategoryEn;
  bool get isLoading => _loading;
  Object? get error => _error;
  bool get hasError => _error != null;
  List<GovtScheme> get allSchemes => _schemes;

  /// Unique categoryEn keys from loaded schemes (sorted by label order).
  List<String> get categoryKeys {
    final seen = <String>{};
    final keys = <String>[];
    for (final s in _schemes) {
      final key = s.categoryEn.trim();
      if (key.isEmpty || seen.contains(key)) continue;
      seen.add(key);
      keys.add(key);
    }
    keys.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return keys;
  }

  String categoryLabel(String categoryEn, String languageCode) {
    final match = _schemes.where((s) => s.categoryEn == categoryEn);
    if (match.isEmpty) return categoryEn;
    return match.first.category(languageCode);
  }

  /// Banner prefers featured schemes that have an admin-uploaded image,
  /// then any scheme with an image, then featured without an image.
  List<GovtScheme> get bannerSchemes {
    final withImages = _schemes.where((s) => s.hasImage).toList();
    final featuredWithImages =
        withImages.where((s) => s.featured).toList();
    if (featuredWithImages.isNotEmpty) return featuredWithImages;
    if (withImages.isNotEmpty) return withImages.take(6).toList();
    return _schemes.where((s) => s.featured).toList();
  }

  List<GovtScheme> get filteredSchemes {
    final query = _searchQuery.trim().toLowerCase();
    return _schemes.where((scheme) {
      final byCategory = _selectedCategoryEn == null ||
          scheme.categoryEn == _selectedCategoryEn;
      if (!byCategory) return false;
      if (query.isEmpty) return true;
      final haystack = [
        scheme.titleEn,
        scheme.titleUr,
        scheme.descriptionEn,
        scheme.descriptionUr,
        scheme.categoryEn,
        scheme.categoryUr,
        scheme.departmentEn,
        scheme.departmentUr,
        scheme.province,
        ...scheme.eligibilityEn,
        ...scheme.eligibilityUr,
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  Future<void> load({bool forceRefresh = false}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _schemes = await _repository.fetchSchemes(forceRefresh: forceRefresh);
      // Drop stale category selection if that category disappeared.
      if (_selectedCategoryEn != null &&
          !categoryKeys.contains(_selectedCategoryEn)) {
        _selectedCategoryEn = null;
      }
    } catch (e) {
      _error = e;
      if (_schemes.isEmpty) {
        // keep empty list
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String value) {
    if (_searchQuery == value) return;
    _searchQuery = value;
    notifyListeners();
  }

  void setCategoryEn(String? categoryEn) {
    if (_selectedCategoryEn == categoryEn) return;
    _selectedCategoryEn = categoryEn;
    notifyListeners();
  }
}
