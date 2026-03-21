// recipe_feed_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import '../widgets/recipe_card.dart';
import 'shopping_list_screen.dart';

class RecipeFeedScreen extends StatefulWidget {
  const RecipeFeedScreen({super.key});

  @override
  _RecipeFeedScreenState createState() => _RecipeFeedScreenState();
}

class _RecipeFeedScreenState extends State<RecipeFeedScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<String> categories = [
    'All',
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snack',
    'Dessert',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        Provider.of<RecipeProvider>(context, listen: false).fetchRecipes();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RecipeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Recipe Explorer"),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ShoppingListScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: categories
                  .map(
                    (cat) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: provider.selectedFilter == cat,
                        onSelected: (_) => provider.setFilter(cat),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          Expanded(
            child: provider.error != null && provider.recipes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(provider.error!),
                        ElevatedButton(
                          onPressed: () =>
                              provider.fetchRecipes(isRefresh: true),
                          child: Text("Retry"),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => provider.fetchRecipes(isRefresh: true),
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount:
                          provider.recipes.length +
                          (provider.isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < provider.recipes.length) {
                          return RecipeCard(recipe: provider.recipes[index]);
                        }
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
