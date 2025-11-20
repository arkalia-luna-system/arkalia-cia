import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service de gestion des thèmes (clair/sombre)
/// Mode sombre optimisé pour le confort visuel (moins agressif pour les yeux)
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
  /// Mode sombre optimisé avec couleurs douces pour le confort visuel
  static ThemeData getThemeData(String theme, Brightness systemBrightness) {
    final isDark = theme == _darkTheme ||
        (theme == _systemTheme && systemBrightness == Brightness.dark);

    if (isDark) {
      // Mode sombre optimisé - couleurs douces pour les yeux
      return ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        
        // Fond principal : gris foncé doux au lieu de noir pur
        scaffoldBackgroundColor: const Color(0xFF1A1A1A), // Gris très foncé doux
        
        // Fond des cartes : légèrement plus clair que le fond
        cardColor: const Color(0xFF242424), // Gris foncé doux
        
        // Fond des dialogs et surfaces élevées
        dialogBackgroundColor: const Color(0xFF2A2A2A),
        
        // Couleurs primaires moins saturées
        primaryColor: const Color(0xFF64B5F6), // Bleu doux
        primaryColorDark: const Color(0xFF42A5F5),
        primaryColorLight: const Color(0xFF90CAF9),
        
        // ColorScheme personnalisé pour mode sombre doux
        colorScheme: const ColorScheme.dark(
          brightness: Brightness.dark,
          // Fond principal
          surface: Color(0xFF1A1A1A),
          // Surfaces élevées (cartes, dialogs)
          surfaceContainerHighest: Color(0xFF2A2A2A),
          surfaceContainerHigh: Color(0xFF242424),
          surfaceContainer: Color(0xFF1F1F1F),
          // Couleur primaire douce
          primary: Color(0xFF64B5F6),
          onPrimary: Color(0xFF000000),
          // Couleur secondaire douce
          secondary: Color(0xFF81C784),
          onSecondary: Color(0xFF000000),
          // Texte principal : blanc cassé doux
          onSurface: Color(0xFFE0E0E0),
          // Texte secondaire : gris clair doux
          onSurfaceVariant: Color(0xFFB0B0B0),
          // Erreur douce
          error: Color(0xFFE57373),
          onError: Color(0xFF000000),
          // Outline doux
          outline: Color(0xFF4A4A4A),
          outlineVariant: Color(0xFF3A3A3A),
        ),
        
        // AppBar : gris foncé doux au lieu de noir
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF242424),
          foregroundColor: Color(0xFFE0E0E0),
          elevation: 0,
          centerTitle: true,
        ),
        
        // Cartes : fond doux avec bordure subtile
        cardTheme: CardTheme(
          color: const Color(0xFF242424),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Colors.white.withOpacity(0.05),
              width: 1,
            ),
          ),
        ),
        
        // InputDecoration : bordures douces
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF242424),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF64B5F6),
              width: 2,
            ),
          ),
        ),
        
        // Divider : très subtil
        dividerColor: Colors.white.withOpacity(0.08),
        
        // IconTheme : icônes douces
        iconTheme: const IconThemeData(
          color: Color(0xFFB0B0B0),
        ),
        
        // TextTheme : textes avec bonne lisibilité
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: Color(0xFFE0E0E0)),
          displayMedium: TextStyle(color: Color(0xFFE0E0E0)),
          displaySmall: TextStyle(color: Color(0xFFE0E0E0)),
          headlineLarge: TextStyle(color: Color(0xFFE0E0E0)),
          headlineMedium: TextStyle(color: Color(0xFFE0E0E0)),
          headlineSmall: TextStyle(color: Color(0xFFE0E0E0)),
          titleLarge: TextStyle(color: Color(0xFFE0E0E0)),
          titleMedium: TextStyle(color: Color(0xFFE0E0E0)),
          titleSmall: TextStyle(color: Color(0xFFE0E0E0)),
          bodyLarge: TextStyle(color: Color(0xFFE0E0E0)),
          bodyMedium: TextStyle(color: Color(0xFFE0E0E0)),
          bodySmall: TextStyle(color: Color(0xFFB0B0B0)),
          labelLarge: TextStyle(color: Color(0xFFE0E0E0)),
          labelMedium: TextStyle(color: Color(0xFFB0B0B0)),
          labelSmall: TextStyle(color: Color(0xFFB0B0B0)),
        ),
        
        // FloatingActionButton : couleur douce
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF64B5F6),
          foregroundColor: Color(0xFF000000),
        ),
        
        // BottomNavigationBar : fond doux
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF242424),
          selectedItemColor: Color(0xFF64B5F6),
          unselectedItemColor: Color(0xFFB0B0B0),
        ),
        
        // ChipTheme : chips douces
        chipTheme: const ChipThemeData(
          backgroundColor: Color(0xFF2A2A2A),
          labelStyle: TextStyle(color: Color(0xFFE0E0E0)),
          secondaryLabelStyle: TextStyle(color: Color(0xFF000000)),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      );
    } else {
      // Mode clair standard
      return ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      );
    }
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

