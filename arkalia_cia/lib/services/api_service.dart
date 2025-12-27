import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../utils/retry_helper.dart';
import '../utils/error_helper.dart';
import '../utils/app_logger.dart';
import 'backend_config_service.dart';
import 'offline_cache_service.dart';
import 'auth_api_service.dart';

class ApiService {
  static Future<String> get baseUrl async => await BackendConfigService.getBackendURL();

  // Headers communs avec authentification JWT
  static Future<Map<String, String>> get _headers async {
    final headers = {
      'Content-Type': 'application/json',
    };
    
    // Ajouter le token JWT si disponible
    final token = await AuthApiService.getAccessToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  /// Vérifie si le backend est configuré et disponible
  static Future<bool> isBackendConfigured() async {
    final url = await baseUrl;
    if (url.isEmpty) {
      return false;
    }
    return await BackendConfigService.isBackendEnabled();
  }

  // === DOCUMENTS ===

  /// Upload un document PDF avec gestion automatique du refresh token
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
      
      // Fonction pour créer et envoyer la requête multipart
      Future<http.StreamedResponse> makeMultipartRequest() async {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('$url/api/v1/documents/upload'),
        );
        
        // Ajouter le token JWT
        final token = await AuthApiService.getAccessToken();
        if (token != null) {
          request.headers['Authorization'] = 'Bearer $token';
        }

        request.files.add(await http.MultipartFile.fromPath(
          'file',
          pdfFile.path,
          filename: pdfFile.path.split('/').last,
        ));

        return await request.send();
      }

      // Première tentative
      var response = await makeMultipartRequest();
      var responseBody = await response.stream.bytesToString();

      // Si 401 (Unauthorized), essayer de rafraîchir le token
      if (response.statusCode == 401) {
        AppLogger.debug('Token expiré lors de l\'upload, tentative de rafraîchissement...');
        final refreshResult = await AuthApiService.refreshToken();

        if (refreshResult['success'] == true) {
          // Token rafraîchi, réessayer l'upload
          AppLogger.debug('Token rafraîchi avec succès, nouvelle tentative d\'upload...');
          response = await makeMultipartRequest();
          responseBody = await response.stream.bytesToString();
        } else {
          // Refresh échoué, déconnecter l'utilisateur
          AppLogger.debug('Impossible de rafraîchir le token, déconnexion...');
          await AuthApiService.logout();
          return {
            'success': false,
            'error': 'Session expirée. Veuillez vous reconnecter.',
            'session_expired': true,
          };
        }
      }

