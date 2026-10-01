import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/marketplace_image_cache.dart';
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

  List<Product> _products = const [];
  bool _loading = true;
  Object? _error;

  List<Product> get allProducts => _products;
  bool get isLoading => _loading;
  Object? get error => _error;
  bool get hasError => _error != null;
  String get searchQuery => _searchQuery;
  String? get selectedCrop => _selectedCrop;
  String? get selectedCategory => _selectedCategory;
  String? get selectedCompany => _selectedCompany;
  MarketplaceSort get sort => _sort;

  List<String> get crops {
    final seen = <String>{};
    final list = <String>[];
    for (final p in _products) {
      final crop = p.crop.trim();
      if (crop.isEmpty || seen.contains(crop)) continue;
      seen.add(crop);
      list.add(crop);
    }
    list.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return list;
  }

  List<String> get categories {
    final seen = <String>{};
    final list = <String>[];
    for (final p in _products) {
      final category = p.category.trim();
      if (category.isEmpty || seen.contains(category)) continue;
      seen.add(category);
      list.add(category);
    }
    list.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return list;
  }

  List<String> get companies {
    final seen = <String>{};
    final list = <String>[];
    for (final p in _products) {
      final company = p.company.trim();
      if (company.isEmpty || seen.contains(company)) continue;
      seen.add(company);
      list.add(company);
    }
    list.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return list;
  }

  List<Product> get filteredProducts {
    final query = _searchQuery.trim().toLowerCase();
    final filtered = _products.where((product) {
      final byCrop =
          _selectedCrop == null || product.crop == _selectedCrop;
      final byCategory =
          _selectedCategory == null || product.category == _selectedCategory;
      final byCompany =
          _selectedCompany == null || product.company == _selectedCompany;
      if (!byCrop || !byCategory || !byCompany) return false;
      if (query.isEmpty) return true;
      final haystack = [
        product.titleEn,
        product.titleUr,
        product.descriptionEn,
        product.descriptionUr,
        product.company,
        product.crop,
        product.category,
        product.sku,
        ...product.phones,
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();

    switch (_sort) {
      case MarketplaceSort.relevant:
        return filtered;
      case MarketplaceSort.priceLow:
        filtered.sort((a, b) => a.price.compareTo(b.price));
        return filtered;
      case MarketplaceSort.priceHigh:
        filtered.sort((a, b) => b.price.compareTo(a.price));
        return filtered;
      case MarketplaceSort.name:
        filtered.sort(
          (a, b) => a.titleEn.toLowerCase().compareTo(b.titleEn.toLowerCase()),
        );
        return filtered;
    }
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
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final products =
          await _repository.fetchProducts(forceRefresh: forceRefresh);
      _products = products;
      _pruneStaleFilters();
      // Warm image disk cache in the background — don't block UI.
      unawaited(MarketplaceImageCache.prefetchProducts(products));
    } catch (e) {
      _error = e;
      // Keep whatever we already have on screen (including empty).
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

  void setCrop(String? value) {
    if (_selectedCrop == value) return;
    _selectedCrop = value;
    notifyListeners();
  }

  void setCategory(String? value) {
    if (_selectedCategory == value) return;
    _selectedCategory = value;
    notifyListeners();
  }

  void setCompany(String? value) {
    if (_selectedCompany == value) return;
    _selectedCompany = value;
    notifyListeners();
  }

  void setSort(MarketplaceSort value) {
    if (_sort == value) return;
    _sort = value;
    notifyListeners();
  }

  void _pruneStaleFilters() {
    if (_selectedCrop != null && !crops.contains(_selectedCrop)) {
      _selectedCrop = null;
    }
    if (_selectedCategory != null && !categories.contains(_selectedCategory)) {
      _selectedCategory = null;
    }
    if (_selectedCompany != null && !companies.contains(_selectedCompany)) {
      _selectedCompany = null;
    }
  }
}
