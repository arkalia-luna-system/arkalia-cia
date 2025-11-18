import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'encryption_helper.dart';

/// Utilitaire pour gérer le stockage local avec chiffrement AES-256
class StorageHelper {
  static const bool _useEncryption = true; // Activer le chiffrement

  /// Pattern générique pour sauvegarder une liste d'éléments (chiffrée)
  static Future<void> saveList(String key, List<Map<String, dynamic>> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (_useEncryption) {
        // Chiffrer les données avant stockage
        final jsonString = json.encode(items);
        final encrypted = await EncryptionHelper.encryptString(jsonString);
        final hash = EncryptionHelper.generateHash(jsonString);
        
        await prefs.setString(key, encrypted);
        await prefs.setString('${key}_hash', hash); // Hash pour vérification intégrité
      } else {
        await prefs.setString(key, json.encode(items));
      }
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde ($key): $e');
    }
  }

  /// Pattern générique pour récupérer une liste d'éléments (déchiffrée)
  static Future<List<Map<String, dynamic>>> getList(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encryptedData = prefs.getString(key);
      
      if (encryptedData == null || encryptedData.isEmpty) {
        return [];
      }

      if (_useEncryption) {
        try {
          // Déchiffrer les données
          final jsonString = await EncryptionHelper.decryptString(encryptedData);
          
          // Vérifier l'intégrité
          final storedHash = prefs.getString('${key}_hash');
          if (storedHash != null) {
            final computedHash = EncryptionHelper.generateHash(jsonString);
            if (storedHash != computedHash) {
              // Données corrompues, nettoyer et retourner liste vide
              await prefs.remove(key);
              await prefs.remove('${key}_hash');
              return [];
            }
          }
          
          final List<dynamic> items = json.decode(jsonString);
          return items.cast<Map<String, dynamic>>();
        } catch (decryptError) {
          // Si le déchiffrement échoue, les données peuvent être corrompues
          // Nettoyer et retourner une liste vide plutôt que de planter
          try {
            await prefs.remove(key);
            await prefs.remove('${key}_hash');
          } catch (_) {
            // Ignorer les erreurs de nettoyage
          }
          return [];
        }
      } else {
        try {
          final List<dynamic> items = json.decode(encryptedData);
          return items.cast<Map<String, dynamic>>();
        } catch (jsonError) {
          // Données JSON invalides, nettoyer et retourner liste vide
          try {
            await prefs.remove(key);
          } catch (_) {
            // Ignorer les erreurs de nettoyage
          }
          return [];
        }
      }
    } catch (e) {
      // En cas d'erreur générale, retourner une liste vide plutôt que de planter
      return [];
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

  /// Pattern générique pour sauvegarder un objet simple (chiffré)
  static Future<void> saveObject(String key, Map<String, dynamic> object) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (_useEncryption) {
        final encrypted = await EncryptionHelper.encryptMap(object);
        final jsonString = json.encode(object);
        final hash = EncryptionHelper.generateHash(jsonString);
        
        await prefs.setString(key, encrypted);
        await prefs.setString('${key}_hash', hash);
      } else {
        await prefs.setString(key, json.encode(object));
      }
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde de l\'objet ($key): $e');
    }
  }

  /// Pattern générique pour récupérer un objet simple (déchiffré)
  static Future<Map<String, dynamic>?> getObject(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encryptedData = prefs.getString(key);

      if (encryptedData == null || encryptedData.isEmpty) {
        return null;
      }

      if (_useEncryption) {
        try {
          final decrypted = await EncryptionHelper.decryptMap(encryptedData);
          
          // Vérifier l'intégrité
          final storedHash = prefs.getString('${key}_hash');
          if (storedHash != null) {
            final jsonString = json.encode(decrypted);
            final computedHash = EncryptionHelper.generateHash(jsonString);
            if (storedHash != computedHash) {
              // Données corrompues, nettoyer et retourner null
              await prefs.remove(key);
              await prefs.remove('${key}_hash');
              return null;
            }
          }
          
          return decrypted;
        } catch (decryptError) {
          // Si le déchiffrement échoue, les données peuvent être corrompues
          // Nettoyer et retourner null plutôt que de planter
          try {
            await prefs.remove(key);
            await prefs.remove('${key}_hash');
          } catch (_) {
            // Ignorer les erreurs de nettoyage
          }
          return null;
        }
      } else {
        try {
          return Map<String, dynamic>.from(json.decode(encryptedData));
        } catch (jsonError) {
          // Données JSON invalides, nettoyer et retourner null
          try {
            await prefs.remove(key);
          } catch (_) {
            // Ignorer les erreurs de nettoyage
          }
          return null;
        }
      }
    } catch (e) {
      // En cas d'erreur générale, retourner null plutôt que de planter
      return null;
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
