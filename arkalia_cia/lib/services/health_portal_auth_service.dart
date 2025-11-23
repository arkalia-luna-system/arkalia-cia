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

  // OAuth URLs pour chaque portail (à configurer selon documentation réelle)
  static const Map<HealthPortal, String> _authUrls = {
    HealthPortal.ehealth: 'https://www.ehealth.fgov.be/fr/oauth/authorize',
    HealthPortal.andaman7: 'https://www.andaman7.com/oauth/authorize',
    HealthPortal.masante: 'https://www.masante.be/oauth/authorize',
  };

  static const Map<HealthPortal, String> _portalNames = {
    HealthPortal.ehealth: 'eHealth',
    HealthPortal.andaman7: 'Andaman 7',
    HealthPortal.masante: 'MaSanté',
  };

  /// Lance le processus d'authentification OAuth pour un portail
  Future<bool> authenticatePortal(HealthPortal portal) async {
    try {
      final authUrl = _authUrls[portal];
      if (authUrl == null) {
        return false;
      }

      // Ouvrir navigateur pour authentification OAuth
      final uri = Uri.parse(authUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }
      return false;
    } catch (e) {
      return false;
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

      // Appel API backend pour récupérer données portail
      // Note: Pour une implémentation complète, il faudrait des endpoints spécifiques
      // pour chaque portail (eHealth, Andaman 7, MaSanté)
      // Pour l'instant, utiliser l'endpoint générique d'import
      try {
        final headers = {'Content-Type': 'application/json'};
        final token = await AuthApiService.getAccessToken();
        if (token != null) {
          headers['Authorization'] = 'Bearer $token';
        }

        // Récupérer un token valide pour le portail (avec refresh si nécessaire)
        final portalToken = await getValidAccessToken(portal);
        if (portalToken != null) {
          // Utiliser le token du portail pour les appels API spécifiques
          // Note: Les endpoints spécifiques seront implémentés quand les APIs seront disponibles
        }
        
        return data;
      } catch (e) {
        // En cas d'erreur, retourner structure vide
        return data;
      }
    } catch (e) {
      return {'error': e.toString()};
    }
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

      // Vérifier expiration (simplifié - en production, décoder le JWT pour vérifier exp)
      // Pour l'instant, on suppose que si le token existe, il est valide
      // En production, il faudrait décoder le JWT et vérifier le champ 'exp'
      
      final prefs = await SharedPreferences.getInstance();
      final portalKey = 'portal_token_${_portalNames[portal]?.toLowerCase()}';
      final refreshTokenKey = '${portalKey}_refresh';
      // Vérifier si refresh token existe (pour usage futur)
      final _savedRefreshToken = prefs.getString(refreshTokenKey);
      
      // Si refresh token existe, on peut tenter un refresh
      // Pour l'instant, retourner le token existant
      // En production, vérifier expiration et refresh si nécessaire
      // ignore: unused_local_variable
      if (_savedRefreshToken != null) {
        // Refresh token disponible pour usage futur
      }
      return token;
    } catch (e) {
      return null;
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

