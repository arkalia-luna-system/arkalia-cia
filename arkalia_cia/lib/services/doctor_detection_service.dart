/// Service pour détecter les médecins dans les documents PDF
/// Utilise des regex pour identifier les noms de médecins et leurs spécialités
class DoctorDetectionService {
  /// Patterns pour détecter les titres de médecins
  /// Supporte les accents et caractères spéciaux
  static final List<RegExp> _doctorTitlePatterns = [
    RegExp(r'\b(?:Dr|Dr\.|Docteur|Dre|Dre\.|Docteure)\s+([A-ZÀÁÂÄÈÉÊËÌÍÎÏÒÓÔÖÙÚÛÜÇ][a-zàáâäèéêëìíîïòóôöùúûüç]+(?:\s+[A-ZÀÁÂÄÈÉÊËÌÍÎÏÒÓÔÖÙÚÛÜÇ][a-zàáâäèéêëìíîïòóôöùúûüç]+)*)', caseSensitive: false),
    RegExp(r'\b(?:M\.|Mme|Monsieur|Madame)\s+(?:le\s+)?(?:Dr|Dr\.|Docteur)\s+([A-ZÀÁÂÄÈÉÊËÌÍÎÏÒÓÔÖÙÚÛÜÇ][a-zàáâäèéêëìíîïòóôöùúûüç]+(?:\s+[A-ZÀÁÂÄÈÉÊËÌÍÎÏÒÓÔÖÙÚÛÜÇ][a-zàáâäèéêëìíîïòóôöùúûüç]+)*)', caseSensitive: false),
    RegExp(r'\b(?:Pr|Pr\.|Professeur)\s+([A-ZÀÁÂÄÈÉÊËÌÍÎÏÒÓÔÖÙÚÛÜÇ][a-zàáâäèéêëìíîïòóôöùúûüç]+(?:\s+[A-ZÀÁÂÄÈÉÊËÌÍÎÏÒÓÔÖÙÚÛÜÇ][a-zàáâäèéêëìíîïòóôöùúûüç]+)*)', caseSensitive: false),
  ];

  /// Patterns pour détecter les spécialités médicales
  static final Map<String, RegExp> _specialtyPatterns = {
    'Cardiologue': RegExp(r'\b(?:cardiologue|cardio|cardiologie)\b', caseSensitive: false),
    'Dermatologue': RegExp(r'\b(?:dermatologue|dermato|dermatologie)\b', caseSensitive: false),
    'Gynécologue': RegExp(r'\b(?:gynécologue|gynéco|gynécologie)\b', caseSensitive: false),
    'Ophtalmologue': RegExp(r'\b(?:ophtalmologue|ophtalmo|ophtalmologie)\b', caseSensitive: false),
    'Orthopédiste': RegExp(r'\b(?:orthopédiste|orthopédie)\b', caseSensitive: false),
    'Pneumologue': RegExp(r'\b(?:pneumologue|pneumo|pneumologie)\b', caseSensitive: false),
    'Rhumatologue': RegExp(r'\b(?:rhumatologue|rhumato|rhumatologie)\b', caseSensitive: false),
    'Neurologue': RegExp(r'\b(?:neurologue|neuro|neurologie)\b', caseSensitive: false),
    'Généraliste': RegExp(r'\b(?:médecin\s+général|généraliste|médecin\s+de\s+famille|MG)\b', caseSensitive: false),
    'Pédiatre': RegExp(r'\b(?:pédiatre|pédiatrie)\b', caseSensitive: false),
    'Psychiatre': RegExp(r'\b(?:psychiatre|psychiatrie)\b', caseSensitive: false),
    'Urologue': RegExp(r'\b(?:urologue|urologie)\b', caseSensitive: false),
    'Endocrinologue': RegExp(r'\b(?:endocrinologue|endocrino|endocrinologie)\b', caseSensitive: false),
  };

