/// Service pour mapper les pathologies aux catégories et sous-catégories
/// Utilise les spécialités médicales comme catégories principales
class PathologyCategoryService {
  /// Mapping pathologie → (catégorie, sous-catégorie)
  /// Catégorie = spécialité médicale principale
  /// Sous-catégorie = type de pathologie dans cette spécialité
  static const Map<String, Map<String, String>> _pathologyToCategory = {
    // Gynécologie
    'Endométriose': {
      'category': 'Gynécologie',
      'subcategory': 'Pathologies gynécologiques',
    },
    'Fibromyalgie': {
      'category': 'Gynécologie',
      'subcategory': 'Syndromes douloureux',
    },
    
    // Cardiologie
    'Hypertension': {
      'category': 'Cardiologie',
      'subcategory': 'Pathologies cardiovasculaires',
    },
    'Cancer': {
      'category': 'Oncologie',
      'subcategory': 'Pathologies cancéreuses',
    },
    
    // Neurologie
    'Parkinson': {
      'category': 'Neurologie',
      'subcategory': 'Maladies neurodégénératives',
    },
    'Alzheimer': {
      'category': 'Neurologie',
      'subcategory': 'Maladies neurodégénératives',
    },
    'Sclérose en plaques': {
      'category': 'Neurologie',
      'subcategory': 'Maladies auto-immunes',
    },
    'Migraine': {
      'category': 'Neurologie',
      'subcategory': 'Céphalées',
    },
    
    // Psychiatrie
    'Dépression': {
      'category': 'Psychiatrie',
      'subcategory': 'Troubles de l\'humeur',
    },
    
    // Endocrinologie
    'Diabète': {
      'category': 'Endocrinologie',
      'subcategory': 'Troubles métaboliques',
    },
    'Hypothyroïdie': {
      'category': 'Endocrinologie',
      'subcategory': 'Troubles thyroïdiens',
    },
    
    // Rhumatologie
    'Arthrite': {
      'category': 'Rhumatologie',
      'subcategory': 'Arthrites',
    },
    'Arthrite rhumatoïde': {
      'category': 'Rhumatologie',
      'subcategory': 'Arthrites',
    },
    'Spondylarthrite': {
      'category': 'Rhumatologie',
      'subcategory': 'Spondyloarthropathies',
    },
    'Ostéoporose': {
      'category': 'Rhumatologie',
      'subcategory': 'Pathologies osseuses',
    },
    'Tendinite': {
      'category': 'Rhumatologie',
      'subcategory': 'Pathologies des tissus mous',
    },
    
    // Dermatologie
    'Eczéma': {
      'category': 'Dermatologie',
      'subcategory': 'Dermatites',
    },
    'Psoriasis': {
      'category': 'Dermatologie',
      'subcategory': 'Maladies inflammatoires',
    },
    
    // Pneumologie
    'Asthme': {
      'category': 'Pneumologie',
      'subcategory': 'Pathologies respiratoires',
    },
    
    // Gastro-entérologie
    'Syndrome du côlon irritable': {
      'category': 'Gastro-entérologie',
      'subcategory': 'Troubles fonctionnels',
    },
    'Reflux gastro-œsophagien': {
      'category': 'Gastro-entérologie',
      'subcategory': 'Troubles digestifs',
    },
    
    // Hématologie
    'Anémie': {
      'category': 'Hématologie',
      'subcategory': 'Troubles sanguins',
    },
    'Myélome': {
      'category': 'Hématologie',
      'subcategory': 'Pathologies malignes',
    },
  };

  /// Retourne la catégorie d'une pathologie
  static String? getCategoryForPathology(String pathologyName) {
    return _pathologyToCategory[pathologyName]?['category'];
  }

  /// Retourne la sous-catégorie d'une pathologie
  static String? getSubcategoryForPathology(String pathologyName) {
    return _pathologyToCategory[pathologyName]?['subcategory'];
  }

  /// Retourne la catégorie et la sous-catégorie d'une pathologie
  static Map<String, String?> getCategoryAndSubcategory(String pathologyName) {
    final data = _pathologyToCategory[pathologyName];
    return {
      'category': data?['category'],
      'subcategory': data?['subcategory'],
    };
  }

  /// Vérifie si une pathologie a un mapping catégorie défini
  static bool hasCategoryMapping(String pathologyName) {
    return _pathologyToCategory.containsKey(pathologyName);
  }

  /// Retourne toutes les catégories disponibles
  static List<String> getAllCategories() {
    final categories = <String>{};
    for (final data in _pathologyToCategory.values) {
      final category = data['category'];
      if (category != null) {
        categories.add(category);
      }
    }
    return categories.toList()..sort();
  }

  /// Retourne toutes les sous-catégories d'une catégorie
  static List<String> getSubcategoriesForCategory(String category) {
    final subcategories = <String>{};
    for (final data in _pathologyToCategory.values) {
      if (data['category'] == category) {
        final subcategory = data['subcategory'];
        if (subcategory != null) {
          subcategories.add(subcategory);
        }
      }
    }
    return subcategories.toList()..sort();
  }

  /// Retourne toutes les pathologies d'une catégorie
  static List<String> getPathologiesForCategory(String category) {
    final pathologies = <String>[];
    _pathologyToCategory.forEach((pathology, data) {
      if (data['category'] == category) {
        pathologies.add(pathology);
      }
    });
    return pathologies..sort();
  }

  /// Retourne toutes les pathologies d'une sous-catégorie
  static List<String> getPathologiesForSubcategory(String subcategory) {
    final pathologies = <String>[];
    _pathologyToCategory.forEach((pathology, data) {
      if (data['subcategory'] == subcategory) {
        pathologies.add(pathology);
      }
    });
    return pathologies..sort();
  }
}

