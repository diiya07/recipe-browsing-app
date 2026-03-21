import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _filterKey = 'selected_meal_type_filter';
  static const String _themeKey = 'app_theme_mode';

  Future<void> saveSelectedFilter(String filter) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_filterKey, filter);
  }

  Future<String> getSelectedFilter() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_filterKey) ?? 'All';
  }

  Future<void> saveThemeMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
  }

  Future<bool> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false;
  }
}
