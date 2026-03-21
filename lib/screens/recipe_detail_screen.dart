// recipe_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import '../providers/recipe_provider.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RecipeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(recipe.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe Image with Placeholder
            Image.network(
              recipe.image,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 250,
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image, size: 50),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Chip(label: Text(recipe.difficulty)),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(
                          "${recipe.cookTimeMinutes + recipe.prepTimeMinutes} mins",
                        ),
                      ),
                      const SizedBox(width: 8),
                      Chip(label: Text(recipe.cuisine)),
                    ],
                  ),
                  const Divider(height: 32),
                  Text(
                    "Ingredients",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Text(
                    "Mark what you don't have at home:",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),

                  // Ingredients List
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recipe.ingredients.length,
                    itemBuilder: (context, index) {
                      final ingredient = recipe.ingredients[index];
                      final isAdded = provider.isIngredientInList(
                        recipe.name,
                        ingredient,
                      );

                      return CheckboxListTile(
                        title: Text(ingredient),
                        subtitle: Text(
                          isAdded ? "Added to shopping list" : "I have this",
                        ),
                        value: isAdded,
                        activeColor: Colors.orange,
                        onChanged: (_) =>
                            provider.toggleIngredient(recipe.name, ingredient),
                        secondary: const Icon(Icons.shopping_basket_outlined),
                      );
                    },
                  ),

                  const Divider(height: 32),
                  Text(
                    "Instructions",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  ...recipe.instructions
                      .asMap()
                      .entries
                      .map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 12,
                                child: Text(
                                  "${entry.key + 1}",
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Text(entry.value)),
                            ],
                          ),
                        ),
                      )
                      ,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
