# Guide de mise à jour Flutter — Authentification JWT

**Version** : 1.3.0  
**Date** : Janvier 2025

---

## Modifications effectuées

### Nouveau service d'authentification

**Fichier créé** : `arkalia_cia/lib/services/auth_api_service.dart`

Ce service gère :
- Inscription (`register`)
- Connexion (`login`)
- Rafraîchissement de token (`refreshToken`)
- Stockage sécurisé des tokens (FlutterSecureStorage)
- Vérification de connexion (`isLoggedIn`)
- Déconnexion (`logout`)

### Mise à jour ApiService

**Fichier modifié** : `arkalia_cia/lib/services/api_service.dart`

**Changements** :
- Tous les endpoints migrés vers `/api/v1/`
- Headers incluent automatiquement le token JWT
- Méthode `_headers` devient asynchrone pour récupérer le token

**Endpoints mis à jour** :
- `/api/documents/upload` → `/api/v1/documents/upload`
- `/api/documents` → `/api/v1/documents`
- `/api/reminders` → `/api/v1/reminders`
- `/api/emergency-contacts` → `/api/v1/emergency-contacts`
- `/api/health-portals` → `/api/v1/health-portals`

### Mise à jour ConversationalAIService

**Fichier modifié** : `arkalia_cia/lib/services/conversational_ai_service.dart`

**Changements** :
- Endpoints migrés vers `/api/v1/`
- Authentification JWT ajoutée à tous les appels

**Endpoints mis à jour** :
- `/api/ai/chat` → `/api/v1/ai/chat`
- `/api/ai/conversations` → `/api/v1/ai/conversations`
- `/api/ai/prepare-appointment` → `/api/v1/ai/prepare-appointment`
- `/api/aria/pain-entries/recent` → `/api/v1/aria/pain-entries/recent`

---

## 🔧 UTILISATION

### Inscription d'un Utilisateur

```dart
import 'package:arkalia_cia/services/auth_api_service.dart';

final result = await AuthApiService.register(
  username: 'patricia',
  password: 'motdepasse123',
  email: 'patricia@example.com',
);

if (result['success']) {
  print('Utilisateur créé avec succès');
} else {
  print('Erreur: ${result['error']}');
}
```

### Connexion

```dart
final result = await AuthApiService.login(
  username: 'patricia',
  password: 'motdepasse123',
);

if (result['success']) {
  print('Connecté avec succès');
  // Les tokens sont automatiquement stockés
} else {
  print('Erreur: ${result['error']}');
}
```

### Vérifier si Connecté

```dart
final isLoggedIn = await AuthApiService.isLoggedIn();
if (isLoggedIn) {
  print('Utilisateur connecté');
}
```

### Déconnexion

```dart
await AuthApiService.logout();
```

### Rafraîchir le Token

```dart
final result = await AuthApiService.refreshToken();
if (result['success']) {
  print('Token rafraîchi');
} else {
  // Token expiré, rediriger vers login
  await AuthApiService.logout();
}
```

---

## 🔄 GESTION AUTOMATIQUE DES TOKENS

Le `ApiService` ajoute automatiquement le token JWT dans les headers de toutes les requêtes :

```dart
// Avant (ancien code)
final response = await http.get(
  Uri.parse('$url/api/documents'),
  headers: {'Content-Type': 'application/json'},
);

// Maintenant (automatique)
final headers = await ApiService._headers; // Inclut automatiquement le token
final response = await http.get(
  Uri.parse('$url/api/v1/documents'),
  headers: headers,
);
```

---

## ⚠️ GESTION DES ERREURS 401

Quand un token est expiré, le backend retourne un 401. Il faut :

1. **Détecter l'erreur 401** dans les réponses
2. **Essayer de rafraîchir le token**
3. **Si échec, rediriger vers l'écran de connexion**

**Exemple d'implémentation**:

```dart
Future<Map<String, dynamic>> _makeRequest(Future<http.Response> Function() request) async {
  var response = await request();
  
  // Si 401, essayer de rafraîchir le token
  if (response.statusCode == 401) {
    final refreshResult = await AuthApiService.refreshToken();
    if (refreshResult['success']) {
      // Réessayer la requête avec le nouveau token
      response = await request();
    } else {
      // Token expiré, déconnecter
      await AuthApiService.logout();
      throw Exception('Session expirée');
    }
  }
  
  return json.decode(response.body);
}
```

---

## 📋 CHECKLIST D'IMPLÉMENTATION

### Écran de Connexion
- [ ] Créer un écran de login (`LoginScreen`)
- [ ] Utiliser `AuthApiService.login()`
- [ ] Gérer les erreurs (mauvais mot de passe, etc.)
- [ ] Rediriger vers l'écran principal après connexion

### Écran d'Inscription
- [ ] Créer un écran d'inscription (`RegisterScreen`)
- [ ] Utiliser `AuthApiService.register()`
- [ ] Valider les champs (username, password, email)
- [ ] Rediriger vers login après inscription

### Gestion de Session
- [ ] Vérifier `isLoggedIn()` au démarrage de l'app
- [ ] Rediriger vers login si non connecté
- [ ] Rafraîchir automatiquement le token avant expiration
- [ ] Gérer la déconnexion

### Protection des Écrans
- [ ] Vérifier l'authentification avant d'accéder aux écrans protégés
- [ ] Afficher un loader pendant la vérification
- [ ] Rediriger vers login si non authentifié

---

## 🧪 TESTS

### Test de Connexion

```dart
void testLogin() async {
  final result = await AuthApiService.login(
    username: 'test',
    password: 'test123456',
  );
  
  assert(result['success'] == true);
  assert(await AuthApiService.isLoggedIn() == true);
}
```

### Test d'Appel API avec Token

```dart
void testApiCallWithToken() async {
  // Se connecter d'abord
  await AuthApiService.login(username: 'test', password: 'test123456');
  
  // Appel API (le token est ajouté automatiquement)
  final documents = await ApiService.getDocuments();
  assert(documents.isNotEmpty);
}
```

---

## 📝 NOTES IMPORTANTES

1. **Stockage Sécurisé**: Les tokens sont stockés avec `FlutterSecureStorage` (Keychain sur iOS, Keystore sur Android)

2. **Expiration des Tokens**:
   - Access token: 30 minutes
   - Refresh token: 7 jours
   - Rafraîchir automatiquement avant expiration

3. **Backward Compatibility**: L'app fonctionne toujours si le backend n'est pas configuré (mode offline)

4. **Migration**: Les utilisateurs existants devront créer un compte et se connecter

---

## ✅ ÉTAPES TERMINÉES

1. ✅ Écrans de login/register créés (`LoginScreen`, `RegisterScreen`)
2. ✅ Gestion automatique du refresh token (via `AuthApiService`)
3. ✅ Protection des écrans (vérification au démarrage dans `_InitialScreen`)
4. ✅ Tests avec le backend (tous les tests mis à jour)

## 🚀 PROCHAINES ÉTAPES (Optionnelles)

1. Ajouter la gestion automatique du refresh token avant expiration
2. Ajouter un écran de profil utilisateur
3. Ajouter la réinitialisation de mot de passe
4. Améliorer les messages d'erreur

---

**Dernière mise à jour**: Janvier 2025  
**Status**: ✅ Écrans UI créés et intégrés

