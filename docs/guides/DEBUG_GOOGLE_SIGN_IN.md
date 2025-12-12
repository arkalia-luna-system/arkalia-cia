# 🐛 Débogage Google Sign-In - Guide de Résolution

**Date** : 12 décembre 2025  
**Version** : 1.3.1

---

## 🔍 DIAGNOSTIC DES ERREURS COURANTES

### Erreur "DEVELOPER_ERROR" (Code 10)

**Symptômes** :
- Message : "10: DEVELOPER_ERROR" ou "Sign in failed"
- La connexion échoue immédiatement

**Causes possibles** :
1. SHA-1 ne correspond pas à celui configuré dans Google Cloud Console
2. Package name incorrect (`com.arkalia.cia`)
3. Client ID Android non configuré ou incorrect

**Solutions** :

1. **Vérifier le SHA-1 actuel** :
```bash
cd arkalia_cia/android
./gradlew signingReport
```
Chercher la section "Variant: debug" et copier le SHA-1.

2. **Vérifier dans Google Cloud Console** :
   - Aller sur : https://console.cloud.google.com/auth/clients/1062485264410-3l6l1kuposfgmn9c609msme3rinlqnap.apps.googleusercontent.com?authuser=1&project=arkalia-cia
   - Vérifier que le SHA-1 correspond exactement
   - Vérifier que le package name est `com.arkalia.cia`

3. **Attendre la propagation** :
   - Les changements peuvent prendre 5-10 minutes à se propager
   - Redémarrer l'app après modification

---

### Erreur "NETWORK_ERROR" (Code 7)

**Symptômes** :
- Message : "7: NETWORK_ERROR"
- La connexion échoue avec erreur réseau

**Solutions** :
1. Vérifier la connexion internet
2. Vérifier que l'API Google Sign-In est activée dans Google Cloud Console
3. Vérifier les permissions internet dans AndroidManifest.xml

---

### Erreur "SIGN_IN_CANCELLED" (Code 12501)

**Symptômes** :
- L'utilisateur annule la connexion
- Pas vraiment une erreur, comportement normal

**Solution** :
- C'est normal, l'utilisateur a simplement annulé
- Aucune action nécessaire

---

### L'app crash au clic sur le bouton

**Causes possibles** :
1. Package `google_sign_in` non installé
2. Configuration AndroidManifest.xml manquante
3. Services Google Play non disponibles

**Solutions** :

1. **Vérifier l'installation du package** :
```bash
cd arkalia_cia
flutter pub get
```

2. **Vérifier AndroidManifest.xml** :
   - Doit contenir la meta-data pour Google Play Services
   - Voir la configuration dans `android/app/src/main/AndroidManifest.xml`

3. **Vérifier les services Google Play** :
   - Sur l'appareil : Paramètres > Applications > Google Play Services
   - Vérifier que les services sont à jour

---

## 🔧 VÉRIFICATIONS SYSTÉMATIQUES

### Checklist de débogage

1. **Configuration Google Cloud Console** :
   - [ ] Projet `arkalia-cia` existe
   - [ ] Client ID Android créé
   - [ ] SHA-1 debug configuré : `2C:68:D5:C0:92:A8:7F:59:E7:6A:7C:5B:7C:F9:77:54:9E:68:14:6E`
   - [ ] SHA-1 production configuré : `AC:9E:D1:E9:29:66:5E:95:DD:0E:0B:7F:9F:F9:88:D1:5D:69:71:19`
   - [ ] Package name : `com.arkalia.cia`
   - [ ] Écran OAuth publié en production
   - [ ] API Google Sign-In activée

2. **Configuration Code** :
   - [ ] Package `google_sign_in` dans `pubspec.yaml`
   - [ ] Service `GoogleAuthService` créé
   - [ ] Écran `WelcomeAuthScreen` utilise le service
   - [ ] AndroidManifest.xml contient la meta-data Google Play Services

3. **Tests** :
   - [ ] App compile sans erreur
   - [ ] App démarre sans crash
   - [ ] Boutons Google/Gmail visibles
   - [ ] Cliquer ouvre le sélecteur de compte

---

## 📱 COMMANDES DE DIAGNOSTIC

### Vérifier le SHA-1 actuel
```bash
cd arkalia_cia/android
./gradlew signingReport
```

### Vérifier les logs
```bash
# Sur Android
adb logcat | grep -i "google\|signin\|auth"

# Filtrer les erreurs
adb logcat | grep -i "error\|exception"
```

### Nettoyer et reconstruire
```bash
cd arkalia_cia
flutter clean
flutter pub get
flutter run -d android
```

---

## 🆘 SI RIEN NE FONCTIONNE

1. **Vérifier les logs détaillés** :
   - Activer les logs dans `GoogleAuthService`
   - Vérifier les messages d'erreur exacts

2. **Tester avec un compte de test** :
   - Créer un compte Google de test
   - Tester la connexion avec ce compte

3. **Vérifier la version du package** :
   - `google_sign_in: ^6.2.1` dans `pubspec.yaml`
   - Mettre à jour si nécessaire : `flutter pub upgrade google_sign_in`

4. **Contacter le support** :
   - Vérifier la documentation officielle : https://pub.dev/packages/google_sign_in
   - Vérifier les issues GitHub du package

---

## ✅ CONFIGURATION CORRECTE

### AndroidManifest.xml doit contenir :
```xml
<meta-data
    android:name="com.google.android.gms.version"
    android:value="@integer/google_play_services_version" />
```

### build.gradle.kts doit avoir :
- `applicationId = "com.arkalia.cia"`
- Pas besoin de configuration supplémentaire (géré automatiquement)

### Google Cloud Console doit avoir :
- Client ID Android avec SHA-1 debug ET production
- Package name : `com.arkalia.cia`
- Écran OAuth publié

---

**Dernière mise à jour** : 12 décembre 2025

