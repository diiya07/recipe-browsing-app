import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';

class ApiService {
  static const String _baseUrl = 'https://dummyjson.com/recipes';

  Future<List<Recipe>> fetchAllRecipes() async {
    List<Recipe> all = [];
    int skip = 0;
    const int limit = 10;
    const int total = 50;

    while (skip < total) {
      final response = await http.get(
        Uri.parse('$_baseUrl?limit=$limit&skip=$skip'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List recipes = data['recipes'] as List;
        all.addAll(recipes.map((r) => Recipe.fromJson(r)));
        skip += limit;
      } else {
        throw Exception('Failed to load recipes: ${response.statusCode}');
      }
    }
    return all;
  }

  Future<List<Recipe>> fetchByMealType(String mealType) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/meal-type/$mealType'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List recipes = data['recipes'] as List;
      return recipes.map((r) => Recipe.fromJson(r)).toList();
    } else {
      throw Exception('Failed to load recipes for $mealType');
    }
  }

  Future<Recipe> fetchRecipeById(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/$id'));
    if (response.statusCode == 200) {
      return Recipe.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load recipe $id');
    }
  }
}
