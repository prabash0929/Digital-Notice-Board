import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeViewModel extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  
  ThemeMode get themeMode => _themeMode;

  ThemeViewModel() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode');
    if (isDark != null) {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
    }
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    if (_themeMode == ThemeMode.dark || _themeMode == ThemeMode.system) {
      _themeMode = ThemeMode.light;
      await prefs.setBool('isDarkMode', false);
    } else {
      _themeMode = ThemeMode.dark;
      await prefs.setBool('isDarkMode', true);
    }
    notifyListeners();
  }
}
