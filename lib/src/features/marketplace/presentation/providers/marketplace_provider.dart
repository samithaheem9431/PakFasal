import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/marketplace_image_cache.dart';
import '../../data/marketplace_labels.dart';
import '../../data/repositories/marketplace_repository.dart';
import '../../domain/entities/product.dart';

enum MarketplaceSort { relevant, priceLow, priceHigh, name }

class MarketplaceProvider extends ChangeNotifier {
  MarketplaceProvider({MarketplaceRepository? repository})
      : _repository = repository ?? MarketplaceRepository() {
    load();
  }

  final MarketplaceRepository _repository;

  final Set<String> _favorites = {};
  String _searchQuery = '';
  String? _selectedCrop;
  String? _selectedCategory;
  String? _selectedCompany;
  MarketplaceSort _sort = MarketplaceSort.relevant;
  int _pageIndex = 0;

  static const int pageSize = 10;

  List<Product> _products = const [];
  bool _loading = true;
  bool _refreshingInBackground = false;
  bool _showingStaleCache = false;
  Object? _error;
  int _loadGeneration = 0;

  List<Product> get allProducts => _products;
  bool get isLoading => _loading;
  bool get isRefreshingInBackground => _refreshingInBackground;
  bool get showingStaleCache => _showingStaleCache;
  Object? get error => _error;
  bool get hasError => _error != null;
  String get searchQuery => _searchQuery;
  String? get selectedCrop => _selectedCrop;
  String? get selectedCategory => _selectedCategory;
  String? get selectedCompany => _selectedCompany;
  MarketplaceSort get sort => _sort;
  int get pageIndex => _pageIndex;
  int get pageNumber => _pageIndex + 1;

  bool get hasActiveFilters =>
      _searchQuery.trim().isNotEmpty ||
      _selectedCrop != null ||
      _selectedCategory != null ||
      _selectedCompany != null ||
      _sort != MarketplaceSort.relevant;

  /// Facet values cascade: only options that still yield results under the
  /// other active filters (and search) are exposed. The currently selected
  /// value is always kept so the chip/dropdown stays consistent.
  List<String> get crops => _facetValues(
        selected: _selectedCrop,
        from: _productsMatching(
          crop: null,
          category: _selectedCategory,
          company: _selectedCompany,
          applySearch: true,
        ).map((p) => p.crop),
      );

  List<String> get categories => _facetValues(
        selected: _selectedCategory,
        from: _productsMatching(
          crop: _selectedCrop,
          category: null,
          company: _selectedCompany,
          applySearch: true,
        ).map((p) => p.category),
      );

  List<String> get companies => _facetValues(
        selected: _selectedCompany,
        from: _productsMatching(
          crop: _selectedCrop,
          category: _selectedCategory,
          company: null,
          applySearch: true,
        ).map((p) => p.company),
      );

  List<Product> get filteredProducts {
    final tokens = _searchTokens(_searchQuery);
    final filtered = _productsMatching(
      crop: _selectedCrop,
      category: _selectedCategory,
      company: _selectedCompany,
      applySearch: true,
    ).toList();

    switch (_sort) {
      case MarketplaceSort.relevant:
        if (tokens.isEmpty) return filtered;
        filtered.sort((a, b) {
          final scoreCmp =
              _relevanceScore(b, tokens).compareTo(_relevanceScore(a, tokens));
          if (scoreCmp != 0) return scoreCmp;
          return a.titleEn.toLowerCase().compareTo(b.titleEn.toLowerCase());
        });
        return filtered;
      case MarketplaceSort.priceLow:
        filtered.sort((a, b) {
          final priceCmp = a.price.compareTo(b.price);
          if (priceCmp != 0) return priceCmp;
          return a.titleEn.toLowerCase().compareTo(b.titleEn.toLowerCase());
        });
        return filtered;
      case MarketplaceSort.priceHigh:
        filtered.sort((a, b) {
          final priceCmp = b.price.compareTo(a.price);
          if (priceCmp != 0) return priceCmp;
          return a.titleEn.toLowerCase().compareTo(b.titleEn.toLowerCase());
        });
        return filtered;
      case MarketplaceSort.name:
        filtered.sort((a, b) {
          final aName = _sortableName(a);
          final bName = _sortableName(b);
          final nameCmp = aName.compareTo(bName);
          if (nameCmp != 0) return nameCmp;
          return a.titleEn.toLowerCase().compareTo(b.titleEn.toLowerCase());
        });
        return filtered;
    }
  }

