# 🔐 Configuration SHA-1 Debug ET Production

**Date** : 12 décembre 2025  
**Version** : 1.3.1

---

## 🎯 POURQUOI LES DEUX SHA-1 ?

### SHA-1 Debug
- Utilisé quand tu testes avec `flutter run` ou `flutter build apk --debug`
- Keystore : `~/.android/debug.keystore`
- SHA-1 : `2C:68:D5:C0:92:A8:7F:59:E7:6A:7C:5B:7C:F9:77:54:9E:68:14:6E`

### SHA-1 Production
- Utilisé pour les builds de production (Google Play Store)
- Keystore : Ton keystore de production (à créer)
- SHA-1 : `AC:9E:D1:E9:29:66:5E:95:DD:0E:0B:7F:9F:F9:88:D1:5D:69:71:19`

**⚠️ IMPORTANT** : Google Cloud Console permet d'ajouter **PLUSIEURS SHA-1** dans le même client Android. C'est la meilleure solution !

---

## ⚠️ LIMITATION IMPORTANTE

**Découverte** : La nouvelle interface Google Cloud Console OAuth **NE PERMET PAS** d'ajouter plusieurs SHA-1 dans un seul client Android (contrairement à l'ancienne interface Firebase/API Console).

**Conséquence** : Il faut choisir entre :
- Un seul SHA-1 par client Android
- Créer plusieurs clients Android (un pour debug, un pour production)

---

## ✅ CONFIGURATION RECOMMANDÉE

### Option 1 : Deux clients Android séparés (RECOMMANDÉ)

1. **Client Android 1** (Debug) - ✅ **DÉJÀ CONFIGURÉ** :
   - Name : `Client Android 1` (ou `Client Android Debug`)
   - Package name : `com.arkalia.cia`
   - SHA-1 : `2C:68:D5:C0:92:A8:7F:59:E7:6A:7C:5B:7C:F9:77:54:9E:68:14:6E`
   - Usage : Tests en développement avec `flutter run`

2. **Client Android 2** (Production) - ⚠️ **À CRÉER AVANT PUBLICATION** :
   - Name : `Client Android 2` (ou `Client Android Production`)
   - Package name : `com.arkalia.cia`
   - SHA-1 : `AC:9E:D1:E9:29:66:5E:95:DD:0E:0B:7F:9F:F9:88:D1:5D:69:71:19`
   - Usage : Builds de production pour Google Play Store

