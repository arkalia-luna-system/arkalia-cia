import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service d'authentification pour Arkalia CIA
/// Sur web : utilise l'authentification PIN locale (via PinAuthService)
/// Sur mobile : authentification désactivée (accès direct)
class AuthService {
  /// Vérifie si l'authentification est activée dans les préférences
  /// Sur web, vérifie l'authentification PIN
  /// Par défaut, désactivé (false) - l'utilisateur peut l'activer manuellement
  static Future<bool> isAuthEnabled() async {
    if (kIsWeb) {
      // Sur web, vérifier l'authentification PIN
      // Par défaut, désactivé (false) - l'utilisateur peut l'activer manuellement
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('pin_auth_enabled') ?? false;
    }
    // Sur mobile, authentification désactivée
    return false;
  }

  /// Active ou désactive l'authentification
  static Future<void> setAuthEnabled(bool enabled) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('pin_auth_enabled', enabled);
    }
    // Sur mobile, rien à faire (authentification désactivée)
  }

  /// Vérifie si l'authentification est nécessaire au démarrage
  /// Sur web, vérifie l'authentification PIN
  /// Par défaut, désactivé (false) - l'utilisateur peut l'activer manuellement
  static Future<bool> shouldAuthenticateOnStartup() async {
    if (kIsWeb) {
      // Sur web, vérifier l'authentification PIN
      // Par défaut, désactivé (false) - l'utilisateur peut l'activer manuellement
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('pin_auth_on_startup') ?? false;
    }
    // Sur mobile, authentification désactivée
    return false;
  }

  /// Configure l'authentification au démarrage
  static Future<void> setAuthOnStartup(bool enabled) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('pin_auth_on_startup', enabled);
    }
    // Sur mobile, rien à faire (authentification désactivée)
  }
}
