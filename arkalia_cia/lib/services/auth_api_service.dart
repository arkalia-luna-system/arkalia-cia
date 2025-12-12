import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../utils/app_logger.dart';
import '../utils/error_helper.dart';
import 'backend_config_service.dart';

/// Service d'authentification API pour Arkalia CIA
/// Gère l'authentification JWT avec le backend
class AuthApiService {
  static const _secureStorage = FlutterSecureStorage();
  static const String _accessTokenKey = 'jwt_access_token';
  static const String _refreshTokenKey = 'jwt_refresh_token';
  static const String _usernameKey = 'username';

  /// Stockage sécurisé (mobile) ou SharedPreferences (web)
  static Future<void> _writeSecure(String key, String value) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } else {
      try {
        await _secureStorage.write(key: key, value: value);
      } on MissingPluginException catch (e) {
        // Fallback vers SharedPreferences si flutter_secure_storage n'est pas disponible
        // (peut arriver en mode test ou si la plateforme n'est pas disponible)
        AppLogger.debug('FlutterSecureStorage non disponible, utilisation SharedPreferences: $e');
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(key, value);
      } catch (e) {
        // Autre erreur, fallback vers SharedPreferences
        AppLogger.debug('Erreur FlutterSecureStorage, utilisation SharedPreferences: $e');
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(key, value);
      }
    }
  }

  static Future<String?> _readSecure(String key) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    } else {
      try {
        return await _secureStorage.read(key: key);
      } on MissingPluginException catch (e) {
        // Fallback vers SharedPreferences si flutter_secure_storage n'est pas disponible
        AppLogger.debug('FlutterSecureStorage non disponible, utilisation SharedPreferences: $e');
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString(key);
      } catch (e) {
        // Autre erreur, fallback vers SharedPreferences
        AppLogger.debug('Erreur FlutterSecureStorage, utilisation SharedPreferences: $e');
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString(key);
      }
    }
  }

  static Future<void> _deleteSecure(String key) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    } else {
      try {
        await _secureStorage.delete(key: key);
      } on MissingPluginException catch (e) {
        // Fallback vers SharedPreferences si flutter_secure_storage n'est pas disponible
        AppLogger.debug('FlutterSecureStorage non disponible, utilisation SharedPreferences: $e');
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(key);
      } catch (e) {
        // Autre erreur, fallback vers SharedPreferences
        AppLogger.debug('Erreur FlutterSecureStorage, utilisation SharedPreferences: $e');
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(key);
      }
    }
  }

  /// Enregistre un nouvel utilisateur
  static Future<Map<String, dynamic>> register({
    required String username,
    required String password,
    String? email,
  }) async {
    try {
      final url = await BackendConfigService.getBackendURL();
      if (url.isEmpty) {
        return {
          'success': false,
          'error': 'Backend non configuré',
        };
      }

      final response = await http.post(
        Uri.parse('$url/api/v1/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
          'email': email,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'user': data,
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': errorData['detail'] ?? 'Erreur lors de l\'inscription',
        };
      }
    } catch (e) {
      AppLogger.error('Erreur inscription', e);
      return {
        'success': false,
        'error': ErrorHelper.getUserFriendlyMessage(e),
      };
    }
  }

  /// Connecte un utilisateur et récupère les tokens JWT
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final url = await BackendConfigService.getBackendURL();
      if (url.isEmpty) {
        return {
          'success': false,
          'error': 'Backend non configuré',
        };
      }

      final response = await http.post(
        Uri.parse('$url/api/v1/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final accessToken = data['access_token'] as String;
        final refreshToken = data['refresh_token'] as String;

        // Stocker les tokens de manière sécurisée
        await _writeSecure(_accessTokenKey, accessToken);
        await _writeSecure(_refreshTokenKey, refreshToken);
        await _writeSecure(_usernameKey, username);

        return {
          'success': true,
          'access_token': accessToken,
          'refresh_token': refreshToken,
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': errorData['detail'] ?? 'Nom d\'utilisateur ou mot de passe incorrect',
        };
      }
    } catch (e) {
      AppLogger.error('Erreur connexion', e);
      return {
        'success': false,
        'error': ErrorHelper.getUserFriendlyMessage(e),
      };
    }
  }

  /// Rafraîchit le token d'accès avec le refresh token
  static Future<Map<String, dynamic>> refreshToken() async {
    try {
      final refreshToken = await _readSecure(_refreshTokenKey);
      if (refreshToken == null) {
        return {
          'success': false,
          'error': 'Aucun refresh token disponible',
        };
      }

      final url = await BackendConfigService.getBackendURL();
      final response = await http.post(
        Uri.parse('$url/api/v1/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'refresh_token': refreshToken,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final accessToken = data['access_token'] as String;
        final newRefreshToken = data['refresh_token'] as String;

        // Mettre à jour les tokens
        await _writeSecure(_accessTokenKey, accessToken);
        await _writeSecure(_refreshTokenKey, newRefreshToken);

        return {
          'success': true,
          'access_token': accessToken,
          'refresh_token': newRefreshToken,
        };
      } else {
        // Refresh token invalide, déconnecter l'utilisateur
        await logout();
        return {
          'success': false,
          'error': 'Session expirée, veuillez vous reconnecter',
        };
      }
    } catch (e) {
      AppLogger.error('Erreur refresh token', e);
      return {
        'success': false,
        'error': ErrorHelper.getUserFriendlyMessage(e),
      };
    }
  }

  /// Récupère le token d'accès actuel
  static Future<String?> getAccessToken() async {
    return await _readSecure(_accessTokenKey);
  }

  /// Vérifie si l'utilisateur est connecté
  static Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Déconnecte l'utilisateur
  static Future<void> logout() async {
    await _deleteSecure(_accessTokenKey);
    await _deleteSecure(_refreshTokenKey);
    await _deleteSecure(_usernameKey);
  }

  /// Récupère le nom d'utilisateur stocké
  static Future<String?> getUsername() async {
    return await _readSecure(_usernameKey);
  }
}

