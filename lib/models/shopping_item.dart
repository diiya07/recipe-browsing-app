class ShoppingItem {
  final int recipeId;
  final String recipeName;
  final String ingredient;

  ShoppingItem({
    required this.recipeId,
    required this.recipeName,
    required this.ingredient,
  });

  String get key => '${recipeId}_$ingredient';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShoppingItem &&
          runtimeType == other.runtimeType &&
          recipeId == other.recipeId &&
          ingredient == other.ingredient;

  @override
  int get hashCode => recipeId.hashCode ^ ingredient.hashCode;
}
