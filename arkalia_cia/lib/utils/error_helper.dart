import 'package:flutter/foundation.dart';

/// Helper pour gérer les erreurs et afficher des messages utilisateur clairs
class ErrorHelper {
  /// Convertit une erreur technique en message utilisateur compréhensible
  static String getUserFriendlyMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    // Erreurs SQLite
    if (errorString.contains('databasefactory') || 
        errorString.contains('database factory') ||
        errorString.contains('not initialized')) {
      return 'Erreur de base de données. Veuillez redémarrer l\'application.';
    }
    
    if (errorString.contains('sqlite') || errorString.contains('database')) {
      return 'Erreur de sauvegarde. Veuillez réessayer.';
    }
    
    // Erreurs réseau
    if (errorString.contains('failed host lookup') || 
        errorString.contains('connection refused') ||
        errorString.contains('network')) {
      return 'Problème de connexion. Vérifiez votre réseau.';
    }
    
    if (errorString.contains('timeout')) {
      return 'La requête a pris trop de temps. Réessayez.';
    }
    
    // Erreurs de permission
    if (errorString.contains('permission') || errorString.contains('denied')) {
      return 'Permission refusée. Vérifiez les paramètres de l\'application.';
    }
    
    // Erreurs de fichier
    if (errorString.contains('file') || errorString.contains('path')) {
      return 'Erreur de fichier. Vérifiez que le fichier existe.';
    }
    
    // Erreur générique
    return 'Une erreur est survenue. Veuillez réessayer.';
  }
  
  /// Log l'erreur technique (seulement en mode debug)
  static void logError(String context, dynamic error) {
    if (kDebugMode) {
      print('[$context] Erreur technique: $error');
    }
  }
}
