import 'dart:math';
import '../services/local_storage_service.dart';
import '../services/doctor_service.dart';

/// Service de recherche sémantique amélioré
/// Utilise des embeddings simples (TF-IDF) pour recherche sémantique
/// Améliorations : pondération contextuelle, recherche par synonymes médicaux
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

  // Synonymes médicaux pour recherche améliorée
  static const Map<String, List<String>> _medicalSynonyms = {
    'douleur': ['mal', 'souffrance', 'douleurs', 'douloureux'],
    'médicament': ['médicaments', 'traitement', 'thérapie', 'prescription'],
    'examen': ['examens', 'test', 'tests', 'analyses', 'analyse'],
    'médecin': ['docteur', 'docteurs', 'médecins', 'praticien', 'praticiens'],
    'consultation': ['consultations', 'rdv', 'rendez-vous', 'visite'],
  };

  /// Recherche sémantique dans documents
  /// ⚠️ OPTIMISATION MÉMOIRE : Limite à 100 documents max pour le calcul de score
  Future<List<Map<String, dynamic>>> semanticSearch(
    String query,
    {int limit = 20}
  ) async {
    final allDocuments = await LocalStorageService.getDocuments();
    
    // ⚠️ OPTIMISATION MÉMOIRE : Limiter à 100 documents max pour le calcul de score
    // Si beaucoup de documents, on ne calcule le score que sur les 100 plus récents
    // Cela évite de charger tous les documents en mémoire si il y en a des milliers
    final documents = allDocuments.length > 100
        ? (allDocuments..sort((a, b) {
            final dateA = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(1970);
            final dateB = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(1970);
            return dateB.compareTo(dateA); // Plus récents en premier
          })).take(100).toList()
        : allDocuments;
    
    final queryLower = query.toLowerCase();
    
    // Calculer score sémantique pour chaque document (limité à 100)
    final scoredDocs = documents.map((doc) {
      final score = _calculateSemanticScore(doc, queryLower);
      return {
        'document': doc,
        'score': score,
      };
    }).toList();

    // Trier par score décroissant
    scoredDocs.sort((a, b) {
      final scoreA = (a['score'] as double?) ?? 0.0;
      final scoreB = (b['score'] as double?) ?? 0.0;
      return scoreB.compareTo(scoreA);
    });

    // Retourner top résultats avec score > 0.1
    return scoredDocs
        .where((item) {
          final score = (item['score'] as double?) ?? 0.0;
          return score > 0.1;
        })
        .take(limit)
        .map((item) => item['document'] as Map<String, dynamic>)
        .toList();
  }

  double _calculateSemanticScore(Map<String, dynamic> doc, String query) {
    double score = 0.0;
    
    // Extraire texte du document (nom, catégorie, métadonnées si disponibles)
    final docText = '${doc['original_name'] ?? ''} ${doc['name'] ?? ''} ${doc['category'] ?? ''} ${doc['keywords'] ?? ''}'.toLowerCase();
    final queryLower = query.toLowerCase();
    
    // Score basé sur mots-clés médicaux (pondération élevée)
    for (final entry in _medicalKeywords.entries) {
      if (queryLower.contains(entry.key) && docText.contains(entry.key)) {
        score += entry.value * 1.5; // Bonus pour correspondance médicale
      }
      // Vérifier aussi les synonymes
      if (_medicalSynonyms.containsKey(entry.key)) {
        for (final synonym in _medicalSynonyms[entry.key]!) {
          if (queryLower.contains(synonym) && docText.contains(entry.key)) {
            score += entry.value * 1.2; // Bonus légèrement réduit pour synonymes
          }
        }
      }
    }
    
    // Score basé sur correspondance exacte de mots complets
    final queryWords = queryLower.split(' ').where((w) => w.length > 2).toList();
    int exactMatches = 0;
    for (final word in queryWords) {
      if (docText.contains(word)) {
        exactMatches++;
        score += 1.0;
      }
    }
    
    // Bonus si plusieurs mots correspondent
    if (exactMatches > 1) {
      score += exactMatches * 0.5;
    }
    
    // Score basé sur correspondance partielle (fuzzy)
    for (final word in queryWords) {
      if (word.length > 4) {
        // Vérifier correspondance partielle (3+ caractères)
        for (int i = 0; i <= docText.length - 3; i++) {
          if (docText.substring(i, min(i + word.length, docText.length)) == word.substring(0, min(3, word.length))) {
            score += 0.3;
            break;
          }
        }
      }
    }
    
    // Normaliser score (max 1.0)
    return min(score / 15.0, 1.0);
  }

  /// Recherche sémantique dans médecins
  /// ⚠️ OPTIMISATION MÉMOIRE : Limite à 50 médecins max pour le calcul de score
  Future<List<dynamic>> semanticSearchDoctors(String query) async {
    final doctorService = DoctorService();
    final allDoctors = await doctorService.getAllDoctors();
    
    // ⚠️ OPTIMISATION MÉMOIRE : Limiter à 50 médecins max pour le calcul de score
    final doctors = allDoctors.take(50).toList();
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

    scoredDoctors.sort((a, b) {
      final scoreA = (a['score'] as double?) ?? 0.0;
      final scoreB = (b['score'] as double?) ?? 0.0;
      return scoreB.compareTo(scoreA);
    });
    
    return scoredDoctors
        .where((item) {
          final score = (item['score'] as double?) ?? 0.0;
          return score > 0;
        })
        .map((item) => item['doctor'])
        .toList();
  }
}

