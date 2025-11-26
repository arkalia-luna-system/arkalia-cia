/// Configuration centralisée de tous les portails de santé
/// 
/// Ce fichier contient toutes les informations sur les portails de santé
/// belges et internationaux utilisés dans l'application.
/// Pour ajouter un nouveau portail :
/// 1. Ajouter l'entrée dans `belgianHealthPortals` ou `internationalHealthPortals`
/// 2. Si OAuth est supporté, ajouter dans `oauthPortalsConfig`
/// 3. Mettre à jour l'enum `HealthPortal` dans `health_portal_auth_service.dart` si nécessaire

class HealthPortalConfig {
  final String name;
  final String url;
  final String description;
  final String category;
  final bool supportsOAuth;
  final String? oauthAuthUrl;
  final String? oauthTokenUrl;
  final String? oauthCallbackUrl;
  final String? oauthScopes;

  const HealthPortalConfig({
    required this.name,
    required this.url,
    required this.description,
    required this.category,
    this.supportsOAuth = false,
    this.oauthAuthUrl,
    this.oauthTokenUrl,
    this.oauthCallbackUrl,
    this.oauthScopes,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'url': url,
      'description': description,
      'category': category,
    };
  }
}

/// Portails santé belges pré-configurés
class BelgianHealthPortals {
  static const List<HealthPortalConfig> portals = [
    // === ADMINISTRATION ===
    HealthPortalConfig(
      name: 'eHealth',
      url: 'https://www.ehealth.fgov.be',
      description: 'Plateforme eHealth belge - Accès sécurisé aux données de santé (Accréditation requise)',
      category: 'Administration',
      supportsOAuth: true,
      oauthAuthUrl: 'https://iam.ehealth.fgov.be/iam-connect/oidc/authorize', // URL réelle
      oauthTokenUrl: 'https://iam.ehealth.fgov.be/iam-connect/oidc/token', // URL réelle
      oauthCallbackUrl: 'arkaliacia://oauth/ehealth',
      oauthScopes: 'ehealthbox.read consultations.read labresults.read', // Scopes réels eHealth
    ),
    HealthPortalConfig(
      name: 'Inami',
      url: 'https://www.inami.fgov.be',
      description: 'Institut national d\'assurance maladie-invalidité',
      category: 'Administration',
      supportsOAuth: false,
    ),
    HealthPortalConfig(
      name: 'SPF Santé Publique',
      url: 'https://www.health.belgium.be',
      description: 'Service public fédéral Santé publique',
      category: 'Administration',
      supportsOAuth: false,
    ),

    // === INFORMATION ===
    HealthPortalConfig(
      name: 'Sciensano',
      url: 'https://www.sciensano.be',
      description: 'Institut scientifique de santé publique',
      category: 'Information',
      supportsOAuth: false,
    ),

    // === APPLICATIONS ===
    HealthPortalConfig(
      name: 'Andaman 7',
      url: 'https://www.andaman7.com',
      description: 'Application santé belge - Import manuel uniquement (export PDF/CSV depuis l\'app)',
      category: 'Application',
      supportsOAuth: false, // Pas d'API publique
      // oauthAuthUrl: null, // Pas d'OAuth disponible
      // oauthTokenUrl: null,
      // oauthCallbackUrl: null,
      // oauthScopes: null,
    ),
    HealthPortalConfig(
      name: 'MaSanté',
      url: 'https://www.masante.belgique.be',
      description: 'Portail santé belge - Import manuel uniquement (export PDF depuis le portail)',
      category: 'Application',
      supportsOAuth: false, // Pas d'API publique
      // oauthAuthUrl: null, // Pas d'OAuth disponible
      // oauthTokenUrl: null,
      // oauthCallbackUrl: null,
      // oauthScopes: null,
    ),
  ];

  /// Retourne tous les portails sous forme de liste de Maps
  /// (format compatible avec l'ancien code)
  static List<Map<String, dynamic>> getPortalsAsMaps() {
    return portals.map((portal) => portal.toMap()).toList();
  }

