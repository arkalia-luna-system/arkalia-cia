import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../utils/retry_helper.dart';
import 'backend_config_service.dart';

class ApiService {
  static Future<String> get baseUrl async => await BackendConfigService.getBackendURL();

  // Headers communs
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
  };

  // === DOCUMENTS ===

  /// Upload un document PDF
  static Future<Map<String, dynamic>> uploadDocument(File pdfFile) async {
    try {
      final url = await baseUrl;
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$url/api/documents/upload'),
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

  /// Récupère tous les documents avec retry automatique
  static Future<List<Map<String, dynamic>>> getDocuments() async {
    return RetryHelper.retryOnNetworkError(
      fn: () async {
        final url = await baseUrl;
        final response = await http
            .get(
              Uri.parse('$url/api/documents'),
              headers: _headers,
            )
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          List<dynamic> data = json.decode(response.body);
          return data.cast<Map<String, dynamic>>();
        } else {
          throw Exception('Erreur HTTP ${response.statusCode}');
        }
      },
    ).catchError((e) {
      debugPrint('Erreur récupération documents après retry: $e');
      return <Map<String, dynamic>>[];
    });
  }

  /// Supprime un document
  static Future<bool> deleteDocument(int documentId) async {
    try {
      final url = await baseUrl;
      final response = await http.delete(
        Uri.parse('$url/api/documents/$documentId'),
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
      final url = await baseUrl;
      final response = await http.post(
        Uri.parse('$url/api/reminders'),
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

  /// Récupère tous les rappels avec retry automatique
  static Future<List<Map<String, dynamic>>> getReminders() async {
    return RetryHelper.retryOnNetworkError(
      fn: () async {
        final url = await baseUrl;
        final response = await http
            .get(
              Uri.parse('$url/api/reminders'),
              headers: _headers,
            )
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          List<dynamic> data = json.decode(response.body);
          return data.cast<Map<String, dynamic>>();
        } else {
          throw Exception('Erreur HTTP ${response.statusCode}');
        }
      },
    ).catchError((e) {
      debugPrint('Erreur récupération rappels après retry: $e');
      return <Map<String, dynamic>>[];
    });
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
      final url = await baseUrl;
      final response = await http.post(
        Uri.parse('$url/api/emergency-contacts'),
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

  /// Récupère tous les contacts d'urgence avec retry automatique
  static Future<List<Map<String, dynamic>>> getEmergencyContacts() async {
    return RetryHelper.retryOnNetworkError(
      fn: () async {
        final url = await baseUrl;
        final response = await http
            .get(
              Uri.parse('$url/api/emergency-contacts'),
              headers: _headers,
            )
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          List<dynamic> data = json.decode(response.body);
          return data.cast<Map<String, dynamic>>();
        } else {
          throw Exception('Erreur HTTP ${response.statusCode}');
        }
      },
    ).catchError((e) {
      debugPrint('Erreur récupération contacts après retry: $e');
      return <Map<String, dynamic>>[];
    });
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
      final baseUrlValue = await baseUrl;
      final response = await http.post(
        Uri.parse('$baseUrlValue/api/health-portals'),
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

  /// Récupère tous les portails santé avec retry automatique
  static Future<List<Map<String, dynamic>>> getHealthPortals() async {
    return RetryHelper.retryOnNetworkError(
      fn: () async {
        final url = await baseUrl;
        final response = await http
            .get(
              Uri.parse('$url/api/health-portals'),
              headers: _headers,
            )
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          List<dynamic> data = json.decode(response.body);
          return data.cast<Map<String, dynamic>>();
        } else {
          throw Exception('Erreur HTTP ${response.statusCode}');
        }
      },
    ).catchError((e) {
      debugPrint('Erreur récupération portails après retry: $e');
      return <Map<String, dynamic>>[];
    });
  }

  // === UTILITAIRES ===

  /// Teste la connexion à l'API
  static Future<bool> testConnection() async {
    try {
      final url = await baseUrl;
      final response = await http.get(
        Uri.parse('$url/health'),
        headers: _headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
