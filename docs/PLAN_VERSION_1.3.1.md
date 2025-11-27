# 🎯 PLAN VERSION 1.3.1 - 27 novembre 2025

**Objectif** : Passer de la version 1.3.0 à 1.3.1 avec toutes les corrections et améliorations

---

## 📊 ÉTAT ACTUEL

### Version actuelle
- **pubspec.yaml** : `1.3.0+2`
- **CI** : ✅ VERTE (27 novembre 2025)
- **Lint** : ✅ 0 erreur Flutter, 0 erreur Python
- **Tests** : ✅ 508 tests Python passent, 1 test Flutter passe
- **Build** : ✅ APK et Web fonctionnent

### Fichiers à mettre à jour
- `arkalia_cia/pubspec.yaml` : `1.3.0+2` → `1.3.1+1`
- `arkalia_cia/lib/screens/settings_screen.dart` : `'1.3.0+1'` → `'1.3.1+1'`
- `arkalia_cia/lib/screens/sync_screen.dart` : `'version': '1.3.0'` → `'version': '1.3.1'`
- `arkalia_cia/check_updates.sh` : `EXPECTED_VERSION="1.3.0+1"` → `EXPECTED_VERSION="1.3.1+1"`

---

## ✅ CE QUI EST DÉJÀ FAIT (27 novembre 2025)

### Corrections CI/CD
- ✅ CI/CD refactorisé en 3 phases séparées
  - Phase 1: Configuration flutter.source
  - Phase 2: Nettoyage fichiers macOS
  - Phase 3: Build APK
- ✅ Configuration flutter.source robuste (init.gradle, settings.gradle.kts, build.gradle.kts)
- ✅ Nettoyage automatique fichiers macOS (`._*`, `.DS_Store`)
- ✅ Vérification permissions gradlew
- ✅ local.properties retiré du suivi Git
- ✅ CI est VERTE ✅

### Corrections Code
- ✅ Warnings Flutter corrigés
  - `withOpacity` → `withValues(alpha: ...)` (avec ignore comments)
  - `Share.share` → `SharePlus.instance.share(ShareParams(...))`
- ✅ BuildContext across async gaps corrigé (settings_screen.dart)
- ✅ Tests widget corrigés (widget_test.dart)
- ✅ 0 erreur lint Flutter (`flutter analyze`)
- ✅ 0 erreur lint Python (`ruff check`, `mypy`)

### Documentation
- ✅ Toutes les dates mises à jour à 27 novembre 2025 (69 fichiers MD)
- ✅ README synchronisé avec date du dernier audit
- ✅ Fichiers MD principaux à jour
- ✅ GUIDE_DEPLOIEMENT_FINAL.md mis à jour

---

## 🔄 À FAIRE POUR VERSION 1.3.1

### 1. Mise à jour des versions dans le code ⚠️ BLOQUANT

#### Fichiers à modifier :
- [ ] `arkalia_cia/pubspec.yaml` : `1.3.0+2` → `1.3.1+1`
- [ ] `arkalia_cia/lib/screens/settings_screen.dart` : `'1.3.0+1'` → `'1.3.1+1'`
- [ ] `arkalia_cia/lib/screens/sync_screen.dart` : `'version': '1.3.0'` → `'version': '1.3.1'`
- [ ] `arkalia_cia/check_updates.sh` : `EXPECTED_VERSION="1.3.0+1"` → `EXPECTED_VERSION="1.3.1+1"`

#### Fichiers Android (automatique via Flutter) :
- ✅ `build.gradle.kts` utilise `flutter.versionCode` et `flutter.versionName` (automatique depuis pubspec.yaml)

---

### 2. Vérifications avant release ⚠️ BLOQUANT

#### Tests
- [ ] Vérifier que tous les tests passent (Flutter + Python)
- [ ] Vérifier que la CI est verte (déjà ✅)
- [ ] Tester build APK release localement
- [ ] Tester build Web release localement

#### Code Quality
- [ ] Vérifier 0 erreur lint Flutter (`flutter analyze`) (déjà ✅)
- [ ] Vérifier 0 erreur lint Python (`ruff check`, `mypy`) (déjà ✅)
- [ ] Vérifier que tous les warnings sont non-bloquants (déjà ✅)

#### Documentation
- [ ] Mettre à jour CHANGELOG.md avec les changements de la 1.3.1
- [ ] Vérifier que tous les fichiers MD mentionnent la bonne version (déjà fait pour certains)
- [ ] Mettre à jour RELEASE_NOTES si nécessaire

---

### 3. Changements de la version 1.3.1

#### Corrections CI/CD
- ✅ Refactorisation CI en 3 phases (Phase 1: Configuration, Phase 2: Nettoyage, Phase 3: Build)
- ✅ Gestion robuste de flutter.source (init.gradle, settings.gradle.kts, build.gradle.kts)
- ✅ Nettoyage automatique fichiers macOS (`._*`, `.DS_Store`)
- ✅ Vérification permissions gradlew
- ✅ local.properties retiré du suivi Git

