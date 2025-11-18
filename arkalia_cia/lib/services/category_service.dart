import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Service de gestion des catégories de documents
class CategoryService {
  static const String _categoriesKey = 'document_categories';
  static const List<String> _defaultCategories = [
    'Médical',
    'Administratif',
    'Autre',
  ];

  /// Récupère toutes les catégories (défaut + personnalisées)
  static Future<List<String>> getCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final customCategoriesJson = prefs.getString(_categoriesKey);
    
    if (customCategoriesJson == null) {
      return List<String>.from(_defaultCategories);
    }
    
    try {
      final customCategories = List<String>.from(jsonDecode(customCategoriesJson));
      // Fusionner les catégories par défaut avec les personnalisées
      final allCategories = List<String>.from(_defaultCategories);
      for (final category in customCategories) {
        if (!allCategories.contains(category)) {
          allCategories.add(category);
        }
      }
      return allCategories;
    } catch (e) {
      return List<String>.from(_defaultCategories);
    }
  }

  /// Ajoute une catégorie personnalisée
  static Future<bool> addCategory(String category) async {
    if (category.trim().isEmpty) return false;
    if (_defaultCategories.contains(category)) return false; // Ne pas ajouter les défaut
    
    final categories = await getCategories();
    if (categories.contains(category)) return false; // Déjà existante
    
    final prefs = await SharedPreferences.getInstance();
    final customCategories = categories.where((c) => !_defaultCategories.contains(c)).toList();
    customCategories.add(category);
    
    await prefs.setString(_categoriesKey, jsonEncode(customCategories));
    return true;
  }

  /// Supprime une catégorie personnalisée
  static Future<bool> deleteCategory(String category) async {
    if (_defaultCategories.contains(category)) return false; // Ne pas supprimer les défaut
    
    final prefs = await SharedPreferences.getInstance();
    final customCategoriesJson = prefs.getString(_categoriesKey);
    
    if (customCategoriesJson == null) return false;
    
    try {
      final customCategories = List<String>.from(jsonDecode(customCategoriesJson));
      customCategories.remove(category);
      await prefs.setString(_categoriesKey, jsonEncode(customCategories));
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Vérifie si une catégorie existe
  static Future<bool> categoryExists(String category) async {
    final categories = await getCategories();
    return categories.contains(category);
  }
}

