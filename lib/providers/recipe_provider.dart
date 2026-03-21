// recipe_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe.dart';

class RecipeProvider with ChangeNotifier {
  List<Recipe> _recipes = [];
  bool _isLoading = false;
  String? _error;
  String _selectedFilter = 'All';
  int _skip = 0;
  bool _hasMore = true;

  // Shopping List: Key is "RecipeName", Value is List of Ingredients
  final Map<String, List<String>> _shoppingList = {};

  List<Recipe> get recipes => _recipes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedFilter => _selectedFilter;
  Map<String, List<String>> get shoppingList => _shoppingList;

  RecipeProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedFilter = prefs.getString('last_filter') ?? 'All';
    fetchRecipes(isRefresh: true);
  }

  Future<void> setFilter(String filter) async {
    _selectedFilter = filter;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_filter', filter);
    fetchRecipes(isRefresh: true);
  }

  Future<void> fetchRecipes({bool isRefresh = false}) async {
    if (isRefresh) {
      _skip = 0;
      _recipes = [];
      _hasMore = true;
    }
    if (!_hasMore || _isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String url = _selectedFilter == 'All'
          ? 'https://dummyjson.com/recipes?limit=10&skip=$_skip'
          : 'https://dummyjson.com/recipes/meal-type/$_selectedFilter';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List newRecipes = data['recipes'];

        _recipes.addAll(
          newRecipes.map((json) => Recipe.fromJson(json)).toList(),
        );
        _skip += 10;
        if (_skip >= 50 || _selectedFilter != 'All') _hasMore = false;
      } else {
        _error = "Failed to load recipes";
      }
    } catch (e) {
      _error = "Connection Error. Please try again.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleIngredient(String recipeName, String ingredient) {
    if (!_shoppingList.containsKey(recipeName)) {
      _shoppingList[recipeName] = [];
    }

    if (_shoppingList[recipeName]!.contains(ingredient)) {
      _shoppingList[recipeName]!.remove(ingredient);
      if (_shoppingList[recipeName]!.isEmpty) _shoppingList.remove(recipeName);
    } else {
      _shoppingList[recipeName]!.add(ingredient);
    }
    notifyListeners();
  }

  void clearShoppingList() {
    _shoppingList.clear();
    notifyListeners();
  }

  bool isIngredientInList(String recipeName, String ingredient) {
    return _shoppingList[recipeName]?.contains(ingredient) ?? false;
  }
}
