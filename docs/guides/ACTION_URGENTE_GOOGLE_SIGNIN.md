# 🚨 ACTION URGENTE - Résolution Erreur Google Sign-In

**Date** : 12 décembre 2025  
**Erreur** : `This android application is not registered to use OAuth2.0`

---

## 🔍 DIAGNOSTIC

### ✅ Configuration Locale (CORRECTE)

- **Package name** : `com.arkalia.cia` ✅
- **SHA-1 Debug** : `2C:68:D5:C0:92:A8:7F:59:E7:6A:7C:5B:7C:F9:77:54:9E:68:14:6E` ✅
- **Code Flutter** : Configuré correctement ✅

### ❌ Problème Identifié

L'erreur dans les logs Android indique que **Google Cloud Console ne reconnaît pas l'application**.

---

## 🎯 ACTIONS À FAIRE MAINTENANT

### 1. Vérifier Google Cloud Console

**URL** : https://console.cloud.google.com/apis/credentials?project=arkalia-cia

#### Étape 1.1 : Vérifier que "Client Android 1" existe

- Si **N'EXISTE PAS** → Créer un nouveau Client Android (voir section 2)
- Si **EXISTE** → Passer à l'étape 1.2

#### Étape 1.2 : Vérifier la configuration de "Client Android 1"

Cliquer sur "Client Android 1" et vérifier :

1. **Package name** :
   - Doit être **EXACTEMENT** : `com.arkalia.cia`
   - ⚠️ **Pas d'espaces avant/après**
   - ⚠️ **Pas de majuscules**

2. **SHA-1 certificate fingerprints** :
   - Doit contenir : `2C:68:D5:C0:92:A8:7F:59:E7:6A:7C:5B:7C:F9:77:54:9E:68:14:6E`
   - ⚠️ **Format exact** : avec les deux-points `:`
   - ⚠️ **Pas d'espaces**

3. **Si le SHA-1 est différent ou manquant** :
   - Cliquer sur "EDIT"
   - Dans "SHA-1 certificate fingerprints", ajouter :
     ```
     2C:68:D5:C0:92:A8:7F:59:E7:6A:7C:5B:7C:F9:77:54:9E:68:14:6E
     ```
   - Cliquer sur "SAVE"
   - **ATTENDRE 5-10 MINUTES** pour la propagation

### 2. Créer "Client Android 1" (si n'existe pas)

1. Aller sur : https://console.cloud.google.com/apis/credentials?project=arkalia-cia
2. Cliquer sur **"+ CREATE CREDENTIALS"** > **"OAuth client ID"**
3. Si demandé, configurer l'écran de consentement OAuth (déjà fait normalement)
4. Sélectionner **"Android"** comme type d'application
5. Remplir :
   - **Name** : `Client Android 1`
   - **Package name** : `com.arkalia.cia`
   - **SHA-1 certificate fingerprint** : `2C:68:D5:C0:92:A8:7F:59:E7:6A:7C:5B:7C:F9:77:54:9E:68:14:6E`
6. Cliquer sur **"CREATE"**
7. **ATTENDRE 5-10 MINUTES** pour la propagation

### 3. Vérifier que l'API Google Sign-In est activée

**URL** : https://console.cloud.google.com/apis/library?project=arkalia-cia

1. Chercher "Google Sign-In API"
2. Si le bouton dit **"ENABLE"** → Cliquer dessus
3. Si le bouton dit **"MANAGE"** → ✅ L'API est déjà activée

---

## ⏱️ APRÈS LES MODIFICATIONS

### 1. Attendre 5-10 minutes

Les modifications dans Google Cloud Console prennent quelques minutes à se propager.

### 2. Redémarrer complètement l'app

```bash
# Arrêter l'app
adb shell am force-stop com.arkalia.cia

# Nettoyer les caches
adb shell pm clear com.arkalia.cia

# Relancer
cd /Volumes/T7/arkalia-cia/arkalia_cia
bash scripts/run-android.sh
```

### 3. Tester la connexion

1. Ouvrir l'app
2. Cliquer sur "Continuer avec Gmail" ou "Continuer avec Google"
3. Vérifier que le sélecteur de compte Google s'ouvre
4. Sélectionner un compte
5. Vérifier que la connexion fonctionne

---

## 🔍 VÉRIFICATION DES LOGS

Si ça ne fonctionne toujours pas, vérifier les logs :

```bash
adb logcat -c  # Nettoyer les logs
# Essayer de se connecter
adb logcat | grep -i "google\|signin\|auth" | tail -20
```

Si l'erreur persiste, vérifier :
- Que le package name est **exactement** `com.arkalia.cia` (copier-coller depuis Google Cloud Console)
- Que le SHA-1 est **exactement** `2C:68:D5:C0:92:A8:7F:59:E7:6A:7C:5B:7C:F9:77:54:9E:68:14:6E` (avec les deux-points)

---

## 📋 CHECKLIST RAPIDE

- [ ] "Client Android 1" existe dans Google Cloud Console
- [ ] Package name = `com.arkalia.cia` (exactement)
- [ ] SHA-1 Debug = `2C:68:D5:C0:92:A8:7F:59:E7:6A:7C:5B:7C:F9:77:54:9E:68:14:6E` (exactement)
- [ ] API Google Sign-In activée
- [ ] Attendu 5-10 minutes après modification
- [ ] App redémarrée complètement
- [ ] Test de connexion effectué

---

## 🆘 SI ÇA NE FONCTIONNE TOUJOURS PAS

1. **Exécuter le script de vérification** :
   ```bash
   bash arkalia_cia/scripts/verifier_google_cloud.sh
   ```

2. **Vérifier les logs détaillés** :
   ```bash
   adb logcat | grep -i "GetTokenResponseHandler\|OAuth2.0\|package name\|SHA-1"
   ```

3. **Vérifier dans Google Cloud Console** :
   - Prendre une capture d'écran de "Client Android 1"
   - Vérifier que tout correspond exactement

---

**Dernière mise à jour** : 12 décembre 2025

