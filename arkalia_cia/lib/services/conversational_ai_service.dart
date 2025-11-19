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
    // Récupérer toutes les données utilisateur
    final documents = await LocalStorageService.getDocuments();
    final doctors = await DoctorService.getDoctors();
    
    return {
      'documents': documents,
      'doctors': doctors.map((d) => d.toMap()).toList(),
      'consultations': [], // TODO: Récupérer consultations
      'pain_records': [], // TODO: Récupérer depuis ARIA
    };
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

