# ✅ Vérification Google Cloud Console - Checklist Complète

**Date** : 12 décembre 2025  
**Version** : 1.3.1

---

## 🔍 INFORMATIONS À VÉRIFIER

### 📱 Informations de ton App

| Élément | Valeur à utiliser |
|---------|-------------------|
| **Package Name (Android)** | `com.arkalia.cia` |
| **Bundle ID (iOS)** | `com.arkalia.cia` |
| **SHA-1 Debug** | Voir ci-dessous (à récupérer) |
| **SHA-1 Production** | Voir ci-dessous (à récupérer) |

---

## 🔐 ÉTAPE 1 : Récupérer les SHA-1

### SHA-1 Debug (pour développement)

```bash
cd arkalia_cia/android
./gradlew signingReport
```

Chercher la section **"Variant: debug"** et copier le **SHA-1**.

### SHA-1 Production (pour Play Store)

```bash
cd arkalia_cia/android
./gradlew signingReport
```

Chercher la section **"Variant: release"** et copier le **SHA-1**.

---

## 🌐 ÉTAPE 2 : Vérifier dans Google Cloud Console

### Lien direct vers les Credentials

https://console.cloud.google.com/apis/credentials?project=arkalia-cia

### Checklist Client Android

1. **Aller dans** : APIs & Services > Credentials
2. **Cliquer sur** : "Client Android 1" (ou le nom de ton client)
3. **Vérifier** :

#### ✅ Package Name
- Doit être exactement : `com.arkalia.cia`
- Pas d'espaces, pas de majuscules
- Vérifier caractère par caractère

#### ✅ SHA-1 Certificate Fingerprints
- **SHA-1 Debug** : Doit correspondre EXACTEMENT au SHA-1 debug de ton app
- **SHA-1 Production** : Doit correspondre EXACTEMENT au SHA-1 release de ton app
- Format : `XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX`
- **IMPORTANT** : Les deux points (:) sont obligatoires
- **IMPORTANT** : Pas d'espaces avant/après

#### ✅ Client ID
- Format : `1062485264410-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.apps.googleusercontent.com`
- Note le Client ID pour référence (mais pas besoin de le mettre dans le code)

---

## 🍎 ÉTAPE 3 : Vérifier Client iOS (si nécessaire)

1. **Aller dans** : APIs & Services > Credentials
2. **Cliquer sur** : "Client iOS 1" (ou le nom de ton client iOS)
3. **Vérifier** :

#### ✅ Bundle ID
- Doit être exactement : `com.arkalia.cia`
- Pas d'espaces, pas de majuscules

---

## ⚠️ ERREURS COURANTES

### Erreur "DEVELOPER_ERROR" (Code 10)

**Causes possibles** :
1. ❌ SHA-1 ne correspond pas exactement
2. ❌ Package name incorrect
3. ❌ SHA-1 avec espaces ou format incorrect
4. ❌ Client ID non configuré

**Solutions** :
1. Vérifier le SHA-1 caractère par caractère
2. Vérifier le package name : `com.arkalia.cia` (exactement)
3. Supprimer les espaces dans le SHA-1
4. Vérifier que le Client ID Android existe

### Erreur "Sign in failed"

**Causes possibles** :
1. ❌ API Google Sign-In non activée
2. ❌ Écran OAuth non publié
3. ❌ Projet Google Cloud non configuré

**Solutions** :
1. Activer l'API Google Sign-In dans Google Cloud Console
2. Publier l'écran OAuth (si en mode test)
3. Vérifier que le projet `arkalia-cia` existe

---

## 📋 CHECKLIST COMPLÈTE

### Google Cloud Console

- [ ] Projet `arkalia-cia` existe
- [ ] API Google Sign-In activée
- [ ] Écran OAuth publié en production

### Client Android

- [ ] Client Android créé
- [ ] Package name : `com.arkalia.cia` (exactement)
- [ ] SHA-1 Debug ajouté et correspond
- [ ] SHA-1 Production ajouté et correspond
- [ ] Format SHA-1 correct (avec `:`)

### Client iOS (si nécessaire)

- [ ] Client iOS créé
- [ ] Bundle ID : `com.arkalia.cia` (exactement)

### Code

- [ ] Package `google_sign_in` installé
- [ ] Service `GoogleAuthService` créé
- [ ] AndroidManifest.xml configuré
- [ ] Info.plist configuré (iOS)

---

## 🔧 COMMANDES DE VÉRIFICATION

### Récupérer SHA-1 actuel

```bash
cd arkalia_cia/android
./gradlew signingReport
```

### Vérifier package name

```bash
grep "applicationId" arkalia_cia/android/app/build.gradle.kts
```

Doit afficher : `applicationId = "com.arkalia.cia"`

### Vérifier Bundle ID (iOS)

```bash
grep "PRODUCT_BUNDLE_IDENTIFIER" arkalia_cia/ios/Runner.xcodeproj/project.pbxproj
```

Doit contenir : `com.arkalia.cia`

---

## ✅ VÉRIFICATION RAPIDE

### Ce qui DOIT correspondre EXACTEMENT

1. **Package Name** :
   - Code : `com.arkalia.cia`
   - Google Cloud : `com.arkalia.cia`
   - ✅ Doit être identique

2. **SHA-1 Debug** :
   - Code : (récupéré via `./gradlew signingReport`)
   - Google Cloud : (dans Client Android)
   - ✅ Doit être identique caractère par caractère

3. **SHA-1 Production** :
   - Code : (récupéré via `./gradlew signingReport`)
   - Google Cloud : (dans Client Android)
   - ✅ Doit être identique caractère par caractère

---

## 🆘 SI ÇA NE FONCTIONNE TOUJOURS PAS

1. **Vérifier les logs** :
   ```bash
   adb logcat | grep -i "google\|signin\|auth"
   ```

2. **Vérifier l'erreur exacte** :
   - Regarder le message d'erreur dans l'app
   - Noter le code d'erreur (10, 7, 12501, etc.)

3. **Attendre la propagation** :
   - Les changements peuvent prendre 5-10 minutes
   - Redémarrer l'app après modification

4. **Vérifier les services Google Play** :
   - Sur le téléphone : Paramètres > Applications > Google Play Services
   - Vérifier que les services sont à jour

---

**Lien direct Google Cloud Console** : https://console.cloud.google.com/apis/credentials?project=arkalia-cia