  /// Retourne uniquement les portails qui supportent OAuth
  static List<HealthPortalConfig> getOAuthPortals() {
    return portals.where((portal) => portal.supportsOAuth).toList();
  }

  /// Retourne les portails par catégorie
  static Map<String, List<HealthPortalConfig>> getPortalsByCategory() {
    final Map<String, List<HealthPortalConfig>> categorized = {};
    for (final portal in portals) {
      categorized.putIfAbsent(portal.category, () => []).add(portal);
    }
    return categorized;
  }

  /// Recherche un portail par nom (insensible à la casse)
  static HealthPortalConfig? findByName(String name) {
    try {
      return portals.firstWhere(
        (portal) => portal.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Recherche un portail par URL
  static HealthPortalConfig? findByUrl(String url) {
    try {
      return portals.firstWhere(
        (portal) => portal.url == url,
      );
    } catch (e) {
      return null;
    }
  }
}

/// Portails santé internationaux (pour extension future)
class InternationalHealthPortals {
  static const List<HealthPortalConfig> portals = [
    // Exemples pour extension future
    // HealthPortalConfig(
    //   name: 'MyHealthRecord (US)',
    //   url: 'https://www.myhealthrecord.gov',
    //   description: 'Portail santé américain',
    //   category: 'Administration',
    //   supportsOAuth: false,
    // ),
  ];

  static List<Map<String, dynamic>> getPortalsAsMaps() {
    return portals.map((portal) => portal.toMap()).toList();
  }
}

/// Configuration OAuth pour les portails qui le supportent
class OAuthPortalsConfig {
  /// Mapping des noms de portails vers leurs URLs OAuth
  static const Map<String, OAuthConfig> configs = {
    'eHealth': OAuthConfig(
      authUrl: 'https://iam.ehealth.fgov.be/iam-connect/oidc/authorize', // URL réelle
      tokenUrl: 'https://iam.ehealth.fgov.be/iam-connect/oidc/token', // URL réelle
      callbackUrl: 'arkaliacia://oauth/ehealth',
      scopes: 'ehealthbox.read consultations.read labresults.read', // Scopes réels
    ),
    // Andaman 7 et MaSanté n'ont pas d'API publique OAuth
    // Import manuel uniquement (PDF/CSV)
    // 'Andaman 7': OAuthConfig(...), // Pas disponible
    // 'MaSanté': OAuthConfig(...), // Pas disponible
  };

  /// Récupère la configuration OAuth pour un portail
  static OAuthConfig? getConfig(String portalName) {
    return configs[portalName];
  }

  /// Vérifie si un portail supporte OAuth
  static bool supportsOAuth(String portalName) {
    return configs.containsKey(portalName);
  }
}

/// Configuration OAuth pour un portail
class OAuthConfig {
  final String authUrl;
  final String tokenUrl;
  final String callbackUrl;
  final String scopes;

  const OAuthConfig({
    required this.authUrl,
    required this.tokenUrl,
    required this.callbackUrl,
    required this.scopes,
  });
}

/// Statistiques et informations sur les portails
class HealthPortalsStats {
  /// Nombre total de portails belges
  static int get totalBelgianPortals => BelgianHealthPortals.portals.length;

  /// Nombre de portails avec OAuth
  static int get oauthPortalsCount => 
      BelgianHealthPortals.getOAuthPortals().length;

  /// Nombre de portails par catégorie
  static Map<String, int> get portalsByCategory {
    final Map<String, int> counts = {};
    for (final portal in BelgianHealthPortals.portals) {
      counts[portal.category] = (counts[portal.category] ?? 0) + 1;
    }
    return counts;
  }

  /// Liste des catégories disponibles
  static List<String> get categories {
    return BelgianHealthPortals.portals
        .map((p) => p.category)
        .toSet()
        .toList();
  }
}

