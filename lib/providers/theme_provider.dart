import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    loadTheme();
  }

  Future<void> loadTheme() async {
    final preferences = await SharedPreferences.getInstance();
    final theme = preferences.getString(_themeKey);

    switch (theme) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      default:
        _themeMode = ThemeMode.system;
    }

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;

    final preferences = await SharedPreferences.getInstance();

    switch (mode) {
      case ThemeMode.light:
        await preferences.setString(_themeKey, 'light');
        break;
      case ThemeMode.dark:
        await preferences.setString(_themeKey, 'dark');
        break;
      case ThemeMode.system:
        await preferences.setString(_themeKey, 'system');
        break;
    }

    notifyListeners();
  }
}
