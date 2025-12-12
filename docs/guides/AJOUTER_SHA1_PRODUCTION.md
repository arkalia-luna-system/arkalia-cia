# 🔐 Ajouter SHA-1 de Production - Guide Rapide

**Date** : 12 décembre 2025  
**Version** : 1.3.1

---

## ✅ SHA-1 TROUVÉS

### SHA-1 Debug (déjà configuré)
```
2C:68:D5:C0:92:A8:7F:59:E7:6A:7C:5B:7C:F9:77:54:9E:68:14:6E
```
✅ **Déjà configuré dans Google Cloud Console**

### SHA-1 Production (à ajouter)
```
AC:9E:D1:E9:29:66:5E:95:DD:0E:0B:7F:9F:F9:88:D1:5D:69:71:19
```
⚠️ **À ajouter dans Google Cloud Console**

---

## 📋 ÉTAPES POUR AJOUTER LE SHA-1 DE PRODUCTION

### 1. Aller dans Google Cloud Console

1. Ouvrir : https://console.cloud.google.com/auth/clients/1062485264410-3l6l1kuposfgmn9c609msme3rinlqnap.apps.googleusercontent.com?authuser=1&project=arkalia-cia
2. Ou aller dans : **APIs & Services** > **Credentials** > Cliquer sur **Client Android 1**

### 2. Ajouter le SHA-1 de production

1. Dans la section **SHA-1 certificate fingerprints**, tu verras déjà :
   - `2C:68:D5:C0:92:A8:7F:59:E7:6A:7C:5B:7C:F9:77:54:9E:68:14:6E` (debug)

2. Cliquer sur **+ ADD SHA-1 CERTIFICATE FINGERPRINT**

3. Coller le SHA-1 de production :
   ```
   AC:9E:D1:E9:29:66:5E:95:DD:0E:0B:7F:9F:F9:88:D1:5D:69:71:19
   ```

4. Cliquer sur **SAVE**

---

## ✅ VÉRIFICATION

Après avoir ajouté le SHA-1, tu devrais voir **2 SHA-1** dans la configuration :
- ✅ SHA-1 Debug : `2C:68:D5:C0:92:A8:7F:59:E7:6A:7C:5B:7C:F9:77:54:9E:68:14:6E`
- ✅ SHA-1 Production : `AC:9E:D1:E9:29:66:5E:95:DD:0E:0B:7F:9F:F9:88:D1:5D:69:71:19`

---

## 🎯 POURQUOI C'EST IMPORTANT

- **SHA-1 Debug** : Pour tester l'app en développement
- **SHA-1 Production** : Pour que l'app publiée sur le Play Store puisse utiliser Google Sign-In

**Sans le SHA-1 de production**, les utilisateurs qui téléchargent l'app depuis le Play Store ne pourront pas se connecter avec Google.

---

## 🔄 PROCHAINES ÉTAPES

1. ✅ Ajouter le SHA-1 de production dans Google Cloud Console
2. ✅ Tester la connexion Google sur une build release
3. ✅ Publier l'app sur le Play Store

---

**Note** : Le changement peut prendre quelques minutes à se propager. Si ça ne fonctionne pas immédiatement, attendre 5-10 minutes et réessayer.

