import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/recipe_provider.dart';
import 'screens/recipe_feed_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(create: (_) => RecipeProvider(), child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Recipe App',
      theme: ThemeData(primarySwatch: Colors.orange, useMaterial3: true),
      home: RecipeFeedScreen(),
    );
  }
}
