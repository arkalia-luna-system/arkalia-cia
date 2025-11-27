# Portails de Santé - Documentation Complète

Ce document liste tous les portails de santé configurés dans Arkalia CIA.

## 📋 Vue d'ensemble

**Total de portails** : 6 portails belges pré-configurés

**Portails avec OAuth** : 1 portail (eHealth uniquement - accréditation requise)

**Import manuel** : 2 portails (Andaman 7, MaSanté - export PDF/CSV)

**Catégories** : Administration, Information, Application

---

## 🇧🇪 Portails Belges

### Administration

#### 1. eHealth
- **URL** : https://www.ehealth.fgov.be
- **Description** : Plateforme eHealth belge - Accès sécurisé aux données de santé
- **OAuth** : ✅ Supporté
  - Auth URL : `https://www.ehealth.fgov.be/fr/oauth/authorize`
  - Token URL : `https://www.ehealth.fgov.be/fr/oauth/token`
  - Callback : `arkaliacia://oauth/ehealth`
  - Scopes : `read:documents read:consultations read:exams`

#### 2. Inami
- **URL** : https://www.inami.fgov.be
- **Description** : Institut national d'assurance maladie-invalidité
- **OAuth** : ❌ Non supporté

#### 3. SPF Santé Publique
- **URL** : https://www.health.belgium.be
- **Description** : Service public fédéral Santé publique
- **OAuth** : ❌ Non supporté

### Information

#### 4. Sciensano
- **URL** : https://www.sciensano.be
- **Description** : Institut scientifique de santé publique
- **OAuth** : ❌ Non supporté

### Applications

