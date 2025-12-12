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

## ✅ CONFIGURATION RECOMMANDÉE

### Option 1 : Un seul client Android avec les DEUX SHA-1 (RECOMMANDÉ)

1. Aller sur : https://console.cloud.google.com/apis/credentials?project=arkalia-cia
2. Ouvrir "Client Android 1"
3. Cliquer sur "EDIT"
4. Dans "SHA-1 certificate fingerprints", ajouter **LES DEUX** :
   ```
   2C:68:D5:C0:92:A8:7F:59:E7:6A:7C:5B:7C:F9:77:54:9E:68:14:6E
   AC:9E:D1:E9:29:66:5E:95:DD:0E:0B:7F:9F:F9:88:D1:5D:69:71:19
   ```
5. Cliquer sur "SAVE"

**Avantages** :
- ✅ Fonctionne en debug ET en production
- ✅ Un seul client à gérer
- ✅ Plus simple

### Option 2 : Deux clients Android séparés

1. **Client Android 1** (Debug) :
   - Package name : `com.arkalia.cia`
   - SHA-1 : `2C:68:D5:C0:92:A8:7F:59:E7:6A:7C:5B:7C:F9:77:54:9E:68:14:6E`

2. **Client Android 2** (Production) :
   - Package name : `com.arkalia.cia`
   - SHA-1 : `AC:9E:D1:E9:29:66:5E:95:DD:0E:0B:7F:9F:F9:88:D1:5D:69:71:19`

**Avantages** :
- ✅ Séparation claire debug/production
- ⚠️ Plus de gestion (deux clients)

---

## 📋 ÉTAT ACTUEL

**Actuellement configuré** :
- ✅ SHA-1 Debug : `2C:68:D5:C0:92:A8:7F:59:E7:6A:7C:5B:7C:F9:77:54:9E:68:14:6E`
- ⚠️ SHA-1 Production : À ajouter avant la publication sur Google Play Store

---

## 🚀 QUAND AJOUTER LE SHA-1 PRODUCTION ?

### Scénario 1 : Test en debug uniquement (MAINTENANT)
- ✅ SHA-1 Debug suffit
- ✅ Tu peux tester la connexion Google Sign-In

### Scénario 2 : Publication sur Google Play Store (PLUS TARD)
- ⚠️ **OBLIGATOIRE** : Ajouter le SHA-1 Production
- Sinon, la connexion Google Sign-In ne fonctionnera pas pour les utilisateurs

---

## 🔧 COMMENT AJOUTER LE SHA-1 PRODUCTION

### Étape 1 : Vérifier le SHA-1 Production

Le SHA-1 Production est déjà connu :
```
AC:9E:D1:E9:29:66:5E:95:DD:0E:0B:7F:9F:F9:88:D1:5D:69:71:19
```

Si tu veux le vérifier depuis ton keystore de production :
```bash
keytool -list -v -keystore /path/to/your/keystore.jks -alias your-key-alias
```

### Étape 2 : Ajouter dans Google Cloud Console

1. Aller sur : https://console.cloud.google.com/apis/credentials?project=arkalia-cia
2. Ouvrir "Client Android 1"
3. Cliquer sur "EDIT"
4. Dans "SHA-1 certificate fingerprints", tu devrais voir :
   ```
   2C:68:D5:C0:92:A8:7F:59:E7:6A:7C:5B:7C:F9:77:54:9E:68:14:6E
   ```
5. Ajouter une nouvelle ligne avec :
   ```
   AC:9E:D1:E9:29:66:5E:95:DD:0E:0B:7F:9F:F9:88:D1:5D:69:71:19
   ```
6. Cliquer sur "SAVE"
7. Attendre 5-10 minutes pour la propagation

---

## ✅ VÉRIFICATION

Après avoir ajouté les deux SHA-1, tu devrais voir dans "Client Android 1" :

**SHA-1 certificate fingerprints** :
```
2C:68:D5:C0:92:A8:7F:59:E7:6A:7C:5B:7C:F9:77:54:9E:68:14:6E
AC:9E:D1:E9:29:66:5E:95:DD:0E:0B:7F:9F:F9:88:D1:5D:69:71:19
```

---

## 🎯 RÉSUMÉ

**Pour l'instant (test en debug)** :
- ✅ SHA-1 Debug configuré
- ✅ Google Sign-In devrait fonctionner

**Avant publication sur Google Play Store** :
- ⚠️ Ajouter le SHA-1 Production dans le même client Android
- ✅ Les deux SHA-1 permettront de fonctionner en debug ET en production

---

**Dernière mise à jour** : 12 décembre 2025