  int get totalFilteredCount => filteredProducts.length;

  int get totalPages {
    final count = totalFilteredCount;
    if (count <= 0) return 1;
    return ((count - 1) ~/ pageSize) + 1;
  }

  bool get hasPreviousPage => _pageIndex > 0;
  bool get hasNextPage => _pageIndex < totalPages - 1;

  /// Current page slice (max [pageSize] products).
  List<Product> get pagedProducts {
    final all = filteredProducts;
    if (all.isEmpty) return const [];
    final start = (_pageIndex * pageSize).clamp(0, all.length);
    final end = (start + pageSize).clamp(0, all.length);
    return all.sublist(start, end);
  }

  bool isFavorite(String productId) => _favorites.contains(productId);

  void toggleFavorite(String productId) {
    if (_favorites.contains(productId)) {
      _favorites.remove(productId);
    } else {
      _favorites.add(productId);
    }
    notifyListeners();
  }

  Future<void> load({bool forceRefresh = false}) async {
    final generation = ++_loadGeneration;
    final showSpinner = _products.isEmpty || forceRefresh;
    if (showSpinner) {
      _loading = true;
      _error = null;
      notifyListeners();
    }

    try {
      final result =
          await _repository.fetchProducts(forceRefresh: forceRefresh);
      if (generation != _loadGeneration) return;

      _products = result.products;
      _showingStaleCache = result.fromCache && result.isStale;
      _error = null;
      _pruneStaleFilters();
      _clampPage();
      unawaited(MarketplaceImageCache.prefetchProducts(result.products));

      if (result.isStale && !forceRefresh) {
        unawaited(_refreshInBackground());
      } else if (!result.isStale) {
        _showingStaleCache = false;
      }
    } catch (e) {
      if (generation != _loadGeneration) return;
      _error = e;
    } finally {
      if (generation == _loadGeneration) {
        _loading = false;
        notifyListeners();
      }
    }
  }

  Future<void> _refreshInBackground() async {
    if (_refreshingInBackground) return;
    _refreshingInBackground = true;
    notifyListeners();
    final generation = _loadGeneration;
    try {
      final result = await _repository.fetchProducts(forceRefresh: true);
      if (generation != _loadGeneration) return;
      _products = result.products;
      _showingStaleCache = false;
      _error = null;
      _pruneStaleFilters();
      _clampPage();
      unawaited(MarketplaceImageCache.prefetchProducts(result.products));
    } catch (_) {
      // Keep showing the stale cache; pull-to-refresh can retry.
      if (generation == _loadGeneration) {
        _showingStaleCache = true;
      }
    } finally {
      if (generation == _loadGeneration) {
        _refreshingInBackground = false;
        notifyListeners();
      }
    }
  }

  void setSearchQuery(String value) {
    if (_searchQuery == value) return;
    _searchQuery = value;
    _resetPage();
    notifyListeners();
  }

  void setCrop(String? value) {
    final normalized = _normalizeFilter(value);
    if (_selectedCrop == normalized) return;
    _selectedCrop = normalized;
    _resetPage();
    notifyListeners();
  }

  void setCategory(String? value) {
    final normalized = _normalizeFilter(value);
    if (_selectedCategory == normalized) return;
    _selectedCategory = normalized;
    _resetPage();
    notifyListeners();
  }

  void setCompany(String? value) {
    final normalized = _normalizeFilter(value);
    if (_selectedCompany == normalized) return;
    _selectedCompany = normalized;
    _resetPage();
    notifyListeners();
  }

  void setSort(MarketplaceSort value) {
    if (_sort == value) return;
    _sort = value;
    _resetPage();
    notifyListeners();
  }

  void clearFilters() {
    if (!hasActiveFilters && _pageIndex == 0) return;
    _searchQuery = '';
    _selectedCrop = null;
    _selectedCategory = null;
    _selectedCompany = null;
    _sort = MarketplaceSort.relevant;
    _resetPage();
    notifyListeners();
  }

  void nextPage() {
    if (!hasNextPage) return;
    _pageIndex++;
    notifyListeners();
  }

  void previousPage() {
    if (!hasPreviousPage) return;
    _pageIndex--;
    notifyListeners();
  }

  void goToPage(int pageNumber) {
    final index = (pageNumber - 1).clamp(0, totalPages - 1);
    if (_pageIndex == index) return;
    _pageIndex = index;
    notifyListeners();
  }

  void _resetPage() {
    _pageIndex = 0;
  }

