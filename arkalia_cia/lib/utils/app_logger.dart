import 'package:flutter/foundation.dart';

/// Logger conditionnel pour l'application
/// N'affiche les logs qu'en mode debug
class AppLogger {
  /// Log un message de debug (uniquement en mode debug)
  static void debug(String message) {
    if (kDebugMode) {
      debugPrint('[ARKALIA] $message');
    }
  }

  /// Log une erreur (toujours affiché, même en release)
  /// Utilisé pour les erreurs critiques qui doivent être visibles
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[ARKALIA ERROR] $message');
      if (error != null) {
        debugPrint('[ARKALIA ERROR] Détails: $error');
      }
      if (stackTrace != null) {
        debugPrint('[ARKALIA ERROR] Stack trace: $stackTrace');
      }
    }
  }

  /// Log une information (uniquement en mode debug)
  static void info(String message) {
    if (kDebugMode) {
      debugPrint('[ARKALIA INFO] $message');
    }
  }

  /// Log un warning (uniquement en mode debug)
  static void warning(String message) {
    if (kDebugMode) {
      debugPrint('[ARKALIA WARNING] $message');
    }
  }
}

