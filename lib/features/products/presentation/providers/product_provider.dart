import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';

enum ProductStatus { initial, loading, loaded, error }

enum ProductSortOption {
  defaultSort('Default'),
  priceLowToHigh('Price: Low to High'),
  priceHighToLow('Price: High to Low'),
  ratingHighToLow('Customer Rating: High to Low'),
  nameAZ('Name: A to Z');

  final String label;
  const ProductSortOption(this.label);
}

class ProductProvider extends ChangeNotifier {
  final ProductRepository productRepository;
  final Connectivity connectivity;

  ProductStatus _status = ProductStatus.initial;
  List<ProductEntity> _products = [];
  List<ProductEntity> _filteredProducts = [];
  List<String> _categories = [];
  String? _selectedCategory;
  String _searchQuery = '';
  ProductSortOption _sortOption = ProductSortOption.defaultSort;
  String? _errorMessage;
  bool _isFromCache = false;
  bool _isOffline = false;

  // Detail view state
  ProductEntity? _selectedProduct;
  bool _isLoadingDetails = false;
  String? _detailsErrorMessage;

  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  ProductProvider({
    required this.productRepository,
    required this.connectivity,
  }) {
    _initConnectivity();
  }

  // Getters
  ProductStatus get status => _status;
  List<ProductEntity> get products => (_searchQuery.isNotEmpty || _selectedCategory != null || _sortOption != ProductSortOption.defaultSort)
      ? _filteredProducts
      : _products;
  int get totalProductsCount => _products.length;
  List<String> get categories => _categories;
  String? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  ProductSortOption get sortOption => _sortOption;
  String? get errorMessage => _errorMessage;
  bool get isFromCache => _isFromCache;
  bool get isOffline => _isOffline;
  ProductEntity? get selectedProduct => _selectedProduct;
  bool get isLoadingDetails => _isLoadingDetails;
  String? get detailsErrorMessage => _detailsErrorMessage;
  bool get isLoading => _status == ProductStatus.loading;

  void _initConnectivity() async {
    final result = await connectivity.checkConnectivity();
    _isOffline = result == ConnectivityResult.none;
    notifyListeners();

    _connectivitySubscription = connectivity.onConnectivityChanged.listen((result) {
      final wasOffline = _isOffline;
      _isOffline = result == ConnectivityResult.none;
      AppLogger.i('📡 Network changed: ${result.name} (isOffline: $_isOffline)');
      notifyListeners();

      if (wasOffline && !_isOffline && _products.isNotEmpty) {
        AppLogger.i('🔄 Device back online! Auto-refreshing FakeStore products...');
        fetchProducts(forceRefresh: true);
      }
    });
  }

  /// Fetches products and categories with offline-first strategy.
  Future<void> fetchProducts({bool forceRefresh = false}) async {
    if (_products.isEmpty) {
      _status = ProductStatus.loading;
      _errorMessage = null;
      notifyListeners();
    }

    // Fetch categories in parallel
    _fetchCategories(forceRefresh: forceRefresh);

    final result = await productRepository.getProducts(
      forceRefresh: forceRefresh,
      category: _selectedCategory,
    );

    _products = result.products;
    _isFromCache = result.isFromCache;
    _errorMessage = result.error;
    _status = _products.isNotEmpty
        ? ProductStatus.loaded
        : (_errorMessage != null ? ProductStatus.error : ProductStatus.loaded);

    _applyFilters();
    notifyListeners();
  }

  Future<void> _fetchCategories({bool forceRefresh = false}) async {
    final cats = await productRepository.getCategories(forceRefresh: forceRefresh);
    if (cats.isNotEmpty) {
      _categories = cats;
      notifyListeners();
    }
  }

  /// Selects category filter and re-filters.
  void selectCategory(String? category) {
    if (_selectedCategory == category) {
      _selectedCategory = null;
    } else {
      _selectedCategory = category;
    }
    _applyFilters();
    notifyListeners();
  }

  /// Sets the sort option and applies sorting.
  void setSortOption(ProductSortOption option) {
    _sortOption = option;
    _applyFilters();
    notifyListeners();
  }

  /// Searches products by title or description.
  void search(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    var list = List<ProductEntity>.from(_products);

    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      list = list.where((p) => p.category.toLowerCase() == _selectedCategory!.toLowerCase()).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final queryLower = _searchQuery.toLowerCase();
      list = list.where((p) {
        return p.title.toLowerCase().contains(queryLower) ||
            p.description.toLowerCase().contains(queryLower) ||
            p.category.toLowerCase().contains(queryLower);
      }).toList();
    }

    // Apply sorting
    switch (_sortOption) {
      case ProductSortOption.priceLowToHigh:
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case ProductSortOption.priceHighToLow:
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case ProductSortOption.ratingHighToLow:
        list.sort((a, b) => b.ratingRate.compareTo(a.ratingRate));
        break;
      case ProductSortOption.nameAZ:
        list.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case ProductSortOption.defaultSort:
        // Keep original order
        break;
    }

    _filteredProducts = list;
  }

  /// Fetches details for a single product by ID.
  Future<void> fetchProductDetails(int id, {bool forceRefresh = false}) async {
    _isLoadingDetails = true;
    _detailsErrorMessage = null;
    notifyListeners();

    final result = await productRepository.getProductDetails(id, forceRefresh: forceRefresh);
    _selectedProduct = result.product;
    _detailsErrorMessage = result.error;
    _isLoadingDetails = false;
    notifyListeners();
  }

  /// Clears Hive cache and refreshes state.
  Future<void> clearLocalCache() async {
    await productRepository.clearCache();
    _products = [];
    _filteredProducts = [];
    _categories = [];
    _selectedCategory = null;
    _status = ProductStatus.initial;
    _errorMessage = null;
    notifyListeners();
    AppLogger.w('🗑️ Cleared FakeStore Hive cache.');
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
