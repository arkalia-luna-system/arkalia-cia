import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/local_storage_service.dart';
import '../services/doctor_service.dart';

class ConversationalAIService {
  static const String _baseUrl = 'http://localhost:8000'; // TODO: Configurer URL backend
  
  Future<AIResponse> askQuestion(String question) async {
    try {
      // Récupérer données utilisateur
      final userData = await _getUserData();
      
      // Appel API backend
      final response = await http.post(
        Uri.parse('$_baseUrl/api/ai/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'question': question,
          'user_data': userData,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AIResponse.fromMap(data);
      } else {
        return AIResponse(
          answer: 'Erreur lors de la communication avec l\'IA.',
          suggestions: [],
        );
      }
    } catch (e) {
      // Mode offline : réponse basique
      return AIResponse(
        answer: 'Mode hors ligne. Connectez-vous pour utiliser l\'IA complète.',
        suggestions: [
          'Vérifiez votre connexion internet',
          'Essayez de reformuler votre question',
        ],
      );
    }
  }
  
  Future<Map<String, dynamic>> _getUserData() async {
    // Récupérer seulement les données récentes pour économiser la mémoire
    // Limiter à 10 documents récents, 5 médecins récents
    // Utiliser cache si disponible pour optimiser
    final allDocuments = await LocalStorageService.getDocuments();
    final doctorService = DoctorService();
    final allDoctors = await doctorService.getAllDoctors();
    
    // Trier par date et prendre seulement les 10 documents les plus récents
    allDocuments.sort((a, b) {
      final dateA = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(1970);
      final dateB = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(1970);
      return dateB.compareTo(dateA);
    });
    final documents = allDocuments.take(10).toList();
    
    // Prendre seulement les 5 médecins les plus récents (ou les plus consultés)
    final doctors = allDoctors.take(5).map((d) => d.toMap()).toList();
    
    // Récupérer données douleur depuis ARIA si disponible (limité à 10)
    List<Map<String, dynamic>> painRecords = [];
    try {
      final ariaResponse = await http.get(
        Uri.parse('$_baseUrl/api/aria/pain-entries/recent?limit=10'),
      ).timeout(const Duration(seconds: 5));
      if (ariaResponse.statusCode == 200) {
        final data = jsonDecode(ariaResponse.body);
        painRecords = List<Map<String, dynamic>>.from(data).take(10).toList();
      }
    } catch (e) {
      // ARIA non disponible, continuer sans
    }
    
    return {
      'documents': documents,
      'doctors': doctors,
      'consultations': [], // TODO: Récupérer consultations depuis DoctorService
      'pain_records': painRecords,
      'user_id': 'default', // TODO: Récupérer ID utilisateur réel
    };
  }
  
  Future<List<Map<String, dynamic>>> getConversationHistory({int limit = 50}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/ai/conversations?limit=$limit'),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      }
    } catch (e) {
      // Erreur silencieuse
    }
    
    return [];
  }

  Future<List<String>> prepareAppointmentQuestions(String doctorId) async {
    try {
      final userData = await _getUserData();
      
      final response = await http.post(
        Uri.parse('$_baseUrl/api/ai/prepare-appointment'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'doctor_id': doctorId,
          'user_data': userData,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<String>.from(data['questions']);
      }
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

