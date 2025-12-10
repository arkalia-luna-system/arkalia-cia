import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Service d'authentification PIN pour le web
/// Utilisé quand l'authentification biométrique n'est pas disponible (web)
class PinAuthService {
  static const String _pinHashKey = 'web_pin_hash';
  static const String _pinConfiguredKey = 'web_pin_configured';

  /// Vérifie si un PIN est configuré
  /// [forceWeb] : Force le mode web pour les tests
  static Future<bool> isPinConfigured({bool forceWeb = false}) async {
    if (!kIsWeb && !forceWeb) {
      return false; // Sur mobile, on utilise l'authentification biométrique
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_pinConfiguredKey) ?? false;
  }

  /// Configure un nouveau PIN
  /// Retourne true si le PIN est valide et a été configuré
  /// [forceWeb] : Force le mode web pour les tests
  static Future<bool> configurePin(String pin, {bool forceWeb = false}) async {
    if (!kIsWeb && !forceWeb) {
      return false; // Sur mobile, on utilise l'authentification biométrique
    }

    // Valider le PIN (4-6 chiffres)
    if (!_isValidPin(pin)) {
      return false;
    }

    // Hasher le PIN avec SHA-256
    final pinHash = _hashPin(pin);

    // Sauvegarder le hash
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinHashKey, pinHash);
    await prefs.setBool(_pinConfiguredKey, true);

    return true;
  }

  /// Vérifie si le PIN est correct
  /// [forceWeb] : Force le mode web pour les tests
  static Future<bool> verifyPin(String pin, {bool forceWeb = false}) async {
    if (!kIsWeb && !forceWeb) {
      return false; // Sur mobile, on utilise l'authentification biométrique
    }

    final prefs = await SharedPreferences.getInstance();
    final storedHash = prefs.getString(_pinHashKey);

    if (storedHash == null) {
      return false; // Aucun PIN configuré
    }

    // Hasher le PIN saisi et comparer
    final pinHash = _hashPin(pin);
    return pinHash == storedHash;
  }

  /// Réinitialise le PIN (supprime la configuration)
  /// [forceWeb] : Force le mode web pour les tests
  static Future<void> resetPin({bool forceWeb = false}) async {
    if (!kIsWeb && !forceWeb) {
      return; // Sur mobile, on utilise l'authentification biométrique
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pinHashKey);
    await prefs.remove(_pinConfiguredKey);
  }

  /// Valide le format du PIN (4-6 chiffres)
  static bool _isValidPin(String pin) {
    if (pin.length < 4 || pin.length > 6) {
      return false;
    }
    // Vérifier que ce sont uniquement des chiffres
    return RegExp(r'^\d+$').hasMatch(pin);
  }

  /// Hash le PIN avec SHA-256
  static String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Vérifie si l'authentification PIN est activée
  /// [forceWeb] : Force le mode web pour les tests
  static Future<bool> isPinAuthEnabled({bool forceWeb = false}) async {
    if (!kIsWeb && !forceWeb) {
      return false; // Sur mobile, on utilise l'authentification biométrique
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('pin_auth_enabled') ?? true;
  }

  /// Active ou désactive l'authentification PIN
  /// [forceWeb] : Force le mode web pour les tests
  static Future<void> setPinAuthEnabled(bool enabled, {bool forceWeb = false}) async {
    if (!kIsWeb && !forceWeb) {
      return; // Sur mobile, on utilise l'authentification biométrique
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pin_auth_enabled', enabled);
  }

  /// Vérifie si l'authentification PIN est nécessaire au démarrage
  /// [forceWeb] : Force le mode web pour les tests
  static Future<bool> shouldAuthenticateOnStartup({bool forceWeb = false}) async {
    if (!kIsWeb && !forceWeb) {
      return false; // Sur mobile, on utilise l'authentification biométrique
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('pin_auth_on_startup') ?? true;
  }

  /// Configure l'authentification PIN au démarrage
  /// [forceWeb] : Force le mode web pour les tests
  static Future<void> setPinAuthOnStartup(bool enabled, {bool forceWeb = false}) async {
    if (!kIsWeb && !forceWeb) {
      return; // Sur mobile, on utilise l'authentification biométrique
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pin_auth_on_startup', enabled);
  }
}

