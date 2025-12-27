# 🏗️ ARCHITECTURE DES SERVICES - Arkalia CIA

**Date** : 12 décembre 2025  
**Version** : 1.3.1+6  
**Statut** : Documentation complète (28 services documentés)

---

## 📋 VUE D'ENSEMBLE

Ce document décrit l'architecture et les responsabilités de tous les services Flutter de l'application Arkalia CIA.

---

## 🔍 SERVICES DE STOCKAGE

### 1. `StorageHelper` (Utils)
**Fichier** : `lib/utils/storage_helper.dart`

**Responsabilité** : 
- Couche d'abstraction bas niveau pour le stockage avec chiffrement AES-256
- Gestion des SharedPreferences avec chiffrement optionnel
- Utilitaires génériques pour listes et objets

**Utilisé par** :
- `LocalStorageService` (utilise StorageHelper pour toutes les opérations)

**Fonctionnalités** :
- `saveList()` : Sauvegarde liste chiffrée
- `getList()` : Récupère liste déchiffrée
- `saveObject()` : Sauvegarde objet chiffré
- `getObject()` : Récupère objet déchiffré
- `clearData()` : Nettoie données
- `hasData()` : Vérifie existence données

**Note** : Ne pas utiliser directement, passer par `LocalStorageService`

---

### 2. `LocalStorageService` (Service)
**Fichier** : `lib/services/local_storage_service.dart`

**Responsabilité** :
- Service de haut niveau pour stockage des données métier
- Gère documents, rappels, contacts d'urgence, infos médicales
- Utilise `StorageHelper` en interne (abstraction)

**Utilisé par** :
- Tous les écrans et services qui ont besoin de données locales

**Fonctionnalités** :
- Documents : `saveDocument()`, `getDocuments()`, `updateDocument()`, `deleteDocument()`
- Rappels : `saveReminder()`, `getReminders()`, `updateReminder()`, `deleteReminder()`, `markReminderComplete()`
- Contacts urgence : `saveEmergencyContact()`, `getEmergencyContacts()`, etc.
- Infos urgence : `saveEmergencyInfo()`, `getEmergencyInfo()`
- Utilitaires : `clearAllData()`, `hasAnyData()`, `exportAllData()`, `importAllData()`

**Note** : Service principal pour stockage local, utilise `StorageHelper` en interne

---

### 3. `FileStorageService` (Service)
**Fichier** : `lib/services/file_storage_service.dart`

**Responsabilité** :
- Gestion des fichiers physiques (PDF, images, etc.)
- Gestion des répertoires documents et temporaires
- Opérations sur fichiers (copie, suppression, chemins)

**Utilisé par** :
- `DocumentsScreen` (upload PDF)
- Services qui manipulent des fichiers

**Fonctionnalités** :
- `getDocumentsDirectory()` : Répertoire documents app
- `getTempDirectory()` : Répertoire temporaire
- `copyToDocumentsDirectory()` : Copie fichier vers documents
- `deleteDocumentFile()` : Supprime fichier
- `getDocumentPath()` : Chemin complet fichier
- `saveBytesToDocumentsDirectory()` : Sauvegarde bytes (non-web)

**Différence avec LocalStorageService** :
- `LocalStorageService` : Données structurées (JSON, listes, objets)
- `FileStorageService` : Fichiers physiques (PDF, images, etc.)

---

## 🔍 SERVICES DE RECHERCHE

### 4. `SemanticSearchService` (Service)
**Fichier** : `lib/services/semantic_search_service.dart`

**Responsabilité** :
- Recherche sémantique avec TF-IDF
- Pondération contextuelle médicale
- Recherche par synonymes médicaux

**Utilisé par** :
- `SearchService` (composition, pas héritage)

**Fonctionnalités** :
- `semanticSearch()` : Recherche sémantique dans documents
- `semanticSearchDoctors()` : Recherche sémantique dans médecins
- `_calculateSemanticScore()` : Calcul score sémantique

**Note** : Service spécialisé pour recherche intelligente, utilisé par `SearchService`

---

### 5. `SearchService` (Service)
**Fichier** : `lib/services/search_service.dart`