#### 5. Andaman 7
- **URL** : https://www.andaman7.com
- **Description** : Application santé belge - Import manuel uniquement (export PDF/CSV depuis l'app)
- **OAuth** : ❌ Non disponible (pas d'API publique)
- **Import** : ✅ Export manuel PDF/CSV depuis l'app Andaman 7, puis upload dans Arkalia CIA
- **Voir** : `INTEGRATION_ANDAMAN7_MASANTE.md` pour guide complet

#### 6. MaSanté
- **URL** : https://www.masante.belgique.be
- **Description** : Portail santé belge - Import manuel uniquement (export PDF depuis le portail)
- **OAuth** : ❌ Non disponible (pas d'API publique)
- **Import** : ✅ Export manuel PDF depuis le portail MaSanté, puis upload dans Arkalia CIA
- **Voir** : `INTEGRATION_ANDAMAN7_MASANTE.md` pour guide complet

---

## 📊 Statistiques

- **Total portails belges** : 6
- **Portails avec OAuth** : 1 (eHealth uniquement - accréditation requise)
- **Import manuel** : 2 (Andaman 7, MaSanté)
- **Portails sans intégration** : 3 (Inami, SPF, Sciensano)

### Par catégorie

- **Administration** : 3 portails
  - eHealth (OAuth ✅)
  - Inami
  - SPF Santé Publique

- **Information** : 1 portail
  - Sciensano

- **Application** : 2 portails
  - Andaman 7 (Import manuel ✅)
  - MaSanté (Import manuel ✅)

---

## 🔧 Configuration Technique

### Fichier de configuration

Tous les portails sont définis dans :
```
arkalia_cia/lib/config/health_portals_config.dart
```

### Utilisation dans le code

```dart
import '../config/health_portals_config.dart';

// Récupérer tous les portails
final portals = BelgianHealthPortals.getPortalsAsMaps();

// Récupérer uniquement les portails OAuth
final oauthPortals = BelgianHealthPortals.getOAuthPortals();

// Rechercher un portail par nom
final portal = BelgianHealthPortals.findByName('eHealth');

// Récupérer la configuration OAuth
final oauthConfig = OAuthPortalsConfig.getConfig('eHealth');
```

### Ajout d'un nouveau portail

1. Ouvrir `arkalia_cia/lib/config/health_portals_config.dart`
2. Ajouter une nouvelle entrée dans `BelgianHealthPortals.portals` :
```dart
HealthPortalConfig(
  name: 'Nouveau Portail',
  url: 'https://exemple.com',
  description: 'Description du portail',
  category: 'Administration', // ou 'Information', 'Application'
  supportsOAuth: true, // ou false
  oauthAuthUrl: 'https://exemple.com/oauth/authorize', // si OAuth
  oauthTokenUrl: 'https://exemple.com/oauth/token', // si OAuth
  oauthCallbackUrl: 'arkaliacia://oauth/nouveau', // si OAuth
  oauthScopes: 'read:data', // si OAuth
),
```
3. Si OAuth est supporté, ajouter aussi dans `OAuthPortalsConfig.configs`
4. Si nécessaire, mettre à jour l'enum `HealthPortal` dans `health_portal_auth_service.dart`

---

## 🔐 Authentification OAuth

### Portails supportant OAuth

1. **eHealth** - Plateforme gouvernementale
2. **Andaman 7** - Application santé
3. **MaSanté** - Portail santé

### Configuration OAuth

Les credentials OAuth (client_id, client_secret) sont configurés dans les paramètres de l'application via `SettingsScreen`.

### Flow OAuth

1. L'utilisateur sélectionne un portail avec OAuth
2. L'app ouvre le navigateur avec l'URL d'autorisation
3. L'utilisateur s'authentifie sur le portail
4. Le portail redirige vers le callback de l'app (`arkaliacia://oauth/...`)
5. L'app échange le code d'autorisation contre un access token
6. Le token est sauvegardé localement (SharedPreferences)
7. L'app peut maintenant récupérer les données du portail

### Refresh Token

Les tokens OAuth sont automatiquement rafraîchis si :
- Le token est expiré
- Le token expire dans moins de 5 minutes
- Un refresh token est disponible

---

## 📱 Utilisation dans l'application

### Écran Santé

Les portails sont affichés dans `HealthScreen` :
- Liste de tous les portails
- Bouton pour ouvrir chaque portail dans le navigateur
- Bouton pour ajouter un nouveau portail manuellement

### Import depuis portails

**eHealth** (si accréditation obtenue) :
- `HealthPortalAuthService.authenticatePortal()` - OAuth automatique
- `HealthPortalAuthService.fetchPortalData()` - Récupération données
- `HealthPortalAuthService.importFromPortal()` - Import automatique

**Andaman 7 et MaSanté** (import manuel) :
- Export PDF/CSV depuis l'app/portail
- Upload dans Arkalia CIA via `import_choice_screen.dart`
- Parsing automatique backend
- **Voir** : `STRATEGIE_GRATUITE_PORTAILS_SANTE.md` pour détails

---

## 🔄 Historique des modifications

- **2025-11-23** : Configuration centralisée créée
  - Tous les portails déplacés dans `health_portals_config.dart`
  - Support OAuth documenté
  - Statistiques ajoutées

---

## 📝 Notes

- Les URLs OAuth sont des exemples et doivent être vérifiées avec la documentation officielle de chaque portail
- Les scopes OAuth peuvent varier selon les permissions demandées
- L'import automatique nécessite une configuration backend active
- Les tokens OAuth sont stockés localement avec SharedPreferences (pour production, considérer flutter_secure_storage)

---

## 🔗 Liens utiles

- [Documentation eHealth](https://www.ehealth.fgov.be)
- [Documentation Inami](https://www.inami.fgov.be)
- [Documentation Andaman 7](https://www.andaman7.com)
- [Documentation MaSanté](https://www.masante.be)

---

**Dernière mise à jour** : 27 novembre 2025

**Stratégie** : Import manuel gratuit pour Andaman 7 et MaSanté (voir `STRATEGIE_GRATUITE_PORTAILS_SANTE.md`)

**Statut** : Voir `STATUT_INTEGRATION_PORTAILS_SANTE.md` pour l'état complet

