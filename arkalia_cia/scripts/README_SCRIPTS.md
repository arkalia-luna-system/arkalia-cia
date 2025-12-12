# 📱 Scripts de Lancement - Arkalia CIA

**Date** : 12 décembre 2025

---

## 🚀 Scripts Disponibles

### 1. `run-web.sh` - Lancer sur Web
Lance l'app sur le navigateur web (Chrome ou web-server).

```bash
cd arkalia_cia
bash scripts/run-web.sh
```

**Fonctionnalités** :
- ✅ Met à jour la branche Git automatiquement
- ✅ Nettoie et installe les dépendances
- ✅ Lance sur http://localhost:8080

---

### 2. `run-android.sh` - Lancer sur Android
Lance l'app sur votre appareil Android connecté.

```bash
cd arkalia_cia
bash scripts/run-android.sh
```

**Fonctionnalités** :
- ✅ Détecte automatiquement l'appareil Android
- ✅ Nettoie les fichiers macOS cachés
- ✅ Gère les erreurs de build

---

### 3. `run-macos.sh` - Lancer sur macOS
Lance l'app sur macOS (pour votre Mac mini).

```bash
cd arkalia_cia
bash scripts/run-macos.sh
```

**Fonctionnalités** :
- ✅ Met à jour la branche Git automatiquement
- ✅ Nettoie et installe les dépendances
- ✅ Lance l'app native macOS

---

### 4. `run-all-platforms.sh` - Lancer TOUTES les plateformes
Lance l'app sur **Web, Android ET macOS** en même temps en parallèle.

```bash
cd arkalia_cia
bash scripts/run-all-platforms.sh
```

**Fonctionnalités** :
- ✅ Met à jour la branche Git automatiquement
- ✅ Lance Web, Android et macOS en parallèle
- ✅ Logs séparés pour chaque plateforme
- ✅ Arrêt propre avec Ctrl+C

**Logs** :
- Web : `/tmp/arkalia_web.log`
- Android : `/tmp/arkalia_android.log`
- macOS : `/tmp/arkalia_macos.log`

---

## 📋 Utilisation Recommandée

### Pour tester une seule plateforme :
```bash
# Web uniquement
bash scripts/run-web.sh

# Android uniquement
bash scripts/run-android.sh

# macOS uniquement
bash scripts/run-macos.sh
```

### Pour tester toutes les plateformes en même temps :
```bash
bash scripts/run-all-platforms.sh
```

---

## ⚠️ Notes Importantes

1. **Mise à jour automatique** : Tous les scripts mettent à jour la branche Git avant de lancer
2. **Nettoyage automatique** : Tous les scripts nettoient et installent les dépendances
3. **Arrêt propre** : Utilisez Ctrl+C pour arrêter proprement tous les processus

---

## 🔧 Dépannage

### Web ne fonctionne pas
- Vérifier que Chrome est installé ou utiliser `web-server`
- Vérifier que le port 8080 est libre

### Android ne fonctionne pas
- Vérifier que l'appareil est connecté : `adb devices`
- Vérifier que USB Debugging est activé

### macOS ne fonctionne pas
- Vérifier que vous êtes sur macOS
- Vérifier que Flutter est configuré : `flutter doctor`

---

**Dernière mise à jour** : 12 décembre 2025

