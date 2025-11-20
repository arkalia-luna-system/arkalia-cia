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

        // Appel backend pour récupérer données depuis portail
        // TODO: Implémenter endpoints spécifiques selon portail quand APIs disponibles
        // Pour l'instant, retourner structure vide prête pour données
        
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
      // TODO: Implémenter refresh token selon portail
      return null;
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

