# 🔧 Résolution Problèmes Google Sign-In

**Date** : 12 décembre 2025  
**Version** : 1.3.1

---

## 🔍 DIAGNOSTIC AUTOMATIQUE

Exécutez le script de diagnostic complet :

```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia
bash scripts/diagnostic_google_complet.sh
```

Ce script vérifie :
- ✅ Code Flutter (package, service, écran)
- ✅ Configuration Android (package name, namespace, AndroidManifest)
- ✅ Configuration iOS (Info.plist, Client ID)
- ✅ SHA-1 Debug (tentative de lecture)
- ✅ Problèmes potentiels

---

## 🐛 PROBLÈMES COURANTS ET SOLUTIONS

### Problème 1 : Erreur "DEVELOPER_ERROR" ou "10:"

**Symptômes** :
- La connexion échoue immédiatement
- Message d'erreur mentionne "configuration" ou "DEVELOPER_ERROR"

**Cause** : SHA-1 ne correspond pas à celui dans Google Cloud Console

**Solution** :

1. **Obtenir le SHA-1 de votre appareil** :

```bash
# Méthode 1 : Depuis le keystore debug
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android | grep SHA1

# Méthode 2 : Depuis Gradle
cd arkalia_cia/android
./gradlew signingReport | grep -A 5 "Variant: debug"
```

2. **Vérifier dans Google Cloud Console** :
   - Aller sur : https://console.cloud.google.com/apis/credentials?project=arkalia-cia
   - Ouvrir "Client Android 1"
   - Vérifier que le SHA-1 correspond EXACTEMENT
   - Si différent, ajouter le nouveau SHA-1
   - Attendre 5-10 minutes pour la propagation

3. **Redémarrer l'app** après modification

---

### Problème 2 : Erreur "NETWORK_ERROR" ou "7:"

**Symptômes** :
- Erreur de connexion réseau
- Impossible de se connecter à Google

**Solutions** :
1. Vérifier la connexion internet
2. Vérifier que l'API Google Sign-In est activée dans Google Cloud Console
3. Vérifier les permissions internet dans AndroidManifest.xml (déjà présent)

---

### Problème 3 : L'app crash au clic sur le bouton

**Causes possibles** :
1. Package `google_sign_in` non installé
2. Google Play Services non disponibles sur l'appareil
3. Configuration AndroidManifest.xml manquante

**Solutions** :

1. **Vérifier l'installation** :
```bash
cd arkalia_cia
flutter pub get
```

2. **Vérifier Google Play Services** :
   - Sur l'appareil : Paramètres > Applications > Google Play Services
   - Vérifier qu'il est installé et à jour

3. **Vérifier AndroidManifest.xml** :
   - Doit contenir : `<meta-data android:name="com.google.android.gms.version" .../>`
   - ✅ Déjà présent dans le projet

---

### Problème 4 : Aucune erreur mais rien ne se passe

**Causes possibles** :
1. Le sélecteur de compte Google ne s'ouvre pas
2. L'utilisateur annule sans le voir
3. Problème de permissions

**Solutions** :

1. **Vérifier les logs détaillés** :
```bash
adb logcat | grep -i "google\|signin\|auth"
```

2. **Vérifier les permissions** :
   - L'app doit avoir accès à Internet (déjà configuré)

3. **Tester avec un autre compte Google**

---

## 📋 CHECKLIST DE VÉRIFICATION

### Configuration Google Cloud Console

- [ ] Projet `arkalia-cia` existe
- [ ] Écran de consentement OAuth publié en production
- [ ] Client Android 1 créé avec :
  - [ ] Package name : `com.arkalia.cia`
  - [ ] SHA-1 Debug : (vérifier qu'il correspond)
  - [ ] SHA-1 Production : `AC:9E:D1:E9:29:66:5E:95:DD:0E:0B:7F:9F:F9:88:D1:5D:69:71:19`
- [ ] API Google Sign-In activée

### Configuration Code

- [ ] Package `google_sign_in: ^6.2.1` dans pubspec.yaml
- [ ] Service `GoogleAuthService` présent
- [ ] Écran `WelcomeAuthScreen` avec boutons Google/Gmail
- [ ] AndroidManifest.xml avec Google Play Services
- [ ] Package name : `com.arkalia.cia`
- [ ] Namespace : `com.arkalia.cia`

### Tests

- [ ] L'app se lance sans erreur
- [ ] Les boutons Google/Gmail sont visibles
- [ ] Le clic ouvre le sélecteur de compte Google
- [ ] La sélection d'un compte connecte l'utilisateur
- [ ] Redirection vers LockScreen après connexion

---

## 🔧 COMMANDES UTILES

### Obtenir le SHA-1

```bash
# Méthode 1 : Keystore debug
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android | grep SHA1

# Méthode 2 : Gradle
cd arkalia_cia/android
./gradlew signingReport

# Méthode 3 : Depuis l'appareil (si app installée)
adb shell "dumpsys package com.arkalia.cia | grep -A 10 signatures"
```

### Vérifier les logs

```bash
# Logs Google Sign-In
adb logcat | grep -i "google\|signin\|auth"

# Logs Flutter
adb logcat | grep -i "flutter"
```

### Tester la connexion

1. Lancer l'app : `bash scripts/run-android.sh`
2. Cliquer sur "Continuer avec Gmail" ou "Continuer avec Google"
3. Vérifier le dialog d'erreur (si erreur)
4. Vérifier les logs avec `adb logcat`

---

## 📞 SUPPORT

Si le problème persiste :

1. **Exécuter le diagnostic complet** :
   ```bash
   bash scripts/diagnostic_google_complet.sh
   ```

2. **Capturer les logs** :
   ```bash
   adb logcat > google_signin_logs.txt
   # Essayer de se connecter
   # Ctrl+C pour arrêter
   ```

3. **Vérifier Google Cloud Console** :
   - URL : https://console.cloud.google.com/apis/credentials?project=arkalia-cia
   - Vérifier tous les SHA-1 configurés
   - Vérifier que le package name est exact

---

## ✅ CONFIGURATION ATTENDUE

### Google Cloud Console

**Client Android 1** :
- Package name : `com.arkalia.cia`
- SHA-1 Debug : `2C:68:D5:C0:92:A8:7F:59:E7:6A:7C:5B:7C:F9:77:54:9E:68:14:6E`
- SHA-1 Production : `AC:9E:D1:E9:29:66:5E:95:DD:0E:0B:7F:9F:F9:88:D1:5D:69:71:19`
- Client ID : `1062485264410-3l6l1kuposfgmn9c609msme3rinlqnap.apps.googleusercontent.com`

**Client iOS 1** :
- Bundle ID : `com.arkalia.cia`
- Client ID : `1062485264410-ifvnihjo5mmna0ckt11321uvfd569jnl`

### Code

- Package name : `com.arkalia.cia`
- Namespace : `com.arkalia.cia`
- Google Play Services : Configuré dans AndroidManifest.xml
- REVERSED_CLIENT_ID iOS : Configuré dans Info.plist

---

**Dernière mise à jour** : 12 décembre 2025

