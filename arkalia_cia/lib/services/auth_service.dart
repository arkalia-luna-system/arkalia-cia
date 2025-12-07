import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service d'authentification biométrique pour Arkalia CIA
class AuthService {
  static final LocalAuthentication _localAuth = LocalAuthentication();

  /// Vérifie si l'authentification biométrique est disponible
  static Future<bool> isBiometricAvailable() async {
    try {
      final bool canAuthenticate = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      return canAuthenticate || isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  /// Récupère les types de biométrie disponibles
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// Authentifie l'utilisateur avec biométrie ou code PIN système
  /// 
  /// Avec biometricOnly: false, le système propose :
  /// 1. D'abord la biométrie (empreinte/visage) si disponible
  /// 2. Si la biométrie échoue ou n'est pas disponible, le système propose
  ///    automatiquement le code PIN/mot de passe de déverrouillage du téléphone
  /// 
  /// L'utilisateur n'a pas besoin de créer un PIN séparé pour l'app,
  /// il utilise le même PIN que celui de son téléphone.
  static Future<bool> authenticate({
    String reason = 'Authentification requise pour accéder à Arkalia CIA',
    bool useErrorDialogs = true,
    bool stickyAuth = true,
  }) async {
    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: false, // false = permet biométrie OU PIN système du téléphone
        ),
      );
      return didAuthenticate;
    } on PlatformException catch (e) {
      // Gérer les erreurs spécifiques
      if (e.code == 'NotAvailable') {
        return false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Vérifie si l'authentification est activée dans les préférences
  static Future<bool> isAuthEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('biometric_auth_enabled') ?? true;
  }

  /// Active ou désactive l'authentification biométrique
  static Future<void> setAuthEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_auth_enabled', enabled);
  }

  /// Vérifie si l'authentification est nécessaire au démarrage
  static Future<bool> shouldAuthenticateOnStartup() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('auth_on_startup') ?? true;
  }

  /// Configure l'authentification au démarrage
  static Future<void> setAuthOnStartup(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auth_on_startup', enabled);
  }

  /// Arrête l'authentification (pour déconnexion)
  static Future<void> stopAuthentication() async {
    try {
      await _localAuth.stopAuthentication();
    } catch (e) {
      // Ignorer les erreurs si l'authentification n'est pas en cours
    }
  }
}

