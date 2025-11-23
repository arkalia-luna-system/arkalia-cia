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

### 3. Refresh Token pour Portails Santé ✅ TERMINÉ

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

### 4. Endpoints Spécifiques Portails Santé

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

### 5. Application ID Android

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

### 6. Configuration Signing Android

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
| 🟡 Moyenne | 0 | ✅ Recherche médecin TERMINÉ, ✅ Refresh token TERMINÉ |
| 🟢 Basse | 2 | Application ID, Signing |

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

