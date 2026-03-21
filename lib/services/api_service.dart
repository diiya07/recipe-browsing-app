import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';
import '../utils/constants.dart';

class ApiService {
  Future<Map<String, dynamic>> fetchRecipes({int limit = 10, int skip = 0}) async {
    final url = Uri.parse('${AppConstants.baseUrl}?limit=$limit&skip=$skip');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List<dynamic> recipesJson = decoded['recipes'];
      final recipes = recipesJson.map((json) => Recipe.fromJson(json)).toList();
      return {
        'recipes': recipes,
        'total': decoded['total'],
      };
    } else {
      throw Exception('Failed to load recipes');
    }
  }

  Future<List<Recipe>> fetchRecipesByMealType(String type) async {
    final url = Uri.parse('${AppConstants.baseUrl}/meal-type/$type');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List<dynamic> recipesJson = decoded['recipes'];
      return recipesJson.map((json) => Recipe.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load recipes by meal type: $type');
    }
  }

  Future<Recipe> fetchRecipeById(int id) async {
    final url = Uri.parse('${AppConstants.baseUrl}/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return Recipe.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load recipe with id: $id');
    }
  }
}
