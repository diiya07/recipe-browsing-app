import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class ThemeProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _init();
  }

  Future<void> _init() async {
    _isDarkMode = await _storageService.getThemeMode();
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _storageService.saveThemeMode(_isDarkMode);
    notifyListeners();
  }
}
