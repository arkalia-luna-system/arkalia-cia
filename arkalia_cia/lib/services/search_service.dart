import '../services/local_storage_service.dart';
import '../services/calendar_service.dart';

/// Service de recherche globale dans l'application
class SearchService {
  /// Recherche dans tous les modules de l'application
  /// 
  /// [query] : Terme de recherche
  /// Retourne un Map avec les résultats groupés par type
  static Future<Map<String, List<Map<String, dynamic>>>> searchAll(String query) async {
    if (query.trim().isEmpty) {
      return {
        'documents': [],
        'reminders': [],
        'contacts': [],
      };
    }

    final lowerQuery = query.toLowerCase();
    final results = <String, List<Map<String, dynamic>>>{
      'documents': [],
      'reminders': [],
      'contacts': [],
    };

    // Recherche dans les documents
    try {
      final documents = await LocalStorageService.getDocuments();
      results['documents'] = documents.where((doc) {
        final name = (doc['original_name'] ?? doc['name'] ?? '').toLowerCase();
        final category = (doc['category'] ?? '').toLowerCase();
        return name.contains(lowerQuery) || category.contains(lowerQuery);
      }).toList();
    } catch (e) {
      // Ignorer les erreurs
    }

    // Recherche dans les rappels
    try {
      final reminders = await LocalStorageService.getReminders();
      results['reminders'] = reminders.where((reminder) {
        final title = (reminder['title'] ?? '').toLowerCase();
        final description = (reminder['description'] ?? '').toLowerCase();
        return title.contains(lowerQuery) || description.contains(lowerQuery);
      }).toList();
    } catch (e) {
      // Ignorer les erreurs
    }

    // Recherche dans les contacts d'urgence
    try {
      final contacts = await LocalStorageService.getEmergencyContacts();
      results['contacts'] = contacts.where((contact) {
        final name = (contact['name'] ?? '').toLowerCase();
        final phone = (contact['phone'] ?? '').toLowerCase();
        final relationship = (contact['relationship'] ?? '').toLowerCase();
        return name.contains(lowerQuery) || 
               phone.contains(lowerQuery) || 
               relationship.contains(lowerQuery);
      }).toList();
    } catch (e) {
      // Ignorer les erreurs
    }

    return results;
  }

  /// Compte le nombre total de résultats
  static Future<int> getTotalResultsCount(String query) async {
    final results = await searchAll(query);
    return results['documents']!.length + 
           results['reminders']!.length + 
           results['contacts']!.length;
  }
}

