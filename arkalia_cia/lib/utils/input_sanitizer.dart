/// Utilitaire de sanitization des entrées utilisateur pour prévenir les attaques XSS
/// 
/// **IMPORTANT** : Toutes les entrées utilisateur doivent être sanitizées avant :
/// - Stockage dans la base de données
/// - Affichage dans l'interface
/// - Envoi au backend
class InputSanitizer {
  /// Sanitize une chaîne de caractères pour prévenir XSS
  /// 
  /// Supprime ou échappe :
  /// - Balises HTML/XML (<script>, <img>, etc.)
  /// - Attributs d'événements (onclick, onerror, etc.)
  /// - Caractères spéciaux dangereux
  /// 
  /// Retourne une chaîne sécurisée pour affichage
  static String sanitize(String input) {
    if (input.isEmpty) return input;
    
    // Échapper les caractères HTML dangereux
    String sanitized = input
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .replaceAll('/', '&#x2F;');
    
    // Supprimer les patterns JavaScript dangereux (même échappés)
    sanitized = sanitized
        .replaceAll(RegExp(r'javascript:', caseSensitive: false), '')
        .replaceAll(RegExp(r'on\w+\s*=', caseSensitive: false), '')
        .replaceAll(RegExp(r'&lt;script', caseSensitive: false), '')
        .replaceAll(RegExp(r'&lt;iframe', caseSensitive: false), '')
        .replaceAll(RegExp(r'&lt;object', caseSensitive: false), '')
        .replaceAll(RegExp(r'&lt;embed', caseSensitive: false), '')
        .replaceAll(RegExp(r'&lt;link', caseSensitive: false), '')
        .replaceAll(RegExp(r'&lt;style', caseSensitive: false), '');
    
    return sanitized.trim();
  }
  
  /// Sanitize pour stockage (moins agressif, garde certains caractères)
  /// 
  /// Utilisé avant stockage dans la base de données
  /// Échappe les balises HTML mais garde les caractères normaux
  static String sanitizeForStorage(String input) {
    if (input.isEmpty) return input;
    
    // Échapper seulement les balises HTML dangereuses
    String sanitized = input
        .replaceAll(RegExp(r'<script[^>]*>.*?</script>', caseSensitive: false, dotAll: true), '')
        .replaceAll(RegExp(r'<iframe[^>]*>.*?</iframe>', caseSensitive: false, dotAll: true), '')
        .replaceAll(RegExp(r'<object[^>]*>.*?</object>', caseSensitive: false, dotAll: true), '')
        .replaceAll(RegExp(r'<embed[^>]*>', caseSensitive: false), '')
        .replaceAll(RegExp(r'<link[^>]*>', caseSensitive: false), '')
        .replaceAll(RegExp(r'<style[^>]*>.*?</style>', caseSensitive: false, dotAll: true), '')
        .replaceAll(RegExp(r'on\w+\s*=', caseSensitive: false), '')
        .replaceAll(RegExp(r'javascript:', caseSensitive: false), '');
    
    return sanitized.trim();
  }
  
  /// Valide qu'une chaîne ne contient pas de contenu dangereux
  /// 
  /// Retourne true si la chaîne est sûre, false sinon
  static bool isValid(String input) {
    if (input.isEmpty) return true;
    
    final dangerousPatterns = [
      RegExp(r'<script', caseSensitive: false),
      RegExp(r'<iframe', caseSensitive: false),
      RegExp(r'<object', caseSensitive: false),
      RegExp(r'<embed', caseSensitive: false),
      RegExp(r'javascript:', caseSensitive: false),
      RegExp(r'on\w+\s*=', caseSensitive: false),
      RegExp(r'<img[^>]*onerror', caseSensitive: false),
      RegExp(r'<img[^>]*onload', caseSensitive: false),
    ];
    
    for (final pattern in dangerousPatterns) {
      if (pattern.hasMatch(input)) {
        return false;
      }
    }
    
    return true;
  }
  
  /// Échappe une chaîne pour affichage HTML (si nécessaire)
  /// 
  /// Note : Flutter utilise Text() qui échappe automatiquement,
  /// mais cette fonction est utile pour d'autres contextes
  static String escapeHtml(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;');
  }
}

