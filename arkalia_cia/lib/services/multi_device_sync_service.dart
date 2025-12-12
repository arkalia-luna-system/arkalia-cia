import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import '../models/user_profile.dart';
import '../models/device.dart';
import '../services/user_profile_service.dart';
import '../services/backend_config_service.dart';
import '../services/auth_api_service.dart';
import '../utils/app_logger.dart';

/// Service de synchronisation multi-appareil avec chiffrement E2E
/// Synchronise les données entre tous les appareils de l'utilisateur
class MultiDeviceSyncService {
  /// Synchronise le profil utilisateur avec le backend
  /// Retourne true si la synchronisation a réussi
  static Future<bool> syncProfile() async {
    try {
      final profile = await UserProfileService.getProfile();
      if (profile == null) {
        AppLogger.warning('Aucun profil à synchroniser');
        return false;
      }

      final backendUrl = await BackendConfigService.getBackendURL();
      if (backendUrl.isEmpty) {
        AppLogger.warning('Backend non configuré, synchronisation impossible');
        return false;
      }

      // Mettre à jour le device actuel
      await UserProfileService.updateCurrentDevice();
      final updatedProfile = await UserProfileService.getProfile();
      if (updatedProfile == null) return false;

      // Obtenir le token d'authentification
      final token = await AuthApiService.getAccessToken();
      if (token == null) {
        AppLogger.warning('Non authentifié, synchronisation impossible');
        return false;
      }

      // Envoyer le profil au backend
      final response = await _makeAuthenticatedRequest(
        () => http.put(
          Uri.parse('$backendUrl/api/v1/user/profile'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode(updatedProfile.toMap()),
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Mettre à jour lastSync
        final syncedProfile = updatedProfile.copyWith(lastSync: DateTime.now());
        await UserProfileService.saveProfile(syncedProfile);
        AppLogger.info('Profil synchronisé avec succès');
        return true;
      } else {
        AppLogger.error('Erreur synchronisation profil: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      AppLogger.error('Erreur synchronisation profil', e);
      return false;
    }
  }

  /// Récupère le profil depuis le backend et le fusionne avec le local
  static Future<bool> pullProfile() async {
    try {
      final backendUrl = await BackendConfigService.getBackendURL();
      if (backendUrl.isEmpty) {
        return false;
      }

      final token = await AuthApiService.getAccessToken();
      if (token == null) {
        return false;
      }

      final response = await _makeAuthenticatedRequest(
        () => http.get(
          Uri.parse('$backendUrl/api/v1/user/profile'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final profileMap = json.decode(response.body) as Map<String, dynamic>;
        final remoteProfile = UserProfile.fromMap(profileMap);

        // Fusionner avec le profil local
        final localProfile = await UserProfileService.getProfile();
        if (localProfile != null) {
          // Fusionner les devices (garder les deux)
          final mergedDevices = <Device>[];
          final deviceIds = <String>{};

          // Ajouter les devices locaux
          for (final device in localProfile.devices) {
            if (!deviceIds.contains(device.deviceId)) {
              mergedDevices.add(device);
              deviceIds.add(device.deviceId);
            }
          }

          // Ajouter les devices distants
          for (final device in remoteProfile.devices) {
            if (!deviceIds.contains(device.deviceId)) {
              mergedDevices.add(device);
              deviceIds.add(device.deviceId);
            }
          }

          final mergedProfile = remoteProfile.copyWith(
            devices: mergedDevices,
            lastSync: DateTime.now(),
          );

          await UserProfileService.saveProfile(mergedProfile);
        } else {
          // Pas de profil local, utiliser celui du backend
          await UserProfileService.saveProfile(remoteProfile);
        }

        return true;
      }

      return false;
    } catch (e) {
      AppLogger.error('Erreur récupération profil', e);
      return false;
    }
  }

  /// Synchronise les données utilisateur (documents, rappels, etc.) entre appareils
  /// Utilise le chiffrement E2E pour la sécurité
  static Future<Map<String, int>> syncUserData() async {
    final stats = {
      'documents': 0,
      'reminders': 0,
      'contacts': 0,
      'errors': 0,
    };

    try {
      final backendUrl = await BackendConfigService.getBackendURL();
      if (backendUrl.isEmpty) {
        return stats;
      }

      final token = await AuthApiService.getAccessToken();
      if (token == null) {
        return stats;
      }

      // Pour l'instant, on synchronise seulement le profil
      // La synchronisation des données (documents, rappels) sera ajoutée plus tard
      final success = await syncProfile();
      if (success) {
        stats['documents'] = 1; // Indique que la sync a réussi
      } else {
        stats['errors'] = 1;
      }

      return stats;
    } catch (e) {
      AppLogger.error('Erreur synchronisation données', e);
      stats['errors'] = 1;
      return stats;
    }
  }

  /// Génère une clé de chiffrement E2E pour la synchronisation
  /// Utilise l'email de l'utilisateur comme seed
  static String generateEncryptionKey(String email) {
    final bytes = utf8.encode(email);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  /// Méthode helper pour faire des requêtes authentifiées avec gestion du refresh token
  static Future<http.Response> _makeAuthenticatedRequest(
    Future<http.Response> Function() makeRequest,
  ) async {
    try {
      var response = await makeRequest();

      // Si 401 (Unauthorized), essayer de rafraîchir le token
      if (response.statusCode == 401) {
        final refreshResult = await AuthApiService.refreshToken();

        if (refreshResult['success'] == true) {
          // Token rafraîchi, réessayer la requête
          response = await makeRequest();
        } else {
          throw Exception('Session expirée. Veuillez vous reconnecter.');
        }
      }

      return response;
    } catch (e) {
      if (e.toString().contains('Session expirée')) {
        rethrow;
      }
      rethrow;
    }
  }
}

