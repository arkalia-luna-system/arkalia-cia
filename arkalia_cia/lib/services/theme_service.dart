import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service de gestion des thèmes (clair/sombre)
class ThemeService {
  static const String _themeKey = 'app_theme';
  static const String _lightTheme = 'light';
  static const String _darkTheme = 'dark';
  static const String _systemTheme = 'system';

  /// Récupère le thème actuel
  static Future<String> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey) ?? _systemTheme;
  }

  /// Définit le thème
  static Future<void> setTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, theme);
  }

  /// Récupère le ThemeData selon le thème sélectionné
  static ThemeData getThemeData(String theme, Brightness systemBrightness) {
    final isDark = theme == _darkTheme ||
        (theme == _systemTheme && systemBrightness == Brightness.dark);

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      primarySwatch: Colors.blue,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: isDark ? Brightness.dark : Brightness.light,
      ),
    );
  }

  /// Récupère le thème selon les préférences et le système
  static Future<ThemeMode> getThemeMode() async {
    final theme = await getTheme();
    switch (theme) {
      case _lightTheme:
        return ThemeMode.light;
      case _darkTheme:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}

