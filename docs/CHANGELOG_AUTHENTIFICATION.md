# Changelog — Authentification JWT

**Version** : 1.3.0 → 1.3.1  
**Date** : Janvier 2025

---

## Version 1.3.1

### Ajouté

#### Authentification JWT

**Service `AuthApiService`** (`arkalia_cia/lib/services/auth_api_service.dart`)
- `register()` — inscription utilisateur
- `login()` — connexion avec récupération des tokens
- `refreshToken()` — rafraîchissement automatique du token
- `logout()` — déconnexion
- `isLoggedIn()` — vérification de connexion
- `getAccessToken()` — récupération du token d'accès
- `getUsername()` — récupération du nom d'utilisateur

#### Écrans utilisateur

**LoginScreen** (`arkalia_cia/lib/screens/auth/login_screen.dart`)
- Formulaire de connexion avec validation
- Gestion des erreurs
- Redirection vers HomePage après connexion

**RegisterScreen** (`arkalia_cia/lib/screens/auth/register_screen.dart`)
- Formulaire d'inscription avec validation (email, password, confirmation)
- Messages de succès/erreur
- Redirection automatique vers LoginScreen

#### Gestion automatique du refresh token

**ApiService** — méthode `_makeAuthenticatedRequest()`
- Détection automatique des erreurs 401
- Rafraîchissement automatique du token
- Réessai automatique de la requête
- Déconnexion automatique si refresh échoue

**ConversationalAIService** — méthode `_makeAuthenticatedRequest()`
- Même fonctionnalité que ApiService
- Intégré dans toutes les méthodes

**PatternsDashboardScreen** — méthode `_makeAuthenticatedRequest()`
- Gestion du refresh token pour l'analyse des patterns

#### Backend

**Module `auth.py`** (`arkalia_cia_python_backend/auth.py`)
- Hashage de mot de passe (`get_password_hash`, `verify_password`)
- Création de tokens JWT (`create_access_token`, `create_refresh_token`)
- Vérification de tokens (`verify_token`)
- Dépendances FastAPI (`get_current_user`, `get_current_active_user`)

**Endpoints API** (`arkalia_cia_python_backend/api.py`)
- `POST /api/v1/auth/register` — inscription
- `POST /api/v1/auth/login` — connexion
- `POST /api/v1/auth/refresh` — rafraîchissement token

**Database** (`arkalia_cia_python_backend/database.py`)
- Table `users` créée
- Table `user_documents` créée
- Méthodes `create_user()`, `get_user_by_username()`, `get_user_by_id()`

#### Tests

**Tests mis à jour** (`tests/unit/test_api_ai_endpoints.py`)
- Fixtures `auth_token` créées pour chaque classe de test
- Tous les endpoints testés avec authentification
- Tous les endpoints migrés vers `/api/v1/`

#### Documentation

Guides créés et fichiers MD mis à jour

### Modifié

#### ApiService
- Toutes les méthodes GET/POST/DELETE utilisent `_makeAuthenticatedRequest()`
- Méthode `_headers` devient asynchrone pour récupérer le token
- `uploadDocument()` gère le refresh token automatiquement

#### ConversationalAIService
- Toutes les méthodes utilisent `_makeAuthenticatedRequest()`
- Appel ARIA dans `_getUserData()` utilise le refresh token

#### PatternsDashboardScreen
- Utilise `ApiService.getDocuments()` au lieu d'appels HTTP directs
- `_makeAuthenticatedRequest()` créée pour l'analyse des patterns

#### Main.dart
- `_InitialScreen` créé pour vérifier l'authentification au démarrage
- Routage automatique selon l'état de connexion

#### SettingsScreen
- Section "Compte utilisateur" ajoutée
- Bouton de déconnexion avec confirmation

#### Backend API
- Tous les endpoints migrés vers `/api/v1/`
- Tous les endpoints protégés par authentification JWT
- Rate limiting amélioré (par utilisateur)

### Sécurité

- Authentification JWT complète
- Stockage sécurisé des tokens (FlutterSecureStorage)
- Hashage des mots de passe (bcrypt)
- Refresh token automatique
- Déconnexion automatique si refresh échoue
- Rate limiting par utilisateur

---

## Statistiques

**Fichiers créés**
- 2 écrans UI (LoginScreen, RegisterScreen)
- 1 service d'authentification (AuthApiService)
- 1 module backend (auth.py)
- Documentation mise à jour

**Fichiers modifiés**
- 3 services (ApiService, ConversationalAIService, PatternsDashboardScreen)
- 2 écrans (main.dart, SettingsScreen)
- 1 fichier backend (api.py)
- 1 fichier database (database.py)
- 1 fichier tests (test_api_ai_endpoints.py)

**Lignes de code**
- ~1500 lignes ajoutées
- ~300 lignes modifiées

---

## Impact

**Avant**
- Pas d'authentification
- Pas de protection des endpoints
- Pas de gestion de session

**Après**
- Authentification JWT complète
- Tous les endpoints protégés
- Gestion automatique des sessions
- Refresh token transparent pour l'utilisateur

---

## Voir aussi

- **[STATUT_FINAL_ULTIME.md](./STATUT_FINAL_ULTIME.md)** — Statut final authentification JWT
- **[guides/GUIDE_MISE_A_JOUR_FLUTTER.md](./guides/GUIDE_MISE_A_JOUR_FLUTTER.md)** — Guide mise à jour Flutter
- **[CHECKLIST_FINALE_SECURITE.md](./CHECKLIST_FINALE_SECURITE.md)** — Checklist sécurité
- **[CHANGELOG.md](./CHANGELOG.md)** — Changelog général du projet
- **[INDEX_DOCUMENTATION.md](./INDEX_DOCUMENTATION.md)** — Index complet de la documentation

---

*Dernière mise à jour : Janvier 2025*

