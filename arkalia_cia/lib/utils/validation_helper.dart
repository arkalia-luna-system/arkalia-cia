/// Helper pour la validation des données
class ValidationHelper {
  /// Valide un numéro de téléphone (format belge ou international)
  static bool isValidPhone(String phone) {
    if (phone.isEmpty) return false;
    
    // Nettoyer le numéro (enlever espaces, tirets, etc.)
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // Format belge : 04XX XX XX XX ou +32 4XX XX XX XX
    final belgianPattern = RegExp(r'^(?:\+32|0)?4[0-9]{8}$');
    
    // Format international : +XX...
    final internationalPattern = RegExp(r'^\+\d{8,15}$');
    
    return belgianPattern.hasMatch(cleaned) || internationalPattern.hasMatch(cleaned);
  }

  /// Valide une URL
  static bool isValidUrl(String url) {
    if (url.isEmpty) return false;
    
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  /// Valide une date ISO 8601
  static bool isValidDate(String dateString) {
    if (dateString.isEmpty) return false;
    
    try {
      DateTime.parse(dateString);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Valide un email (basique)
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    
    final emailPattern = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailPattern.hasMatch(email);
  }

  /// Valide un nom (non vide, caractères valides)
  static bool isValidName(String name) {
    if (name.trim().isEmpty) return false;
    if (name.length < 2) return false;
    if (name.length > 100) return false;
    
    // Autoriser lettres, espaces, tirets, apostrophes
    final namePattern = RegExp(r"^[a-zA-ZÀ-ÿ\s\-']+$");
    return namePattern.hasMatch(name);
  }

  /// Valide un titre (non vide)
  static bool isValidTitle(String title) {
    return title.trim().isNotEmpty && title.length <= 200;
  }

  /// Valide une description (optionnelle mais si présente, max longueur)
  static bool isValidDescription(String? description) {
    if (description == null || description.isEmpty) return true; // Optionnel
    return description.length <= 1000;
  }

  /// Valide un nom de fichier PDF
  static bool isValidPdfFileName(String fileName) {
    if (fileName.isEmpty) return false;
    return fileName.toLowerCase().endsWith('.pdf');
  }

  /// Formate un numéro de téléphone belge pour affichage
  static String formatBelgianPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // Si commence par +32, remplacer par 0
    if (cleaned.startsWith('+32')) {
      final number = cleaned.substring(3);
      if (number.length == 9 && number.startsWith('4')) {
        return '0$number';
      }
    }
    
    // Format belge : 04XX XX XX XX
    if (cleaned.length == 10 && cleaned.startsWith('04')) {
      return '${cleaned.substring(0, 4)} ${cleaned.substring(4, 6)} ${cleaned.substring(6, 8)} ${cleaned.substring(8, 10)}';
    }
    
    return phone; // Retourner tel quel si format non reconnu
  }
}