**Responsabilité** :
- Service de recherche principal (multi-sources)
- Recherche dans documents, rappels, contacts
- Utilise `SemanticSearchService` pour recherche intelligente
- Gestion cache avec `OfflineCacheService`

**Utilisé par** :
- `HomePage` (recherche globale)
- `AdvancedSearchScreen` (recherche avancée)

**Fonctionnalités** :
- `searchAll()` : Recherche globale (documents, rappels, contacts)
- `search()` : Recherche avec filtres avancés
- `_matchesDocument()` : Vérifie correspondance document
- Cache automatique des résultats

**Composition** :
- Utilise `SemanticSearchService` pour recherche intelligente (si requête > 3 caractères)
- Utilise `OfflineCacheService` pour cache
- Utilise `LocalStorageService` pour données

**Note** : Service principal de recherche, compose `SemanticSearchService` (pas de duplication)

---

## 🔍 SERVICES MÉTIER

### 6. `DoctorService` (Service)
**Fichier** : `lib/services/doctor_service.dart`

**Responsabilité** :
- Gestion CRUD médecins
- Recherche et filtres médecins
- Statistiques par médecin

**Fonctionnalités** :
- `insertDoctor()`, `updateDoctor()`, `deleteDoctor()`, `getAllDoctors()`
- `getDoctorById()`, `getDoctorsBySpecialty()`
- `findSimilarDoctors()` : Détection doublons
- `getConsultationsByDoctor()`, `getDoctorStats()`

---

### 7. `PathologyService` (Service)
**Fichier** : `lib/services/pathology_service.dart`

**Responsabilité** :
- Gestion pathologies (templates, tracking, statistiques)

**Fonctionnalités** :
- Templates pathologies (9 pathologies)
- Tracking symptômes
- Statistiques et graphiques

---

### 8. `MedicationService` (Service)
**Fichier** : `lib/services/medication_service.dart`

**Responsabilité** :
- Gestion médicaments et rappels

**Fonctionnalités** :
- CRUD médicaments
- Rappels adaptatifs

---

### 9. `HydrationService` (Service)
**Fichier** : `lib/services/hydration_service.dart`

**Responsabilité** :
- Gestion hydratation et objectifs quotidiens

**Fonctionnalités** :
- Tracking hydratation
- Objectifs quotidiens

---

## 🔍 SERVICES API & BACKEND

### 10. `ApiService` (Service)
**Fichier** : `lib/services/api_service.dart`

**Responsabilité** :
- Communication avec backend FastAPI
- Upload documents, gestion erreurs réseau

**Fonctionnalités** :
- `uploadDocument()` : Upload PDF avec refresh token automatique
- Gestion erreurs réseau
- Authentification automatique

---

### 11. `AuthApiService` (Service)
**Fichier** : `lib/services/auth_api_service.dart`

**Responsabilité** :
- Authentification JWT (login, register, refresh token)
- Gestion tokens sécurisés (flutter_secure_storage)

**Fonctionnalités** :
- `login()`, `register()`, `logout()`
- `refreshToken()` : Rafraîchissement automatique
- `getAccessToken()`, `isLoggedIn()`

---

### 12. `ConversationalAIService` (Service)
**Fichier** : `lib/services/conversational_ai_service.dart`

**Responsabilité** :
- Communication avec IA conversationnelle backend
- Gestion refresh token automatique
- Intégration ARIA

**Fonctionnalités** :
- `askQuestion()` : Question à l'IA
- `_makeAuthenticatedRequest()` : Helper avec refresh token
- Intégration données ARIA

---

### 13. `BackendConfigService` (Service)
**Fichier** : `lib/services/backend_config_service.dart`

**Responsabilité** :
- Configuration backend (URL, activation/désactivation)
- Stockage préférences utilisateur

**Fonctionnalités** :
- `getBackendURL()`, `setBackendURL()`
- `isBackendEnabled()`, `setBackendEnabled()`

---

## 🔍 SERVICES SYSTÈME

### 14. `CalendarService` (Service)
**Fichier** : `lib/services/calendar_service.dart`

**Responsabilité** :
- Intégration calendrier système natif
- Synchronisation bidirectionnelle
- Rappels médicaments et hydratation

