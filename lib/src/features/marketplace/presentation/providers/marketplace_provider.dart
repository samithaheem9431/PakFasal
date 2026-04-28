import 'package:flutter/material.dart';

import '../../data/mock/mock_products.dart';
import '../../domain/entities/product.dart';

class MarketplaceProvider extends ChangeNotifier {
  final Set<String> _favorites = {};
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedCompany = 'All';
  final bool _isOffline = true;

  List<Product> get allProducts => mockProducts;

  bool get isOffline => _isOffline;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  String get selectedCompany => _selectedCompany;

  List<String> get categories => ['All', 'Seeds', 'Fertilizers', 'Pesticides'];

  List<String> get companies {
    final list = allProducts.map((e) => e.companyName).toSet().toList()..sort();
    return ['All', ...list];
  }

  List<Product> get filteredProducts {
    return allProducts.where((product) {
      final bySearch = product.name.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      final byCategory =
          _selectedCategory == 'All' || product.category == _selectedCategory;
      final byCompany =
          _selectedCompany == 'All' || product.companyName == _selectedCompany;
      return bySearch && byCategory && byCompany;
    }).toList();
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

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void setCategory(String value) {
    _selectedCategory = value;
    notifyListeners();
  }

  void setCompany(String value) {
    _selectedCompany = value;
    notifyListeners();
  }
}
