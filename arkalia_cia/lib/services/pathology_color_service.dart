import 'package:flutter/material.dart';
import '../models/doctor.dart';

/// Service pour mapper les pathologies aux couleurs des spécialités
/// Garantit la cohérence entre les couleurs des pathologies et celles des spécialités
class PathologyColorService {
  /// Mapping pathologie → spécialité
  /// Utilisé pour déterminer la couleur d'une pathologie basée sur sa spécialité
  static const Map<String, String> _pathologyToSpecialty = {
    // Gynécologie
    'Endométriose': 'Gynécologue',
    'Fibromyalgie': 'Gynécologue', // Souvent suivi par gynéco
    
    // Cardiologie
    'Hypertension': 'Cardiologue',
    'Cancer': 'Cardiologue', // Peut être suivi par plusieurs spécialités, mais souvent cardio
    
    // Neurologie
    'Parkinson': 'Neurologue',
    'Alzheimer': 'Neurologue',
    'Sclérose en plaques': 'Neurologue',
    'Migraine': 'Neurologue',
    
    // Psychiatrie
    'Dépression': 'Psychiatre',
    'TDAH': 'Psychiatre',
    
    // Endocrinologie
    'Diabète': 'Endocrinologue',
    'Hypothyroïdie': 'Endocrinologue',
    
    // Rhumatologie
    'Arthrite': 'Rhumatologue',
    'Arthrose': 'Rhumatologue', // Variante d'arthrite
    'Arthrite rhumatoïde': 'Rhumatologue',
    'Polyarthrite rhumatoïde': 'Rhumatologue', // Variante
    'Spondylite': 'Rhumatologue',
    'Spondylarthrite': 'Rhumatologue', // Variante
    'Ostéoporose': 'Rhumatologue',
    'Tendinite': 'Rhumatologue',
    
    // Dermatologie
    'Eczéma': 'Dermatologue',
    'Psoriasis': 'Dermatologue',
    
    // Pneumologie
    'Asthme': 'Pneumologue',
    
    // Gastro-entérologie (pas de spécialité dans Doctor, utiliser Généraliste)
    'Syndrome du côlon irritable': 'Généraliste',
    'Reflux gastro-œsophagien': 'Généraliste',
    
    // Hématologie (pas de spécialité dans Doctor, utiliser Généraliste)
    'Anémie': 'Généraliste',
    'Myélome': 'Généraliste',
  };

  /// Retourne la couleur standardisée pour une pathologie
  /// Utilise la couleur de la spécialité associée
  static Color getColorForPathology(String pathologyName) {
    // Chercher la spécialité associée à la pathologie
    final specialty = _pathologyToSpecialty[pathologyName];
    
    if (specialty != null) {
      // Utiliser la couleur de la spécialité
      return Doctor.getColorForSpecialty(specialty);
    }
    
    // Si la pathologie n'est pas dans le mapping, utiliser la couleur par défaut
    return Colors.blue;
  }

  /// Retourne la spécialité associée à une pathologie
  static String? getSpecialtyForPathology(String pathologyName) {
    return _pathologyToSpecialty[pathologyName];
  }

  /// Vérifie si une pathologie a un mapping spécialité défini
  static bool hasSpecialtyMapping(String pathologyName) {
    return _pathologyToSpecialty.containsKey(pathologyName);
  }

  /// Retourne toutes les pathologies mappées
  static List<String> getMappedPathologies() {
    return _pathologyToSpecialty.keys.toList()..sort();
  }
}

