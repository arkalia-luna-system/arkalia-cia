# Plan d'Action - Problèmes Restants

**Date** : 12 décembre 2025  
**Version** : 1.3.1+6  
**Statut** : 18/20 problèmes résolus (90%)

---

## RÉSUMÉ

**Problèmes restants** : 5/20 (25%)

- **Critique** : 0 (Tous résolus - Profil multi-appareil implémenté)
- **Élevé** : 0 (100% résolu)
- **Moyen** : 4 (Patterns, Statistiques, Dialog partage, BBIA)

---

## RECOMMANDATION : PAR QUOI COMMENCER

### ✅ Priorité 1 : Pathologies - Sous-catégories (TERMINÉ - 12 décembre 2025)

**Statut** : Résolu

**Ce qui a été fait** :
1. ✅ Modèle `Pathology` : Ajout champs `category` et `subcategory`
2. ✅ Service `PathologyCategoryService` : Mapping pathologie → catégorie → sous-catégorie
3. ✅ Migration base de données : Colonnes `category` et `subcategory` ajoutées
4. ✅ `PathologyService` : Méthodes de groupement et filtrage par catégorie
5. ✅ `PathologyListScreen` : UI avec sections par catégorie (ExpansionTile)
6. ✅ Tous les templates mis à jour avec catégories
7. ✅ Tests créés et passés

**Fichiers modifiés** :
- `arkalia_cia/lib/models/pathology.dart`
- `arkalia_cia/lib/services/pathology_category_service.dart` (nouveau)
- `arkalia_cia/lib/services/pathology_service.dart`
- `arkalia_cia/lib/screens/pathology_list_screen.dart`
- `arkalia_cia/test/models/pathology_test.dart` (nouveau)
- `arkalia_cia/test/services/pathology_category_service_test.dart` (nouveau)

### Priorité 1 (nouvelle) : Médecins - Détection auto (1 jour)

**Pourquoi commencer par ça ?**
- Seul problème élevé restant
- Impact UX important (organisation des pathologies)
- Complexité modérée (2-3 jours)
- Base solide déjà en place (PathologyService, PathologyColorService)

**Ce qui existe déjà :**
- `Pathology` modèle avec couleur basée sur spécialité
- `PathologyService` avec CRUD complet
- `PathologyColorService` pour mapping pathologie → spécialité → couleur
- `PathologyListScreen` qui affiche les pathologies en liste simple
- 24 templates de pathologies déjà créés

**Ce qui manque :**
- Champ `category` et `subcategory` dans modèle `Pathology`
- Système hiérarchique dans `PathologyService`
- UI avec catégories/sous-catégories dans `PathologyListScreen`
- Filtres par catégorie/spécialité

**Plan d'implémentation :**

1. **Modifier modèle `Pathology`** (2-3 heures)
   - Ajouter champs `category` (String?) et `subcategory` (String?)
   - Mettre à jour `toMap()` et `fromMap()`
   - Migration base de données (ajouter colonnes)

2. **Créer mapping catégories** (2-3 heures)
   - Mapping pathologie → catégorie → sous-catégorie
   - Utiliser spécialités médicales comme catégories principales
   - Exemple : "Gynécologie" → "Endométriose", "Fibromyalgie"

3. **Modifier `PathologyService`** (3-4 heures)
   - Méthodes pour grouper par catégorie
   - Filtres par catégorie/sous-catégorie
   - Migration données existantes (assigner catégories aux pathologies)

4. **Modifier `PathologyListScreen`** (4-6 heures)
   - UI avec sections par catégorie (ExpansionTile)
   - Filtres par catégorie/spécialité
   - Choix couleur personnalisée (en plus des couleurs spécialités)
   - Organisation hiérarchique claire

5. **Tests** (2-3 heures)
   - Tests modèle avec catégories
   - Tests service avec filtres
   - Tests UI avec sections

**Total estimé** : 2-3 jours

---

### Priorité 2 : Médecins - Détection auto (1 jour)

**Pourquoi après ?**
- Amélioration UX (gain de temps utilisateur)
- Complexité faible (1 jour)
- Impact modéré

**Ce qui existe déjà :**
- `DoctorService` pour gestion médecins
- Upload PDF dans `DocumentsScreen`
- Parsing PDF dans backend (`pdf_processor.py`)

**Ce qui manque :**
- Détection nom médecin dans PDF
- Dialog proposition après détection
- Ajout rapide depuis dialog

**Plan d'implémentation :**

1. **Détection médecin dans PDF** (3-4 heures)
   - Utiliser regex pour détecter noms (Dr., Docteur, etc.)
   - Extraire nom + spécialité si disponible
   - Retourner suggestions

2. **Dialog proposition** (2-3 heures)
   - Afficher médecin détecté après upload PDF
   - Boutons "Ajouter" / "Ignorer"
   - Pré-remplir formulaire si "Ajouter"

3. **Tests** (1-2 heures)
   - Tests détection noms
   - Tests dialog

**Total estimé** : 1 jour

---

### Priorité 3 : Patterns - Erreur non spécifiée (1 jour)

