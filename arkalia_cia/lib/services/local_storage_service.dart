import '../utils/storage_helper.dart';

/// Service de stockage local sécurisé pour Arkalia CIA
/// Gère le stockage des documents, rappels et contacts d'urgence
/// Version refactorisée sans duplication de code
class LocalStorageService {
  // Clés de stockage
  static const String _documentsKey = 'documents';
  static const String _remindersKey = 'reminders';
  static const String _emergencyContactsKey = 'emergency_contacts';
  static const String _emergencyInfoKey = 'emergency_info';

  /// Initialise le service
  static Future<void> init() async {
    // Initialisation du service si nécessaire
  }

  // === DOCUMENTS ===

  /// Sauvegarde un document médical
  static Future<void> saveDocument(Map<String, dynamic> document) =>
      StorageHelper.addToList(_documentsKey, document);

  /// Récupère tous les documents
  static Future<List<Map<String, dynamic>>> getDocuments() =>
      StorageHelper.getList(_documentsKey);

  /// Met à jour un document
  static Future<void> updateDocument(Map<String, dynamic> document) =>
      StorageHelper.updateInList(_documentsKey, document);

  /// Supprime un document
  static Future<void> deleteDocument(String documentId) =>
      StorageHelper.removeFromList(_documentsKey, documentId);

  // === RAPPELS ===

  /// Sauvegarde un rappel
  static Future<void> saveReminder(Map<String, dynamic> reminder) =>
      StorageHelper.addToList(_remindersKey, reminder);

  /// Récupère tous les rappels
  static Future<List<Map<String, dynamic>>> getReminders() =>
      StorageHelper.getList(_remindersKey);

  /// Met à jour un rappel
  static Future<void> updateReminder(Map<String, dynamic> reminder) =>
      StorageHelper.updateInList(_remindersKey, reminder);

  /// Supprime un rappel
  static Future<void> deleteReminder(String reminderId) =>
      StorageHelper.removeFromList(_remindersKey, reminderId);

  /// Marque un rappel comme terminé
  static Future<void> markReminderComplete(String reminderId) async {
    final reminders = await getReminders();
    final reminderIndex = reminders.indexWhere((r) => r['id'] == reminderId);

    if (reminderIndex != -1) {
      final reminder = reminders[reminderIndex];
      reminder['is_completed'] = true;
      reminder['completed_at'] = DateTime.now().toIso8601String();
      await updateReminder(reminder);
    }
  }

  // === CONTACTS D'URGENCE ===

  /// Sauvegarde un contact d'urgence
  static Future<void> saveEmergencyContact(Map<String, dynamic> contact) =>
      StorageHelper.addToList(_emergencyContactsKey, contact);

  /// Récupère tous les contacts d'urgence
  static Future<List<Map<String, dynamic>>> getEmergencyContacts() =>
      StorageHelper.getList(_emergencyContactsKey);

  /// Met à jour un contact d'urgence
  static Future<void> updateEmergencyContact(Map<String, dynamic> contact) =>
      StorageHelper.updateInList(_emergencyContactsKey, contact);

  /// Supprime un contact d'urgence
  static Future<void> deleteEmergencyContact(String contactId) =>
      StorageHelper.removeFromList(_emergencyContactsKey, contactId);

  // === INFORMATIONS D'URGENCE ===

  /// Sauvegarde les informations médicales d'urgence
  static Future<void> saveEmergencyInfo(Map<String, dynamic> info) =>
      StorageHelper.saveObject(_emergencyInfoKey, info);

  /// Récupère les informations médicales d'urgence
  static Future<Map<String, dynamic>?> getEmergencyInfo() =>
      StorageHelper.getObject(_emergencyInfoKey);

  // === UTILITAIRES ===

  /// Nettoie toutes les données
  static Future<void> clearAllData() async {
    await Future.wait([
      StorageHelper.clearData(_documentsKey),
      StorageHelper.clearData(_remindersKey),
      StorageHelper.clearData(_emergencyContactsKey),
      StorageHelper.clearData(_emergencyInfoKey),
    ]);
  }

  /// Vérifie si des données existent
  static Future<bool> hasAnyData() async {
    final checks = await Future.wait([
      StorageHelper.hasData(_documentsKey),
      StorageHelper.hasData(_remindersKey),
      StorageHelper.hasData(_emergencyContactsKey),
      StorageHelper.hasData(_emergencyInfoKey),
    ]);
    return checks.any((hasData) => hasData);
  }

  /// Exporte toutes les données pour sauvegarde
  static Future<Map<String, dynamic>> exportAllData() async {
    final data = await Future.wait([
      getDocuments(),
      getReminders(),
      getEmergencyContacts(),
      getEmergencyInfo(),
    ]);

    return {
      'documents': data[0],
      'reminders': data[1],
      'emergency_contacts': data[2],
      'emergency_info': data[3],
      'export_date': DateTime.now().toIso8601String(),
    };
  }

  /// Importe des données depuis une sauvegarde
  static Future<void> importAllData(Map<String, dynamic> backup) async {
    if (backup['documents'] != null) {
      await StorageHelper.saveList(_documentsKey,
          List<Map<String, dynamic>>.from(backup['documents']));
    }

    if (backup['reminders'] != null) {
      await StorageHelper.saveList(_remindersKey,
          List<Map<String, dynamic>>.from(backup['reminders']));
    }

    if (backup['emergency_contacts'] != null) {
      await StorageHelper.saveList(_emergencyContactsKey,
          List<Map<String, dynamic>>.from(backup['emergency_contacts']));
    }

    if (backup['emergency_info'] != null) {
      await StorageHelper.saveObject(_emergencyInfoKey,
          Map<String, dynamic>.from(backup['emergency_info']));
    }
  }
}
