import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import '../providers/shopping_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/recipe_card.dart';
import '../widgets/shimmer_card.dart';
import '../widgets/error_view.dart';
import '../widgets/empty_state.dart';
import 'recipe_detail_screen.dart';
import 'shopping_list_screen.dart';

class RecipeFeedScreen extends StatelessWidget {
  const RecipeFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Consumer<RecipeProvider>(
          builder: (context, provider, _) {
            return RefreshIndicator(
              color: AppTheme.primary,
              onRefresh: () => provider.loadRecipes(refresh: true),
              child: CustomScrollView(
                slivers: [
                  // App Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 16, 0),
                      child: Row(
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Discover',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textDark,
                                  letterSpacing: -1,
                                ),
                              ),
                              Text(
                                'Find your next favourite recipe',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textLight,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Consumer<ShoppingProvider>(
                            builder: (ctx, shopping, _) => Stack(
                              children: [
                                IconButton(
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ShoppingListScreen(),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.shopping_basket_outlined,
                                    color: AppTheme.textDark,
                                    size: 26,
                                  ),
                                ),
                                if (shopping.totalCount > 0)
                                  Positioned(
                                    right: 6,
                                    top: 6,
                                    child: Container(
                                      width: 16,
                                      height: 16,
                                      decoration: const BoxDecoration(
                                        color: AppTheme.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          shopping.totalCount > 99
                                              ? '99+'
                                              : '${shopping.totalCount}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Filter chips
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 8),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            _FilterChip(
                              label: 'All',
                              selected: provider.selectedMealType == null,
                              onTap: () => provider.selectMealType(null),
                            ),
                            const SizedBox(width: 8),
                            ...RecipeProvider.mealTypes.map(
                              (type) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: _FilterChip(
                                  label: type,
                                  selected: provider.selectedMealType == type,
                                  onTap: () => provider.selectMealType(type),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Content
                  if (provider.isLoading)
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, __) => const ShimmerCard(),
                        childCount: 5,
                      ),
                    )
                  else if (provider.hasError)
                    SliverFillRemaining(
                      child: ErrorView(
                        message: provider.errorMessage,
                        onRetry: () => provider.loadRecipes(),
                      ),
                    )
                  else if (provider.recipes.isEmpty)
                    SliverFillRemaining(
                      child: EmptyState(
                        icon: Icons.no_meals_outlined,
                        title: 'No recipes found',
                        subtitle:
                            'We couldn\'t find any recipes for this category.\nTry selecting a different filter.',
                        action: TextButton(
                          onPressed: () => provider.selectMealType(null),
                          child: const Text(
                            'Show all recipes',
                            style: TextStyle(color: AppTheme.primary),
                          ),
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final recipe = provider.recipes[index];
                          return RecipeCard(
                            recipe: recipe,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    RecipeDetailScreen(recipeId: recipe.id),
                              ),
                            ),
                          );
                        },
                        childCount: provider.recipes.length,
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : const Color(0xFFEFEBE5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppTheme.textMedium,
          ),
        ),
      ),
    );
  }
}