**Pourquoi après ?**
- Correction bug (important mais pas bloquant)
- Complexité faible (1 jour)
- Impact utilisateur modéré

**Ce qui existe déjà :**
- `pattern_analyzer.py` dans backend
- `PatternsDashboardScreen` dans Flutter
- Gestion erreurs basique

**Ce qui manque :**
- Messages d'erreur clairs et spécifiques
- Logging détaillé
- Fallback gracieux

**Plan d'implémentation :**

1. **Améliorer gestion erreurs backend** (2-3 heures)
   - Messages d'erreur spécifiques par type d'erreur
   - Logging détaillé avec contexte
   - Fallback gracieux si analyse échoue

2. **Améliorer affichage erreurs Flutter** (2-3 heures)
   - Messages utilisateur clairs
   - Suggestions de solutions
   - Bouton "Réessayer"

3. **Tests** (1-2 heures)
   - Tests erreurs backend
   - Tests affichage erreurs Flutter

**Total estimé** : 1 jour

---

### Priorité 4 : Statistiques - Placement UI (1 jour)

**Pourquoi après ?**
- Amélioration UX (organisation)
- Complexité faible (1 jour)
- Impact modéré

**Ce qui existe déjà :**
- Statistiques dans `HomePage`
- Graphiques dans certaines sections

**Ce qui manque :**
- Section "Statistiques" dans `SettingsScreen`
- Déplacer statistiques détaillées en paramètres
- Garder indicateurs simples sur écrans principaux

**Plan d'implémentation :**

1. **Créer section Statistiques dans Settings** (3-4 heures)
   - Graphiques détaillés
   - Filtres par période
   - Export données

2. **Simplifier indicateurs HomePage** (2-3 heures)
   - Garder seulement indicateurs clés
   - Lien vers statistiques détaillées

3. **Tests** (1 heure)
   - Tests navigation
   - Tests affichage statistiques

**Total estimé** : 1 jour

---

### Priorité 5 : Dialog partage - Feedback (1 jour)

**Pourquoi après ?**
- Amélioration UX (confirmation)
- Complexité très faible (1 jour)
- Impact faible mais utile

**Ce qui existe déjà :**
- `FamilySharingScreen` avec partage
- `FamilySharingService` fonctionnel

**Ce qui manque :**
- SnackBar avec confirmation après partage
- Indicateur visuel pendant partage
- Compteur documents partagés

**Plan d'implémentation :**

1. **Ajouter feedback visuel** (2-3 heures)
   - SnackBar avec confirmation
   - Indicateur de chargement pendant partage
   - Compteur documents partagés

2. **Tests** (1 heure)
   - Tests feedback
   - Tests compteur

**Total estimé** : 1 jour

---

### Priorité 6 : Profil multi-appareil ✅ IMPLÉMENTÉ

**Statut** : ✅ Implémenté le 12 décembre 2025

**Ce qui a été fait** :
1. ✅ Modèles `UserProfile` et `Device` créés
2. ✅ Service `UserProfileService` pour gestion profil local
3. ✅ Service `MultiDeviceSyncService` avec synchronisation E2E
4. ✅ Écran `UserProfileScreen` pour gestion profil et appareils
5. ✅ Tests complets pour modèles et services
6. ⚠️ Endpoints backend à ajouter (`/api/v1/user/profile`)

**Fichiers créés** :
- `arkalia_cia/lib/models/user_profile.dart`
- `arkalia_cia/lib/models/device.dart`
- `arkalia_cia/lib/services/user_profile_service.dart`
- `arkalia_cia/lib/services/multi_device_sync_service.dart`
- `arkalia_cia/lib/screens/user_profile_screen.dart`
- Tests associés

---

### Priorité 7 : BBIA - Placeholder (Phase 4)

**Pourquoi en dernier ?**
- Fonctionnalité future
- Pas prioritaire
- Nécessite projet BBIA séparé

**Statut** : Fonctionnalité future, Phase 4

---

## ORDRE RECOMMANDÉ

1. **Pathologies - Sous-catégories** (2-3 jours) - Élevé
2. **Médecins - Détection auto** (1 jour) - Moyen
3. **Patterns - Erreur** (1 jour) - Moyen
4. **Statistiques - Placement** (1 jour) - Moyen
5. **Dialog partage - Feedback** (1 jour) - Moyen
6. ✅ **Profil multi-appareil** - Implémenté (12 décembre 2025)
7. **BBIA** (Phase 4) - Futur

**Total estimé** : 5-7 jours pour problèmes prioritaires (1-5)

---

## DÉCISION

**Commencer par : Pathologies - Sous-catégories**

**Raisons :**
- Seul problème élevé restant
- Impact UX important
- Complexité modérée
- Base solide déjà en place
- 2-3 jours de développement

**Après ça :**
- Enchaîner avec les problèmes moyens (1 jour chacun)
- Total : 5-7 jours pour tout résoudre (hors profil multi-appareil et BBIA)

---

**Dernière mise à jour** : 12 décembre 2025

