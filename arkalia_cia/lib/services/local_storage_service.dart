import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service de stockage local sécurisé pour Arkalia CIA
/// Gère le stockage des documents, rappels et contacts d'urgence
class LocalStorageService {
  /// Initialise le service
  static Future<void> init() async {
    // Initialisation du service
  }

  static const String _documentsKey = 'documents';
  static const String _remindersKey = 'reminders';
  static const String _emergencyContactsKey = 'emergency_contacts';

  /// Sauvegarde un document médical
  static Future<void> saveDocument(Map<String, dynamic> document) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final documentsJson = prefs.getString(_documentsKey) ?? '[]';
      final List<dynamic> documents = json.decode(documentsJson);

      documents.add(document);
      await prefs.setString(_documentsKey, json.encode(documents));
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde du document: $e');
    }
  }

  /// Récupère tous les documents
  static Future<List<Map<String, dynamic>>> getDocuments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final documentsJson = prefs.getString(_documentsKey) ?? '[]';
      final List<dynamic> documents = json.decode(documentsJson);

      return documents.cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des documents: $e');
    }
  }

  /// Sauvegarde un rappel
  static Future<void> saveReminder(Map<String, dynamic> reminder) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final remindersJson = prefs.getString(_remindersKey) ?? '[]';
      final List<dynamic> reminders = json.decode(remindersJson);

      reminders.add(reminder);
      await prefs.setString(_remindersKey, json.encode(reminders));
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde du rappel: $e');
    }
  }

  /// Récupère tous les rappels
  static Future<List<Map<String, dynamic>>> getReminders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final remindersJson = prefs.getString(_remindersKey) ?? '[]';
      final List<dynamic> reminders = json.decode(remindersJson);

      return reminders.cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des rappels: $e');
    }
  }

  /// Sauvegarde un contact d'urgence
  static Future<void> saveEmergencyContact(Map<String, dynamic> contact) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final contactsJson = prefs.getString(_emergencyContactsKey) ?? '[]';
      final List<dynamic> contacts = json.decode(contactsJson);

      contacts.add(contact);
      await prefs.setString(_emergencyContactsKey, json.encode(contacts));
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde du contact: $e');
    }
  }

  /// Récupère tous les contacts d'urgence
  static Future<List<Map<String, dynamic>>> getEmergencyContacts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final contactsJson = prefs.getString(_emergencyContactsKey) ?? '[]';
      final List<dynamic> contacts = json.decode(contactsJson);

      return contacts.cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des contacts: $e');
    }
  }

  /// Supprime un document
  static Future<void> deleteDocument(int documentId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final documentsJson = prefs.getString(_documentsKey) ?? '[]';
      final List<dynamic> documents = json.decode(documentsJson);

      documents.removeWhere((doc) => doc['id'] == documentId);
      await prefs.setString(_documentsKey, json.encode(documents));
    } catch (e) {
      throw Exception('Erreur lors de la suppression du document: $e');
    }
  }

  /// Supprime un rappel
  static Future<void> deleteReminder(int reminderId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final remindersJson = prefs.getString(_remindersKey) ?? '[]';
      final List<dynamic> reminders = json.decode(remindersJson);

      reminders.removeWhere((reminder) => reminder['id'] == reminderId);
      await prefs.setString(_remindersKey, json.encode(reminders));
    } catch (e) {
      throw Exception('Erreur lors de la suppression du rappel: $e');
    }
  }

  /// Supprime un contact d'urgence
  static Future<void> deleteEmergencyContact(int contactId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final contactsJson = prefs.getString(_emergencyContactsKey) ?? '[]';
      final List<dynamic> contacts = json.decode(contactsJson);

      contacts.removeWhere((contact) => contact['id'] == contactId);
      await prefs.setString(_emergencyContactsKey, json.encode(contacts));
    } catch (e) {
      throw Exception('Erreur lors de la suppression du contact: $e');
    }
  }

  /// Récupère les informations d'urgence
  static Future<Map<String, dynamic>?> getEmergencyInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final emergencyJson = prefs.getString('emergency_info');
      if (emergencyJson != null) {
        return json.decode(emergencyJson);
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération des informations d\'urgence: $e');
    }
  }

  /// Sauvegarde les informations d'urgence
  static Future<void> saveEmergencyInfo(Map<String, dynamic> emergencyInfo) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('emergency_info', json.encode(emergencyInfo));
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde des informations d\'urgence: $e');
    }
  }

  /// Vide tout le stockage local
  static Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_documentsKey);
      await prefs.remove(_remindersKey);
      await prefs.remove(_emergencyContactsKey);
    } catch (e) {
      throw Exception('Erreur lors du nettoyage du stockage: $e');
    }
  }
}
