# 🔐 Authentification Web - Code PIN Local

**Date** : 10 décembre 2025  
**Version** : 1.3.1

---

## 🎯 PROBLÈME RÉSOLU

### Problème Initial

Sur le web (PWA), l'authentification biométrique ne fonctionne pas car `local_auth` n'est pas disponible sur le web.  
Si le navigateur ne propose pas de s'enregistrer mais propose directement un code, ça pose problème.

### Solution Implémentée

**Système d'authentification PIN local pour le web** :
- ✅ Détection automatique web vs mobile
- ✅ Sur web : Authentification PIN local (4-6 chiffres)
- ✅ Sur mobile : Authentification biométrique/PIN système (comme avant)
- ✅ PIN hashé avec SHA-256 (sécurité)
- ✅ Configuration PIN au premier lancement (web)
- ✅ Écran de saisie PIN pour authentification

---

## 🔧 ARCHITECTURE

### Services Créés

1. **`PinAuthService`** (`lib/services/pin_auth_service.dart`)
   - Gestion du PIN (configuration, vérification, réinitialisation)
   - Hash SHA-256 pour sécurité
   - Validation format (4-6 chiffres uniquement)
   - Préférences web/mobile

2. **`PinSetupScreen`** (`lib/screens/pin_setup_screen.dart`)
   - Écran de configuration du PIN (web uniquement)
   - Validation format et confirmation
   - Interface adaptée seniors

3. **`PinEntryScreen`** (`lib/screens/pin_entry_screen.dart`)
   - Écran de saisie du PIN (web uniquement)
   - Limite de tentatives (5 max)
   - Blocage temporaire après 5 échecs (30 secondes)

### Services Modifiés

1. **`AuthService`** (`lib/services/auth_service.dart`)
   - Détection web vs mobile
   - Sur web : Retourne false (indique d'utiliser PinEntryScreen)
   - Sur mobile : Fonctionne comme avant (biométrie/PIN système)

2. **`LockScreen`** (`lib/screens/lock_screen.dart`)
   - Détection web vs mobile
   - Sur web : Affiche PinSetupScreen ou PinEntryScreen
   - Sur mobile : Fonctionne comme avant (biométrie)

---

## 🔄 FLUX D'AUTHENTIFICATION

### Sur Mobile (comme avant)

```
LockScreen → AuthService.authenticate() → Biométrie/PIN système → HomePage
```

### Sur Web (nouveau)

```
LockScreen → Vérifier PIN configuré
  ├─ Non configuré → PinSetupScreen → Configurer PIN → PinEntryScreen → HomePage
  └─ Configuré → PinEntryScreen → Vérifier PIN → HomePage
```

---

## 🔒 SÉCURITÉ

### Hash du PIN

- **Algorithme** : SHA-256
- **Stockage** : Hash uniquement (jamais le PIN en clair)
- **Localisation** : SharedPreferences (web) / FlutterSecureStorage (mobile)

### Limites de Sécurité

- **Tentatives max** : 5
- **Blocage temporaire** : 30 secondes après 5 échecs
- **Format PIN** : 4-6 chiffres uniquement
- **Validation** : Regex `^\d+$`

---

## 🧪 TESTS

### Tests Créés

**`test/services/pin_auth_service_test.dart`** :
- ✅ 16 tests complets
- ✅ Configuration PIN
- ✅ Vérification PIN
- ✅ Validation format
- ✅ Réinitialisation
- ✅ Préférences

**Résultat** : ✅ Tous les tests passent (16/16)

---

## 📋 UTILISATION

### Pour l'Utilisateur (Web)

1. **Premier lancement** :
   - L'app affiche l'écran de configuration PIN
   - Choisir un PIN de 4 à 6 chiffres
   - Confirmer le PIN
   - ✅ PIN configuré

2. **Lancements suivants** :
   - L'app affiche l'écran de saisie PIN
   - Entrer le PIN configuré
   - ✅ Accès à l'app

3. **En cas d'oubli** :
   - Vider les données du navigateur (SharedPreferences)
   - Le PIN sera réinitialisé au prochain lancement

### Pour le Développeur

**Détection web** :
```dart
if (kIsWeb) {
  // Code pour web
} else {
  // Code pour mobile
}
```

**Utilisation PinAuthService** :
```dart
// Configurer un PIN
await PinAuthService.configurePin('1234');

// Vérifier un PIN
final isValid = await PinAuthService.verifyPin('1234');

// Vérifier si configuré
final isConfigured = await PinAuthService.isPinConfigured();
```

---

## ✅ CHECKLIST

- [x] Service PinAuthService créé
- [x] Écran PinSetupScreen créé
- [x] Écran PinEntryScreen créé
- [x] AuthService adapté (détection web)
- [x] LockScreen adapté (détection web)
- [x] Tests créés (16 tests)
- [x] Tous les tests passent
- [x] Aucune erreur de lint
- [x] Documentation créée

---

## 🎯 RÉSULTAT

**✅ Problème résolu !**

- ✅ Sur web : Authentification PIN local fonctionnelle
- ✅ Sur mobile : Authentification biométrique inchangée
- ✅ Sécurité : PIN hashé SHA-256
- ✅ Tests : 16 tests passent
- ✅ Aucune erreur de lint

**L'app fonctionne maintenant correctement sur web ET mobile !**

---

**Date** : 10 décembre 2025

