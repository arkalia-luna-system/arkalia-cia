# 📱 Installation sur iPhone - Arkalia CIA

**Date**: November 17, 2025

---

## ✅ **PRÉREQUIS**

### **1. Installer Xcode**
```bash
# Installer Xcode depuis l'App Store
# Ou vérifier l'installation :
xcode-select --print-path

# Si pas installé :
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

### **2. Installer CocoaPods**
```bash
# Installer CocoaPods
sudo gem install cocoapods

# Vérifier l'installation
pod --version
```

### **3. Vérifier Flutter**
```bash
cd arkalia_cia
flutter doctor -v
```

**Résultat attendu** :
- ✅ Flutter SDK
- ✅ Xcode (avec iOS toolchain)
- ✅ CocoaPods

---

## 🚀 **MÉTHODE 1 : Via Xcode (Recommandé)**

### **Étape 1 : Générer le projet iOS**
```bash
cd arkalia_cia
flutter pub get
flutter build ios --no-codesign
```

### **Étape 2 : Ouvrir dans Xcode**
```bash
cd ios
open Runner.xcworkspace
# OU
open Runner.xcodeproj
```

### **Étape 3 : Configurer le projet dans Xcode**

1. **Sélectionner le target "Runner"**
2. **Onglet "Signing & Capabilities"** :
   - Cocher "Automatically manage signing"
   - Sélectionner votre **Team** (Apple Developer Account)
   - Le **Bundle Identifier** sera généré automatiquement

3. **Connecter votre iPhone** :
   - Brancher l'iPhone via USB
   - Autoriser l'ordinateur sur l'iPhone
   - Sélectionner votre iPhone dans la liste des devices

4. **Choisir le schéma** :
   - En haut, sélectionner "Runner" > votre iPhone

### **Étape 4 : Build et Run**
- Cliquer sur le bouton **▶️ Play** (ou Cmd+R)
- L'app va compiler et s'installer sur l'iPhone

---

## 🚀 **MÉTHODE 2 : Via Flutter CLI (Plus rapide)**

### **Étape 1 : Connecter l'iPhone**
```bash
# Brancher l'iPhone via USB
# Autoriser l'ordinateur sur l'iPhone
```

### **Étape 2 : Vérifier la connexion**
```bash
cd arkalia_cia
flutter devices
```

**Résultat attendu** :
```
iPhone de [Nom] (mobile) • [UUID] • ios • iOS 17.0
```

### **Étape 3 : Installer les dépendances iOS**
```bash
cd ios
pod install
cd ..
```

### **Étape 4 : Lancer sur iPhone**
```bash
flutter run -d [UUID_DE_L_IPHONE]
# OU simplement (si un seul device) :
flutter run
```

---

## 🔧 **MÉTHODE 3 : Build Release pour TestFlight**

### **Étape 1 : Build Archive**
```bash
cd arkalia_cia
flutter build ios --release
```

### **Étape 2 : Ouvrir dans Xcode**
```bash
cd ios
open Runner.xcworkspace
```

### **Étape 3 : Créer Archive**
1. Dans Xcode : **Product** > **Archive**
2. Attendre la fin de la compilation
3. Dans **Organizer** :
   - Sélectionner l'archive
   - Cliquer sur **Distribute App**
   - Choisir **App Store Connect**
   - Suivre les étapes

---

## ⚠️ **PROBLÈMES COURANTS**

### **Erreur : "No iOS devices found"**
```bash
# Vérifier que l'iPhone est bien connecté
flutter devices

# Si pas visible :
# 1. Débrancher/rebrancher l'iPhone
# 2. Autoriser l'ordinateur sur l'iPhone
# 3. Vérifier que le câble USB fonctionne
```

### **Erreur : "Signing for Runner requires a development team"**
1. Ouvrir Xcode
2. Aller dans **Preferences** > **Accounts**
3. Ajouter votre Apple ID
4. Dans le projet, sélectionner votre Team dans Signing

### **Erreur : "CocoaPods not installed"**
```bash
sudo gem install cocoapods
cd arkalia_cia/ios
pod install
```

### **Erreur : "Xcode installation is incomplete"**
```bash
# Installer Xcode depuis l'App Store
# Puis :
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -license accept
```

---

## 📋 **CHECKLIST RAPIDE**

- [ ] Xcode installé et configuré
- [ ] CocoaPods installé
- [ ] iPhone connecté et autorisé
- [ ] `flutter devices` montre l'iPhone
- [ ] `pod install` exécuté dans `ios/`
- [ ] Team Apple Developer configurée dans Xcode
- [ ] App lancée avec succès sur iPhone

---

## 🎯 **POUR PRENDRE LES SCREENSHOTS**

### **Sur iPhone :**
Une fois l'app installée sur iPhone :

1. **Lancer l'app**
2. **Naviguer** vers chaque écran :
   - Home Page
   - Documents
   - Emergency
   - Health
3. **Capturer** l'écran :
   - iPhone : **Volume Up + Power** (ou **Volume Up + Side Button**)
   - Les screenshots sont dans **Photos** > **Screenshots**

### **Sur iPad Pro (Recommandé aussi !)** ✅

**iPad Pro est une excellente option** car :
- ✅ **App Store requiert** des screenshots iPad Pro 12.9" (2048 x 2732 px)
- ✅ **Meilleure qualité** : Plus d'espace pour voir les détails
- ✅ **Design adaptatif** : L'app Flutter s'adapte automatiquement
- ✅ **Même app** : Fonctionne exactement pareil

**Comment capturer sur iPad Pro :**
1. **Installer l'app** sur iPad Pro (même méthode que iPhone)
2. **Lancer l'app** et naviguer vers chaque écran
3. **Capturer** : **Volume Up + Power** (ou **Volume Up + Top Button**)
4. **Les screenshots** sont dans **Photos** > **Screenshots**

**Tailles iPad Pro :**
- **iPad Pro 12.9"** : 2048 x 2732 pixels (requis pour App Store)
- Minimum 3 screenshots par taille

**Transférer les screenshots :**
- AirDrop vers Mac
- Ou connecter iPad et copier depuis Photos

---

**Dernière mise à jour**: November 17, 2025
