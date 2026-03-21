import 'package:flutter/material.dart';
import '../models/shopping_item.dart';

class ShoppingProvider extends ChangeNotifier {
  final Set<String> _itemKeys = {};
  final List<ShoppingItem> _items = [];

  List<ShoppingItem> get items => List.unmodifiable(_items);

  bool isMarked(int recipeId, String ingredient) {
    final key = '${recipeId}_$ingredient';
    return _itemKeys.contains(key);
  }

  void toggle(int recipeId, String recipeName, String ingredient) {
    final key = '${recipeId}_$ingredient';
    if (_itemKeys.contains(key)) {
      _itemKeys.remove(key);
      _items.removeWhere((i) => i.key == key);
    } else {
      _itemKeys.add(key);
      _items.add(ShoppingItem(
        recipeId: recipeId,
        recipeName: recipeName,
        ingredient: ingredient,
      ));
    }
    notifyListeners();
  }

  void clearAll() {
    _itemKeys.clear();
    _items.clear();
    notifyListeners();
  }

  /// Returns items grouped by recipe name
  Map<String, List<String>> get groupedItems {
    final Map<String, List<String>> grouped = {};
    for (final item in _items) {
      grouped.putIfAbsent(item.recipeName, () => []).add(item.ingredient);
    }
    return grouped;
  }

  int get totalCount => _items.length;
}
