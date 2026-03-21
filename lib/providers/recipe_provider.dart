import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe.dart';
import '../services/api_service.dart';

class RecipeProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<Recipe> _recipes = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  String? _selectedMealType;

  static const List<String> mealTypes = [
    'Breakfast', 'Lunch', 'Dinner', 'Snack', 'Appetizer', 'Side Dish', 'Dessert'
  ];
  static const String _prefKey = 'selected_meal_type';

  List<Recipe> get recipes => _recipes;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  String? get selectedMealType => _selectedMealType;

  RecipeProvider() {
    _loadSavedFilter();
  }

  Future<void> _loadSavedFilter() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefKey);
    _selectedMealType = saved;
    await loadRecipes();
  }

  Future<void> _saveFilter(String? mealType) async {
    final prefs = await SharedPreferences.getInstance();
    if (mealType == null) {
      await prefs.remove(_prefKey);
    } else {
      await prefs.setString(_prefKey, mealType);
    }
  }

  Future<void> loadRecipes({bool refresh = false}) async {
    _isLoading = true;
    _hasError = false;
    _recipes = [];
    notifyListeners();

    try {
      if (_selectedMealType == null) {
        _recipes = await _api.fetchAllRecipes();
      } else {
        _recipes = await _api.fetchByMealType(_selectedMealType!);
      }
    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectMealType(String? mealType) async {
    _selectedMealType = mealType;
    await _saveFilter(mealType);
    await loadRecipes();
  }

  Future<Recipe> getRecipeById(int id) async {
    // Check cache first
    final cached = _recipes.where((r) => r.id == id);
    if (cached.isNotEmpty) return cached.first;
    return await _api.fetchRecipeById(id);
  }
}
