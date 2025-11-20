# 🔧 Mise à jour S25 - Guide Corrigé

**Date** : 19 novembre 2025  
**Problème résolu** : L'app ne se mettait pas à jour sur le S25

---

## ✅ **PROBLÈMES IDENTIFIÉS ET CORRIGÉS**

### 1. **Versions obsolètes dans le code**
- ❌ `check_updates.sh` : Version attendue `1.1.0+1` (ancienne)
- ❌ `settings_screen.dart` : Version affichée `1.1.0+1` (ancienne)
- ❌ `sync_screen.dart` : Version export `1.1.0` (ancienne)
- ✅ **Corrigé** : Toutes mises à jour vers `1.2.0+1`

### 2. **Script de mise à jour amélioré**
- ✅ Script `update_s25.sh` créé (mise à jour simplifiée)
- ✅ Script `update_all_devices.sh` amélioré :
  - Arrêt forcé de l'app avant installation
  - Vérification de l'existence de l'APK
  - Meilleure gestion des erreurs

---

## 🚀 **MÉTHODE 1 : Script Simplifié (Recommandé)**

```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia
./update_s25.sh
```

Ce script :
1. ✅ Vérifie la connexion WiFi
2. ✅ Compile l'APK release
3. ✅ Arrête l'app avant installation
4. ✅ Installe la nouvelle version
5. ✅ Vérifie la version installée

---

## 🚀 **MÉTHODE 2 : Script Complet (Tous les appareils)**

```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia
./update_all_devices.sh
```

Ce script met à jour tous les appareils détectés (S25, iPad, macOS).

---

## 🚀 **MÉTHODE 3 : Manuel (Flutter)**

```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia

# Compiler l'APK
flutter build apk --release

# Installer sur le S25
export PATH="$HOME/Library/Android/sdk/platform-tools:$PATH"
adb -s 192.168.129.46:5555 shell "am force-stop com.example.arkalia_cia"
adb -s 192.168.129.46:5555 install -r build/app/outputs/flutter-apk/app-release.apk
```

---

## 🔍 **VÉRIFICATION**

### Vérifier la version installée :

```bash
export PATH="$HOME/Library/Android/sdk/platform-tools:$PATH"
adb -s 192.168.129.46:5555 shell "dumpsys package com.example.arkalia_cia | grep versionName"
```

**Résultat attendu** : `versionName=1.2.0`

### Vérifier la connexion :

```bash
adb devices
flutter devices
```

**Résultat attendu** :
```
List of devices attached
192.168.129.46:5555     device

Found 1 connected device:
  SM S938B (mobile) • 192.168.129.46:5555 • android-arm64 • Android 16
```

---

## 🐛 **DÉPANNAGE**

### ❌ "APK non trouvé"
**Solution** : Compiler d'abord :
```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia
flutter build apk --release
```

### ❌ "device not found" ou "offline"
**Solution** : Reconnecter via WiFi :
```bash
export PATH="$HOME/Library/Android/sdk/platform-tools:$PATH"
adb connect 192.168.129.46:5555
```

### ❌ "INSTALL_FAILED_UPDATE_INCOMPATIBLE"
**Solution** : Désinstaller puis réinstaller :
```bash
adb -s 192.168.129.46:5555 uninstall com.example.arkalia_cia
adb -s 192.168.129.46:5555 install build/app/outputs/flutter-apk/app-release.apk
```

### ❌ L'app ne se lance pas après installation
**Solution** : Vérifier les permissions :
```bash
adb -s 192.168.129.46:5555 shell "pm grant com.example.arkalia_cia android.permission.READ_CONTACTS"
adb -s 192.168.129.46:5555 shell "pm grant com.example.arkalia_cia android.permission.WRITE_CALENDAR"
```

---

## 📋 **RÉSUMÉ RAPIDE**

1. **Vérifier connexion** : `adb devices` → doit voir `192.168.129.46:5555 device`
2. **Mettre à jour** : `cd arkalia_cia && ./update_s25.sh`
3. **Vérifier version** : `adb -s 192.168.129.46:5555 shell "dumpsys package com.example.arkalia_cia | grep versionName"`

---

## Voir aussi

- [MISE_A_JOUR_S25_WIFI.md](MISE_A_JOUR_S25_WIFI.md) - Guide de mise à jour via WiFi
- [deployment/CONFIGURATION_BACKEND_WIFI.md](deployment/CONFIGURATION_BACKEND_WIFI.md) - Configuration WiFi pour le backend
- [deployment/CONNECTER_S25_ANDROID.md](deployment/CONNECTER_S25_ANDROID.md) - Guide de connexion Android
- [TESTER_ET_METTRE_A_JOUR.md](TESTER_ET_METTRE_A_JOUR.md) - Guide complet de test et mise à jour
- [INDEX_DOCUMENTATION.md](INDEX_DOCUMENTATION.md) - Index de la documentation

---

**Dernière mise à jour** : 19 novembre 2025

