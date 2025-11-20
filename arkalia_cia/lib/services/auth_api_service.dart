import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/app_logger.dart';
import '../utils/error_helper.dart';
import 'backend_config_service.dart';

/// Service d'authentification API pour Arkalia CIA
/// Gère l'authentification JWT avec le backend
class AuthApiService {
  static const _storage = FlutterSecureStorage();
  static const String _accessTokenKey = 'jwt_access_token';
  static const String _refreshTokenKey = 'jwt_refresh_token';
  static const String _usernameKey = 'username';

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
        await _storage.write(key: _accessTokenKey, value: accessToken);
        await _storage.write(key: _refreshTokenKey, value: refreshToken);
        await _storage.write(key: _usernameKey, value: username);

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
      final refreshToken = await _storage.read(key: _refreshTokenKey);
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
        await _storage.write(key: _accessTokenKey, value: accessToken);
        await _storage.write(key: _refreshTokenKey, value: newRefreshToken);

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
    return await _storage.read(key: _accessTokenKey);
  }

  /// Vérifie si l'utilisateur est connecté
  static Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Déconnecte l'utilisateur
  static Future<void> logout() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _usernameKey);
  }

  /// Récupère le nom d'utilisateur stocké
  static Future<String?> getUsername() async {
    return await _storage.read(key: _usernameKey);
  }
}

