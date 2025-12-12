# 🚀 Guide Publication Google Play Store - Google Sign-In

**Date** : 12 décembre 2025  
**Version** : 1.3.1

---

## 📋 CHECKLIST AVANT PUBLICATION

### 1. Configuration Google Cloud Console

- [ ] **Client Android 2** créé avec SHA-1 Production
  - Name : `Client Android 2` (ou `Client Android Production`)
  - Package name : `com.arkalia.cia`
  - SHA-1 : `AC:9E:D1:E9:29:66:5E:95:DD:0E:0B:7F:9F:F9:88:D1:5D:69:71:19`

**OU**

- [ ] **Client Android 1** modifié avec SHA-1 Production
  - Remplacer le SHA-1 Debug par le SHA-1 Production
  - ⚠️ Les tests en debug ne fonctionneront plus après ce changement

### 2. Build de production

- [ ] Keystore de production créé et configuré
- [ ] `key.properties` configuré avec les bonnes informations
- [ ] Build App Bundle généré : `flutter build appbundle --release`

### 3. Vérification

- [ ] SHA-1 Production correspond au keystore utilisé pour signer l'App Bundle
- [ ] Package name : `com.arkalia.cia`
- [ ] Google Sign-In API activée dans Google Cloud Console

---

## 🔧 CRÉER "CLIENT ANDROID 2" (PRODUCTION)

### Étape 1 : Accéder à Google Cloud Console

URL : https://console.cloud.google.com/apis/credentials?project=arkalia-cia

### Étape 2 : Créer le client

1. Cliquer sur **"+ CREATE CREDENTIALS"**
2. Sélectionner **"OAuth client ID"**
3. Si demandé, configurer l'écran de consentement OAuth (déjà fait normalement)
4. Sélectionner **"Android"** comme type d'application

### Étape 3 : Remplir les informations

- **Name** : `Client Android 2` (ou `Client Android Production`)
- **Package name** : `com.arkalia.cia`
- **SHA-1 certificate fingerprint** : `AC:9E:D1:E9:29:66:5E:95:DD:0E:0B:7F:9F:F9:88:D1:5D:69:71:19`

### Étape 4 : Créer et attendre

1. Cliquer sur **"CREATE"**
2. **Attendre 5-10 minutes** pour la propagation
3. Vérifier que le client apparaît dans la liste

---

## ✅ VÉRIFICATION FINALE

### Vérifier les deux clients

Dans Google Cloud Console, tu devrais voir :

1. **Client Android 1** (Debug) :
   - SHA-1 : `2C:68:D5:C0:92:A8:7F:59:E7:6A:7C:5B:7C:F9:77:54:9E:68:14:6E`
   - Usage : Tests en développement

2. **Client Android 2** (Production) :
   - SHA-1 : `AC:9E:D1:E9:29:66:5E:95:DD:0E:0B:7F:9F:F9:88:D1:5D:69:71:19`
   - Usage : Builds de production pour Google Play Store

### Tester le build de production

1. Générer un App Bundle :
   ```bash
   cd /Volumes/T7/arkalia-cia/arkalia_cia
   flutter build appbundle --release
   ```

2. Installer sur un appareil (si possible) :
   ```bash
   # Extraire l'APK depuis l'App Bundle pour tester
   bundletool build-apks --bundle=build/app/outputs/bundle/release/app-release.aab --output=app.apks
   bundletool install-apks --apks=app.apks
   ```

3. Tester la connexion Google Sign-In :
   - Ouvrir l'app
   - Cliquer sur "Continuer avec Gmail"
   - Vérifier que la connexion fonctionne

---

## 🎯 RÉSUMÉ

**Configuration actuelle** :
- ✅ Client Android 1 : SHA-1 Debug (pour les tests)
- ⚠️ Client Android 2 : À créer avant publication (SHA-1 Production)

**Avant publication** :
1. Créer "Client Android 2" avec le SHA-1 Production
2. Attendre 5-10 minutes pour la propagation
3. Générer l'App Bundle de production
4. Tester la connexion Google Sign-In
5. Publier sur Google Play Store

---

**Dernière mise à jour** : 12 décembre 2025

