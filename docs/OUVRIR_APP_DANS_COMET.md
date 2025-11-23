# 🌐 Ouvrir l'App dans Comet (Navigateur)

**Date** : 23 novembre 2025  
**Version** : 1.3.0

---

## 🎯 Objectif

Ouvrir l'interface web de l'application Arkalia CIA dans le navigateur Comet sur votre iPad.

---

## 📋 Prérequis

1. ✅ Le backend Python doit être démarré sur votre Mac
2. ✅ Le Mac et l'iPad doivent être sur le **même réseau WiFi**
3. ✅ Comet installé sur votre iPad

---

## 🚀 Étapes

### **ÉTAPE 1 : Démarrer le Backend sur le Mac**

Ouvrez Terminal sur votre Mac et exécutez :

```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia_python_backend
python -m uvicorn api:app --host 0.0.0.0 --port 8000
```

**Important** : Utiliser `--host 0.0.0.0` pour accepter les connexions depuis le réseau local.

Vous devriez voir :
```
INFO:     Uvicorn running on http://0.0.0.0:8000 (Press CTRL+C to quit)
```

---

### **ÉTAPE 2 : Trouver l'IP de votre Mac**

L'IP de votre Mac est : **192.168.129.35**

*(Si cette IP change, vous pouvez la retrouver avec : `ifconfig | grep "inet " | grep -v 127.0.0.1`)*

---

### **ÉTAPE 3 : Ouvrir dans Comet sur iPad**

1. **Ouvrez Comet** sur votre iPad
2. **Dans la barre d'adresse**, tapez :
   ```
   http://192.168.129.35:8000
   ```
3. **Appuyez sur "Aller"** ou "Entrée"

---

## ✅ Vérification

### **Page d'accueil de l'API**

Vous devriez voir :
```json
{
  "message": "Arkalia CIA API",
  "version": "1.0.0",
  "status": "running"
}
```

### **Test de santé**

Allez à :
```
http://192.168.129.35:8000/health
```

Vous devriez voir :
```json
{
  "status": "ok"
}
```

---

## 📚 Endpoints disponibles

### **Documentation API interactive**

```
http://192.168.129.35:8000/docs
```

Interface Swagger pour tester toutes les API.

### **Documentation alternative**

```
http://192.168.129.35:8000/redoc
```

---

## 🔧 Dépannage

### **❌ "Impossible de se connecter"**

**Vérifications :**
1. ✅ Le backend est démarré sur le Mac avec `--host 0.0.0.0`
2. ✅ Le Mac et l'iPad sont sur le **même réseau WiFi**
3. ✅ L'IP est correcte (192.168.129.35)
4. ✅ Le port 8000 n'est pas bloqué par le pare-feu Mac

### **Désactiver le pare-feu Mac (si nécessaire)**

1. **Préférences Système** > **Sécurité et confidentialité** > **Pare-feu**
2. Cliquez sur le cadenas 🔒 pour déverrouiller
3. Cliquez sur **"Options"**
4. Vérifiez que **"Bloquer toutes les connexions entrantes"** n'est **PAS** coché

---

## 🎉 C'est tout !

Une fois ouvert dans Comet, vous pouvez :
- ✅ Consulter la documentation API
- ✅ Tester les endpoints
- ✅ Vérifier que le backend fonctionne

---

**Note** : L'interface web complète de l'application sera disponible dans une future version. Pour l'instant, vous pouvez utiliser l'API et la documentation Swagger.