**Avantages** :
- ✅ Séparation claire debug/production
- ✅ Pas besoin de changer le SHA-1 selon le contexte
- ✅ Les deux fonctionnent simultanément
- ⚠️ Deux clients à gérer (mais c'est la seule option avec la nouvelle interface)

**Comment créer "Client Android 2"** :
1. Aller sur : https://console.cloud.google.com/apis/credentials?project=arkalia-cia
2. Cliquer sur **"+ CREATE CREDENTIALS"** > **"OAuth client ID"**
3. Sélectionner **"Android"**
4. Remplir :
   - **Name** : `Client Android 2` (ou `Client Android Production`)
   - **Package name** : `com.arkalia.cia`
   - **SHA-1 certificate fingerprint** : `AC:9E:D1:E9:29:66:5E:95:DD:0E:0B:7F:9F:F9:88:D1:5D:69:71:19`
5. Cliquer sur **"CREATE"**

### Option 2 : Changer le SHA-1 selon besoin (Alternative simple)

**Pour les tests en debug** (actuel) :
- ✅ SHA-1 Debug configuré dans "Client Android 1"
- ✅ Fonctionne avec `flutter run`

**Avant publication sur Google Play Store** :
1. Ouvrir "Client Android 1" dans Google Cloud Console
2. Cliquer sur "EDIT"
3. Remplacer le SHA-1 Debug par le SHA-1 Production
4. Sauvegarder
5. Attendre 5-10 minutes pour la propagation

**Avantages** :
- ✅ Un seul client à gérer
- ⚠️ Nécessite de changer le SHA-1 avant chaque publication
- ⚠️ Les tests en debug ne fonctionneront plus après le changement

---

## 📋 ÉTAT ACTUEL

**Actuellement configuré** :
- ✅ **Client Android 1** : SHA-1 Debug configuré (`2C:68:D5:...`)
- ✅ Google Sign-In fonctionne pour les tests en debug
- ⚠️ **Client Android 2** : À créer avant la publication sur Google Play Store (SHA-1 Production)

---

## 🚀 QUAND AJOUTER LE SHA-1 PRODUCTION ?

### Scénario 1 : Test en debug uniquement (MAINTENANT)
- ✅ SHA-1 Debug suffit
- ✅ Tu peux tester la connexion Google Sign-In

### Scénario 2 : Publication sur Google Play Store (PLUS TARD)
- ⚠️ **OBLIGATOIRE** : Ajouter le SHA-1 Production
- Sinon, la connexion Google Sign-In ne fonctionnera pas pour les utilisateurs

---

## 🔧 COMMENT PRÉPARER LA PRODUCTION

### Option recommandée : Créer "Client Android 2" (Production)

**Étape 1** : Vérifier le SHA-1 Production

Le SHA-1 Production est déjà connu :
```
AC:9E:D1:E9:29:66:5E:95:DD:0E:0B:7F:9F:F9:88:D1:5D:69:71:19
```

Si tu veux le vérifier depuis ton keystore de production :
```bash
keytool -list -v -keystore /path/to/your/keystore.jks -alias your-key-alias | grep SHA1
```

**Étape 2** : Créer "Client Android 2" dans Google Cloud Console

1. Aller sur : https://console.cloud.google.com/apis/credentials?project=arkalia-cia
2. Cliquer sur **"+ CREATE CREDENTIALS"** > **"OAuth client ID"**
3. Sélectionner **"Android"**
4. Remplir :
   - **Name** : `Client Android 2` (ou `Client Android Production`)
   - **Package name** : `com.arkalia.cia`
   - **SHA-1 certificate fingerprint** : `AC:9E:D1:E9:29:66:5E:95:DD:0E:0B:7F:9F:F9:88:D1:5D:69:71:19`
5. Cliquer sur **"CREATE"**
6. Attendre 5-10 minutes pour la propagation

**Résultat** : Tu auras deux clients Android :
- **Client Android 1** : SHA-1 Debug (pour les tests)
- **Client Android 2** : SHA-1 Production (pour Google Play Store)

### Option alternative : Remplacer le SHA-1 dans "Client Android 1"

Si tu préfères un seul client, tu peux remplacer le SHA-1 Debug par le SHA-1 Production avant de publier :

1. Aller sur : https://console.cloud.google.com/apis/credentials?project=arkalia-cia
2. Ouvrir "Client Android 1"
3. Cliquer sur "EDIT"
4. Remplacer le SHA-1 Debug par :
   ```
   AC:9E:D1:E9:29:66:5E:95:DD:0E:0B:7F:9F:F9:88:D1:5D:69:71:19
   ```
5. Cliquer sur "SAVE"
6. Attendre 5-10 minutes pour la propagation

**⚠️ Attention** : Après ce changement, les tests en debug ne fonctionneront plus jusqu'à ce que tu remettes le SHA-1 Debug.

---

## 🎯 RÉSUMÉ

**Pour l'instant (test en debug)** :
- ✅ SHA-1 Debug configuré dans "Client Android 1"
- ✅ Google Sign-In fonctionne pour les tests

**Avant publication sur Google Play Store** :
- ⚠️ **Recommandé** : Créer "Client Android 2" avec le SHA-1 Production
- ⚠️ **Alternative** : Remplacer le SHA-1 Debug par le SHA-1 Production dans "Client Android 1"

**Limitation Google Cloud Console** :
- ❌ Impossible d'ajouter plusieurs SHA-1 dans un seul client Android (nouvelle interface)
- ✅ Solution : Créer deux clients Android séparés (recommandé)

---

**Dernière mise à jour** : 12 décembre 2025

