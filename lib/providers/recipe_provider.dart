import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class RecipeProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  List<Recipe> _recipes = [];
  bool _isLoading = false;
  bool _isFetchingMore = false;
  String _error = '';
  String _selectedFilter = 'All';
  
  int _skip = 0;
  final int _limit = 10;
  bool _hasMore = true;

  // Getters
  List<Recipe> get recipes => _recipes;
  bool get isLoading => _isLoading;
  bool get isFetchingMore => _isFetchingMore;
  String get error => _error;
  String get selectedFilter => _selectedFilter;
  bool get hasMore => _hasMore;

  RecipeProvider() {
    _init();
  }

  Future<void> _init() async {
    _selectedFilter = await _storageService.getSelectedFilter();
    await fetchRecipes();
  }

  Future<void> fetchRecipes() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      if (_selectedFilter == 'All') {
        _skip = 0;
        final result = await _apiService.fetchRecipes(limit: _limit, skip: _skip);
        _recipes = result['recipes'];
        _hasMore = _skip + _limit < (result['total'] as int);
        if (_skip + _limit >= 50) _hasMore = false; // API max
      } else {
        _recipes = await _apiService.fetchRecipesByMealType(_selectedFilter);
        _hasMore = false; // No pagination for filter
      }
    } catch (e) {
      _error = 'Failed to load recipes. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMoreRecipes() async {
    if (_isFetchingMore || !_hasMore || _selectedFilter != 'All' || _isLoading) return;

    _isFetchingMore = true;
    notifyListeners();

    try {
      _skip += _limit;
      final result = await _apiService.fetchRecipes(limit: _limit, skip: _skip);
      final newRecipes = result['recipes'] as List<Recipe>;
      
      _recipes.addAll(newRecipes);
      _hasMore = _skip + _limit < (result['total'] as int);
      if (_skip + _limit >= 50) _hasMore = false;
    } catch (e) {
      _error = 'Failed to load more recipes.';
    } finally {
      _isFetchingMore = false;
      notifyListeners();
    }
  }

  Future<void> setFilter(String filter) async {
    if (_selectedFilter == filter) return;
    
    _selectedFilter = filter;
    await _storageService.saveSelectedFilter(filter);
    
    await fetchRecipes();
  }
  
  Future<void> refresh() async {
    await fetchRecipes();
  }
}
