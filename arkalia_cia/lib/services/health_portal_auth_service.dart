import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';

enum HealthPortal {
  ehealth,
  andaman7,
  masante,
}

class HealthPortalAuthService {
  static const String _baseUrl = 'http://localhost:8000';

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
      // TODO: Implémenter récupération données selon portail
      // Pour l'instant, retourner structure vide
      return {
        'portal': _portalNames[portal],
        'documents': [],
        'consultations': [],
        'exams': [],
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Importe les données depuis un portail
  Future<bool> importFromPortal(
    HealthPortal portal,
    Map<String, dynamic> data,
  ) async {
    try {
      // Envoyer données au backend pour traitement
      final response = await http.post(
        Uri.parse('$_baseUrl/api/health-portals/import'),
        headers: {'Content-Type': 'application/json'},
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

