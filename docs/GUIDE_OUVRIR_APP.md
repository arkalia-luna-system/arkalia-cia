# 🌐 Guide : Ouvrir l'Application Arkalia CIA

**Date** : 26 novembre 2025  
**Version** : 1.3.0

Guide consolidé pour ouvrir l'application dans différents environnements.

---

## 🎯 Options disponibles

1. **Web Flutter** (Interface complète) - `http://localhost:8080`
2. **Backend API** (Documentation) - `http://localhost:8000/docs`
3. **Sur iPad via WiFi** - `http://192.168.129.35:8000`

---

## 🌐 Option 1 : Interface Web Flutter (Recommandé)

### Sur Mac

**Méthode automatique** :
```bash
cd /Volumes/T7/arkalia-cia
./scripts/start_flutter_web.sh
```

**Méthode manuelle** :
```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia
flutter pub get
flutter run -d web-server --web-port=8080 --web-hostname=localhost
```

**Ouvrir dans Comet** :
```
http://localhost:8080
```

**Ce que vous verrez** :
- ✅ Interface complète de l'application
- ✅ Tous les modules (Documents, Médecins, Rappels, etc.)
- ✅ Interface identique à celle sur iPad/iPhone

---

## 🔧 Option 2 : Backend API (Documentation)

### Sur Mac

**Démarrer le backend** :
```bash
cd /Volumes/T7/arkalia-cia
./scripts/start_backend.sh
```

**Ouvrir dans Comet** :
```
http://localhost:8000/docs
```

**Ce que vous verrez** :
- ✅ Documentation Swagger interactive
- ✅ Tous les endpoints API
- ✅ Possibilité de tester les API directement

---

## 📱 Option 3 : Sur iPad via WiFi

### Prérequis

1. ✅ Le backend doit être démarré sur le Mac avec `--host 0.0.0.0`
2. ✅ Le Mac et l'iPad doivent être sur le **même réseau WiFi**
3. ✅ IP du Mac : **192.168.129.35** (ou trouver avec `ifconfig`)

### Démarrer le backend

```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia_python_backend
python -m uvicorn api:app --host 0.0.0.0 --port 8000
```

### Ouvrir sur iPad

1. Ouvrez **Comet** sur votre iPad
2. Dans la barre d'adresse, tapez :
   ```
   http://192.168.129.35:8000
   ```
3. Appuyez sur "Aller"

**Ce que vous verrez** :
- ✅ Page d'accueil de l'API
- ✅ Documentation Swagger à `/docs`
- ✅ Health check à `/health`

---

## ⚠️ Important

### Deux serveurs différents

1. **Backend API** : `http://localhost:8000` (Python/FastAPI)
   - Documentation API
   - Endpoints REST
   - Health checks

2. **App Flutter Web** : `http://localhost:8080` (Flutter/Dart)
   - Interface complète de l'application
   - Tous les modules fonctionnels
   - Identique à l'app mobile

### Le backend doit être démarré

Pour que l'app Flutter fonctionne complètement, le backend doit être démarré :
```bash
./scripts/start_backend.sh
```

---

## 🔍 Dépannage

### Port 8080 occupé

Si le port 8080 est occupé, Flutter utilisera automatiquement 8081, 8082, etc.

Vérifiez dans le terminal quel port est utilisé.

### "Impossible de se connecter" sur iPad

**Vérifications** :
1. ✅ Le backend est démarré avec `--host 0.0.0.0`
2. ✅ Le Mac et l'iPad sont sur le **même réseau WiFi**
3. ✅ L'IP est correcte (192.168.129.35 ou votre IP)
4. ✅ Le pare-feu Mac n'est pas activé

### Désactiver le pare-feu Mac (si nécessaire)

1. **Préférences Système** > **Sécurité et confidentialité** > **Pare-feu**
2. Cliquez sur le cadenas 🔒 pour déverrouiller
3. Cliquez sur **"Options"**
4. Vérifiez que **"Bloquer toutes les connexions entrantes"** n'est **PAS** coché

---

## 🎉 Résumé rapide

**Pour voir l'interface complète sur Mac** :
1. `./scripts/start_backend.sh` (terminal 1)
2. `./scripts/start_flutter_web.sh` (terminal 2)
3. Ouvrir Comet : `http://localhost:8080`

**Pour voir l'API sur iPad** :
1. `python -m uvicorn api:app --host 0.0.0.0 --port 8000` (sur Mac)
2. Ouvrir Comet sur iPad : `http://192.168.129.35:8000/docs`

---

*Dernière mise à jour : 26 novembre 2025*

