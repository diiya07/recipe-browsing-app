import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/recipe_card.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/filter_chips.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import 'recipe_detail_screen.dart';
import 'shopping_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<RecipeProvider>().fetchMoreRecipes();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipes'),
        actions: [
          IconButton(
            icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              themeProvider.toggleTheme();
            },
            tooltip: 'Toggle Theme',
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ShoppingListScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<RecipeProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              FilterChips(
                selectedFilter: provider.selectedFilter,
                onFilterSelected: (filter) {
                  provider.setFilter(filter);
                  _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                },
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: provider.refresh,
                  child: _buildBody(provider),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(RecipeProvider provider) {
    if (provider.isLoading && provider.recipes.isEmpty) {
      return const ShimmerRecipeList();
    }

    if (provider.error.isNotEmpty && provider.recipes.isEmpty) {
      return ErrorState(
        message: provider.error,
        onRetry: provider.refresh,
      );
    }

    if (provider.recipes.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: constraints.maxHeight,
              child: const EmptyState(
                title: 'No Recipes Found',
                message: 'We could not find any recipes for this category.',
                icon: Icons.search_off,
              ),
            ),
          );
        }
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;

        if (isWide) {
          int crossAxisCount = constraints.maxWidth > 900 ? 3 : 2;
          
          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    mainAxisExtent: 390, // Fixed height for recipe cards
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final recipe = provider.recipes[index];
                      return RecipeCard(
                        recipe: recipe,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe)),
                          );
                        },
                      );
                    },
                    childCount: provider.recipes.length,
                  ),
                ),
              ),
              if (provider.isFetchingMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          );
        } else {
          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: provider.recipes.length + (provider.isFetchingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == provider.recipes.length) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final recipe = provider.recipes[index];
              return RecipeCard(
                recipe: recipe,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe)),
                  );
                },
              );
            },
          );
        }
      },
    );
  }
}
