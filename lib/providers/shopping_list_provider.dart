import 'package:flutter/material.dart';
import '../models/shopping_list_item.dart';

class ShoppingListProvider with ChangeNotifier {
  final List<ShoppingListItem> _items = [];

  List<ShoppingListItem> get items => _items;

  bool hasIngredient(int recipeId, String ingredient) {
    return _items.any((item) => item.recipeId == recipeId && item.ingredient == ingredient);
  }

  void toggleIngredient(int recipeId, String recipeName, String ingredient) {
    if (hasIngredient(recipeId, ingredient)) {
      _items.removeWhere((item) => item.recipeId == recipeId && item.ingredient == ingredient);
    } else {
      _items.add(ShoppingListItem(
        recipeId: recipeId,
        recipeName: recipeName,
        ingredient: ingredient,
      ));
    }
    notifyListeners();
  }

  void clearList() {
    _items.clear();
    notifyListeners();
  }
}
