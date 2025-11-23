# 📝 TODOs Documentés - 23 Novembre 2025

**Date**: 23 novembre 2025  
**Statut**: Mis à jour - Sélection médecin et refresh token implémentés

---

## 🔴 TODOs CRITIQUES (Fonctionnalités manquantes)

### 1. Import Portails Santé

**Fichiers concernés**:
- `arkalia_cia/lib/screens/onboarding/import_choice_screen.dart` (ligne 99)
- `arkalia_cia/lib/screens/onboarding/import_progress_screen.dart` (ligne 104)

**Description**: Implémenter l'import automatique depuis les portails santé belges (eHealth, Andaman 7, MaSanté)

**Statut actuel**: 
- ✅ Structure UI existe
- ✅ Backend endpoint `/api/v1/health-portals/import` existe
- ❌ Parsing réel des données portails non implémenté
- ❌ Synchronisation automatique non implémentée

**Priorité**: 🟠 ÉLEVÉE (fonctionnalité promise aux utilisateurs)

**Estimation**: 2-3 semaines de développement

**Dépendances**:
- APIs OAuth des portails santé belges
- Documentation APIs eHealth, Andaman 7, MaSanté
- Parsing des formats de données spécifiques

---

### 2. Sélection Médecin dans Recherche Avancée ✅ TERMINÉ

**Fichier**: `arkalia_cia/lib/screens/advanced_search_screen.dart`

**Description**: Ajouter un sélecteur de médecin dans l'écran de recherche avancée

**Statut actuel**:
- ✅ Recherche avancée fonctionnelle
- ✅ Filtres par date, type, etc.
- ✅ Filtre par médecin implémenté (23 novembre 2025)
- ✅ Dialog de sélection médecin avec liste complète
- ✅ Intégration dans SearchFilters avec doctorId

**Priorité**: 🟡 MOYENNE (amélioration UX) - **TERMINÉ**

**Implémentation**:
- FilterChip pour sélection médecin ajouté
- Dialog de sélection avec RadioListTile
- Support doctorId dans SearchFilters
- Filtrage dans SearchService._matchesDocument()

---

## 🟡 TODOs MOYENS (Améliorations)

### 3. Filtre Type d'Examen dans Recherche Avancée ✅ TERMINÉ

**Fichier**: `arkalia_cia/lib/screens/advanced_search_screen.dart`

**Description**: Ajouter un filtre par type d'examen dans la recherche avancée

**Statut actuel**:
- ✅ Filtre type d'examen implémenté (23 novembre 2025)
- ✅ Dialog de sélection avec types d'examens courants
- ✅ Support examType dans SearchFilters
- ✅ Filtrage dans SearchService._matchesDocument()

**Priorité**: 🟡 MOYENNE (amélioration UX) - **TERMINÉ**

**Implémentation**:
- FilterChip pour sélection type d'examen ajouté
- Dialog de sélection avec RadioListTile
- Liste de types d'examens médicaux courants
- Filtrage par nom de document et métadonnées

---

### 4. Refresh Token pour Portails Santé ✅ TERMINÉ

**Fichier**: `arkalia_cia/lib/services/health_portal_auth_service.dart`

**Description**: Implémenter le rafraîchissement automatique des tokens OAuth pour les portails santé

**Statut actuel**:
- ✅ Authentification OAuth de base implémentée
- ✅ Structure pour refresh token existe
- ✅ Logique de refresh automatique implémentée (23 novembre 2025)
- ✅ Méthode `refreshAccessToken()` complète
- ✅ Méthode `getValidAccessToken()` pour vérification et refresh automatique
- ✅ Stockage refresh token dans SharedPreferences

**Priorité**: 🟡 MOYENNE (amélioration robustesse) - **TERMINÉ**

**Implémentation**:
- Méthode `refreshAccessToken()` avec appel API OAuth
- Méthode `getValidAccessToken()` pour gestion automatique
- Support des URLs de refresh pour chaque portail
- Gestion des erreurs et fallback

---

### 5. Audit Log Partage Familial ✅ TERMINÉ

**Fichier**: `arkalia_cia/lib/services/family_sharing_service.dart`

**Description**: Implémenter un audit log complet pour le partage familial (qui a accédé à quoi)

**Statut actuel**:
- ✅ Classe `SharingAuditLog` créée (23 novembre 2025)
- ✅ Méthodes `getAuditLogForDocument()` et `getAuditLogForMember()` implémentées
- ✅ Méthodes `logDocumentAccess()` et `logDocumentDownload()` implémentées
- ✅ Enregistrement automatique lors du partage et du départage
- ✅ Stockage dans SharedPreferences

**Priorité**: 🟡 MOYENNE (amélioration sécurité) - **TERMINÉ**

