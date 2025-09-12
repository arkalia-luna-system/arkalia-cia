import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:8000';

  // Headers communs
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
  };

  // === DOCUMENTS ===

  /// Upload un document PDF
  static Future<Map<String, dynamic>> uploadDocument(File pdfFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/documents/upload'),
      );

      request.files.add(await http.MultipartFile.fromPath(
        'file',
        pdfFile.path,
        filename: pdfFile.path.split('/').last,
      ));

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return json.decode(responseBody);
      } else {
        return {
          'success': false,
          'error': 'Erreur upload: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erreur: $e',
      };
    }
  }

  /// Récupère tous les documents
  static Future<List<Map<String, dynamic>>> getDocuments() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/documents'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('Erreur récupération documents: $e');
      return [];
    }
  }

  /// Supprime un document
  static Future<bool> deleteDocument(int documentId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/documents/$documentId'),
        headers: _headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Erreur suppression document: $e');
      return false;
    }
  }

  // === RAPPELS ===

  /// Crée un rappel
  static Future<Map<String, dynamic>> createReminder({
    required String title,
    String? description,
    required String reminderDate,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/reminders'),
        headers: _headers,
        body: json.encode({
          'title': title,
          'description': description,
          'reminder_date': reminderDate,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'error': 'Erreur création rappel: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erreur: $e',
      };
    }
  }

  /// Récupère tous les rappels
  static Future<List<Map<String, dynamic>>> getReminders() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/reminders'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('Erreur récupération rappels: $e');
      return [];
    }
  }

  // === CONTACTS D'URGENCE ===

  /// Crée un contact d'urgence
  static Future<Map<String, dynamic>> createEmergencyContact({
    required String name,
    required String phone,
    String? relationship,
    bool isPrimary = false,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/emergency-contacts'),
        headers: _headers,
        body: json.encode({
          'name': name,
          'phone': phone,
          'relationship': relationship,
          'is_primary': isPrimary,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'error': 'Erreur création contact: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erreur: $e',
      };
    }
  }

  /// Récupère tous les contacts d'urgence
  static Future<List<Map<String, dynamic>>> getEmergencyContacts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/emergency-contacts'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('Erreur récupération contacts: $e');
      return [];
    }
  }

  // === PORTAILS SANTÉ ===

  /// Crée un portail santé
  static Future<Map<String, dynamic>> createHealthPortal({
    required String name,
    required String url,
    String? description,
    String? category,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/health-portals'),
        headers: _headers,
        body: json.encode({
          'name': name,
          'url': url,
          'description': description,
          'category': category,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'error': 'Erreur création portail: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erreur: $e',
      };
    }
  }

  /// Récupère tous les portails santé
  static Future<List<Map<String, dynamic>>> getHealthPortals() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/health-portals'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('Erreur récupération portails: $e');
      return [];
    }
  }

  // === UTILITAIRES ===

  /// Teste la connexion à l'API
  static Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: _headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
