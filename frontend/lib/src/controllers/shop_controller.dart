import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/catalog_service.dart';

enum DemoSection { home, catalog, favorites, admin, pos, database }

enum CatalogSort { recommended, newest, priceLow, priceHigh, discount }

class ShopController extends ChangeNotifier {
  ShopController({CatalogService catalogService = const CatalogService()})
      : products = catalogService.loadDemoProducts();

  final List<Product> products;
  final Set<String> favoriteIds = {};
  final Set<String> comparisonIds = {};
  final Set<String> restockAlertIds = {};
  final Set<String> priceAlertIds = {};
  final List<Product> cart = [];
  final List<String> searchHistory = [];
  final List<String> recentIds = [];

  DemoSection section = DemoSection.home;
  String category = 'Todo';
  String query = '';
  String branch = 'Equipetrol';
  Set<String> sizes = {};
  Set<String> colors = {};
  Set<String> materials = {};
  Set<String> fits = {};
  Set<String> styles = {};
  Set<String> occasions = {};
  RangeValues priceRange = const RangeValues(0, 1000);
  bool onlyDiscounts = false;
  bool onlyBranchStock = false;
  bool darkMode = false;
  bool compactGrid = false;
  int displayLimit = 8;
  CatalogSort sort = CatalogSort.recommended;

  static const popularSearches = [
    'Abrigo',
    'Vestido',
    'Blazer',
    'Pantalón wide leg'
  ];
  static const corrections = {
    'abrigoz': 'abrigos',
    'vestidoz': 'vestido',
    'blacer': 'blazer',
    'pantalom': 'pantalón'
  };

  String? get suggestedCorrection => corrections[query.trim().toLowerCase()];

  List<Product> get visibleProducts {
    var result = products.where((product) {
      final normalized = query.trim().toLowerCase();
      final matchesCategory = category == 'Todo' ||
          category == 'Ofertas' && product.oldPrice != null ||
          category == 'Novedades' && product.isNew ||
          category == 'Últimas unidades' && product.hasLowStock ||
          product.category == category ||
          product.occasion == category;
      final matchesQuery = normalized.isEmpty ||
          product.name.toLowerCase().contains(normalized) ||
          product.category.toLowerCase().contains(normalized) ||
          product.id.toLowerCase().contains(normalized) ||
          product.material.toLowerCase().contains(normalized);
      return matchesCategory &&
          matchesQuery &&
          (sizes.isEmpty || sizes.any(product.sizes.contains)) &&
          (colors.isEmpty || colors.contains(product.colorName)) &&
          (materials.isEmpty || materials.contains(product.material)) &&
          (fits.isEmpty || fits.contains(product.fit)) &&
          (styles.isEmpty || styles.contains(product.style)) &&
          (occasions.isEmpty || occasions.contains(product.occasion)) &&
          product.price >= priceRange.start &&
          product.price <= priceRange.end &&
          (!onlyDiscounts || product.oldPrice != null) &&
          (!onlyBranchStock || (product.stockByBranch[branch] ?? 0) > 0);
    }).toList();
    switch (sort) {
      case CatalogSort.recommended:
        result.sort((a, b) => b.popularity.compareTo(a.popularity));
      case CatalogSort.newest:
        result.sort((a, b) => (b.isNew ? 1 : 0).compareTo(a.isNew ? 1 : 0));
      case CatalogSort.priceLow:
        result.sort((a, b) => a.price.compareTo(b.price));
      case CatalogSort.priceHigh:
        result.sort((a, b) => b.price.compareTo(a.price));
      case CatalogSort.discount:
        result.sort((a, b) => b.discount.compareTo(a.discount));
    }
    return result;
  }