  /// Détecte un médecin dans un texte
  /// Retourne un Map avec firstName, lastName, specialty, ou null si aucun médecin détecté
  static Map<String, String>? detectDoctor(String text) {
    if (text.isEmpty) return null;

    String? doctorName;
    String? specialty;

    // Chercher un nom de médecin avec les patterns
    for (final pattern in _doctorTitlePatterns) {
      final match = pattern.firstMatch(text);
      if (match != null && match.groupCount >= 1) {
        final name = match.group(1)?.trim();
        if (name != null && name.isNotEmpty) {
          doctorName = name;
          break;
        }
      }
    }

    // Si aucun pattern ne correspond, chercher des patterns alternatifs
    if (doctorName == null) {
      // Pattern pour "Nom Prénom" après "Dr" ou "Docteur" (avec accents)
      final altPattern = RegExp(
        r'\b(?:Dr|Dr\.|Docteur|Dre|Dre\.|Docteure)\s+([A-ZÀÁÂÄÈÉÊËÌÍÎÏÒÓÔÖÙÚÛÜÇ][a-zàáâäèéêëìíîïòóôöùúûüç]+(?:\s+[A-ZÀÁÂÄÈÉÊËÌÍÎÏÒÓÔÖÙÚÛÜÇ][a-zàáâäèéêëìíîïòóôöùúûüç]+){1,2})',
        caseSensitive: false,
      );
      final match = altPattern.firstMatch(text);
      if (match != null && match.groupCount >= 1) {
        final name = match.group(1)?.trim();
        if (name != null && name.isNotEmpty) {
          doctorName = name;
        }
      }
    }

    // Chercher une spécialité
    for (final entry in _specialtyPatterns.entries) {
      if (entry.value.hasMatch(text)) {
        specialty = entry.key;
        break;
      }
    }

    // Si on a trouvé un nom, retourner les informations
    if (doctorName != null) {
      // Séparer prénom et nom (généralement le dernier mot est le nom)
      final nameParts = doctorName.split(RegExp(r'\s+'));
      if (nameParts.length >= 2) {
        final firstName = nameParts.first;
        final lastName = nameParts.sublist(1).join(' ');
        return {
          'firstName': firstName,
          'lastName': lastName,
          'specialty': specialty ?? '',
        };
      } else if (nameParts.length == 1) {
        // Un seul mot, considérer comme nom de famille
        return {
          'firstName': '',
          'lastName': nameParts.first,
          'specialty': specialty ?? '',
        };
      }
    }

    return null;
  }

  /// Détecte un médecin depuis les métadonnées d'un document
  /// Les métadonnées peuvent venir du backend (extraction automatique)
  static Map<String, String>? detectDoctorFromMetadata(Map<String, dynamic>? metadata) {
    if (metadata == null) return null;

    final doctorName = metadata['doctor_name'] as String?;
    final doctorSpecialty = metadata['doctor_specialty'] as String?;

    if (doctorName != null && doctorName.isNotEmpty) {
      // Séparer prénom et nom
      final nameParts = doctorName.trim().split(RegExp(r'\s+'));
      if (nameParts.length >= 2) {
        final firstName = nameParts.first;
        final lastName = nameParts.sublist(1).join(' ');
        return {
          'firstName': firstName,
          'lastName': lastName,
          'specialty': doctorSpecialty ?? '',
        };
      } else if (nameParts.length == 1) {
        return {
          'firstName': '',
          'lastName': nameParts.first,
          'specialty': doctorSpecialty ?? '',
        };
      }
    }

    return null;
  }

  /// Combine détection depuis métadonnées et depuis texte
  /// Priorité aux métadonnées (plus fiables)
  static Map<String, String>? detectDoctorFromDocument({
    Map<String, dynamic>? metadata,
    String? textContent,
  }) {
    // D'abord essayer les métadonnées (extraction backend)
    final fromMetadata = detectDoctorFromMetadata(metadata);
    if (fromMetadata != null) {
      return fromMetadata;
    }

    // Sinon, essayer depuis le texte
    if (textContent != null && textContent.isNotEmpty) {
      return detectDoctor(textContent);
    }

    return null;
  }
}

