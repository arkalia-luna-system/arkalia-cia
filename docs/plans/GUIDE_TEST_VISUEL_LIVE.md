# Guide : Test visuel en live

**Version** : 1.0.0  
**Date** : 20 novembre 2025  
**Statut** : ✅ Guide actif

---

## Vue d'ensemble

Tester l'app directement avec visualisation interface en temps réel.

---

## 🎯 **OBJECTIF**

Permettre de **voir l'interface en live** pendant le développement plutôt que de tester chaque bouton individuellement :
- ✅ Hot Reload : Voir changements instantanément
- ✅ Simulateur iOS : Tester sur iPhone virtuel
- ✅ Émulateur Android : Tester sur Android virtuel
- ✅ Device physique : Tester sur vrai téléphone
- ✅ Widget Inspector : Inspecter interface en temps réel

---

## 🚀 **MÉTHODES DE TEST**

### **1. Hot Reload Flutter (Recommandé)**

#### **Avantages**
- ⚡ Changements instantanés (sans redémarrer app)
- 🎨 Voir interface en temps réel
- 🔄 Garde l'état de l'app (navigation, données)

#### **Utilisation**

```bash
# Lancer l'app en mode développement
cd arkalia_cia
flutter run

# Pendant l'exécution :
# - Appuyer sur 'r' pour Hot Reload (changements rapides)
# - Appuyer sur 'R' pour Hot Restart (redémarrer complètement)
# - Appuyer sur 'q' pour quitter
```

#### **Workflow Recommandé**

1. **Lancer app** : `flutter run`
2. **Modifier code** : Éditer fichier Dart
3. **Sauvegarder** : Cmd+S / Ctrl+S
4. **Hot Reload automatique** : Changements visibles instantanément
5. **Voir résultat** : Interface mise à jour en direct

---

### **2. Simulateur iOS (macOS uniquement)**

#### **Avantages**
- 📱 Interface iPhone fidèle
- 🎨 Design iOS natif
- 🔄 Hot Reload fonctionne

#### **Configuration**

```bash
# 1. Ouvrir Simulator
open -a Simulator

# 2. Choisir device iPhone
# Simulator > File > Open Simulator > iPhone 15 Pro Max (recommandé)

# 3. Lancer app sur simulateur
flutter run -d "iPhone 15 Pro Max"
```

#### **Commandes Utiles**

```bash
# Lister devices disponibles
flutter devices

# Lancer sur simulateur spécifique
flutter run -d "iPhone 15 Pro Max"

# Hot Reload pendant exécution
# Appuyer sur 'r' dans terminal
```

---

### **3. Émulateur Android**

#### **Avantages**
- 📱 Interface Android fidèle
- 🎨 Design Material Design
- 🔄 Hot Reload fonctionne

#### **Configuration**

```bash
# 1. Ouvrir Android Studio
# Tools > Device Manager

# 2. Créer émulateur (si pas encore fait)
# - Cliquer "Create Device"
# - Choisir Pixel 7 ou Pixel 8 (recommandé)
# - Télécharger système Android (API 33+)
# - Créer émulateur

# 3. Lancer émulateur
flutter emulators --launch <emulator_id>

# 4. Lancer app sur émulateur
flutter run
```

#### **Commandes Utiles**

```bash
# Lister émulateurs disponibles
flutter emulators

# Lancer émulateur spécifique
flutter emulators --launch Pixel_7_API_33

# Lancer app sur émulateur
flutter run -d "emulator-5554"
```

---

### **4. Device Physique (Téléphone Réel)**

#### **Avantages**
- 📱 Performance réelle
- 🎨 Vraie expérience utilisateur
- 🔄 Hot Reload fonctionne

#### **Configuration iOS (iPhone)**

```bash
# 1. Connecter iPhone via USB
# 2. Autoriser sur iPhone : "Faire confiance à cet ordinateur"
# 3. Activer mode développeur sur iPhone :
#    Settings > Privacy & Security > Developer Mode > ON

# 4. Vérifier device détecté
flutter devices

# 5. Lancer app sur iPhone
flutter run -d "iPhone de [Votre Nom]"
```

#### **Configuration Android**

```bash
# 1. Activer options développeur sur Android :
#    Settings > About Phone > Tap "Build Number" 7 fois

# 2. Activer USB Debugging :
#    Settings > Developer Options > USB Debugging > ON

# 3. Connecter téléphone via USB
# 4. Autoriser sur téléphone : "Autoriser le débogage USB"

# 5. Vérifier device détecté
flutter devices
adb devices

# 6. Lancer app sur téléphone
flutter run -d "SM-G991B"  # (exemple ID Samsung)
```

---

### **5. Flutter DevTools (Inspecteur Visuel)**

#### **Avantages**
- 🔍 Inspecter widgets en temps réel
- 📊 Voir performance
- 🎨 Analyser layout

#### **Utilisation**

```bash
# 1. Lancer app
flutter run

# 2. DevTools s'ouvre automatiquement dans navigateur
#    Sinon : http://127.0.0.1:9100

# 3. Utiliser Widget Inspector
#    - Cliquer sur widget dans interface
#    - Voir propriétés en temps réel
#    - Analyser arbre de widgets
```

#### **Fonctionnalités DevTools**

- **Widget Inspector** : Inspecter widgets
- **Performance** : Analyser performance
- **Memory** : Voir utilisation mémoire
- **Network** : Voir requêtes réseau
- **Logging** : Voir logs en temps réel

---

## 🎨 **WORKFLOW RECOMMANDÉ**

### **Développement Quotidien**

