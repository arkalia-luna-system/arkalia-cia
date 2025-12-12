# 🔐 Guide Configuration Google Sign In

**Date** : 12 décembre 2025  
**Version** : 1.3.1

---

## 🎯 Vue d'ensemble

Arkalia CIA supporte la connexion Google/Gmail pour une authentification simple et sécurisée. Cette fonctionnalité est **100% gratuite** et fonctionne en mode **offline-first** (les données utilisateur sont stockées localement).

---

## ✅ Fonctionnalités

- ✅ **Connexion Google/Gmail** : Authentification via Google Sign In
- ✅ **Gratuit** : Aucun coût, pas de backend requis
- ✅ **Offline-first** : Stockage local des informations utilisateur
- ✅ **Sécurisé** : Utilise les standards OAuth de Google
- ✅ **Multi-plateforme** : Android et iOS supportés

---

## 🔧 Configuration

### Prérequis

1. **Compte Google Cloud** (gratuit)
   - Créer un projet sur [Google Cloud Console](https://console.cloud.google.com/)
   - Activer l'API Google Sign-In

2. **Client IDs OAuth**
   - Android : Client ID pour application Android
   - iOS : Client ID pour application iOS

---

## 📱 Configuration Android

### 1. Obtenir le SHA-1 de votre keystore

```bash
# Pour debug (développement)
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# Pour release (production)
keytool -list -v -keystore /path/to/your/keystore.jks -alias your-key-alias
```

### 2. Configurer dans Google Cloud Console

1. Aller sur [Google Cloud Console](https://console.cloud.google.com/)
2. Sélectionner votre projet
3. Aller dans **APIs & Services** > **Credentials**
4. Créer un **OAuth 2.0 Client ID** pour Android :
   - **Application type** : Android
   - **Package name** : `com.arkalia.cia`
   - **SHA-1 certificate fingerprint** : Coller le SHA-1 obtenu à l'étape 1

### 3. Le package `google_sign_in` gère automatiquement la configuration

Aucune configuration supplémentaire n'est nécessaire dans le code Android. Le package utilise automatiquement le client ID configuré dans Google Cloud Console.

---

## 🍎 Configuration iOS

### 1. Obtenir le Bundle ID

Le Bundle ID est configuré dans `ios/Runner.xcodeproj` :
- **Bundle Identifier** : `com.arkalia.cia`

### 2. Configurer dans Google Cloud Console

1. Aller sur [Google Cloud Console](https://console.cloud.google.com/)
2. Sélectionner votre projet
3. Aller dans **APIs & Services** > **Credentials**
4. Créer un **OAuth 2.0 Client ID** pour iOS :
   - **Application type** : iOS
   - **Bundle ID** : `com.arkalia.cia`

### 3. Configurer Info.plist

Le fichier `ios/Runner/Info.plist` contient déjà la configuration des URL schemes :

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.arkalia.cia</string>
        </array>
    </dict>
</array>
```

**Important** : Si vous utilisez un `REVERSED_CLIENT_ID` depuis `GoogleService-Info.plist`, remplacez `com.arkalia.cia` par votre `REVERSED_CLIENT_ID`.

### 4. Ajouter GoogleService-Info.plist (optionnel)

Si vous utilisez Firebase, ajoutez le fichier `GoogleService-Info.plist` dans `ios/Runner/` et configurez le `REVERSED_CLIENT_ID` dans Info.plist.

---

## 💻 Utilisation dans le code

### Service GoogleAuthService

Le service `GoogleAuthService` (`lib/services/google_auth_service.dart`) gère toute l'authentification :

```dart
// Connexion
final result = await GoogleAuthService.signIn();
if (result['success'] == true) {
  // Connexion réussie
  final user = result['user'];
  print('Connecté: ${user.email}');
}

// Vérifier si connecté
final isSignedIn = await GoogleAuthService.isSignedIn();

// Récupérer l'utilisateur actuel
final user = await GoogleAuthService.getCurrentUser();

// Déconnexion
await GoogleAuthService.signOut();
```

### Écran d'accueil

L'écran `WelcomeAuthScreen` (`lib/screens/auth/welcome_auth_screen.dart`) propose deux boutons :
- **Continuer avec Gmail** : Utilise Google Sign In
- **Continuer avec Google** : Utilise Google Sign In (même fonctionnalité)

Les deux boutons utilisent le même système d'authentification (Gmail est un service Google).

---

## 🔒 Sécurité et Confidentialité

### Données stockées localement

Les informations suivantes sont stockées localement (SharedPreferences) :
- Email de l'utilisateur
- Nom d'affichage
- Photo de profil (URL)
- ID utilisateur Google

**Aucune donnée n'est envoyée à un serveur externe** (sauf l'authentification Google elle-même).

### Mode offline-first

- Les données utilisateur sont stockées sur l'appareil
- Aucun backend requis
- Fonctionne même sans connexion internet (après la première connexion)

---

## 🐛 Dépannage

### Erreur "Sign in failed"

1. Vérifier que le SHA-1 est correctement configuré dans Google Cloud Console
2. Vérifier que le package name correspond (`com.arkalia.cia`)
3. Vérifier que l'API Google Sign-In est activée

### Erreur sur iOS

1. Vérifier que le Bundle ID correspond dans Google Cloud Console
2. Vérifier que les URL schemes sont correctement configurés dans Info.plist
3. Vérifier que `GoogleService-Info.plist` est présent (si utilisé)

### Erreur "DEVELOPER_ERROR"

Cette erreur indique généralement que le SHA-1 (Android) ou le Bundle ID (iOS) ne correspond pas à la configuration dans Google Cloud Console.

---

## 📚 Ressources

- [Documentation Google Sign In Flutter](https://pub.dev/packages/google_sign_in)
- [Google Cloud Console](https://console.cloud.google.com/)
- [Guide OAuth Google](https://developers.google.com/identity/protocols/oauth2)

---

## ✅ Checklist de configuration

### Android
- [ ] Projet créé dans Google Cloud Console
- [ ] API Google Sign-In activée
- [ ] SHA-1 obtenu (debug et release)
- [ ] Client ID Android créé avec SHA-1 et package name
- [ ] Package `google_sign_in` ajouté au `pubspec.yaml`

### iOS
- [ ] Projet créé dans Google Cloud Console
- [ ] API Google Sign-In activée
- [ ] Bundle ID vérifié (`com.arkalia.cia`)
- [ ] Client ID iOS créé avec Bundle ID
- [ ] URL schemes configurés dans Info.plist
- [ ] Package `google_sign_in` ajouté au `pubspec.yaml`

---

**Note** : La configuration Google Sign In est **gratuite** et ne nécessite aucun backend. Toutes les données utilisateur sont stockées localement sur l'appareil.

