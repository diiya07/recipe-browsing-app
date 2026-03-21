import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/recipe_provider.dart';
import 'providers/shopping_provider.dart';
import 'screens/recipe_feed_screen.dart';
import 'utils/app_theme.dart';

void main() {
  runApp(const RecipeApp());
}

class RecipeApp extends StatelessWidget {
  const RecipeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RecipeProvider()),
        ChangeNotifierProvider(create: (_) => ShoppingProvider()),
      ],
      child: MaterialApp(
        title: 'Recipe App',
        theme: AppTheme.theme,
        debugShowCheckedModeBanner: false,
        home: const RecipeFeedScreen(),
      ),
    );
  }
}
