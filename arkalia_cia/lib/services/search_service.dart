import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../services/local_storage_service.dart';
import '../services/doctor_service.dart';

class SearchFilters {
  final String? query;
  final String? examType;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? doctorId;
  final String? category;

  SearchFilters({
    this.query,
    this.examType,
    this.startDate,
    this.endDate,
    this.doctorId,
    this.category,
  });
}

class SearchResult {
  final String id;
  final String title;
  final String type;  // 'document', 'consultation', 'doctor'
  final DateTime? date;
  final String? preview;
  final double? relevanceScore;

  SearchResult({
    required this.id,
    required this.title,
    required this.type,
    this.date,
    this.preview,
    this.relevanceScore,
  });
}

class SearchService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'arkalia_cia.db');
    return await openDatabase(path, version: 1);
  }

  /// Recherche simple avec une requête texte
  static Future<Map<String, List<Map<String, dynamic>>>> searchAll(String query) async {
    final results = <String, List<Map<String, dynamic>>>{
      'documents': [],
      'reminders': [],
      'contacts': [],
    };

    try {
      // Recherche dans les documents
      final documents = await LocalStorageService.getDocuments();
      for (var doc in documents) {
        final name = (doc['original_name'] ?? doc['name'] ?? '').toLowerCase();
        if (name.contains(query.toLowerCase())) {
          results['documents']!.add(doc);
        }
      }

      // Recherche dans les rappels
      final reminders = await LocalStorageService.getReminders();
      for (var reminder in reminders) {
        final title = (reminder['title'] ?? '').toLowerCase();
        final description = (reminder['description'] ?? '').toLowerCase();
        if (title.contains(query.toLowerCase()) || description.contains(query.toLowerCase())) {
          results['reminders']!.add(reminder);
        }
      }

      // Recherche dans les contacts d'urgence
      final contacts = await LocalStorageService.getEmergencyContacts();
      for (var contact in contacts) {
        final name = (contact['name'] ?? '').toLowerCase();
        final phone = (contact['phone'] ?? '').toLowerCase();
        if (name.contains(query.toLowerCase()) || phone.contains(query.toLowerCase())) {
          results['contacts']!.add(contact);
        }
      }
    } catch (e) {
      // En cas d'erreur, retourner les résultats partiels
    }

    return results;
  }

  Future<List<SearchResult>> search(SearchFilters filters) async {
    final List<SearchResult> results = [];

    // Recherche dans documents
    final documents = await LocalStorageService.getDocuments();
    for (var doc in documents) {
      final matches = _matchesDocument(doc, filters);
      if (matches) {
        results.add(SearchResult(
          id: doc['id']?.toString() ?? '',
          title: doc['original_name'] ?? doc['name'] ?? 'Sans titre',
          type: 'document',
          date: doc['created_at'] != null 
              ? DateTime.tryParse(doc['created_at']) 
              : null,
          preview: doc['category'] ?? '',
        ));
      }
    }

    // Recherche dans médecins
    if (filters.query != null && filters.query!.isNotEmpty) {
      final doctorService = DoctorService();
      final doctors = await doctorService.searchDoctors(filters.query!);
      for (var doctor in doctors) {
        results.add(SearchResult(
          id: doctor.id?.toString() ?? '',
          title: doctor.fullName,
          type: 'doctor',
          preview: doctor.specialty,
        ));
      }
    }

    // Trier par pertinence (date récente d'abord)
    results.sort((a, b) {
      if (a.date != null && b.date != null) {
        return b.date!.compareTo(a.date!);
      }
      return 0;
    });

    return results;
  }

  bool _matchesDocument(Map<String, dynamic> doc, SearchFilters filters) {
    // Filtre texte
    if (filters.query != null && filters.query!.isNotEmpty) {
      final query = filters.query!.toLowerCase();
      final name = (doc['original_name'] ?? doc['name'] ?? '').toLowerCase();
      if (!name.contains(query)) {
        return false;
      }
    }

    // Filtre catégorie
    if (filters.category != null) {
      if ((doc['category'] ?? '') != filters.category) {
        return false;
      }
    }

    // Filtre date
    if (filters.startDate != null || filters.endDate != null) {
      final docDate = doc['created_at'] != null 
          ? DateTime.tryParse(doc['created_at']) 
          : null;
      if (docDate == null) return false;
      
      if (filters.startDate != null && docDate.isBefore(filters.startDate!)) {
        return false;
      }
      if (filters.endDate != null && docDate.isAfter(filters.endDate!)) {
        return false;
      }
    }

    return true;
  }

  Future<List<String>> getSearchSuggestions(String partialQuery) async {
    final documents = await LocalStorageService.getDocuments();
    final suggestions = <String>{};
    
    for (var doc in documents) {
      final name = doc['original_name'] ?? doc['name'] ?? '';
      if (name.toLowerCase().contains(partialQuery.toLowerCase())) {
        suggestions.add(name);
      }
    }
    
    return suggestions.take(10).toList();
  }
}