      if (response.statusCode == 200) {
        return json.decode(responseBody);
      } else {
        return {
          'success': false,
          'error': 'Erreur upload: ${response.statusCode}',
        };
      }
    } catch (e) {
      AppLogger.error('Erreur upload document', e);
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
      AppLogger.debug('Utilisation du cache offline pour documents');
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
        
        final response = await _makeAuthenticatedRequest(() async {
          final headers = await _headers;
          return await http
              .get(
                Uri.parse('$url/api/v1/documents'),
                headers: headers,
              )
              .timeout(const Duration(seconds: 10));
        });

        List<dynamic> data = response as List;
        final result = data.cast<Map<String, dynamic>>();
        
        // Mettre en cache pour usage offline
        await OfflineCacheService.cacheData('documents', result);
        
        return result;
      },
    ).catchError((e) {
      ErrorHelper.logError('ApiService.getDocuments', e);
      
      // En cas d'erreur réseau, retourner le cache si disponible
      if (ErrorHelper.isNetworkError(e) && cached != null) {
        AppLogger.debug('Erreur réseau, utilisation du cache offline');
        return List<Map<String, dynamic>>.from(cached);
      }
      
      return <Map<String, dynamic>>[];
    });
  }

  /// Supprime un document
  static Future<bool> deleteDocument(int documentId) async {
    try {
      final url = await baseUrl;
      await _makeAuthenticatedRequest(() async {
        final headers = await _headers;
        return await http.delete(
          Uri.parse('$url/api/v1/documents/$documentId'),
          headers: headers,
        );
      });
      return true;
    } catch (e) {
      AppLogger.error('Erreur suppression document', e);
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
      final response = await _makeAuthenticatedRequest(() async {
        final headers = await _headers;
        return await http.post(
          Uri.parse('$url/api/v1/reminders'),
          headers: headers,
          body: json.encode({
            'title': title,
            'description': description,
            'reminder_date': reminderDate,
          }),
        );
      });

      if (response is http.Response) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          final jsonData = json.decode(response.body) as Map<String, dynamic>;
          return jsonData;
        }
      }
      
      return {
        'success': false,
        'error': 'Erreur lors de la création du rappel',
      };
    } catch (e) {
      ErrorHelper.logError('ApiService.createReminder', e);
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
        final response = await _makeAuthenticatedRequest(() async {
          final headers = await _headers;
          return await http
              .get(
                Uri.parse('$url/api/v1/reminders'),
                headers: headers,
              )
              .timeout(const Duration(seconds: 10));
        });

        List<dynamic> data = response as List;
        return data.cast<Map<String, dynamic>>();
      },
    ).catchError((e) {
      ErrorHelper.logError('ApiService.getReminders', e);
      return <Map<String, dynamic>>[];
    });
  }

  // === CONTACTS D'URGENCE ===

  /// Crée un contact d'urgence avec gestion automatique du refresh token
  static Future<Map<String, dynamic>> createEmergencyContact({
    required String name,
    required String phone,
    String? relationship,
    bool isPrimary = false,
  }) async {
    try {
      final url = await baseUrl;
      if (url.isEmpty) {
        return {
          'success': false,
          'error': 'Backend non configuré. Configurez l\'URL du backend dans les paramètres.',
          'backend_not_configured': true,
        };
      }

      final response = await _makeAuthenticatedRequest(() async {
        final headers = await _headers;
        return await http.post(
          Uri.parse('$url/api/v1/emergency-contacts'),
          headers: headers,
          body: json.encode({
            'name': name,
            'phone': phone,
            'relationship': relationship,
            'is_primary': isPrimary,
          }),
        ).timeout(const Duration(seconds: 10));
      });

      // _makeAuthenticatedRequest retourne un Map décodé en cas de succès
      // ou lance une Exception en cas d'erreur (géré par le catch)
      if (response is Map<String, dynamic>) {
        // Succès : retourner la réponse du backend (contient id, name, phone, etc.)
        return response;
      } else {
        // Réponse inattendue
        return {
          'success': false,
          'error': 'Réponse inattendue du serveur',
        };
      }
    } catch (e) {
      ErrorHelper.logError('ApiService.createEmergencyContact', e);
      
      // Extraire le message d'erreur de l'exception
      String errorMsg;
      final errorString = e.toString();
      
      // Si l'exception contient un message détaillé (venant de _makeAuthenticatedRequest)
      if (errorString.startsWith('Exception: ')) {
        errorMsg = errorString.substring(11); // Enlever "Exception: "
      } else {
        errorMsg = ErrorHelper.getUserFriendlyMessage(e);
      }
      
      // Vérifier si c'est une erreur de timeout ou de connexion
      if (errorString.contains('TimeoutException') || errorString.contains('timeout')) {
        errorMsg = 'Délai d\'attente dépassé. Vérifiez votre connexion.';
      } else if (errorString.contains('SocketException') || errorString.contains('Failed host lookup')) {
        errorMsg = 'Impossible de se connecter au serveur. Vérifiez votre connexion internet.';
      }
      
      return {
        'success': false,
        'error': errorMsg,
        'technical_error': e.toString(),
      };
    }
  }

  /// Récupère tous les contacts d'urgence avec retry automatique
  static Future<List<Map<String, dynamic>>> getEmergencyContacts() async {
    return RetryHelper.retryOnNetworkError(
      fn: () async {
        final url = await baseUrl;
        final response = await _makeAuthenticatedRequest(() async {
          final headers = await _headers;
          return await http
              .get(
                Uri.parse('$url/api/v1/emergency-contacts'),
                headers: headers,
              )
              .timeout(const Duration(seconds: 10));
        });

        List<dynamic> data = response as List;
        return data.cast<Map<String, dynamic>>();
      },
    ).catchError((e) {
      ErrorHelper.logError('ApiService.getEmergencyContacts', e);
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

      final headers = await _headers;
      final response = await http.post(
        Uri.parse('$baseUrlValue/api/v1/health-portals'),
        headers: headers,
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
        ErrorHelper.logError('ApiService.createHealthPortal', e);
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
        final response = await _makeAuthenticatedRequest(() async {
          final headers = await _headers;
          return await http
              .get(
                Uri.parse('$url/api/v1/health-portals'),
                headers: headers,
              )
              .timeout(const Duration(seconds: 10));
        });

        List<dynamic> data = response as List;
        return data.cast<Map<String, dynamic>>();
      },
    ).catchError((e) {
      ErrorHelper.logError('ApiService.getHealthPortals', e);
      return <Map<String, dynamic>>[];
    });
  }

  // === UTILITAIRES ===

  /// Teste la connexion à l'API
  static Future<bool> testConnection() async {
    try {
      final url = await baseUrl;
      final headers = await _headers;
      final response = await http.get(
        Uri.parse('$url/health'),
        headers: headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Méthode générique GET avec gestion automatique du refresh token
  static Future<dynamic> get(String endpoint) async {
    return _makeAuthenticatedRequest(() async {
      final url = await baseUrl;
      if (url.isEmpty) {
        // Retourner une réponse HTTP vide au lieu d'une liste vide
        return http.Response('[]', 200);
      }

      final headers = await _headers;
      final response = await http
          .get(
            Uri.parse('$url$endpoint'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      return response;
    });
  }

  /// Méthode helper pour gérer automatiquement le refresh token en cas de 401
  /// Retourne la réponse décodée si succès, ou lance une exception si erreur
  static Future<dynamic> _makeAuthenticatedRequest(
    Future<http.Response> Function() makeRequest,
  ) async {
    try {
      var response = await makeRequest();

      // Si 401 (Unauthorized), essayer de rafraîchir le token
      if (response.statusCode == 401) {
        AppLogger.debug('Token expiré, tentative de rafraîchissement...');
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
        return json.decode(body);
      } else {
        // Pour les erreurs, essayer de décoder le message d'erreur
        try {
          final errorData = json.decode(response.body);
          // FastAPI peut retourner 'detail' comme string ou liste (pour erreurs de validation)
          dynamic detail = errorData['detail'];
          String errorMsg;
          
          if (detail is List && detail.isNotEmpty) {
            // Si detail est une liste (erreurs de validation FastAPI)
            // Extraire le message de la première erreur
            final firstError = detail.first;
            if (firstError is Map && firstError.containsKey('msg')) {
              errorMsg = firstError['msg'] as String;
            } else {
              errorMsg = firstError.toString();
            }
          } else if (detail is String) {
            errorMsg = detail;
          } else {
            errorMsg = errorData['message'] ?? 
                      errorData['error'] ??
                      'Erreur HTTP ${response.statusCode}';
          }
          
          AppLogger.debug('Erreur API (${response.statusCode}): $errorMsg');
          throw Exception(errorMsg);
        } catch (e) {
          // Si le parsing échoue ou si c'est déjà une Exception, la relancer
          if (e is Exception) {
            rethrow;
          }
          throw Exception('Erreur HTTP ${response.statusCode}');
        }
      }
    } catch (e) {
      if (e.toString().contains('Session expirée')) {
        rethrow;
      }
      AppLogger.error('Erreur requête authentifiée', e);
      rethrow;
    }
  }

  // === RAPPORTS MÉDICAUX ===

  /// Génère un rapport médical pré-consultation combinant CIA + ARIA
  /// 
  /// [consultationDate] Date de consultation (ISO format, optionnel, défaut: aujourd'hui)
  /// [daysRange] Nombre de jours à inclure (défaut: 30)
  /// [includeAria] Inclure les données ARIA si disponibles (défaut: true)
  static Future<Map<String, dynamic>> generateMedicalReport({
    String? consultationDate,
    int daysRange = 30,
    bool includeAria = true,
  }) async {
    try {
      final url = await baseUrl;
      if (url.isEmpty) {
        return {
          'success': false,
          'error': 'Backend non configuré',
          'backend_not_configured': true,
        };
      }

      final headers = await _headers;
      final body = json.encode({
        if (consultationDate != null) 'consultation_date': consultationDate,
        'days_range': daysRange,
        'include_aria': includeAria,
      });

      final response = await http
          .post(
            Uri.parse('$url/api/v1/medical-reports/generate'),
            headers: headers,
            body: body,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': errorData['detail'] ?? 'Erreur lors de la génération du rapport',
        };
      }
    } catch (e) {
      AppLogger.error('Erreur génération rapport médical', e);
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}
