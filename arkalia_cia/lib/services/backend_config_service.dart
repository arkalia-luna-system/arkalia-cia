import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

/// Service de configuration du backend API
class BackendConfigService {
  static const String _backendUrlKey = 'backend_api_url';
  static const String _backendEnabledKey = 'backend_enabled';
  static const String _defaultUrl = 'http://localhost:8000';

  /// Récupère l'URL du backend depuis les préférences
  static Future<String> getBackendURL() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_backendUrlKey) ?? _defaultUrl;
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

