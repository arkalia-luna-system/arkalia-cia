import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/local_storage_service.dart';
import '../services/doctor_service.dart';
import '../services/backend_config_service.dart';
import '../utils/app_logger.dart';
import '../utils/error_helper.dart';
import 'auth_api_service.dart';

class ConversationalAIService {
  /// Méthode helper pour gérer automatiquement le refresh token en cas de 401
  Future<dynamic> _makeAuthenticatedRequest(
    Future<http.Response> Function() makeRequest,
  ) async {
    try {
      var response = await makeRequest();

      // Si 401 (Unauthorized), essayer de rafraîchir le token
      if (response.statusCode == 401) {
        AppLogger.debug('Token expiré dans ConversationalAI, tentative de rafraîchissement...');
        final refreshResult = await AuthApiService.refreshToken();

        if (refreshResult['success'] == true) {
          // Token rafraîchi, réessayer la requête avec les nouveaux headers
          AppLogger.debug('Token rafraîchi avec succès, nouvelle tentative...');
          response = await makeRequest();
        } else {
          // Refresh échoué, déconnecter l'utilisateur
          AppLogger.debug('Impossible de rafraîchir le token, déconnexion...');
          await AuthApiService.logout();
          throw Exception('Session expirée. Veuillez vous reconnecter.');
        }
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = response.body;
        if (body.isEmpty) {
          return {};
        }
        return jsonDecode(body);
      } else {
        // Pour les erreurs, essayer de décoder le message d'erreur
        try {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['detail'] ?? 'Erreur HTTP ${response.statusCode}');
        } catch (_) {
          throw Exception('Erreur HTTP ${response.statusCode}');
        }
      }
    } catch (e) {
      if (e.toString().contains('Session expirée')) {
        rethrow;
      }
      AppLogger.error('Erreur requête authentifiée ConversationalAI', e);
      rethrow;
    }
  }
  
  Future<AIResponse> askQuestion(String question) async {
    try {
      // Récupérer données utilisateur
      final userData = await _getUserData();
      
      // Récupérer URL backend configurée
      final baseUrl = await BackendConfigService.getBackendURL();
      final backendEnabled = await BackendConfigService.isBackendEnabled();
      
      // Mode offline : Si backend non configuré ou désactivé, utiliser mode basique
      if (baseUrl.isEmpty || !backendEnabled) {
        // Mode offline : Réponse basique avec données locales
        final userData = await _getUserData();
        final docCount = userData['documents']?.length ?? 0;
        final doctorCount = userData['doctors']?.length ?? 0;
        
        // Réponse simple basée sur les données locales
        String answer = 'Bonjour ! Je suis votre assistant santé intelligent.\n\n';
        if (docCount > 0) {
          answer += '📄 Vous avez $docCount document(s) dans votre coffre-fort.\n';
        }
        if (doctorCount > 0) {
          answer += '👨‍⚕️ Vous avez $doctorCount médecin(s) enregistré(s).\n';
        }
        answer += '\n💡 Pour une assistance IA complète, configurez le backend dans les paramètres (⚙️ > Backend API).\n\n';
        answer += 'En attendant, je peux vous aider avec :\n';
        answer += '• Vos documents médicaux\n';
        answer += '• Vos médecins\n';
        answer += '• Vos rappels médicaments\n';
        answer += '• Vos consultations';
        
        return AIResponse(
          answer: answer,
          suggestions: [
            'Voir mes documents',
            'Voir mes médecins',
            'Configurer le backend',
          ],
        );
      }
      
      // Appel API backend avec authentification et gestion automatique du refresh token
      final response = await _makeAuthenticatedRequest(() async {
        final headers = {'Content-Type': 'application/json'};
        final token = await AuthApiService.getAccessToken();
        if (token != null) {
          headers['Authorization'] = 'Bearer $token';
        }
        
        return await http.post(
          Uri.parse('$baseUrl/api/v1/ai/chat'),
          headers: headers,
          body: jsonEncode({
            'question': question,
            'user_data': userData,
          }),
        );
      });
      
      final data = response as Map<String, dynamic>;
      return AIResponse.fromMap(data);
    } catch (e) {
      // Mode offline : réponse basique avec message d'erreur clair
      ErrorHelper.logError('ConversationalAIService.askQuestion', e);
      final errorMessage = e.toString();
      String userMessage;
      
      if (errorMessage.contains('Failed to fetch') || 
          errorMessage.contains('Failed host lookup') || 
          errorMessage.contains('Connection refused') ||
          errorMessage.contains('NetworkError')) {
        userMessage = '⚠️ Impossible de se connecter au serveur.\n\n'
            'Vérifiez que :\n'
            '• Votre connexion internet fonctionne\n'
            '• Le serveur est démarré\n'
            '• L\'adresse du serveur est correcte dans les paramètres (⚙️ > Backend API)';
      } else if (errorMessage.contains('timeout')) {
        userMessage = '⏱️ Le backend met trop de temps à répondre.\n\n'
            'Vérifiez que le backend est bien démarré et accessible.';
      } else {
        userMessage = '⚠️ Impossible de se connecter au serveur.\n\n'
            'Vérifiez que :\n'
            '• Votre connexion internet fonctionne\n'
            '• Le serveur est démarré\n'
            '• L\'adresse du serveur est correcte dans les paramètres (⚙️ > Backend API)';
      }
      
      return AIResponse(
        answer: userMessage,
        suggestions: [
          'Vérifier la configuration du backend',
          'Vérifier que le backend est démarré',
          'Tester la connexion dans les paramètres',
        ],
      );
    }
  }
  
  Future<Map<String, dynamic>> _getUserData() async {
    // Récupérer seulement les données récentes pour économiser la mémoire
    // Limiter à 10 documents récents, 5 médecins récents
    // Utiliser cache si disponible pour optimiser
    
    // ⚠️ OPTIMISATION MÉMOIRE : Ne charger que les données nécessaires
    // Note: SharedPreferences charge tout en mémoire, mais on limite ensuite
    // Pour vraiment optimiser, il faudrait implémenter pagination au niveau storage
    final allDocuments = await LocalStorageService.getDocuments();
    final doctorService = DoctorService();
    final allDoctors = await doctorService.getAllDoctors();
    
    // Optimisation : Trier seulement si nécessaire (éviter tri complet si peu de données)
    final documents = allDocuments.length > 10
        ? (allDocuments..sort((a, b) {
            final dateA = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(1970);
            final dateB = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(1970);
            return dateB.compareTo(dateA);
          })).take(10).toList()
        : allDocuments.take(10).toList();
    
    // Prendre seulement les 5 médecins les plus récents (ou les plus consultés)
    final doctors = allDoctors.take(5).map((d) => d.toMap()).toList();
    
    // Libérer les références aux listes complètes pour libérer la mémoire
    // (le GC Dart gère automatiquement, mais on peut aider)
    
    // Récupérer données douleur depuis ARIA si disponible (limité à 10)
    List<Map<String, dynamic>> painRecords = [];
    try {
      final baseUrl = await BackendConfigService.getBackendURL();
      if (baseUrl.isNotEmpty) {
        final ariaResponse = await _makeAuthenticatedRequest(() async {
          final ariaHeaders = <String, String>{};
          final ariaToken = await AuthApiService.getAccessToken();
          if (ariaToken != null) {
            ariaHeaders['Authorization'] = 'Bearer $ariaToken';
          }
          
          return await http.get(
            Uri.parse('$baseUrl/api/v1/aria/pain-entries/recent?limit=10'),
            headers: ariaHeaders,
          ).timeout(const Duration(seconds: 5));
        });
        
        painRecords = List<Map<String, dynamic>>.from(ariaResponse as List).take(10).toList();
      }
    } catch (e) {
      // ARIA non disponible, continuer sans
      AppLogger.debug('ARIA non disponible: $e');
    }
    
    // Récupérer consultations depuis médecins
    final consultations = <Map<String, dynamic>>[];
    for (var doctor in allDoctors.take(5)) {
      if (doctor.id != null) {
        try {
          final doctorConsultations = await doctorService.getConsultationsByDoctor(doctor.id!);
          for (var consult in doctorConsultations.take(3)) { // Limiter à 3 consultations par médecin
            consultations.add({
              'doctor_id': doctor.id.toString(),
              'date': consult.date.toIso8601String(),
              'reason': consult.reason,
              'notes': consult.notes,
            });
          }
        } catch (e) {
          // Continuer si erreur
        }
      }
    }
    
    return {
      'documents': documents,
      'doctors': doctors,
      'consultations': consultations,
      'pain_records': painRecords,
      'user_id': 'default', // ID utilisateur par défaut (peut être amélioré avec authentification)
    };
  }
  
  Future<List<Map<String, dynamic>>> getConversationHistory({int limit = 50}) async {
    try {
      final baseUrl = await BackendConfigService.getBackendURL();
      if (baseUrl.isEmpty) {
        return [];
      }
      
      final response = await _makeAuthenticatedRequest(() async {
        final headers = <String, String>{};
        final token = await AuthApiService.getAccessToken();
        if (token != null) {
          headers['Authorization'] = 'Bearer $token';
        }
        
        return await http.get(
          Uri.parse('$baseUrl/api/v1/ai/conversations?limit=$limit'),
          headers: headers,
        );
      });
      
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      // Erreur silencieuse
      AppLogger.debug('Erreur récupération historique conversations: $e');
    }
    
    return [];
  }

  Future<List<String>> prepareAppointmentQuestions(String doctorId) async {
    try {
      final userData = await _getUserData();
      final baseUrl = await BackendConfigService.getBackendURL();
      if (baseUrl.isEmpty) {
        return [
          'Quels sont vos symptômes actuels ?',
          'Y a-t-il eu des changements depuis votre dernière visite ?',
          'Prenez-vous de nouveaux médicaments ?',
        ];
      }
      
      final response = await _makeAuthenticatedRequest(() async {
        final headers = {'Content-Type': 'application/json'};
        final token = await AuthApiService.getAccessToken();
        if (token != null) {
          headers['Authorization'] = 'Bearer $token';
        }
        
        return await http.post(
          Uri.parse('$baseUrl/api/v1/ai/prepare-appointment'),
          headers: headers,
          body: jsonEncode({
            'doctor_id': doctorId,
            'user_data': userData,
          }),
        );
      });
      
      final data = response as Map<String, dynamic>;
      return List<String>.from(data['questions'] ?? []);
    } catch (e) {
      // Mode offline : questions par défaut
    }
    
    return [
      'Quels sont vos symptômes actuels ?',
      'Y a-t-il eu des changements depuis votre dernière visite ?',
      'Prenez-vous de nouveaux médicaments ?',
    ];
  }
}

class AIResponse {
  final String answer;
  final List<String> relatedDocuments;
  final List<String> suggestions;
  final Map<String, dynamic>? patternsDetected;
  final String? questionType;
  
  AIResponse({
    required this.answer,
    this.relatedDocuments = const [],
    this.suggestions = const [],
    this.patternsDetected,
    this.questionType,
  });
  
  factory AIResponse.fromMap(Map<String, dynamic> map) {
    return AIResponse(
      answer: map['answer'] ?? '',
      relatedDocuments: List<String>.from(map['related_documents'] ?? []),
      suggestions: List<String>.from(map['suggestions'] ?? []),
      patternsDetected: map['patterns_detected'],
      questionType: map['question_type'],
    );
  }
}

