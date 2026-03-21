import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFFF6D00); // Deep Orange
  static const Color primaryLight = Color(0xFFFF9E40);
  static const Color background = Color(0xFFF8F9FA); // Off-white
  static const Color cardColor = Colors.white;
  static const Color textDark = Color(0xFF2D3142);
  static const Color textLight = Color(0xFF9095A0);
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
}

class AppConstants {
  static const String baseUrl = 'https://dummyjson.com/recipes';
  static const List<String> mealTypes = [
    'All',
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snack',
    'Appetizer',
    'Side Dish',
    'Dessert',
  ];
}