  void _clampPage() {
    final maxIndex = totalPages - 1;
    if (_pageIndex > maxIndex) {
      _pageIndex = maxIndex < 0 ? 0 : maxIndex;
    }
  }

  Iterable<Product> _productsMatching({
    required String? crop,
    required String? category,
    required String? company,
    required bool applySearch,
  }) {
    final tokens = applySearch ? _searchTokens(_searchQuery) : const <String>[];
    return _products.where((product) {
      if (!_matchesFilter(product.crop, crop)) return false;
      if (!_matchesFilter(product.category, category)) return false;
      if (!_matchesFilter(product.company, company)) return false;
      if (tokens.isEmpty) return true;
      return _matchesSearch(product, tokens);
    });
  }

  bool _matchesFilter(String productValue, String? selected) {
    if (selected == null) return true;
    return productValue.trim().toLowerCase() == selected.trim().toLowerCase();
  }

  bool _matchesSearch(Product product, List<String> tokens) {
    final haystack = [
      product.titleEn,
      product.titleUr,
      product.descriptionEn,
      product.descriptionUr,
      product.company,
      product.crop,
      product.category,
      product.sku,
      MarketplaceLabels.crop(product.crop, 'en'),
      MarketplaceLabels.crop(product.crop, 'ur'),
      MarketplaceLabels.category(product.category, 'en'),
      MarketplaceLabels.category(product.category, 'ur'),
      ...product.phones,
    ].join(' ').toLowerCase();
    return tokens.every(haystack.contains);
  }

  int _relevanceScore(Product product, List<String> tokens) {
    if (tokens.isEmpty) return 0;
    final title = '${product.titleEn} ${product.titleUr}'.toLowerCase();
    final company = product.company.toLowerCase();
    final sku = product.sku.toLowerCase();
    final crop = [
      product.crop,
      MarketplaceLabels.crop(product.crop, 'en'),
      MarketplaceLabels.crop(product.crop, 'ur'),
    ].join(' ').toLowerCase();
    final category = [
      product.category,
      MarketplaceLabels.category(product.category, 'en'),
      MarketplaceLabels.category(product.category, 'ur'),
    ].join(' ').toLowerCase();

    var score = 0;
    for (final token in tokens) {
      if (title == token) {
        score += 120;
      } else if (title.startsWith(token)) {
        score += 90;
      } else if (title.contains(token)) {
        score += 60;
      }
      if (sku == token || sku.contains(token)) score += 40;
      if (company.contains(token)) score += 25;
      if (crop.contains(token)) score += 15;
      if (category.contains(token)) score += 15;
    }
    return score;
  }

  String _sortableName(Product product) {
    final en = product.titleEn.trim().toLowerCase();
    final ur = product.titleUr.trim().toLowerCase();
    if (en.isNotEmpty) return en;
    return ur;
  }

  List<String> _searchTokens(String query) {
    return query
        .trim()
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .toList(growable: false);
  }

  String? _normalizeFilter(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  List<String> _facetValues({
    required String? selected,
    required Iterable<String> from,
  }) {
    final list = _uniqueSorted(from);
    if (selected == null) return list;
    final key = selected.toLowerCase();
    if (list.any((v) => v.toLowerCase() == key)) return list;
    list.add(selected);
    list.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return list;
  }

  List<String> _uniqueSorted(Iterable<String> values) {
    final seen = <String>{};
    final list = <String>[];
    for (final raw in values) {
      final value = raw.trim();
      if (value.isEmpty) continue;
      final key = value.toLowerCase();
      if (seen.contains(key)) continue;
      seen.add(key);
      list.add(value);
    }
    list.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return list;
  }

  void _pruneStaleFilters() {
    final cropKeys = _uniqueSorted(_products.map((p) => p.crop))
        .map((c) => c.toLowerCase())
        .toSet();
    final categoryKeys = _uniqueSorted(_products.map((p) => p.category))
        .map((c) => c.toLowerCase())
        .toSet();
    final companyKeys = _uniqueSorted(_products.map((p) => p.company))
        .map((c) => c.toLowerCase())
        .toSet();

    if (_selectedCrop != null &&
        !cropKeys.contains(_selectedCrop!.toLowerCase())) {
      _selectedCrop = null;
    }
    if (_selectedCategory != null &&
        !categoryKeys.contains(_selectedCategory!.toLowerCase())) {
      _selectedCategory = null;
    }
    if (_selectedCompany != null &&
        !companyKeys.contains(_selectedCompany!.toLowerCase())) {
      _selectedCompany = null;
    }
  }
}
