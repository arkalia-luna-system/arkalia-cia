# 📋 TODO RESTANT - Version 1.3.1

**Date** : 27 novembre 2025  
**Statut** : Version 1.3.1 complète, tâches restantes non-bloquantes

---

## ✅ DÉJÀ FAIT (Version 1.3.1 complète)

- ✅ Version 1.3.1 mise à jour (4 fichiers)
- ✅ CHANGELOG.md mis à jour
- ✅ Tests Flutter : 1 → 19 tests (+1800%)
- ✅ Tests PDF améliorés
- ✅ Audit consolidé créé (`audits/AUDIT_COMPLET_27_NOVEMBRE_2025.md`)
- ✅ Plan d'organisation documentation créé
- ✅ CI verte et stable
- ✅ Fichiers redondants archivés

---

## 🎯 CE QUI RESTE À FAIRE

### 1. Organisation Documentation (1-2 heures) 🟡 PRIORITÉ

**Statut** : Partiellement fait, reste à finaliser

**Actions** :

- [x] Fusionner les audits en un seul fichier ✅
  - ✅ Créé `audits/AUDIT_COMPLET_27_NOVEMBRE_2025.md` (fusionné)
  - ✅ Anciens fichiers archivés
- [ ] Fusionner les corrections (optionnel)
  - `CORRECTIONS_AUDIT_CONSOLIDEES.md` existe déjà (complet)
  - `CORRECTIONS_CONSOLIDEES.md` est dans archive/ (ancien)
- [x] Organiser en dossiers ✅
  - ✅ Guides dans `guides/`
  - ✅ Deployment dans `deployment/`
  - ✅ Audits dans `audits/`
  - ✅ Releases redondants archivés
- [x] Archiver fichiers obsolètes ✅
  - ✅ Fichiers avec dates anciennes archivés
  - ✅ Fichiers redondants archivés
- [ ] Créer README.md dans `docs/` avec index (optionnel)

**Impact** : Améliore la maintenabilité, facilite la navigation

---

### 2. Tests Flutter supplémentaires (en cours) 🟡 PRIORITÉ

**Statut** : 19 tests créés, peut continuer

**Actions** :

- [x] Tests unitaires services simples ✅
  - ✅ OnboardingService (3 tests)
  - ✅ AuthService (3 tests)
  - ✅ ThemeService (7 tests)
  - ✅ BackendConfigService (5 tests)
  - ✅ CategoryService (8 tests) - **NOUVEAU**
- [ ] Tests pour autres services simples
  - `local_storage_service.dart` (peut-être testable)
- [ ] Tests widget pour écrans principaux
  - `home_screen.dart`
  - `documents_screen.dart`
  - `settings_screen.dart`
- [ ] Tests d'intégration basiques

**Impact** : Améliore la qualité et la confiance dans le code

---

### 3. Tests avec fichiers réels PDF (2-3 jours) ⚠️ NON-BLOQUANT

**Statut** : Tests avec PDFs générés fonctionnent ✅

**Actions** :

- [ ] Obtenir PDF réel Andaman 7
- [ ] Obtenir PDF réel MaSanté
- [ ] Tester parser avec vrais PDFs
- [ ] Ajuster regex si nécessaire
- [ ] Tester endpoint backend end-to-end
- [ ] Tester UI Flutter end-to-end

**Blocage** : Nécessite des fichiers PDF réels (non disponibles actuellement)

**Impact** : Important pour valider la fonctionnalité d'import manuel

---

### 4. Accréditation eHealth (2-4 semaines) ⚠️ NON-BLOQUANT

**Statut** : Procédure administrative, non-bloquant

**Actions** :

- [ ] Contacter `integration-support@ehealth.fgov.be`
- [ ] Préparer dossier d'enregistrement
- [ ] Obtenir certificat eHealth (sandbox puis production)
- [ ] Obtenir `client_id` et `client_secret`
- [ ] Configurer callback URL dans eHealth

**Blocage** : Procédure administrative longue

**Impact** : Important pour l'intégration eHealth, mais non-bloquant pour la release

---

## 🎯 PLAN D'ACTION IMMÉDIAT

### Option 1 : Organisation Documentation (recommandé)

**Temps** : 1-2 heures  
**Impact** : Améliore la maintenabilité  
**Faisable maintenant** : ✅ Oui

### Option 2 : Continuer Tests Flutter

**Temps** : 1-2 heures  
**Impact** : Améliore la qualité  
**Faisable maintenant** : ✅ Oui

### Option 3 : Les deux en parallèle

**Temps** : 2-3 heures  
**Impact** : Maximum  
**Faisable maintenant** : ✅ Oui

---

## 📊 STATISTIQUES ACTUELLES

- **Tests Flutter** : 19 tests (1 widget + 18 services)
- **Tests Python** : 508 tests (71.98% coverage)
- **Fichiers MD** : ~135 fichiers (redondances archivées)
- **CI** : ✅ VERTE
- **Lint** : ✅ 0 erreur
- **Version** : ✅ 1.3.1+1 (complète)

**Dernière mise à jour** : 27 novembre 2025

