import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Helper pour la gestion centralisée des erreurs réseau
class ErrorHelper {
  /// Convertit une exception en message utilisateur compréhensible
  static String getUserFriendlyMessage(dynamic error) {
    if (error is SocketException) {
      return 'Pas de connexion Internet. Vérifiez votre connexion réseau.';
    }
    
    if (error is HttpException) {
      return 'Erreur de communication avec le serveur. Veuillez réessayer.';
    }
    
    if (error is FormatException) {
      return 'Erreur de format de données. Les données peuvent être corrompues.';
    }
    
    if (error is TimeoutException) {
      return 'La requête a pris trop de temps. Vérifiez votre connexion.';
    }
    
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('connection') || errorString.contains('network')) {
      return 'Problème de connexion réseau. Vérifiez votre connexion Internet.';
    }
    
    if (errorString.contains('timeout')) {
      return 'La connexion a expiré. Veuillez réessayer.';
    }
    
    if (errorString.contains('404') || errorString.contains('not found')) {
      return 'Ressource introuvable sur le serveur.';
    }
    
    if (errorString.contains('401') || errorString.contains('unauthorized')) {
      return 'Vous n\'êtes pas autorisé à effectuer cette action.';
    }
    
    if (errorString.contains('403') || errorString.contains('forbidden')) {
      return 'Accès interdit. Vérifiez vos permissions.';
    }
    
    if (errorString.contains('500') || errorString.contains('server error')) {
      return 'Erreur serveur. Veuillez réessayer plus tard.';
    }
    
    if (errorString.contains('503') || errorString.contains('service unavailable')) {
      return 'Service temporairement indisponible. Veuillez réessayer plus tard.';
    }
    
    // Message générique si aucune correspondance
    return 'Une erreur est survenue. Veuillez réessayer.';
  }

  /// Vérifie si l'erreur est liée au réseau
  static bool isNetworkError(dynamic error) {
    return error is SocketException ||
           error is HttpException ||
           error is TimeoutException ||
           error.toString().toLowerCase().contains('connection') ||
           error.toString().toLowerCase().contains('network') ||
           error.toString().toLowerCase().contains('timeout');
  }

  /// Vérifie si l'erreur est récupérable (peut être réessayée)
  static bool isRetryableError(dynamic error) {
    if (error is SocketException) return true;
    if (error is TimeoutException) return true;
    
    final errorString = error.toString().toLowerCase();
    return errorString.contains('timeout') ||
           errorString.contains('connection') ||
           errorString.contains('network') ||
           errorString.contains('500') ||
           errorString.contains('503') ||
           errorString.contains('502'); // Bad Gateway
  }

  /// Obtient le code d'erreur HTTP si disponible
  static int? getHttpStatusCode(dynamic error) {
    final errorString = error.toString();
    
    // Chercher les codes HTTP courants
    final codes = [400, 401, 403, 404, 500, 502, 503, 504];
    for (final code in codes) {
      if (errorString.contains(code.toString())) {
        return code;
      }
    }
    
    return null;
  }

  /// Log l'erreur avec contexte pour le débogage
  static void logError(dynamic error, {String? context, StackTrace? stackTrace}) {
    final message = getUserFriendlyMessage(error);
    final httpCode = getHttpStatusCode(error);
    
    debugPrint('=== ERREUR ${context != null ? "($context)" : ""} ===');
    debugPrint('Message utilisateur: $message');
    if (httpCode != null) {
      debugPrint('Code HTTP: $httpCode');
    }
    debugPrint('Erreur technique: $error');
    if (stackTrace != null) {
      debugPrint('Stack trace: $stackTrace');
    }
    debugPrint('========================');
  }
}