  List<Product> get displayedProducts =>
      visibleProducts.take(displayLimit).toList();
  List<Product> get favorites =>
      products.where((p) => favoriteIds.contains(p.id)).toList();
  List<Product> get comparison =>
      products.where((p) => comparisonIds.contains(p.id)).toList();
  List<Product> get recents =>
      recentIds.map((id) => products.firstWhere((p) => p.id == id)).toList();
  int get activeFilterCount =>
      sizes.length +
      colors.length +
      materials.length +
      fits.length +
      styles.length +
      occasions.length +
      (onlyDiscounts ? 1 : 0) +
      (onlyBranchStock ? 1 : 0) +
      (priceRange != const RangeValues(0, 1000) ? 1 : 0);

  void goTo(DemoSection value) {
    section = value;
    notifyListeners();
  }

  void setCategory(String value) {
    category = value;
    displayLimit = 8;
    section = DemoSection.catalog;
    notifyListeners();
  }

  void setBranch(String value) {
    branch = value;
    notifyListeners();
  }

  void toggleTheme() {
    darkMode = !darkMode;
    notifyListeners();
  }

  void toggleGridDensity() {
    compactGrid = !compactGrid;
    notifyListeners();
  }

  void setQuery(String value) {
    query = value.trim();
    if (query.isNotEmpty) {
      searchHistory.remove(query);
      searchHistory.insert(0, query);
      if (searchHistory.length > 5) searchHistory.removeLast();
    }
    displayLimit = 8;
    section = DemoSection.catalog;
    notifyListeners();
  }

  void removeSearchHistory(String value) {
    searchHistory.remove(value);
    notifyListeners();
  }

  void setSort(CatalogSort value) {
    sort = value;
    notifyListeners();
  }

  void setPriceRange(RangeValues value) {
    priceRange = value;
    notifyListeners();
  }

  void setOnlyDiscounts(bool value) {
    onlyDiscounts = value;
    notifyListeners();
  }

  void setOnlyBranchStock(bool value) {
    onlyBranchStock = value;
    notifyListeners();
  }

  void toggleSetValue(Set<String> target, String value) {
    target.contains(value) ? target.remove(value) : target.add(value);
    notifyListeners();
  }

  void clearFilters() {
    sizes.clear();
    colors.clear();
    materials.clear();
    fits.clear();
    styles.clear();
    occasions.clear();
    priceRange = const RangeValues(0, 1000);
    onlyDiscounts = false;
    onlyBranchStock = false;
    notifyListeners();
  }

  void showMore() {
    displayLimit += 4;
    notifyListeners();
  }

  void toggleFavorite(Product product) {
    favoriteIds.contains(product.id)
        ? favoriteIds.remove(product.id)
        : favoriteIds.add(product.id);
    notifyListeners();
  }

  void toggleCompare(Product product) {
    if (comparisonIds.contains(product.id)) {
      comparisonIds.remove(product.id);
    } else if (comparisonIds.length < 3) {
      comparisonIds.add(product.id);
    }
    notifyListeners();
  }

  void viewProduct(Product product) {
    recentIds.remove(product.id);
    recentIds.insert(0, product.id);
    if (recentIds.length > 4) recentIds.removeLast();
    notifyListeners();
  }

  void toggleRestockAlert(Product product) {
    restockAlertIds.contains(product.id)
        ? restockAlertIds.remove(product.id)
        : restockAlertIds.add(product.id);
    notifyListeners();
  }

  void togglePriceAlert(Product product) {
    priceAlertIds.contains(product.id)
        ? priceAlertIds.remove(product.id)
        : priceAlertIds.add(product.id);
    notifyListeners();
  }

  void addToCart(Product product) {
    cart.add(product);
    notifyListeners();
  }

  void removeFromCart(Product product) {
    cart.remove(product);
    notifyListeners();
  }
}

class ShopScope extends InheritedNotifier<ShopController> {
  const ShopScope(
      {super.key, required ShopController controller, required super.child})
      : super(notifier: controller);
  static ShopController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ShopScope>();
    assert(scope != null, 'ShopScope no encontrado en el árbol.');
    return scope!.notifier!;
  }
}
