import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'backend_config_service.dart';
import 'auth_api_service.dart';

enum HealthPortal {
  ehealth,
  andaman7,
  masante,
}

class HealthPortalAuthService {

  // OAuth URLs pour chaque portail (URLs réelles eHealth, autres à vérifier)
  static const Map<HealthPortal, String> _authUrls = {
    HealthPortal.ehealth: 'https://iam.ehealth.fgov.be/iam-connect/oidc/authorize', // URL réelle eHealth
    HealthPortal.andaman7: 'https://www.andaman7.com/oauth/authorize', // À vérifier
    HealthPortal.masante: 'https://www.masante.be/oauth/authorize', // À vérifier
  };
  
  // Token URLs pour chaque portail
  static const Map<HealthPortal, String> _tokenUrls = {
    HealthPortal.ehealth: 'https://iam.ehealth.fgov.be/iam-connect/oidc/token', // URL réelle eHealth
    HealthPortal.andaman7: 'https://www.andaman7.com/oauth/token', // À vérifier
    HealthPortal.masante: 'https://www.masante.be/oauth/token', // À vérifier
  };

  static const Map<HealthPortal, String> _portalNames = {
    HealthPortal.ehealth: 'eHealth',
    HealthPortal.andaman7: 'Andaman 7',
    HealthPortal.masante: 'MaSanté',
  };