**Implémentation**:
- Classe SharingAuditLog avec actions (shared, accessed, downloaded, unshared)
- Stockage dans SharedPreferences avec clé `sharing_audit_log`
- Méthodes pour récupérer l'audit log par document ou par membre
- Enregistrement automatique lors des actions de partage

---

### 6. Export/Import Médecins ✅ TERMINÉ

**Fichier**: `arkalia_cia/lib/services/doctor_service.dart`

**Description**: Permettre l'export et l'import des médecins et consultations au format JSON

**Statut actuel**:
- ✅ Méthode `exportDoctors()` implémentée (23 novembre 2025)
- ✅ Méthode `importDoctors()` implémentée (23 novembre 2025)
- ✅ Export au format JSON avec version et date
- ✅ Import avec gestion des IDs pour éviter conflits
- ✅ Import des consultations associées

**Priorité**: 🟡 MOYENNE (amélioration fonctionnalité) - **TERMINÉ**

**Implémentation**:
- Export JSON avec structure complète (doctors, consultations)
- Import avec création de nouveaux IDs pour éviter conflits
- Gestion des consultations lors de l'import
- Format JSON versionné pour compatibilité future

---

### 7. Endpoints Spécifiques Portails Santé

**Fichier**: `arkalia_cia/lib/services/health_portal_auth_service.dart` (ligne 81)

**Description**: Implémenter les endpoints spécifiques pour chaque portail santé quand les APIs seront disponibles

**Statut actuel**:
- ✅ Structure générique existe
- ✅ Gestion OAuth de base
- ❌ Endpoints spécifiques non implémentés (APIs non disponibles)

**Priorité**: 🟢 BASSE (dépend de disponibilité APIs)

**Estimation**: 1-2 semaines par portail (quand APIs disponibles)

**Portails concernés**:
- eHealth (API non documentée publiquement)
- Andaman 7 (API privée)
- MaSanté (API non documentée)

---

## 🟢 TODOs BAS (Notes techniques)

### 8. Application ID Android ✅ TERMINÉ

**Fichier**: `arkalia_cia/android/app/build.gradle.kts` (ligne 30)

**Description**: Spécifier un Application ID unique pour Android

**Statut actuel**: 
- ✅ Application ID mis à jour : `com.arkalia.cia` (23 novembre 2025)
- ✅ TODO supprimé

**Priorité**: 🟢 BASSE (pour production uniquement) - **TERMINÉ**

**Fichier**: `arkalia_cia/android/app/build.gradle.kts` (ligne 30)

**Description**: Spécifier un Application ID unique pour Android

**Statut actuel**: 
- ✅ Application ID par défaut fonctionne
- ⚠️ Devrait être personnalisé pour production

**Priorité**: 🟢 BASSE (pour production uniquement)

**Action requise**: 
- Choisir un Application ID unique (ex: `com.arkalia.cia`)
- Mettre à jour `build.gradle.kts`

---

### 9. Configuration Signing Android

**Fichier**: `arkalia_cia/android/app/build.gradle.kts` (ligne 42)

**Description**: Ajouter configuration de signature pour release build

**Statut actuel**:
- ✅ Debug build fonctionne
- ⚠️ Release build nécessite configuration signing

**Priorité**: 🟢 BASSE (pour release uniquement)

**Action requise**:
- Créer keystore pour signature
- Configurer `signingConfigs` dans `build.gradle.kts`

---

## 📊 RÉSUMÉ

| Priorité | Nombre | Statut |
|----------|--------|--------|
| 🔴 Critique | 0 | - |
| 🟠 Élevée | 1 | Import portails (nécessite APIs externes) |
| 🟡 Moyenne | 0 | ✅ Tous terminés (Recherche médecin, Refresh token, Type examen, Audit log, Export/import) |
| 🟢 Basse | 1 | Signing (Application ID TERMINÉ) |

---

## ✅ ACTIONS RECOMMANDÉES

1. **Court terme** (1-2 semaines): ✅ TERMINÉ
   - ✅ Implémenter sélection médecin dans recherche avancée (23 novembre 2025)
   - Documenter APIs portails santé (si disponibles)

2. **Moyen terme** (1-2 mois): ✅ PARTIELLEMENT TERMINÉ
   - Implémenter import portails santé (nécessite APIs externes)
   - ✅ Implémenter refresh token automatique (23 novembre 2025)

3. **Long terme** (quand APIs disponibles):
   - Endpoints spécifiques par portail
   - Configuration production Android

---

**Note**: Ces TODOs sont documentés mais ne bloquent pas le fonctionnement actuel de l'application. Ils représentent des améliorations et fonctionnalités futures.

