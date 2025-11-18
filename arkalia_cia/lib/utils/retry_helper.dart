import 'dart:async';
import 'package:flutter/foundation.dart';

/// Helper pour retry automatique avec backoff exponentiel
class RetryHelper {
  /// Exécute une fonction avec retry automatique
  /// 
  /// [fn] : La fonction à exécuter
  /// [maxRetries] : Nombre maximum de tentatives (défaut: 3)
  /// [initialDelay] : Délai initial en secondes (défaut: 1)
  /// [maxDelay] : Délai maximum en secondes (défaut: 10)
  /// 
  /// Retourne le résultat de la fonction ou lance la dernière exception
  static Future<T> retry<T>({
    required Future<T> Function() fn,
    int maxRetries = 3,
    int initialDelay = 1,
    int maxDelay = 10,
  }) async {
    int attempt = 0;
    int delay = initialDelay;

    while (attempt < maxRetries) {
      try {
        return await fn();
      } catch (e) {
        attempt++;
        
        if (attempt >= maxRetries) {
          debugPrint('Retry épuisé après $maxRetries tentatives. Dernière erreur: $e');
          rethrow;
        }

        debugPrint('Tentative $attempt/$maxRetries échouée. Nouvelle tentative dans ${delay}s...');
        await Future.delayed(Duration(seconds: delay));
        
        // Backoff exponentiel : double le délai à chaque tentative
        delay = (delay * 2).clamp(initialDelay, maxDelay);
      }
    }

    throw Exception('Retry épuisé');
  }

  /// Exécute une fonction avec retry uniquement pour les erreurs réseau
  static Future<T> retryOnNetworkError<T>({
    required Future<T> Function() fn,
    int maxRetries = 3,
    int initialDelay = 1,
  }) async {
    return retry(
      fn: fn,
      maxRetries: maxRetries,
      initialDelay: initialDelay,
    );
  }
}

