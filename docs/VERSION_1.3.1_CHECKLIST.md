# 📋 CHECKLIST VERSION 1.3.1 - 27 novembre 2025

**Objectif** : Passer de la version 1.3.0 à 1.3.1 avec toutes les corrections et améliorations

---

## ✅ CE QUI EST DÉJÀ FAIT

### Corrections CI/CD (27 novembre 2025)
- ✅ CI/CD refactorisé en 3 phases séparées
- ✅ Configuration flutter.source robuste
- ✅ Nettoyage fichiers macOS automatisé
- ✅ Permissions gradlew vérifiées
- ✅ local.properties retiré du suivi Git
- ✅ CI est VERTE ✅

### Corrections Code
- ✅ Warnings Flutter corrigés (withOpacity → withValues, Share → SharePlus)
- ✅ BuildContext across async gaps corrigé
- ✅ Tests widget corrigés
- ✅ 0 erreur lint Flutter
- ✅ 0 erreur lint Python

### Documentation
- ✅ Toutes les dates mises à jour à 27 novembre 2025
- ✅ README synchronisé
- ✅ Fichiers MD principaux à jour

---

## 🔄 À FAIRE POUR VERSION 1.3.1

### 1. Mise à jour des versions dans le code

#### Fichiers à modifier :
- [ ] `arkalia_cia/pubspec.yaml` : `1.3.0+2` → `1.3.1+1`
- [ ] `arkalia_cia/lib/screens/settings_screen.dart` : `'1.3.0+1'` → `'1.3.1+1'`
- [ ] `arkalia_cia/lib/screens/sync_screen.dart` : `'version': '1.3.0'` → `'version': '1.3.1'`
- [ ] `arkalia_cia/check_updates.sh` : `EXPECTED_VERSION="1.3.0+1"` → `EXPECTED_VERSION="1.3.1+1"`

#### Fichiers Android (automatique via Flutter) :
- ✅ `build.gradle.kts` utilise `flutter.versionCode` et `flutter.versionName` (automatique)

---

### 2. Vérifications avant release

#### Tests
- [ ] Vérifier que tous les tests passent (Flutter + Python)
- [ ] Vérifier que la CI est verte
- [ ] Tester build APK release
- [ ] Tester build Web release

#### Code Quality
- [ ] Vérifier 0 erreur lint Flutter (`flutter analyze`)
- [ ] Vérifier 0 erreur lint Python (`ruff check`, `mypy`)
- [ ] Vérifier que tous les warnings sont non-bloquants

#### Documentation
- [ ] Mettre à jour CHANGELOG.md avec les changements de la 1.3.1
- [ ] Vérifier que tous les fichiers MD mentionnent la bonne version
- [ ] Mettre à jour RELEASE_NOTES si nécessaire

---

### 3. Changements de la version 1.3.1

#### Corrections CI/CD
- ✅ Refactorisation CI en 3 phases (Phase 1: Configuration, Phase 2: Nettoyage, Phase 3: Build)
- ✅ Gestion robuste de flutter.source
- ✅ Nettoyage automatique fichiers macOS
- ✅ Vérification permissions gradlew

#### Corrections Code
- ✅ Warnings Flutter corrigés (withOpacity, Share)
- ✅ BuildContext across async gaps
- ✅ Tests widget corrigés

#### Améliorations
- ✅ Documentation synchronisée (dates 27 novembre 2025)
- ✅ local.properties retiré du suivi Git
- ✅ .gitignore amélioré

---

### 4. Ce qui reste à faire (non-bloquant pour 1.3.1)

#### Tests avec fichiers réels (CRITIQUE mais non-bloquant)
- [ ] Obtenir PDF réel Andaman 7
- [ ] Obtenir PDF réel MaSanté
- [ ] Tester parser avec vrais PDFs
- **Temps estimé** : 2-3 jours

#### Accréditation eHealth (CRITIQUE mais non-bloquant)
- [ ] Contacter integration-support@ehealth.fgov.be
- [ ] Préparer dossier d'enregistrement
- [ ] Obtenir certificat eHealth
- **Temps estimé** : 2-4 semaines

#### Tests Flutter (Amélioration)
- [ ] Ajouter tests unitaires pour services
- [ ] Ajouter tests widget pour écrans principaux
- [ ] Ajouter tests d'intégration
- **Temps estimé** : 1-2 semaines

#### Organisation Documentation (Amélioration)
- [ ] Fusionner fichiers redondants
- [ ] Organiser en dossiers
- [ ] Archiver fichiers obsolètes
- **Temps estimé** : 1-2 heures

---

## 📊 RÉSUMÉ

### Version actuelle
- **pubspec.yaml** : `1.3.0+2`
- **CI** : ✅ VERTE
- **Lint** : ✅ 0 erreur
- **Tests** : ✅ Tous passent

### Version cible
- **pubspec.yaml** : `1.3.1+1`
- **Changements** : Corrections CI/CD, warnings Flutter, documentation
- **Statut** : Prêt pour release après mise à jour des versions

---

**Dernière mise à jour** : 27 novembre 2025

