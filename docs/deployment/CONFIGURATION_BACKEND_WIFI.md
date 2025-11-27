# 📡 Configuration Backend WiFi - Arkalia CIA

**Date** : 27 novembre 2025  
**Version** : 1.3.1+1  
**Plateformes** : iPad, Android (S25)

---

## ⚠️ **IMPORTANT : localhost ne fonctionne PAS sur mobile !**

Sur un appareil mobile (iPad ou Android), `localhost` fait référence à l'appareil lui-même, **pas au Mac** qui héberge le backend.

**Solution** : Utiliser l'**IP locale du Mac** sur le réseau WiFi.

---

## 🔧 **ÉTAPE 1 : Trouver l'IP locale du Mac**

### **Méthode 1 : Via les Préférences Système**

1. Sur votre Mac, ouvrez **Préférences Système** (⚙️)
2. Cliquez sur **Réseau**
3. Sélectionnez votre connexion WiFi active
4. L'IP s'affiche à droite, par exemple : **192.168.1.100**

### **Méthode 2 : Via Terminal**

```bash
# Sur le Mac, ouvrez Terminal et tapez :
ifconfig | grep "inet " | grep -v 127.0.0.1

# Vous verrez quelque chose comme :
# inet 192.168.1.100 netmask 0xffffff00 broadcast 192.168.1.255
```

**L'IP est** : `192.168.1.100` (exemple)

---

## 🚀 **ÉTAPE 2 : Démarrer le Backend sur le Mac**

```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia_python_backend
python -m uvicorn api:app --host 0.0.0.0 --port 8000
```

**Important** : Utiliser `--host 0.0.0.0` pour accepter les connexions depuis le réseau local.

Le backend sera accessible à : `http://192.168.1.100:8000` (remplacez par votre IP)

---

## 📱 **ÉTAPE 3 : Configurer l'App sur iPad/S25**

### **Sur iPad ou Android :**

1. Ouvrez l'app **Arkalia CIA**
2. Allez dans **Paramètres** (⚙️)
3. Faites défiler jusqu'à **"Backend API"**
4. Cliquez sur **"URL du backend"**
5. Entrez l'URL : `http://192.168.1.100:8000` (remplacez par votre IP)
6. Cliquez sur **"Enregistrer"**
7. Cliquez sur le bouton **✅** pour tester la connexion
8. Activez le switch **"Activer le backend"**

---

## ✅ **Vérification**

### **Test de connexion depuis l'app :**

1. Dans **Paramètres** > **Backend API**
2. Cliquez sur le bouton **✅** à côté de l'URL
3. Vous devriez voir : **"✅ Connexion réussie au backend !"**

### **Test depuis le navigateur (optionnel) :**

Sur votre iPad/S25, ouvrez Safari/Chrome et allez à :
```
http://192.168.1.100:8000/health
```

Vous devriez voir : `{"status":"ok"}`

---

## 🔍 **Dépannage**

### **❌ "Impossible de se connecter au backend"**

**Vérifications :**

1. ✅ Le backend est démarré sur le Mac avec `--host 0.0.0.0`
2. ✅ Le Mac et l'appareil mobile sont sur le **même réseau WiFi**
3. ✅ L'IP du Mac est correcte (vérifiez avec `ifconfig`)
4. ✅ Le port 8000 n'est pas bloqué par le pare-feu Mac
5. ✅ L'URL dans l'app commence par `http://` (pas `https://`)

### **Désactiver le pare-feu Mac (si nécessaire) :**

1. **Préférences Système** > **Sécurité et confidentialité** > **Pare-feu**
2. Cliquez sur le cadenas 🔒 pour déverrouiller
3. Cliquez sur **"Options"**
4. Vérifiez que **"Bloquer toutes les connexions entrantes"** n'est **PAS** coché

### **Vérifier que le backend écoute sur toutes les interfaces :**

```bash
# Sur le Mac, vérifiez que le backend écoute bien :
netstat -an | grep 8000

# Vous devriez voir :
# *.8000                 *.*                    LISTEN
```

---

## 📝 **Exemples d'URLs valides**

✅ **Correctes :**
- `http://192.168.1.100:8000`
- `http://192.168.0.50:8000`
- `http://10.0.0.100:8000`

❌ **Incorrectes (ne fonctionnent PAS sur mobile) :**
- `http://localhost:8000` ❌
- `http://127.0.0.1:8000` ❌
- `192.168.1.100:8000` (manque `http://`) ❌

---

## 🎯 **Résumé**

1. **Trouver l'IP du Mac** : `ifconfig` ou Préférences Système > Réseau
2. **Démarrer le backend** : `uvicorn api:app --host 0.0.0.0 --port 8000`
3. **Configurer dans l'app** : Paramètres > Backend API > URL
4. **Tester** : Bouton ✅ dans les paramètres

---

## 🎉 **C'est tout !**

Une fois configuré, l'app fonctionnera en mode **hybride** :
- ✅ **Mode offline** : Fonctionne sans backend (données locales)
- ✅ **Mode online** : Synchronise avec le backend quand disponible

L'app détecte automatiquement si le backend est disponible et utilise le cache offline si nécessaire.

---

---

## Voir aussi

- **[deployment/CONNECTER_S25_ANDROID.md](./CONNECTER_S25_ANDROID.md)** — Connexion Android
- **[deployment/DEPLOIEMENT_WIFI_IOS.md](./DEPLOIEMENT_WIFI_IOS.md)** — Déploiement WiFi iOS
- **[troubleshooting/EXPLICATION_WIFI_ADB.md](../troubleshooting/EXPLICATION_WIFI_ADB.md)** — Explication WiFi ADB
- **[deployment/DEPLOYMENT.md](./DEPLOYMENT.md)** — Guide de déploiement général
- **[INDEX_DOCUMENTATION.md](../INDEX_DOCUMENTATION.md)** — Index complet de la documentation

---

*Dernière mise à jour : Janvier 2025*

