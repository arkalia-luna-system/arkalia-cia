import 'package:flutter/foundation.dart';
import 'package:root_detector/root_detector.dart';
import '../utils/app_logger.dart';

/// Service de sécurité runtime pour détecter root/jailbreak et vérifier l'intégrité
class RuntimeSecurityService {
  static bool _isInitialized = false;
  static bool? _isRooted;
  static bool? _isJailbroken;

  /// Initialise le service de sécurité runtime
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Détecter root/jailbreak (uniquement sur mobile)
      if (!kIsWeb) {
        _isRooted = await RootDetector.isRooted();
        // Note: root_detector 0.0.6 ne supporte que isRooted (Android)
        // Pour iOS jailbreak, il faudrait utiliser un autre package
        _isJailbroken = false; // TODO: Implémenter avec flutter_jailbreak_detection si nécessaire
        
        if (_isRooted == true || _isJailbroken == true) {
          AppLogger.warning('⚠️ Appareil rooté/jailbreaké détecté - Sécurité compromise');
          // En production, on pourrait bloquer l'app ou afficher un avertissement
        }
      } else {
        // Sur web, pas de détection root/jailbreak
        _isRooted = false;
        _isJailbroken = false;
      }

      _isInitialized = true;
      AppLogger.info('✅ Runtime Security Service initialisé');
    } catch (e) {
      AppLogger.error('Erreur initialisation Runtime Security', e);
      // En cas d'erreur, on continue mais on log l'erreur
      _isRooted = false;
      _isJailbroken = false;
      _isInitialized = true;
    }
  }

  /// Vérifie si l'appareil est rooté (Android)
  static bool isRooted() {
    return _isRooted ?? false;
  }

  /// Vérifie si l'appareil est jailbreaké (iOS)
  static bool isJailbroken() {
    return _isJailbroken ?? false;
  }

  /// Vérifie si l'appareil est compromis (root ou jailbreak)
  static bool isDeviceCompromised() {
    return isRooted() || isJailbroken();
  }

  /// Vérifie l'intégrité de l'application
  /// Note: Vérification basique, peut être améliorée avec signature checking
  static Future<bool> verifyAppIntegrity() async {
    try {
      // Vérification basique de l'intégrité
      // En production, on pourrait vérifier la signature de l'app
      // ou utiliser des techniques anti-tampering plus avancées
      
      if (isDeviceCompromised()) {
        AppLogger.warning('⚠️ Intégrité compromise - Appareil rooté/jailbreaké');
        return false;
      }

      return true;
    } catch (e) {
      AppLogger.error('Erreur vérification intégrité', e);
      return false;
    }
  }

  /// Affiche un avertissement si l'appareil est compromis
  static String? getSecurityWarning() {
    if (isRooted()) {
      return '⚠️ Votre appareil Android est rooté. Cela peut compromettre la sécurité de vos données médicales.';
    }
    if (isJailbroken()) {
      return '⚠️ Votre appareil iOS est jailbreaké. Cela peut compromettre la sécurité de vos données médicales.';
    }
    return null;
  }
}
