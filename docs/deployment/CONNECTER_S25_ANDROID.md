# 📱 Connecter le Samsung S25 à Flutter

**Date** : 19 novembre 2025  
**Problème** : Le S25 n'apparaît pas dans `flutter devices`

---

## ✅ **CORRECTION APPLIQUÉE**

ADB a été ajouté au PATH dans `~/.zshrc`. 

**Pour appliquer immédiatement** (sans redémarrer le terminal) :
```bash
source ~/.zshrc
```

---

## 🔍 **DIAGNOSTIC**

### **Vérifier si ADB fonctionne :**

```bash
adb devices
```

Si vous voyez "List of devices attached" (vide), le S25 n'est pas connecté ou le débogage USB n'est pas activé.

---

## ✅ **SOLUTION 1 : Installer Android SDK Platform Tools**

### **Option A : Via Homebrew (Recommandé)**

```bash
# Installer Homebrew si pas déjà installé
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Installer Android Platform Tools
brew install --cask android-platform-tools
```

### **Option B : Télécharger manuellement**

1. Aller sur : https://developer.android.com/tools/releases/platform-tools
2. Télécharger "SDK Platform-Tools for macOS"
3. Extraire dans un dossier (ex: `~/android-platform-tools`)
4. Ajouter au PATH :

```bash
# Ajouter dans ~/.zshrc
echo 'export PATH="$HOME/android-platform-tools:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

---

## 📱 **CONFIGURER LE S25**

### **ÉTAPE 1 : Activer le Mode Développeur**

1. Sur le S25, ouvrez **Paramètres**
2. Allez dans **À propos du téléphone**
3. Trouvez **Numéro de build** (ou **Build number**)
4. **Appuyez 7 fois** sur "Numéro de build"
5. Un message apparaît : "Vous êtes maintenant développeur !"

### **ÉTAPE 2 : Activer le Débogage USB**

1. Retournez dans **Paramètres**
2. Trouvez **Options développeur** (ou **Developer options**)
3. Activez **Débogage USB** (ou **USB debugging**)
4. Acceptez l'avertissement de sécurité

### **ÉTAPE 3 : Connecter le S25 au Mac**

1. **Branchez le S25 au Mac** via USB
2. Sur le S25, une popup apparaît : **"Autoriser le débogage USB ?"**
3. Cochez **"Toujours autoriser depuis cet ordinateur"**
4. Cliquez sur **"Autoriser"**

---

## 🔧 **VÉRIFIER LA CONNEXION**

### **Test 1 : Vérifier avec ADB**

```bash
# Redémarrer ADB
adb kill-server
adb start-server

# Vérifier les appareils
adb devices
```

**Résultat attendu :**
```
List of devices attached
R5CT90XXXXX    device
```

Si vous voyez `unauthorized`, acceptez la popup sur le téléphone.

### **Test 2 : Vérifier avec Flutter**

```bash
flutter devices
```

**Résultat attendu :**
```
Found 2 connected devices:
  macOS (desktop) • macos • darwin-arm64
  SM-S925B (mobile) • R5CT90XXXXX • android-arm64 • Android 15
```

---

## 🚀 **INSTALLER L'APP SUR LE S25**

### **Méthode 1 : Via Flutter Run (Recommandé)**

```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia

# Lister les appareils
flutter devices

# Installer sur le S25 (remplacez par l'ID de votre appareil)
flutter run -d R5CT90XXXXX
```

### **Méthode 2 : Créer un APK**

```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia

# Créer l'APK
flutter build apk --release

# Installer via ADB
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

---

## 📡 **CONFIGURER LE DÉPLOIEMENT WiFi (Optionnel)**

Une fois connecté en USB, vous pouvez configurer le WiFi pour ne plus avoir besoin du câble :

### **ÉTAPE 1 : Trouver l'IP du S25**

Sur le S25 :
1. **Paramètres** > **Wi‑Fi**
2. Cliquez sur le réseau WiFi connecté
3. Notez l'**Adresse IP** (ex: `192.168.1.105`)

### **ÉTAPE 2 : Activer ADB WiFi**

```bash
# Sur le Mac, avec le téléphone branché en USB
adb tcpip 5555
adb connect 192.168.1.105:5555
```

**Remplacez `192.168.1.105` par l'IP de votre S25 !**

### **ÉTAPE 3 : Débrancher et vérifier**

```bash
# Débranchez le câble USB
adb devices
```

Vous devriez voir :
```
List of devices attached
192.168.1.105:5555    device
```

### **ÉTAPE 4 : Installer via WiFi**

```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia
flutter run -d 192.168.1.105:5555
```

---

## 🐛 **DÉPANNAGE**

### **❌ "adb: command not found"**

**Solution** : Installer Android Platform Tools (voir Solution 1 ci-dessus)

### **❌ "no devices/emulators found"**

**Vérifications :**
1. ✅ Câble USB branché
2. ✅ Débogage USB activé sur le S25
3. ✅ Popup "Autoriser le débogage USB" acceptée
4. ✅ Câble USB supporte les données (pas seulement la charge)

**Test :**
```bash
adb kill-server
adb start-server
adb devices
```

### **❌ "unauthorized" dans `adb devices`**

**Solution :**
1. Sur le S25, acceptez la popup "Autoriser le débogage USB"
2. Cochez "Toujours autoriser depuis cet ordinateur"
3. Relancez `adb devices`

### **❌ Flutter ne détecte toujours pas le S25**

**Solution :**
```bash
# Vérifier que Flutter voit ADB
flutter doctor -v

# Si Android toolchain n'est pas configuré :
flutter doctor --android-licenses
```

---

## 📝 **RÉSUMÉ RAPIDE**

1. **Installer ADB** : `brew install --cask android-platform-tools`
2. **Activer Mode Développeur** : Paramètres > À propos > Numéro de build (7 fois)
3. **Activer Débogage USB** : Paramètres > Options développeur
4. **Brancher le S25** et accepter la popup
5. **Vérifier** : `adb devices` puis `flutter devices`
6. **Installer** : `flutter run -d [ID_APPAREIL]`

---

---

## Voir aussi

- **[deployment/CONFIGURATION_BACKEND_WIFI.md](./CONFIGURATION_BACKEND_WIFI.md)** — Configuration backend WiFi
- **[troubleshooting/EXPLICATION_WIFI_ADB.md](../troubleshooting/EXPLICATION_WIFI_ADB.md)** — Explication WiFi ADB
- **[troubleshooting/TROUVER_CONNECT_VIA_NETWORK.md](../troubleshooting/TROUVER_CONNECT_VIA_NETWORK.md)** — Trouver et connecter via réseau
- **[TESTER_ET_METTRE_A_JOUR.md](../TESTER_ET_METTRE_A_JOUR.md)** — Guide de test et mise à jour
- **[INDEX_DOCUMENTATION.md](../INDEX_DOCUMENTATION.md)** — Index complet de la documentation

---

*Dernière mise à jour : Janvier 2025*

