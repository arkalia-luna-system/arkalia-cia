import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tailles de texte disponibles
enum AccessibilityTextSize {
  small(0.85, 'Petit'),
  normal(1.0, 'Normal'),
  large(1.2, 'Grand'),
  extraLarge(1.5, 'Très Grand');

  final double multiplier;
  final String label;
  const AccessibilityTextSize(this.multiplier, this.label);
}

/// Tailles d'icônes disponibles
enum AccessibilityIconSize {
  small(0.85, 'Petit'),
  normal(1.0, 'Normal'),
  large(1.2, 'Grand'),
  extraLarge(1.5, 'Très Grand');

  final double multiplier;
  final String label;
  const AccessibilityIconSize(this.multiplier, this.label);
}

/// Service de gestion de l'accessibilité (taille texte, taille icônes, mode simplifié)
class AccessibilityService {
  static const String _textSizeKey = 'accessibility_text_size';
  static const String _iconSizeKey = 'accessibility_icon_size';
  static const String _simplifiedModeKey = 'accessibility_simplified_mode';

  /// Récupère la taille de texte actuelle
  static Future<AccessibilityTextSize> getTextSize() async {
    final prefs = await SharedPreferences.getInstance();
    final sizeIndex = prefs.getInt(_textSizeKey) ?? 1; // Normal par défaut
    return AccessibilityTextSize.values[sizeIndex.clamp(0, AccessibilityTextSize.values.length - 1)];
  }

  /// Définit la taille de texte
  static Future<void> setTextSize(AccessibilityTextSize size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_textSizeKey, size.index);
  }

  /// Récupère la taille d'icône actuelle
  static Future<AccessibilityIconSize> getIconSize() async {
    final prefs = await SharedPreferences.getInstance();
    final sizeIndex = prefs.getInt(_iconSizeKey) ?? 1; // Normal par défaut
    return AccessibilityIconSize.values[sizeIndex.clamp(0, AccessibilityIconSize.values.length - 1)];
  }

  /// Définit la taille d'icône
  static Future<void> setIconSize(AccessibilityIconSize size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_iconSizeKey, size.index);
  }

  /// Vérifie si le mode simplifié est activé
  static Future<bool> isSimplifiedModeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_simplifiedModeKey) ?? false;
  }

  /// Active ou désactive le mode simplifié
  static Future<void> setSimplifiedMode(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_simplifiedModeKey, enabled);
  }

  /// Retourne le multiplicateur de taille de texte pour le thème
  static Future<double> getTextSizeMultiplier() async {
    final textSize = await getTextSize();
    return textSize.multiplier;
  }

  /// Retourne le multiplicateur de taille d'icône
  static Future<double> getIconSizeMultiplier() async {
    final iconSize = await getIconSize();
    return iconSize.multiplier;
  }

  /// Applique la taille de texte à un TextStyle
  static Future<TextStyle> applyTextSize(TextStyle baseStyle) async {
    final multiplier = await getTextSizeMultiplier();
    return baseStyle.copyWith(
      fontSize: (baseStyle.fontSize ?? 14) * multiplier,
    );
  }

  /// Retourne la taille d'icône standardisée
  static Future<double> getStandardIconSize() async {
    const baseSize = 24.0; // Taille de base
    final multiplier = await getIconSizeMultiplier();
    return baseSize * multiplier;
  }
}