**Fonctionnalités** :
- `init()`, `getUpcomingReminders()`
- `addReminder()`, `updateReminder()`, `deleteReminder()`
- Intégration médicaments 💊 et hydratation 💧

---

### 15. `ContactsService` (Service)
**Fichier** : `lib/services/contacts_service.dart`

**Responsabilité** :
- Intégration contacts système natif
- Gestion contacts ICE (In Case of Emergency)

**Fonctionnalités** :
- `getEmergencyContacts()`, `addEmergencyContact()`
- Intégration contacts système

---

### 16. `NotificationService` (Service)
**Fichier** : `lib/services/notification_service.dart`

**Responsabilité** :
- Notifications locales (rappels, médicaments, hydratation)
- Gestion permissions

**Fonctionnalités** :
- `initialize()`, `scheduleNotification()`
- Notifications rappels

---

## 🔍 SERVICES UTILITAIRES

### 17. `OfflineCacheService` (Service)
**Fichier** : `lib/services/offline_cache_service.dart`

**Responsabilité** :
- Cache intelligent pour données offline
- Expiration automatique cache

**Fonctionnalités** :
- `getCachedData()`, `setCachedData()`
- `clearExpiredCaches()` : Nettoyage automatique

---

### 18. `AutoSyncService` (Service)
**Fichier** : `lib/services/auto_sync_service.dart`

**Responsabilité** :
- Synchronisation automatique avec backend
- Sync périodique et au démarrage

**Fonctionnalités** :
- `syncIfNeeded()`, `setAutoSyncEnabled()`
- `isSyncOnStartupEnabled()`

---

### 19. `ThemeService` (Service)
**Fichier** : `lib/services/theme_service.dart`

**Responsabilité** :
- Gestion thèmes (clair, sombre, système)
- Stockage préférences thème

**Fonctionnalités** :
- `getThemeMode()`, `setThemeMode()`
- `getThemeData()` : Thème Material Design

---

### 20. `CategoryService` (Service)
**Fichier** : `lib/services/category_service.dart`

**Responsabilité** :
- Gestion catégories documents
- Catégories prédéfinies

**Fonctionnalités** :
- `getCategories()`, `getCategoryIcon()`

---

### 21. `OnboardingService` (Service)
**Fichier** : `lib/services/onboarding_service.dart`

**Responsabilité** :
- Gestion onboarding utilisateur
- Première utilisation

**Fonctionnalités** :
- `hasCompletedOnboarding()`, `setOnboardingCompleted()`

---

### 22. `ARIService` (Service)
**Fichier** : `lib/services/aria_service.dart`

**Responsabilité** :
- Intégration avec Arkalia ARIA
- Récupération données douleur, patterns, métriques

**Fonctionnalités** :
- `getPainData()`, `getPatterns()`, `getHealthMetrics()`
- Détection serveur ARIA

---

### 23. `FamilySharingService` (Service)
**Fichier** : `lib/services/family_sharing_service.dart`

**Responsabilité** :
- Partage familial sécurisé
- Chiffrement AES-256 bout-en-bout
- Gestion membres et permissions

**Fonctionnalités** :
- `shareDocument()`, `getSharedDocuments()`
- `addFamilyMember()`, `removeFamilyMember()`
- Permissions granulaires (view, download, full)

---

### 24. `HealthPortalAuthService` (Service)
**Fichier** : `lib/services/health_portal_auth_service.dart`

**Responsabilité** :
- Authentification OAuth portails santé belges
- Gestion tokens OAuth (eHealth, Andaman 7, MaSanté)

**Fonctionnalités** :
- `authenticatePortal()`, `getAccessToken()`, `refreshAccessToken()`
- `fetchPortalData()` : Récupération données portails

---

### 25. `HealthPortalImportService` (Service)
**Fichier** : `lib/services/health_portal_import_service.dart`

**Responsabilité** :
- Import manuel de documents depuis portails santé (stratégie gratuite)
- Upload PDF exporté depuis Andaman 7 ou MaSanté

**Fonctionnalités** :
- `uploadPortalPDF()` : Upload PDF avec parsing automatique
- Gestion progression upload
- Support Andaman 7 et MaSanté

**Note** : Alternative gratuite aux APIs payantes (2 000-5 000€/an)

