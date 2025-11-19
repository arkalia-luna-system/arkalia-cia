import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../utils/retry_helper.dart';
import '../utils/error_helper.dart';
import 'backend_config_service.dart';
import 'offline_cache_service.dart';

class ApiService {
  static Future<String> get baseUrl async => await BackendConfigService.getBackendURL();

  // Headers communs
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
  };

  /// Vérifie si le backend est configuré et disponible
  static Future<bool> isBackendConfigured() async {
    final url = await baseUrl;
    if (url.isEmpty) {
      return false;
    }
    return await BackendConfigService.isBackendEnabled();
  }

  // === DOCUMENTS ===

  /// Upload un document PDF
  static Future<Map<String, dynamic>> uploadDocument(File pdfFile) async {
    try {
      final url = await baseUrl;
      if (url.isEmpty) {
        return {
          'success': false,
          'error': 'Backend non configuré. Configurez l\'URL du backend dans les paramètres.',
          'backend_not_configured': true,
        };
      }
      
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

  /// Récupère tous les documents avec retry automatique et cache offline
  static Future<List<Map<String, dynamic>>> getDocuments() async {
    // Essayer d'abord le cache offline
    final cached = await OfflineCacheService.getCachedData('documents');
    if (cached != null) {
      debugPrint('Utilisation du cache offline pour documents');
    }

    return RetryHelper.retryOnNetworkError(
      fn: () async {
        final url = await baseUrl;
        if (url.isEmpty) {
          // Retourner le cache si disponible, sinon liste vide
          if (cached != null && cached is List) {
            return List<Map<String, dynamic>>.from(
              cached.map((item) => item as Map<String, dynamic>)
            );
          }
          return <Map<String, dynamic>>[];
        }
        
        final response = await http
            .get(
              Uri.parse('$url/api/documents'),
              headers: _headers,
            )
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          List<dynamic> data = json.decode(response.body);
          final result = data.cast<Map<String, dynamic>>();
          
          // Mettre en cache pour usage offline
          await OfflineCacheService.cacheData('documents', result);
          
          return result;
        } else {
          throw Exception('Erreur HTTP ${response.statusCode}');
        }
      },
    ).catchError((e) {
      ErrorHelper.logError(e, context: 'getDocuments');
      
      // En cas d'erreur réseau, retourner le cache si disponible
      if (ErrorHelper.isNetworkError(e) && cached != null) {
        debugPrint('Erreur réseau, utilisation du cache offline');
        return List<Map<String, dynamic>>.from(cached);
      }
      
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
        final errorMsg = ErrorHelper.getUserFriendlyMessage(
          Exception('HTTP ${response.statusCode}'),
        );
        return {
          'success': false,
          'error': errorMsg,
          'status_code': response.statusCode,
        };
      }
    } catch (e) {
      ErrorHelper.logError(e, context: 'createReminder');
      return {
        'success': false,
        'error': ErrorHelper.getUserFriendlyMessage(e),
        'technical_error': e.toString(),
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
      ErrorHelper.logError(e, context: 'getReminders');
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
        final errorMsg = ErrorHelper.getUserFriendlyMessage(
          Exception('HTTP ${response.statusCode}'),
        );
        return {
          'success': false,
          'error': errorMsg,
          'status_code': response.statusCode,
        };
      }
    } catch (e) {
      ErrorHelper.logError(e, context: 'createEmergencyContact');
      return {
        'success': false,
        'error': ErrorHelper.getUserFriendlyMessage(e),
        'technical_error': e.toString(),
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
      ErrorHelper.logError(e, context: 'getEmergencyContacts');
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
    // Vérifier si le backend est disponible avant d'essayer
    final backendEnabled = await BackendConfigService.isBackendEnabled();
    if (!backendEnabled) {
      return {
        'success': false,
        'error': 'Backend non disponible',
        'backend_disabled': true,
      };
    }

    try {
      final baseUrlValue = await baseUrl;
      
      // Test rapide de connexion avant la requête principale
      final isConnected = await BackendConfigService.testConnection(baseUrlValue);
      if (!isConnected) {
        return {
          'success': false,
          'error': 'Backend non disponible',
          'backend_unavailable': true,
        };
      }

      final response = await http.post(
        Uri.parse('$baseUrlValue/api/health-portals'),
        headers: _headers,
        body: json.encode({
          'name': name,
          'url': url,
          'description': description,
          'category': category,
        }),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorMsg = ErrorHelper.getUserFriendlyMessage(
          Exception('HTTP ${response.statusCode}'),
        );
        return {
          'success': false,
          'error': errorMsg,
          'status_code': response.statusCode,
        };
      }
    } catch (e) {
      // Ne logger l'erreur que si ce n'est pas une erreur de connexion normale (backend non disponible)
      final errorString = e.toString().toLowerCase();
      final isConnectionRefused = e is SocketException && 
                                  (errorString.contains('connection refused') || 
                                   errorString.contains('errno = 61'));
      
      if (!isConnectionRefused) {
        ErrorHelper.logError(e, context: 'createHealthPortal');
      }
      
      return {
        'success': false,
        'error': ErrorHelper.getUserFriendlyMessage(e),
        'technical_error': e.toString(),
        'backend_unavailable': e is SocketException,
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
      ErrorHelper.logError(e, context: 'getHealthPortals');
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
