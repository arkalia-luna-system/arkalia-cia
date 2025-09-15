import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Utilitaire pour gérer le stockage local sans duplication de code
class StorageHelper {
  /// Pattern générique pour sauvegarder une liste d'éléments
  static Future<void> saveList(String key, List<Map<String, dynamic>> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, json.encode(items));
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde ($key): $e');
    }
  }

  /// Pattern générique pour récupérer une liste d'éléments
  static Future<List<Map<String, dynamic>>> getList(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(key) ?? '[]';
      final List<dynamic> items = json.decode(jsonString);
      return items.cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Erreur lors de la récupération ($key): $e');
    }
  }

  /// Pattern générique pour ajouter un élément à une liste
  static Future<void> addToList(String key, Map<String, dynamic> item) async {
    try {
      final items = await getList(key);

      // Générer un ID unique si pas présent
      if (!item.containsKey('id')) {
        item['id'] = DateTime.now().millisecondsSinceEpoch.toString();
      }

      items.add(item);
      await saveList(key, items);
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout ($key): $e');
    }
  }

  /// Pattern générique pour mettre à jour un élément dans une liste
  static Future<void> updateInList(String key, Map<String, dynamic> updatedItem) async {
    try {
      final items = await getList(key);
      final id = updatedItem['id'];

      if (id == null) {
        throw Exception('ID manquant pour la mise à jour');
      }

      final index = items.indexWhere((item) => item['id'] == id);
      if (index == -1) {
        throw Exception('Élément non trouvé pour la mise à jour');
      }

      items[index] = updatedItem;
      await saveList(key, items);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour ($key): $e');
    }
  }

  /// Pattern générique pour supprimer un élément d'une liste
  static Future<void> removeFromList(String key, String id) async {
    try {
      final items = await getList(key);
      items.removeWhere((item) => item['id'] == id);
      await saveList(key, items);
    } catch (e) {
      throw Exception('Erreur lors de la suppression ($key): $e');
    }
  }

  /// Pattern générique pour sauvegarder un objet simple
  static Future<void> saveObject(String key, Map<String, dynamic> object) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, json.encode(object));
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde de l\'objet ($key): $e');
    }
  }

  /// Pattern générique pour récupérer un objet simple
  static Future<Map<String, dynamic>?> getObject(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(key);

      if (jsonString == null || jsonString.isEmpty) {
        return null;
      }

      return Map<String, dynamic>.from(json.decode(jsonString));
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'objet ($key): $e');
    }
  }

  /// Nettoie toutes les données d'un type
  static Future<void> clearData(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    } catch (e) {
      throw Exception('Erreur lors du nettoyage ($key): $e');
    }
  }

  /// Vérifie si des données existent pour une clé
  static Future<bool> hasData(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(key);
    } catch (e) {
      return false;
    }
  }
}
