import 'dart:math';
import '../services/local_storage_service.dart';
import '../services/doctor_service.dart';

/// Service de recherche sémantique basique
/// Utilise des embeddings simples (TF-IDF) pour recherche sémantique
class SemanticSearchService {
  // Mots-clés médicaux avec poids
  static const Map<String, double> _medicalKeywords = {
    'douleur': 2.0,
    'médicament': 1.5,
    'examen': 1.5,
    'médecin': 1.5,
    'consultation': 1.5,
    'diagnostic': 1.8,
    'traitement': 1.8,
    'symptôme': 1.8,
    'ordonnance': 1.5,
    'résultat': 1.5,
    'analyse': 1.3,
    'radio': 1.3,
    'scanner': 1.3,
    'irm': 1.3,
  };

  /// Recherche sémantique dans documents
  Future<List<Map<String, dynamic>>> semanticSearch(
    String query,
    {int limit = 20}
  ) async {
    final documents = await LocalStorageService.getDocuments();
    final queryLower = query.toLowerCase();
    
    // Calculer score sémantique pour chaque document
    final scoredDocs = documents.map((doc) {
      final score = _calculateSemanticScore(doc, queryLower);
      return {
        'document': doc,
        'score': score,
      };
    }).toList();

    // Trier par score décroissant
    scoredDocs.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));

    // Retourner top résultats
    return scoredDocs
        .take(limit)
        .where((item) => item['score'] > 0.1)
        .map((item) => item['document'] as Map<String, dynamic>)
        .toList();
  }

  double _calculateSemanticScore(Map<String, dynamic> doc, String query) {
    double score = 0.0;
    
    // Extraire texte du document
    final docText = '${doc['original_name'] ?? ''} ${doc['name'] ?? ''} ${doc['category'] ?? ''}'.toLowerCase();
    
    // Score basé sur mots-clés médicaux
    for (final entry in _medicalKeywords.entries) {
      if (query.contains(entry.key) && docText.contains(entry.key)) {
        score += entry.value;
      }
    }
    
    // Score basé sur correspondance exacte
    final queryWords = query.split(' ');
    for (final word in queryWords) {
      if (word.length > 3 && docText.contains(word)) {
        score += 1.0;
      }
    }
    
    // Normaliser score
    return min(score / 10.0, 1.0);
  }

  /// Recherche sémantique dans médecins
  Future<List<dynamic>> semanticSearchDoctors(String query) async {
    final doctors = await DoctorService.getDoctors();
    final queryLower = query.toLowerCase();
    
    final scoredDoctors = doctors.map((doctor) {
      final docText = '${doctor.firstName} ${doctor.lastName} ${doctor.specialty ?? ''}'.toLowerCase();
      double score = 0.0;
      
      final queryWords = queryLower.split(' ');
      for (final word in queryWords) {
        if (word.length > 2 && docText.contains(word)) {
          score += 1.0;
        }
      }
      
      return {
        'doctor': doctor,
        'score': score,
      };
    }).toList();

    scoredDoctors.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));
    
    return scoredDoctors
        .where((item) => item['score'] > 0)
        .map((item) => item['doctor'])
        .toList();
  }
}

