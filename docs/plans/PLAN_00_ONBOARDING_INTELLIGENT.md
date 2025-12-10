# Plan 00 : Onboarding Intelligent

**Version** : 1.0.0 | **Date** : 10 décembre 2025  
**Statut** : ✅ Implémenté

---

## 🎯 Objectif

Première connexion : import automatique intelligent pour créer historique complet dès le départ.

**Fonctionnalités** :
- ✅ Onboarding intelligent avec import automatique
- ✅ Import depuis portails santé (eHealth, Andaman 7, MaSanté)
- ✅ Extraction intelligente (essentiel uniquement)
- ✅ Interface ultra-simple (validation utilisateur)

---

## 🏗️ Architecture

### Flow Onboarding

```
Première Connexion
├── Étape 1 : Bienvenue + Explication
├── Étape 2 : Choix import (portails / manuel / skip)
├── Étape 3 : Authentification portails (si choisi)
├── Étape 4 : Import automatique avec progression
├── Étape 5 : Extraction intelligente données essentielles
└── Étape 6 : Validation historique créé
```

### Structure Fichiers

```
arkalia_cia/lib/screens/onboarding/
├── welcome_screen.dart           ✅ Écran bienvenue
├── import_choice_screen.dart     ✅ Choix import
├── portal_auth_screen.dart       ✅ Auth portails
└── import_progress_screen.dart   ✅ Progression import

arkalia_cia/lib/services/
├── onboarding_service.dart       ✅ Service onboarding
├── portal_import_service.dart    ✅ Import portails
└── intelligent_extractor.dart   ✅ Extraction intelligente
```

---

## 🔧 Implémentation

### Étape 1 : Écran Bienvenue ✅

**Fichier** : `welcome_screen.dart`

- Explication onboarding
- Bouton "Commencer"
- Navigation vers choix import

### Étape 2 : Choix Import ✅

**Fichier** : `import_choice_screen.dart`

- Option 1 : Import portails santé
- Option 2 : Import manuel PDF
- Option 3 : Commencer vide

### Étape 3 : Authentification Portails ✅

**Fichier** : `portal_auth_screen.dart`

- OAuth flow pour eHealth, Andaman 7, MaSanté
- Stockage tokens sécurisé
- Validation consentement

### Étape 4 : Import Automatique ✅

**Fichier** : `import_progress_screen.dart`

- Barre progression
- Import asynchrone
- Gestion erreurs

### Étape 5 : Extraction Intelligente ✅

**Fichier** : `intelligent_extractor.dart`

- Extraction médecins
- Extraction examens importants
- Limite données (50 examens max)

---

## ✅ Tests

- ✅ Tests UI onboarding
- ✅ Tests import portails
- ✅ Tests extraction intelligente
- ✅ Tests validation données

---

## 🚀 Performance

- ✅ Import asynchrone (non-bloquant)
- ✅ Extraction progressive
- ✅ Cache données importées
- ✅ Limite données (essentiel uniquement)

---

## 🔐 Sécurité

- ✅ Consentement explicite avant import
- ✅ Stockage local chiffré
- ✅ Validation données avant import
- ✅ Chiffrement tokens portails

---

## 📅 Timeline

**Semaine 1** : Onboarding UI ✅  
**Semaine 2** : Backend Import ✅  
**Semaine 3** : Extraction Intelligente ✅  
**Semaine 4** : Intégration ✅

---

## 📚 Ressources

- **eHealth API** : https://www.ehealth.fgov.be
- **Andaman 7** : https://www.andaman7.com
- **MaSanté** : https://www.masante.be

---

<div align="center">

**Statut** : ✅ **IMPLÉMENTÉ**  
**Priorité** : ✅ **TERMINÉ**

</div>
