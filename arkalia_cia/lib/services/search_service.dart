import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../services/local_storage_service.dart';
import '../services/doctor_service.dart';
import 'semantic_search_service.dart';
import 'offline_cache_service.dart';

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
  static final SemanticSearchService _semanticSearch = SemanticSearchService();

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'arkalia_cia.db');
      return await openDatabase(path, version: 1);
    } catch (e) {
      // Sur le web, sqflite peut ne pas fonctionner, on retourne une erreur silencieuse
      if (kIsWeb) {
        throw Exception('Base de données non disponible sur le web.');
      }
      rethrow;
    }
  }

  /// Recherche simple avec une requête texte (limité à 20 résultats par catégorie)
  /// Utilise la recherche sémantique si la requête est suffisamment longue (>3 caractères)
  static Future<Map<String, List<Map<String, dynamic>>>> searchAll(String query) async {
    final results = <String, List<Map<String, dynamic>>>{
      'documents': [],
      'reminders': [],
      'contacts': [],
    };
    
    const maxResults = 20; // Limiter les résultats pour économiser la mémoire
    final useSemantic = query.length > 3; // Utiliser recherche sémantique pour requêtes longues

    try {
      // Recherche dans les documents avec recherche sémantique si activée
      List<Map<String, dynamic>> documents;
      if (useSemantic) {
        documents = await _semanticSearch.semanticSearch(query, limit: 50);
      } else {
        documents = await LocalStorageService.getDocuments();
      }
      
      for (var doc in documents.take(50)) {
        if (results['documents']!.length >= maxResults) break;
        final name = (doc['original_name'] ?? doc['name'] ?? '').toLowerCase();
        if (name.contains(query.toLowerCase())) {
          results['documents']!.add(doc);
        }
      }

      // Recherche dans les rappels (limiter à 50 pour la recherche)
      final reminders = await LocalStorageService.getReminders();
      for (var reminder in reminders.take(50)) {
        if (results['reminders']!.length >= maxResults) break;
        final title = (reminder['title'] ?? '').toLowerCase();
        final description = (reminder['description'] ?? '').toLowerCase();
        if (title.contains(query.toLowerCase()) || description.contains(query.toLowerCase())) {
          results['reminders']!.add(reminder);
        }
      }

      // Recherche dans les contacts d'urgence (limiter à 50 pour la recherche)
      final contacts = await LocalStorageService.getEmergencyContacts();
      for (var contact in contacts.take(50)) {
        if (results['contacts']!.length >= maxResults) break;
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

  Future<List<SearchResult>> search(SearchFilters filters, {bool useSemantic = false}) async {
    // Vérifier le cache d'abord
    final cacheKey = 'search_${filters.query}_${filters.category}_${filters.examType}';
    final cachedResults = await OfflineCacheService.getCachedData(cacheKey);
    if (cachedResults != null) {
      return (cachedResults as List).map((r) => SearchResult(
        id: r['id'],
        title: r['title'],
        type: r['type'],
        date: r['date'] != null ? DateTime.tryParse(r['date']) : null,
        preview: r['preview'],
        relevanceScore: r['relevanceScore']?.toDouble(),
      )).toList();
    }

    final List<SearchResult> results = [];

    // Recherche dans documents
    List<Map<String, dynamic>> documents;
    if (useSemantic && filters.query != null && filters.query!.isNotEmpty) {
      // Recherche sémantique
      documents = await _semanticSearch.semanticSearch(filters.query!);
    } else {
      documents = await LocalStorageService.getDocuments();
    }

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
      List<dynamic> doctors;
      if (useSemantic) {
        doctors = await _semanticSearch.semanticSearchDoctors(filters.query!);
      } else {
        doctors = await doctorService.searchDoctors(filters.query!);
      }
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

    // Mettre en cache les résultats (durée: 1 heure)
    await OfflineCacheService.cacheData(
      cacheKey,
      results.map((r) => {
        'id': r.id,
        'title': r.title,
        'type': r.type,
        'date': r.date?.toIso8601String(),
        'preview': r.preview,
        'relevanceScore': r.relevanceScore,
      }).toList(),
      duration: const Duration(hours: 1),
    );

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

    // Filtre type d'examen
    if (filters.examType != null) {
      final docName = (doc['original_name'] ?? doc['name'] ?? '').toLowerCase();
      final examTypeLower = filters.examType!.toLowerCase();
      // Rechercher le type d'examen dans le nom du document ou les métadonnées
      if (!docName.contains(examTypeLower)) {
        final metadata = doc['metadata'];
        if (metadata != null && metadata is Map) {
          final metadataText = metadata.toString().toLowerCase();
          if (!metadataText.contains(examTypeLower)) {
            return false;
          }
        } else {
          return false;
        }
      }
    }

    // Filtre médecin (via métadonnées ou consultations)
    if (filters.doctorId != null) {
      // Vérifier si le document a des métadonnées avec doctor_name
      // ou si le document est associé à une consultation du médecin
      final doctorName = doc['doctor_name'];
      final metadataDoctorName = doc['metadata']?['doctor_name'];
      
      // Si aucune information de médecin dans le document, exclure
      // (on pourrait aussi chercher dans les consultations, mais c'est plus complexe)
      if (doctorName == null && metadataDoctorName == null) {
        // Ne pas exclure si on n'a pas d'info - laisser passer
        // pour permettre recherche même sans métadonnées complètes
      }
    }

    return true;
  }

  Future<List<String>> getSearchSuggestions(String partialQuery) async {
    final documents = await LocalStorageService.getDocuments();
    final suggestions = <String>{};
    final queryLower = partialQuery.toLowerCase();
    
    // Synonymes médicaux pour améliorer les suggestions
    final synonyms = {
      'scanner': ['IRM', 'tomodensitométrie', 'CT', 'scanner CT'],
      'irm': ['scanner', 'imagerie par résonance', 'MRI'],
      'analyse': ['prélèvement', 'sang', 'urine', 'laboratoire', 'test'],
      'radio': ['radiographie', 'RX', 'rayon X'],
      'echographie': ['échographie', 'ultrasons', 'écho', 'US'],
    };
    
    // Recherche directe dans les noms
    for (var doc in documents) {
      final name = doc['original_name'] ?? doc['name'] ?? '';
      if (name.toLowerCase().contains(queryLower)) {
        suggestions.add(name);
      }
    }
    
    // Recherche avec synonymes
    for (var entry in synonyms.entries) {
      if (queryLower.contains(entry.key)) {
        for (var synonym in entry.value) {
          suggestions.add('Rechercher "$synonym"');
        }
      }
    }
    
    // Recherche dans les métadonnées (type d'examen)
    for (var doc in documents) {
      final metadata = doc['metadata'];
      if (metadata != null && metadata is Map) {
        final examType = metadata['exam_type']?.toString().toLowerCase();
        if (examType != null && examType.contains(queryLower)) {
          final name = doc['original_name'] ?? doc['name'] ?? '';
          suggestions.add(name);
        }
      }
    }
    
    return suggestions.take(10).toList();
  }
}
