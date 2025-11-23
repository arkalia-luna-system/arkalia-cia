# 🌐 Ouvrir l'App Flutter dans Comet sur Mac

**Date** : 23 novembre 2025  
**Version** : 1.3.0

---

## 🎯 Objectif

Ouvrir l'**interface complète** de l'application Arkalia CIA dans Comet sur votre Mac, pas juste l'API !

---

## ✅ Bonne nouvelle !

L'application Flutter peut fonctionner sur le **web** ! Vous pouvez donc voir l'interface complète dans Comet sur votre Mac.

---

## 🚀 Méthode 1 : Script automatique (Recommandé)

```bash
cd /Volumes/T7/arkalia-cia
./scripts/start_flutter_web.sh
```

Le script va :
1. ✅ Vérifier que Flutter est installé
2. ✅ Installer les dépendances
3. ✅ Générer le build web si nécessaire
4. ✅ Démarrer le serveur web sur `http://localhost:8080`

Puis **ouvrez Comet** et allez à : `http://localhost:8080`

---

## 🚀 Méthode 2 : Commande manuelle

```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia
flutter pub get
flutter run -d web-server --web-port=8080 --web-hostname=localhost
```

Puis **ouvrez Comet** et allez à : `http://localhost:8080` (ou `http://localhost:8081` si le port 8080 est déjà utilisé)

---

## 📱 Ce que vous verrez

Vous verrez l'**interface complète** de l'application :
- ✅ Page d'accueil
- ✅ Documents
- ✅ Rappels
- ✅ Contacts d'urgence
- ✅ Toutes les fonctionnalités de l'app mobile
- ✅ Interface identique à celle sur iPad/iPhone

---

## 🔧 Première fois : Configuration Web

Si c'est la première fois, Flutter doit configurer le support web :

```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia
flutter create . --platforms web
```

Cela crée les fichiers nécessaires pour le web.

---

## 🌐 URLs disponibles

### **App Flutter (Interface complète)**
```
http://localhost:8080
```
ou si le port est occupé :
```
http://localhost:8081
```
**C'est ici que vous verrez l'interface complète !**

### **API Backend (Documentation)**
```
http://localhost:8000/docs
```
Pour tester les API.

---

## ⚠️ Important

1. **Le backend doit être démarré** pour que l'app fonctionne complètement
   ```bash
   ./scripts/start_backend.sh
   ```

2. **Deux serveurs différents** :
   - Backend API : `http://localhost:8000` (Python/FastAPI)
   - App Flutter Web : `http://localhost:8080` (Flutter/Dart)

3. **L'app Flutter se connecte au backend** automatiquement si configuré

---

## 🎉 Résumé

**Pour voir l'interface complète dans Comet sur Mac :**

1. Démarrer le backend : `./scripts/start_backend.sh` (dans un terminal)
2. Démarrer l'app web : `./scripts/start_flutter_web.sh` (dans un autre terminal)
3. Ouvrir Comet : `http://localhost:8080` (ou `http://localhost:8081` si 8080 est occupé)

**C'est tout !** Vous verrez maintenant l'interface complète de l'application dans Comet ! 🎊