#### Corrections Code
- ✅ Warnings Flutter corrigés (withOpacity, Share)
- ✅ BuildContext across async gaps
- ✅ Tests widget corrigés

#### Améliorations
- ✅ Documentation synchronisée (dates 27 novembre 2025)
- ✅ local.properties retiré du suivi Git
- ✅ .gitignore amélioré

---

## ⏸️ CE QUI RESTE À FAIRE (NON-BLOQUANT pour 1.3.1)

### 1. Tests avec fichiers réels (CRITIQUE mais non-bloquant) ⚠️

**Statut** : Tests créés mais pas testés avec vrais PDFs

**Actions** :
- [ ] Obtenir PDF réel Andaman 7 (ou générer un PDF plus réaliste)
- [ ] Obtenir PDF réel MaSanté (ou générer un PDF plus réaliste)
- [ ] Tester parser Andaman 7 avec PDF réel
- [ ] Tester parser MaSanté avec PDF réel
- [ ] Ajuster regex si nécessaire
- [ ] Tester endpoint backend end-to-end
- [ ] Tester UI Flutter end-to-end

**Temps estimé** : 2-3 jours

**Impact** : Important pour la fonctionnalité d'import manuel, mais non-bloquant pour la release 1.3.1

---

### 2. Accréditation eHealth (CRITIQUE mais non-bloquant) ⚠️

**Statut** : En attente

**Actions nécessaires** :
- [ ] Contacter `integration-support@ehealth.fgov.be`
- [ ] Préparer dossier d'enregistrement
- [ ] Obtenir certificat eHealth (sandbox puis production)
- [ ] Obtenir `client_id` et `client_secret`
- [ ] Configurer callback URL dans eHealth

**Temps estimé** : 2-4 semaines (procédure administrative)

**Blocage** : Impossible de tester sans accréditation

**Impact** : Important pour l'intégration eHealth, mais non-bloquant pour la release 1.3.1

---

### 3. Tests Flutter (Amélioration) 🟡

**Statut** : 1 seul test (widget_test.dart)

**Actions** :
- [ ] Ajouter tests unitaires pour services
- [ ] Ajouter tests widget pour écrans principaux
- [ ] Ajouter tests d'intégration

**Temps estimé** : 1-2 semaines

**Impact** : Amélioration de la qualité, mais non-bloquant pour la release 1.3.1

---

### 4. Organisation Documentation (Amélioration) 🟡

**Statut** : 118 fichiers MD (trop dispersés)

**Actions** :
- [ ] Fusionner fichiers redondants
- [ ] Organiser en dossiers (`guides/`, `portails/`, `audits/`)
- [ ] Archiver fichiers obsolètes dans `deprecated/`

**Temps estimé** : 1-2 heures

**Impact** : Amélioration de la maintenabilité, mais non-bloquant pour la release 1.3.1

---

## 📋 CHECKLIST FINALE POUR RELEASE 1.3.1

### Avant de commiter
- [ ] Mettre à jour `pubspec.yaml` : `1.3.0+2` → `1.3.1+1`
- [ ] Mettre à jour `settings_screen.dart` : `'1.3.0+1'` → `'1.3.1+1'`
- [ ] Mettre à jour `sync_screen.dart` : `'version': '1.3.0'` → `'version': '1.3.1'`
- [ ] Mettre à jour `check_updates.sh` : `EXPECTED_VERSION="1.3.0+1"` → `EXPECTED_VERSION="1.3.1+1"`
- [ ] Mettre à jour `CHANGELOG.md` avec les changements de la 1.3.1

### Vérifications
- [ ] `flutter analyze` : 0 erreur ✅
- [ ] `ruff check` : 0 erreur ✅
- [ ] `mypy` : 0 erreur ✅
- [ ] Tests Python : Tous passent ✅
- [ ] Tests Flutter : Tous passent ✅
- [ ] CI : VERTE ✅

### Builds
- [ ] `flutter build apk --release` : Succès
- [ ] `flutter build web --release` : Succès

### Documentation
- [ ] CHANGELOG.md mis à jour
- [ ] README.md vérifié
- [ ] Fichiers MD principaux vérifiés

---

## 🎯 RÉSUMÉ

### Version actuelle
- **pubspec.yaml** : `1.3.0+2`
- **CI** : ✅ VERTE
- **Lint** : ✅ 0 erreur
- **Tests** : ✅ Tous passent

### Version cible
- **pubspec.yaml** : `1.3.1+1`
- **Changements** : Corrections CI/CD, warnings Flutter, documentation
- **Statut** : Prêt pour release après mise à jour des versions

### Actions immédiates
1. Mettre à jour les versions dans le code (4 fichiers)
2. Mettre à jour CHANGELOG.md
3. Vérifier que la CI passe toujours
4. Commit et push

---

**Dernière mise à jour** : 27 novembre 2025

