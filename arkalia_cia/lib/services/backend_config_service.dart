import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../utils/app_logger.dart';

/// Service de configuration du backend API
class BackendConfigService {
  static const String _backendUrlKey = 'backend_api_url';
  static const String _backendEnabledKey = 'backend_enabled';

  /// Récupère l'URL du backend depuis les préférences
  static Future<String> getBackendURL() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUrl = prefs.getString(_backendUrlKey);
    
    // Si aucune URL n'est configurée, utiliser localhost:8000 par défaut pour le web
    if (savedUrl == null || savedUrl.isEmpty) {
      if (kIsWeb) {
        // Sur le web, localhost:8000 fonctionne
        return 'http://localhost:8000';
      }
      // Sur mobile, retourner vide pour forcer la configuration
      return '';
    }
    
    // Si l'URL contient localhost ou 127.0.0.1, remplacer par une IP vide
    // pour forcer la reconfiguration sur mobile (mais OK sur web)
    if (savedUrl.contains('localhost') || savedUrl.contains('127.0.0.1')) {
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        AppLogger.warning('localhost détecté sur mobile - URL invalide, retour vide');
        return '';
      }
    }
    
    return savedUrl;
  }

  /// Définit l'URL du backend
  static Future<void> setBackendURL(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_backendUrlKey, url);
  }

  /// Vérifie si le backend est activé
  static Future<bool> isBackendEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_backendEnabledKey) ?? false;
  }

  /// Active ou désactive le backend
  static Future<void> setBackendEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_backendEnabledKey, enabled);
  }

  /// Teste la connexion au backend
  static Future<bool> testConnection(String url) async {
    try {
      final response = await http
          .get(Uri.parse('$url/health'))
          .timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

