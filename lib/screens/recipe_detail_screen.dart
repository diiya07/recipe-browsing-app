import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../models/recipe.dart';
import '../providers/shopping_list_provider.dart';
import '../utils/constants.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            iconTheme: const IconThemeData(
              color: Colors.white,
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'recipe_image_${recipe.id}',
                    child: CachedNetworkImage(
                      imageUrl: recipe.image,
                      fit: BoxFit.cover,
                      placeholder: (context, url) {
                        final isDark = Theme.of(context).brightness == Brightness.dark;
                        return Shimmer.fromColors(
                          baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                          highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
                          child: Container(color: Colors.white),
                        );
                      },
                      errorWidget: (context, url, err) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                      ),
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black54, Colors.transparent, Colors.black87],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
              title: Text(
                recipe.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black87, blurRadius: 4)],
                ),
              ),
              titlePadding: const EdgeInsets.only(left: 48, bottom: 16, right: 16),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBasicInfo(context),
                  const SizedBox(height: 24),
                  Text('Ingredients', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  _buildIngredientsList(context),
                  const SizedBox(height: 24),
                  Text('Instructions', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  _buildInstructionsList(context),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfo(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildInfoItem(context, Icons.timer, '${recipe.prepTimeMinutes + recipe.cookTimeMinutes}m'),
        _buildInfoItem(context, Icons.local_fire_department, '${recipe.caloriesPerServing} kcal'),
        _buildInfoItem(context, Icons.person, '${recipe.servings} Servings'),
        _buildInfoItem(context, Icons.star, recipe.rating.toString()),
      ],
    );
  }

  Widget _buildInfoItem(BuildContext context, IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildIngredientsList(BuildContext context) {
    return Consumer<ShoppingListProvider>(
      builder: (context, provider, child) {
        return ListView.builder(
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: recipe.ingredients.length,
          itemBuilder: (context, index) {
            final ingredient = recipe.ingredients[index];
            final isMissing = provider.hasIngredient(recipe.id, ingredient);

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isMissing ? AppColors.primary.withValues(alpha: 0.05) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isMissing ? AppColors.primary.withValues(alpha: 0.3) : Colors.grey.shade200,
                ),
              ),
              child: ListTile(
                title: Text(
                  ingredient,
                  style: TextStyle(
                    color: isMissing ? AppColors.primary : AppColors.textDark,
                    fontWeight: isMissing ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                trailing: TextButton.icon(
                  onPressed: () {
                    provider.toggleIngredient(recipe.id, recipe.name, ingredient);
                  },
                  icon: Icon(
                    isMissing ? Icons.remove_circle : Icons.add_circle_outline,
                    color: isMissing ? AppColors.error : AppColors.primary,
                  ),
                  label: Text(
                    isMissing ? 'I have this' : 'I don\'t have this',
                    style: TextStyle(
                      color: isMissing ? AppColors.error : AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInstructionsList(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: recipe.instructions.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.primary,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  recipe.instructions[index],
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