---

### 26. `AuthService` (Service)
**Fichier** : `lib/services/auth_service.dart`

**Responsabilité** :
- Gestion authentification PIN (web uniquement)
- Sur mobile : authentification désactivée (accès direct)

**Fonctionnalités** :
- `isAuthEnabled()` : Vérifie si authentification activée
- `setAuthEnabled()` : Active/désactive authentification
- `shouldAuthenticateOnStartup()` : Vérifie si auth nécessaire au démarrage
- `setAuthOnStartup()` : Configure auth au démarrage

**Note** : Sur web, utilise `PinAuthService` pour le PIN. Sur mobile, pas d'authentification.

---

### 27. `PinAuthService` (Service)
**Fichier** : `lib/services/pin_auth_service.dart`

**Responsabilité** :
- Authentification PIN pour le web
- Stockage sécurisé hash PIN

**Fonctionnalités** :
- `isPinConfigured()` : Vérifie si PIN configuré
- `configurePin()` : Configure nouveau PIN (4-6 chiffres)
- `verifyPin()` : Vérifie PIN
- `changePin()` : Change PIN existant
- `clearPin()` : Supprime PIN

**Note** : Utilisé uniquement sur web. Sur mobile, pas d'authentification (accès direct).

---

### 28. `RuntimeSecurityService` (Service)
**Fichier** : `lib/services/runtime_security_service.dart`

**Responsabilité** :
- Détection root/jailbreak (sécurité runtime)
- Vérification intégrité application
- Protection contre appareils compromis

**Fonctionnalités** :
- `initialize()` : Initialise détection sécurité
- `isRooted()` : Détecte Android rooté
- `isJailbroken()` : Détecte iOS jailbreaké
- `checkIntegrity()` : Vérifie intégrité app

**Note** : Protection sécurité importante pour données médicales sensibles

---

## 📊 RÉSUMÉ DES RESPONSABILITÉS

| Service | Responsabilité Principale | Utilise |
|---------|-------------------------|---------|
| `StorageHelper` | Stockage bas niveau + chiffrement | - |
| `LocalStorageService` | Stockage données métier | `StorageHelper` |
| `FileStorageService` | Fichiers physiques | - |
| `SemanticSearchService` | Recherche sémantique | `LocalStorageService` |
| `SearchService` | Recherche multi-sources | `SemanticSearchService`, `OfflineCacheService` |
| `DoctorService` | CRUD médecins | - |
| `PathologyService` | Pathologies | - |
| `MedicationService` | Médicaments | - |
| `HydrationService` | Hydratation | - |
| `ApiService` | Communication backend | `AuthApiService` |
| `AuthApiService` | Authentification JWT | - |
| `ConversationalAIService` | IA conversationnelle | `AuthApiService`, `BackendConfigService` |
| `BackendConfigService` | Configuration backend | - |
| `CalendarService` | Calendrier système | - |
| `ContactsService` | Contacts système | - |
| `NotificationService` | Notifications locales | - |
| `OfflineCacheService` | Cache intelligent | - |
| `AutoSyncService` | Sync automatique | `BackendConfigService` |
| `ThemeService` | Thèmes | - |
| `CategoryService` | Catégories | - |
| `OnboardingService` | Onboarding | - |
| `ARIService` | Intégration ARIA | `BackendConfigService` |
| `FamilySharingService` | Partage familial | - |
| `HealthPortalAuthService` | OAuth portails santé | `AuthApiService` |
| `HealthPortalImportService` | Import manuel portails | `AuthApiService` |
| `AuthService` | Authentification PIN (web uniquement) | - |
| `PinAuthService` | Authentification PIN (web) | - |
| `RuntimeSecurityService` | Sécurité runtime | - |

---

## ✅ CONCLUSION

**Pas de duplication** : Les services ont des responsabilités claires et distinctes :
- `SearchService` compose `SemanticSearchService` (pas de duplication)
- `LocalStorageService` utilise `StorageHelper` (abstraction, pas duplication)
- `FileStorageService` gère fichiers physiques (différent de `LocalStorageService`)

**Architecture propre** : Séparation des responsabilités respectée, services réutilisables.

---

**Dernière mise à jour** : 27 novembre 2025

