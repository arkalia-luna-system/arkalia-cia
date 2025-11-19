# 🔧 Correction Erreurs sqflite_darwin iOS

**Date** : 19 novembre 2025  
**Problème** : Erreurs de compilation iOS avec `sqflite_darwin`

---

## ❌ **ERREURS RENCONTRÉES**

```
'Flutter/Flutter.h' file not found
double-quoted include "SqfliteImportPublic.h" in framework header
could not build module 'sqflite_darwin'
```

---

## ✅ **SOLUTION APPLIQUÉE**

### **ÉTAPE 1 : Nettoyer Flutter**

```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia
flutter clean
flutter pub get
```

### **ÉTAPE 2 : Nettoyer CocoaPods**

```bash
cd ios
rm -rf Pods Podfile.lock .symlinks
find . -name "._*" -type f -delete
pod deintegrate
```

### **ÉTAPE 3 : Corriger le Podfile**

Le Podfile a été modifié pour spécifier la version iOS :

```ruby
platform :ios, '13.0'
```

### **ÉTAPE 4 : Réinstaller les Pods**

```bash
pod install --repo-update
```

### **ÉTAPE 5 : Nettoyer le cache Xcode**

```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/Runner-*
```

### **ÉTAPE 6 : Rebuild**

```bash
cd ..
flutter clean
flutter pub get
cd ios
pod install
```

---

## 🔍 **VÉRIFICATIONS**

### **Vérifier que les fichiers Flutter sont générés :**

```bash
ls -la ios/Flutter/Generated.xcconfig
```

### **Vérifier que les Pods sont installés :**

```bash
ls -la ios/Pods/sqflite_darwin/
```

### **Tester la compilation :**

```bash
flutter build ios --no-codesign
```

---

## 🐛 **SI LES ERREURS PERSISTENT**

### **Solution 1 : Nettoyer complètement**

```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia

# Nettoyer Flutter
flutter clean

# Nettoyer iOS
cd ios
rm -rf Pods Podfile.lock .symlinks
rm -rf ~/Library/Developer/Xcode/DerivedData/Runner-*

# Réinstaller
cd ..
flutter pub get
cd ios
pod install --repo-update
```

### **Solution 2 : Vérifier la version de CocoaPods**

```bash
pod --version
# Devrait être >= 1.11.0
```

### **Solution 3 : Mettre à jour CocoaPods**

```bash
sudo gem install cocoapods
pod repo update
```

---

## 📝 **MODIFICATIONS APPORTÉES**

1. ✅ **Podfile** : Ajout de `platform :ios, '13.0'`
2. ✅ **Nettoyage** : Suppression des fichiers macOS cachés (`._*`)
3. ✅ **Cache** : Nettoyage du cache Xcode DerivedData
4. ✅ **Pods** : Réinstallation complète des dépendances

---

## ✅ **RÉSULTAT**

Après ces corrections :
- ✅ Les Pods sont correctement installés
- ✅ Les fichiers Flutter sont générés
- ✅ La compilation iOS devrait fonctionner

---

**Dernière mise à jour** : 19 novembre 2025