  /// Lance le processus d'authentification OAuth pour un portail
  /// Retourne l'URL de callback avec le code d'autorisation si succès
  Future<Map<String, dynamic>> authenticatePortal(HealthPortal portal) async {
    try {
      // Récupérer client_id depuis les préférences (configuré dans settings)
      final prefs = await SharedPreferences.getInstance();
      final clientIdKey = 'portal_client_id_${_portalNames[portal]?.toLowerCase()}';
      final clientId = prefs.getString(clientIdKey);
      
      // URLs de callback pour chaque portail (deep links)
      final callbackUrls = {
        HealthPortal.ehealth: 'arkaliacia://oauth/ehealth',
        HealthPortal.andaman7: 'arkaliacia://oauth/andaman7',
        HealthPortal.masante: 'arkaliacia://oauth/masante',
      };

      // Construire URL OAuth complète avec paramètres
      final baseAuthUrl = _authUrls[portal];
      if (baseAuthUrl == null) {
        return {'success': false, 'error': 'Portail non configuré'};
      }

      final callbackUrl = callbackUrls[portal] ?? 'arkaliacia://oauth/callback';
      final state = DateTime.now().millisecondsSinceEpoch.toString(); // State pour sécurité
      
      // Sauvegarder state pour vérification callback
      await prefs.setString('oauth_state_${portal.name}', state);

      // Construire URL OAuth avec paramètres
      final authUrl = Uri.parse(baseAuthUrl).replace(queryParameters: {
        'response_type': 'code',
        'client_id': clientId ?? 'arkalia_cia', // Client ID par défaut
        'redirect_uri': callbackUrl,
        'scope': _getPortalScopes(portal),
        'state': state,
      });

      // Ouvrir navigateur pour authentification OAuth
      if (await canLaunchUrl(authUrl)) {
        await launchUrl(authUrl, mode: LaunchMode.externalApplication);
        return {
          'success': true,
          'callback_url': callbackUrl,
          'state': state,
        };
      }
      return {'success': false, 'error': 'Impossible d\'ouvrir le navigateur'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Récupère les scopes OAuth requis pour chaque portail
  String _getPortalScopes(HealthPortal portal) {
    switch (portal) {
      case HealthPortal.ehealth:
        return 'ehealthbox.read consultations.read labresults.read'; // Scopes réels eHealth
      case HealthPortal.andaman7:
        return 'read:health_data read:documents'; // À vérifier
      case HealthPortal.masante:
        return 'read:medical_data read:documents'; // À vérifier
    }
  }

  /// Traite le callback OAuth et échange le code contre un token
  Future<Map<String, dynamic>> handleOAuthCallback(
    HealthPortal portal,
    String authorizationCode,
    String? state,
  ) async {
    try {
      // Vérifier state pour sécurité
      final prefs = await SharedPreferences.getInstance();
      final savedState = prefs.getString('oauth_state_${portal.name}');
      if (state != null && savedState != null && state != savedState) {
        return {'success': false, 'error': 'State invalide - possible attaque CSRF'};
      }

      // Récupérer client_id et client_secret
      final clientIdKey = 'portal_client_id_${_portalNames[portal]?.toLowerCase()}';
      final clientSecretKey = 'portal_client_secret_${_portalNames[portal]?.toLowerCase()}';
      final clientId = prefs.getString(clientIdKey) ?? 'arkalia_cia';
      final clientSecret = prefs.getString(clientSecretKey) ?? '';

      // URLs de token pour chaque portail (utiliser _tokenUrls si défini, sinon fallback)
      final tokenUrls = _tokenUrls.isNotEmpty 
          ? _tokenUrls 
          : {
              HealthPortal.ehealth: 'https://iam.ehealth.fgov.be/iam-connect/oidc/token', // URL réelle
              HealthPortal.andaman7: 'https://www.andaman7.com/oauth/token', // À vérifier
              HealthPortal.masante: 'https://www.masante.be/oauth/token', // À vérifier
            };

      final tokenUrl = tokenUrls[portal];
      if (tokenUrl == null) {
        return {'success': false, 'error': 'Portail non configuré'};
      }

      final callbackUrls = {
        HealthPortal.ehealth: 'arkaliacia://oauth/ehealth',
        HealthPortal.andaman7: 'arkaliacia://oauth/andaman7',
        HealthPortal.masante: 'arkaliacia://oauth/masante',
      };
      final callbackUrl = callbackUrls[portal] ?? 'arkaliacia://oauth/callback';

      // Échanger code contre token
      // Pour eHealth, utiliser application/x-www-form-urlencoded avec Basic Auth possible
      final headers = {'Content-Type': 'application/x-www-form-urlencoded'};
      
      // Pour eHealth, on peut aussi utiliser Basic Auth (client_id:client_secret en base64)
      // Mais pour l'instant, on utilise le format standard
      final response = await http.post(
        Uri.parse(tokenUrl),
        headers: headers,
        body: {
          'grant_type': 'authorization_code',
          'code': authorizationCode,
          'redirect_uri': callbackUrl,
          'client_id': clientId,
          'client_secret': clientSecret,
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final accessToken = data['access_token'] as String?;
        final refreshToken = data['refresh_token'] as String?;
        final expiresIn = data['expires_in'] as int?;

        if (accessToken != null) {
          // Sauvegarder tokens
          await saveAccessToken(portal, accessToken, refreshToken: refreshToken);
          
          // Sauvegarder expiration si disponible
          if (expiresIn != null) {
            final expiryTime = DateTime.now().add(Duration(seconds: expiresIn));
            await prefs.setString(
              'portal_token_expiry_${_portalNames[portal]?.toLowerCase()}',
              expiryTime.toIso8601String(),
            );
          }

          // Nettoyer state
          await prefs.remove('oauth_state_${portal.name}');

          return {
            'success': true,
            'access_token': accessToken,
            'refresh_token': refreshToken,
            'expires_in': expiresIn,
          };
        }
      }

      return {
        'success': false,
        'error': 'Erreur lors de l\'échange du code: ${response.statusCode}',
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Récupère les données depuis un portail authentifié
  Future<Map<String, dynamic>> fetchPortalData(
    HealthPortal portal,
    String accessToken,
  ) async {
    try {
      // Récupérer URL backend configurée
      final baseUrl = await BackendConfigService.getBackendURL();
      if (baseUrl.isEmpty) {
        return {'error': 'Backend non configuré'};
      }

      // Structure pour stocker les données récupérées
      final data = {
        'portal': _portalNames[portal],
        'documents': <Map<String, dynamic>>[],
        'consultations': <Map<String, dynamic>>[],
        'exams': <Map<String, dynamic>>[],
      };

      // Récupérer un token valide pour le portail (avec refresh si nécessaire)
      final portalToken = await getValidAccessToken(portal) ?? accessToken;
      
      // Appel API backend pour récupérer données portail avec endpoints spécifiques
      try {
        final headers = {'Content-Type': 'application/json'};
        final token = await AuthApiService.getAccessToken();
        if (token != null) {
          headers['Authorization'] = 'Bearer $token';
        }

        // Endpoints spécifiques pour chaque portail
        final portalEndpoints = {
          HealthPortal.ehealth: '/api/v1/health-portals/ehealth/fetch',
          HealthPortal.andaman7: '/api/v1/health-portals/andaman7/fetch',
          HealthPortal.masante: '/api/v1/health-portals/masante/fetch',
        };

        final endpoint = portalEndpoints[portal];
        if (endpoint != null && portalToken.isNotEmpty) {
          try {
            // Appel API spécifique au portail avec le token OAuth
            final response = await http.post(
              Uri.parse('$baseUrl$endpoint'),
              headers: {
                ...headers,
                'X-Portal-Token': portalToken, // Token OAuth du portail
              },
              body: jsonEncode({
                'access_token': portalToken,
                'portal': _portalNames[portal],
              }),
            ).timeout(const Duration(seconds: 30));

            if (response.statusCode == 200) {
              final responseData = jsonDecode(response.body) as Map<String, dynamic>;
              // Fusionner les données récupérées
              if (responseData['documents'] != null) {
                data['documents'] = List<Map<String, dynamic>>.from(responseData['documents']);
              }
              if (responseData['consultations'] != null) {
                data['consultations'] = List<Map<String, dynamic>>.from(responseData['consultations']);
              }
              if (responseData['exams'] != null) {
                data['exams'] = List<Map<String, dynamic>>.from(responseData['exams']);
              }
              return data;
            } else {
              // Si endpoint spécifique n'existe pas encore, utiliser endpoint générique
              return await _fetchGenericPortalData(baseUrl, headers, portal, portalToken);
            }
          } catch (e) {
            // En cas d'erreur, essayer endpoint générique
            return await _fetchGenericPortalData(baseUrl, headers, portal, portalToken);
          }
        } else {
          // Utiliser endpoint générique si pas de token ou endpoint spécifique
          return await _fetchGenericPortalData(baseUrl, headers, portal, portalToken);
        }
      } catch (e) {
        // En cas d'erreur, retourner structure vide
        return data;
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Récupère les données via l'endpoint générique (fallback)
  Future<Map<String, dynamic>> _fetchGenericPortalData(
    String baseUrl,
    Map<String, String> headers,
    HealthPortal portal,
    String portalToken,
  ) async {
    final data = {
      'portal': _portalNames[portal],
      'documents': <Map<String, dynamic>>[],
      'consultations': <Map<String, dynamic>>[],
      'exams': <Map<String, dynamic>>[],
    };

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/health-portals/import'),
        headers: headers,
        body: jsonEncode({
          'portal': _portalNames[portal],
          'access_token': portalToken,
          'action': 'fetch',
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        if (responseData['data'] != null) {
          final fetchedData = responseData['data'] as Map<String, dynamic>;
          if (fetchedData['documents'] != null) {
            data['documents'] = List<Map<String, dynamic>>.from(fetchedData['documents']);
          }
          if (fetchedData['consultations'] != null) {
            data['consultations'] = List<Map<String, dynamic>>.from(fetchedData['consultations']);
          }
          if (fetchedData['exams'] != null) {
            data['exams'] = List<Map<String, dynamic>>.from(fetchedData['exams']);
          }
        }
      }
    } catch (e) {
      // Ignorer erreur, retourner structure vide
    }
    
    return data;
  }

  /// Sauvegarde le token OAuth pour un portail
  Future<bool> saveAccessToken(HealthPortal portal, String accessToken, {String? refreshToken}) async {
    try {
      // Utiliser SharedPreferences pour stockage local
      // Note: Pour production, utiliser flutter_secure_storage pour plus de sécurité
      final prefs = await SharedPreferences.getInstance();
      final portalKey = 'portal_token_${_portalNames[portal]?.toLowerCase()}';
      await prefs.setString(portalKey, accessToken);
      if (refreshToken != null) {
        await prefs.setString('${portalKey}_refresh', refreshToken);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Récupère le token OAuth sauvegardé pour un portail
  Future<String?> getAccessToken(HealthPortal portal) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final portalKey = 'portal_token_${_portalNames[portal]?.toLowerCase()}';
      return prefs.getString(portalKey);
    } catch (e) {
      return null;
    }
  }

  /// Rafraîchit le token OAuth si expiré
  Future<String?> refreshAccessToken(HealthPortal portal, String refreshToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final portalKey = 'portal_token_${_portalNames[portal]?.toLowerCase()}';
      final refreshTokenKey = '${portalKey}_refresh';
      
      // Récupérer le refresh token sauvegardé
      final savedRefreshToken = prefs.getString(refreshTokenKey);
      if (savedRefreshToken == null) {
        return null;
      }

      // URLs de refresh pour chaque portail (à configurer selon documentation réelle)
      final refreshUrls = {
        HealthPortal.ehealth: 'https://www.ehealth.fgov.be/fr/oauth/token',
        HealthPortal.andaman7: 'https://www.andaman7.com/oauth/token',
        HealthPortal.masante: 'https://www.masante.be/oauth/token',
      };

      final refreshUrl = refreshUrls[portal];
      if (refreshUrl == null) {
        return null;
      }

      // Appel API pour rafraîchir le token
      final response = await http.post(
        Uri.parse(refreshUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'refresh_token',
          'refresh_token': savedRefreshToken,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final newAccessToken = data['access_token'] as String?;
        final newRefreshToken = data['refresh_token'] as String?;
        
        if (newAccessToken != null) {
          // Sauvegarder le nouveau token
          await prefs.setString(portalKey, newAccessToken);
          if (newRefreshToken != null) {
            await prefs.setString(refreshTokenKey, newRefreshToken);
          }
          return newAccessToken;
        }
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Vérifie si le token est expiré et le rafraîchit si nécessaire
  Future<String?> getValidAccessToken(HealthPortal portal) async {
    try {
      final token = await getAccessToken(portal);
      if (token == null) {
        return null;
      }

      final prefs = await SharedPreferences.getInstance();
      final portalKey = 'portal_token_${_portalNames[portal]?.toLowerCase()}';
      final refreshTokenKey = '${portalKey}_refresh';
      final expiryKey = 'portal_token_expiry_${_portalNames[portal]?.toLowerCase()}';
      
      // Vérifier expiration
      final expiryString = prefs.getString(expiryKey);
      if (expiryString != null) {
        try {
          final expiryTime = DateTime.parse(expiryString);
          final now = DateTime.now();
          
          // Si token expiré ou expire dans moins de 5 minutes, rafraîchir
          if (now.isAfter(expiryTime.subtract(const Duration(minutes: 5)))) {
            final savedRefreshToken = prefs.getString(refreshTokenKey);
            if (savedRefreshToken != null) {
              // Rafraîchir le token
              final newToken = await refreshAccessToken(portal, savedRefreshToken);
              if (newToken != null) {
                return newToken;
              }
            }
            // Si refresh échoué, retourner null (token expiré)
            return null;
          }
        } catch (e) {
          // Erreur parsing date, continuer avec token existant
        }
      }
      
      // Vérifier si refresh token existe pour usage futur
      final savedRefreshToken = prefs.getString(refreshTokenKey);
      if (savedRefreshToken != null) {
        // Refresh token disponible
      }
      
      return token;
    } catch (e) {
      return null;
    }
  }

  /// Configure les credentials OAuth pour un portail
  Future<bool> setPortalCredentials(
    HealthPortal portal,
    String clientId,
    String clientSecret,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final clientIdKey = 'portal_client_id_${_portalNames[portal]?.toLowerCase()}';
      final clientSecretKey = 'portal_client_secret_${_portalNames[portal]?.toLowerCase()}';
      
      await prefs.setString(clientIdKey, clientId);
      await prefs.setString(clientSecretKey, clientSecret);
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Récupère les credentials OAuth configurés pour un portail
  Future<Map<String, String?>> getPortalCredentials(HealthPortal portal) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final clientIdKey = 'portal_client_id_${_portalNames[portal]?.toLowerCase()}';
      final clientSecretKey = 'portal_client_secret_${_portalNames[portal]?.toLowerCase()}';
      
      return {
        'client_id': prefs.getString(clientIdKey),
        'client_secret': prefs.getString(clientSecretKey),
      };
    } catch (e) {
      return {'client_id': null, 'client_secret': null};
    }
  }

  /// Importe les données depuis un portail
  Future<bool> importFromPortal(
    HealthPortal portal,
    Map<String, dynamic> data,
  ) async {
    try {
      // Récupérer URL backend configurée
      final baseUrl = await BackendConfigService.getBackendURL();
      if (baseUrl.isEmpty) {
        return false;
      }
      
      // Envoyer données au backend pour traitement
      final headers = {'Content-Type': 'application/json'};
      final token = await AuthApiService.getAccessToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/health-portals/import'),
        headers: headers,
        body: jsonEncode({
          'portal': _portalNames[portal],
          'data': data,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static String getPortalName(HealthPortal portal) {
    return _portalNames[portal] ?? 'Portail inconnu';
  }
}

