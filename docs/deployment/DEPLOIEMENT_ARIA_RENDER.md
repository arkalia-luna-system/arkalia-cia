# 🚀 Déploiement ARIA sur Render.com

**Date** : 12 décembre 2025  
**Version** : 1.0  
**Statut** : ✅ Guide complet

---

## 📋 PRÉREQUIS

- Compte Render.com (gratuit)
- Accès au repository GitHub
- Backend ARIA fonctionnel localement

---

## 🎯 OBJECTIF

Héberger le serveur ARIA sur Render.com pour qu'il soit accessible 24/7, sans nécessiter que le Mac soit allumé.

---

## 📝 ÉTAPES DE DÉPLOIEMENT

### 1. Préparer le backend ARIA

Le backend ARIA est dans `arkalia_cia_python_backend/aria_integration/api.py`.

**Fichier à vérifier** : `arkalia_cia_python_backend/aria_integration/api.py`

```python
# Ligne 18 - Actuellement en dur
ARIA_BASE_URL = "http://127.0.0.1:8001"  # Port différent de CIA
```

**⚠️ IMPORTANT** : Cette URL sera remplacée par l'URL Render.com après déploiement.

---

### 2. Créer un compte Render.com

1. Aller sur [render.com](https://render.com)
2. Créer un compte (gratuit)
3. Connecter votre compte GitHub

---

### 3. Créer un nouveau Web Service

1. Dans le dashboard Render.com, cliquer sur **"New +"** → **"Web Service"**
2. Connecter le repository GitHub `arkalia-cia`
3. Configurer le service :

**Configuration de base** :
- **Name** : `arkalia-aria` (ou autre nom)
- **Region** : `Frankfurt` (ou plus proche de vous)
- **Branch** : `develop` (ou `main`)
- **Root Directory** : `arkalia_cia_python_backend`
- **Runtime** : `Python 3`
- **Build Command** : `pip install -r ../requirements.txt`
- **Start Command** : `uvicorn aria_integration.api:router --host 0.0.0.0 --port $PORT`

**⚠️ NOTE** : Render.com fournit automatiquement le port via la variable d'environnement `$PORT`.

---

### 4. Configurer les variables d'environnement

Dans Render.com, aller dans **"Environment"** et ajouter :

```
PYTHON_VERSION=3.11
PORT=10000
```

**⚠️ NOTE** : Render.com utilise le port fourni via `$PORT`, mais on peut aussi utiliser un port fixe.

---

### 5. Modifier le code pour Render.com

**Option A (Recommandée)** : Utiliser une variable d'environnement

Modifier `arkalia_cia_python_backend/aria_integration/api.py` :

```python
import os

# Configuration ARIA - Support local et hébergé
ARIA_BASE_URL = os.getenv("ARIA_BASE_URL", "http://127.0.0.1:8001")
ARIA_TIMEOUT = int(os.getenv("ARIA_TIMEOUT", "10"))
```

Dans Render.com, ajouter la variable d'environnement :
- **Key** : `ARIA_BASE_URL`
- **Value** : `https://arkalia-aria.onrender.com` (remplacer par votre URL Render)

**Option B** : Créer un fichier `render.yaml` dans le root du projet

```yaml
services:
  - type: web
    name: arkalia-aria
    env: python
    buildCommand: pip install -r requirements.txt
    startCommand: uvicorn arkalia_cia_python_backend.aria_integration.api:router --host 0.0.0.0 --port $PORT
    envVars:
      - key: ARIA_BASE_URL
        value: https://arkalia-aria.onrender.com
      - key: PORT
        value: 10000
```

---

### 6. Créer un fichier `Procfile` (optionnel)

Créer `arkalia_cia_python_backend/Procfile` :

```
web: uvicorn aria_integration.api:router --host 0.0.0.0 --port $PORT
```

---

### 7. Déployer

1. Cliquer sur **"Create Web Service"** dans Render.com
2. Attendre le déploiement (5-10 minutes)
3. Noter l'URL fournie : `https://arkalia-aria-xxxx.onrender.com`

---

### 8. Tester le déploiement

1. Ouvrir l'URL dans le navigateur : `https://arkalia-aria-xxxx.onrender.com/status`
2. Vérifier que la réponse est `200 OK`
3. Tester depuis l'app Flutter :

```dart
// Dans ARIAService
await ARIAService.setARIAIP('arkalia-aria-xxxx.onrender.com');
await ARIAService.setARIAPort('443'); // HTTPS
// Ou utiliser directement l'URL complète
```

---

### 9. Mettre à jour l'app Flutter

**Modifier `arkalia_cia/lib/services/aria_service.dart`** :

```dart
/// Construit l'URL de base ARIA
static Future<String?> getBaseURL() async {
  final ip = await getARIAIP();
  if (ip == null || ip.isEmpty) return null;
  final port = await getARIAPort();
  
  // Détecter si c'est une URL complète (https://) ou IP
  if (ip.startsWith('http://') || ip.startsWith('https://')) {
    return ip; // URL complète
  }
  
  // Détecter si c'est HTTPS (port 443) ou HTTP
  if (port == '443' || port == '80') {
    final protocol = port == '443' ? 'https' : 'http';
    return '$protocol://$ip';
  }
  
  return 'http://$ip:$port';
}
```

---

## 🔧 CONFIGURATION ALTERNATIVE : Railway.app

Si Render.com ne fonctionne pas, utiliser Railway.app :

1. Aller sur [railway.app](https://railway.app)
2. Créer un compte
3. Créer un nouveau projet
4. Connecter le repository GitHub
5. Configurer :
   - **Start Command** : `uvicorn arkalia_cia_python_backend.aria_integration.api:router --host 0.0.0.0 --port $PORT`
   - **Root Directory** : `arkalia_cia_python_backend`

---

## ⚠️ LIMITATIONS FREE TIER

### Render.com
- **Sleep après 15 min d'inactivité** : Le service se met en veille
- **Premier démarrage lent** : 30-60 secondes après veille
- **Solution** : Utiliser un service de "ping" pour garder actif (UptimeRobot, etc.)

### Railway.app
- **Limite de crédits** : 500 heures/mois gratuits
- **Pas de sleep** : Service toujours actif

---

## 🎯 PROCHAINES ÉTAPES

1. ✅ Déployer sur Render.com
2. ✅ Tester depuis l'app Flutter
3. ✅ Mettre à jour `ARIAService` pour supporter URLs hébergées
4. ✅ Documenter l'URL dans les paramètres de l'app

---

## 📚 RESSOURCES

- [Documentation Render.com](https://render.com/docs)
- [Documentation Railway.app](https://docs.railway.app)
- [FastAPI Deployment](https://fastapi.tiangolo.com/deployment/)

---

**✅ Une fois déployé, ARIA sera accessible 24/7 sans nécessiter que le Mac soit allumé !**

