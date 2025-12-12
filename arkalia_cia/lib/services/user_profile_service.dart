import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:device_info_plus/device_info_plus.dart'; // Optionnel, version simplifiée utilisée
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/user_profile.dart';
import '../models/device.dart';
import '../utils/app_logger.dart';

// Note: dart:io n'est pas disponible sur web, donc on évite son utilisation

/// Service de gestion du profil utilisateur
/// Gère le stockage local et la synchronisation avec le backend
class UserProfileService {
  static const String _profileKey = 'user_profile';
  static const String _currentDeviceIdKey = 'current_device_id';
  static const _uuid = Uuid();

  /// Récupère le profil utilisateur depuis le stockage local
  static Future<UserProfile?> getProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString(_profileKey);
      if (profileJson == null) return null;
      final profileMap = json.decode(profileJson) as Map<String, dynamic>;
      return UserProfile.fromMap(profileMap);
    } catch (e) {
      AppLogger.error('Erreur récupération profil', e);
      return null;
    }
  }

  /// Sauvegarde le profil utilisateur localement
  static Future<void> saveProfile(UserProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = json.encode(profile.toMap());
      await prefs.setString(_profileKey, profileJson);
    } catch (e) {
      AppLogger.error('Erreur sauvegarde profil', e);
      rethrow;
    }
  }

  /// Crée un nouveau profil utilisateur
  static Future<UserProfile> createProfile({
    required String email,
    String? displayName,
  }) async {
    final userId = _uuid.v4();
    final currentDevice = await _getCurrentDeviceSimple();

    final profile = UserProfile(
      userId: userId,
      email: email,
      displayName: displayName,
      devices: [currentDevice],
    );

    await saveProfile(profile);
    await _saveCurrentDeviceId(currentDevice.deviceId);

    return profile;
  }

  /// Récupère ou crée l'ID du device actuel
  static Future<String> getCurrentDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString(_currentDeviceIdKey);

    if (deviceId == null) {
      deviceId = _uuid.v4();
      await _saveCurrentDeviceId(deviceId);
    }

    return deviceId;
  }

  /// Sauvegarde l'ID du device actuel
  static Future<void> _saveCurrentDeviceId(String deviceId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentDeviceIdKey, deviceId);
  }

  /// Récupère les informations du device actuel (version simplifiée)
  static Future<Device> _getCurrentDeviceSimple() async {
    final deviceId = await getCurrentDeviceId();
    String deviceName = 'Appareil inconnu';
    String platform = 'Unknown';

    if (kIsWeb) {
      platform = 'Web';
      deviceName = 'Navigateur Web';
    } else {
      // Sur mobile/desktop, on utilise des valeurs génériques
      // Pour une détection précise, utiliser device_info_plus (optionnel)
      platform = 'Mobile/Desktop';
      deviceName = 'Appareil';
    }

    return Device(
      deviceId: deviceId,
      deviceName: deviceName,
      platform: platform,
      lastSeen: DateTime.now(),
      isActive: true,
    );
  }

  /// Ajoute un device au profil
  static Future<void> addDevice(Device device) async {
    final profile = await getProfile();
    if (profile == null) {
      throw Exception('Aucun profil utilisateur trouvé');
    }

    // Vérifier si le device existe déjà
    final existingDeviceIndex = profile.devices.indexWhere(
      (d) => d.deviceId == device.deviceId,
    );

    if (existingDeviceIndex >= 0) {
      // Mettre à jour le device existant
      final updatedDevices = List<Device>.from(profile.devices);
      updatedDevices[existingDeviceIndex] = device;
      final updatedProfile = profile.copyWith(devices: updatedDevices);
      await saveProfile(updatedProfile);
    } else {
      // Ajouter le nouveau device
      final updatedDevices = [...profile.devices, device];
      final updatedProfile = profile.copyWith(devices: updatedDevices);
      await saveProfile(updatedProfile);
    }
  }

  /// Met à jour le device actuel (dernière connexion)
  static Future<void> updateCurrentDevice() async {
    final profile = await getProfile();
    if (profile == null) return;

    final currentDevice = await _getCurrentDeviceSimple();

    await addDevice(currentDevice);

    // Mettre à jour lastSync
    final updatedProfile = profile.copyWith(lastSync: DateTime.now());
    await saveProfile(updatedProfile);
  }

  /// Supprime un device du profil
  static Future<void> removeDevice(String deviceId) async {
    final profile = await getProfile();
    if (profile == null) return;

    final updatedDevices = profile.devices.where((d) => d.deviceId != deviceId).toList();
    final updatedProfile = profile.copyWith(devices: updatedDevices);
    await saveProfile(updatedProfile);
  }

  /// Désactive un device (au lieu de le supprimer)
  static Future<void> deactivateDevice(String deviceId) async {
    final profile = await getProfile();
    if (profile == null) return;

    final updatedDevices = profile.devices.map((d) {
      if (d.deviceId == deviceId) {
        return d.copyWith(isActive: false);
      }
      return d;
    }).toList();

    final updatedProfile = profile.copyWith(devices: updatedDevices);
    await saveProfile(updatedProfile);
  }

  /// Vérifie si un profil existe
  static Future<bool> hasProfile() async {
    final profile = await getProfile();
    return profile != null;
  }

  /// Supprime le profil (déconnexion)
  static Future<void> deleteProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_profileKey);
      // Ne pas supprimer currentDeviceId pour permettre réutilisation
    } catch (e) {
      AppLogger.error('Erreur suppression profil', e);
      rethrow;
    }
  }
}