```bash
# 1. Ouvrir simulateur/émulateur
# iOS : open -a Simulator
# Android : flutter emulators --launch Pixel_7_API_33

# 2. Lancer app en mode développement
cd arkalia_cia
flutter run

# 3. Ouvrir DevTools (optionnel)
# DevTools s'ouvre automatiquement

# 4. Développer avec Hot Reload
# - Modifier code
# - Sauvegarder (Cmd+S)
# - Voir changements instantanément (Hot Reload automatique)
# - Ou appuyer sur 'r' pour forcer Hot Reload
```

### **Test Visuel Interface**

```bash
# 1. Lancer app
flutter run

# 2. Naviguer dans l'app
# - Tester chaque écran
# - Voir interface en temps réel

# 3. Modifier design
# - Changer couleurs, tailles, etc.
# - Hot Reload pour voir changements

# 4. Utiliser Widget Inspector
# - Cliquer sur éléments
# - Voir propriétés
# - Ajuster en temps réel
```

---

## 🛠️ **OUTILS COMPLÉMENTAIRES**

### **1. Flutter Widget Inspector (VS Code)**

#### **Installation**

```bash
# Extension VS Code
# Flutter (Dart) - par Dart Code
```

#### **Utilisation**

1. **Lancer app** : `flutter run`
2. **Ouvrir Inspector** : Cmd+Shift+P > "Flutter: Open Widget Inspector"
3. **Inspecter widgets** : Cliquer sur éléments dans interface

---

### **2. Flutter Widget Inspector (Android Studio)**

#### **Utilisation**

1. **Lancer app** : Run > Run 'main.dart'
2. **Ouvrir Inspector** : View > Tool Windows > Flutter Inspector
3. **Inspecter widgets** : Cliquer sur éléments

---

### **3. Screenshot Automatique**

#### **Prendre screenshots pendant développement**

```bash
# iOS Simulator
xcrun simctl io booted screenshot screenshot.png

# Android Emulator
adb shell screencap -p /sdcard/screenshot.png
adb pull /sdcard/screenshot.png
```

---

## 📱 **CONFIGURATION RECOMMANDÉE**

### **Pour Développement Rapide**

#### **macOS (Recommandé)**
- ✅ Simulateur iOS : iPhone 15 Pro Max
- ✅ Émulateur Android : Pixel 8 (API 33+)
- ✅ Hot Reload activé
- ✅ DevTools ouvert

#### **Windows/Linux**
- ✅ Émulateur Android : Pixel 8 (API 33+)
- ✅ Device physique Android (si possible)
- ✅ Hot Reload activé
- ✅ DevTools ouvert

---

## 🎯 **BONNES PRATIQUES**

### **1. Toujours Utiliser Hot Reload**

```dart
// ❌ Éviter : Redémarrer app complètement
// ✅ Préférer : Hot Reload (r) ou Hot Restart (R)
```

### **2. Tester sur Plusieurs Devices**

```bash
# Tester sur :
# - iPhone (Simulator)
# - Android (Emulator)
# - Device physique (si possible)
```

### **3. Utiliser Widget Inspector**

```bash
# Inspecter widgets pour :
# - Vérifier propriétés
# - Déboguer layout
# - Optimiser performance
```

### **4. Prendre Screenshots Régulièrement**

```bash
# Documenter interface avec screenshots
# Utile pour :
# - Documentation
# - Tests visuels
# - Comparaisons avant/après
```

---

## 🚨 **DÉPANNAGE**

### **Hot Reload ne fonctionne pas**

```bash
# Solution 1 : Hot Restart
# Appuyer sur 'R' (majuscule) dans terminal

# Solution 2 : Redémarrer app
# Appuyer sur 'q' puis relancer flutter run

# Solution 3 : Nettoyer build
flutter clean
flutter pub get
flutter run
```

### **Simulateur/Émulateur ne démarre pas**

```bash
# iOS Simulator
# Vérifier Xcode installé
xcode-select --print-path

# Android Emulator
# Vérifier Android Studio installé
# Vérifier AVD créé dans Device Manager
```

### **Device physique non détecté**

```bash
# iOS
# - Vérifier câble USB
# - Autoriser sur iPhone
# - Vérifier mode développeur activé

# Android
# - Vérifier USB Debugging activé
# - Autoriser sur téléphone
# - Vérifier drivers USB installés
```

---

## 📚 **RESSOURCES**

- **Flutter Hot Reload** : https://docs.flutter.dev/development/tools/hot-reload
- **Flutter DevTools** : https://docs.flutter.dev/development/tools/devtools
- **iOS Simulator** : https://developer.apple.com/documentation/xcode/running-your-app-in-the-simulator-or-on-a-device
- **Android Emulator** : https://developer.android.com/studio/run/emulator

---

## ✅ **CHECKLIST DÉMARRAGE RAPIDE**

### **Première Utilisation**

- [ ] Installer Flutter SDK
- [ ] Installer Xcode (macOS) ou Android Studio
- [ ] Configurer simulateur/émulateur
- [ ] Lancer `flutter doctor` pour vérifier
- [ ] Tester `flutter run` sur projet

### **Développement Quotidien**

- [ ] Ouvrir simulateur/émulateur
- [ ] Lancer `flutter run`
- [ ] Utiliser Hot Reload (r)
- [ ] Inspecter avec DevTools
- [ ] Tester sur device physique (optionnel)

---

**Statut** : 📋 **GUIDE PRÊT**  
**Utilisation** : 🚀 **DÉVELOPPEMENT QUOTIDIEN**

