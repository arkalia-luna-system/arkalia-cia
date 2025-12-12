# 🔧 Fix Fichiers macOS Cachés - Guide

**Date** : 12 décembre 2025  
**Problème** : Erreurs de compilation Android dues aux fichiers macOS cachés

---

## 🐛 PROBLÈME

Lors de la compilation Android, des erreurs apparaissent :
```
ERROR: D8: Unexpected class file name: io/flutter/plugins/._GeneratedPluginRegistrant.class
ERROR: Invalid classfile header
```

**Cause** : Fichiers macOS cachés (`._*`) sur disque externe (T7) qui interfèrent avec la compilation Android.

---

## ✅ SOLUTION RAPIDE

### Nettoyage automatique

```bash
cd arkalia_cia

# 1. Supprimer les fichiers macOS cachés
find . -name "._*" -type f -delete
find build -name "._*" -type f -delete

# 2. Nettoyer Flutter
flutter clean

# 3. Nettoyer Gradle
cd android
./gradlew clean
cd ..

# 4. Relancer
flutter run -d android
```

---

## 🔄 SOLUTION PERMANENTE

### Script de nettoyage automatique

Créer un script `clean_macos.sh` :

```bash
#!/bin/bash
# Nettoyer les fichiers macOS cachés avant compilation

echo "🧹 Nettoyage des fichiers macOS cachés..."

# Supprimer tous les fichiers ._*
find . -name "._*" -type f -delete 2>/dev/null
find build -name "._*" -type f -delete 2>/dev/null

# Supprimer .DS_Store
find . -name ".DS_Store" -delete 2>/dev/null

echo "✅ Nettoyage terminé"
```

### Utilisation

```bash
chmod +x clean_macos.sh
./clean_macos.sh
flutter run -d android
```

---

## 📋 CHECKLIST

Avant chaque compilation Android :

- [ ] Nettoyer les fichiers macOS cachés
- [ ] `flutter clean`
- [ ] `./gradlew clean` (dans android/)
- [ ] Relancer la compilation

---

## 🎯 PRÉVENTION

### Option 1 : .gitignore (déjà fait)

Le `.gitignore` exclut déjà ces fichiers, mais ils peuvent toujours être créés localement.

### Option 2 : Script pré-compilation

Ajouter dans `build.gradle.kts` (déjà fait dans le projet) :

```kotlin
tasks.matching { 
    it.name.contains("compile") || it.name.contains("assemble")
}.configureEach {
    doFirst {
        // Nettoyer les fichiers macOS
        fileTree(".").matching {
            include("**/._*")
            include("**/.DS_Store")
        }.forEach { it.delete() }
    }
}
```

---

## ✅ RÉSUMÉ

**Problème** : Fichiers macOS cachés (`._*`) sur disque externe  
**Solution** : Nettoyer avant compilation  
**Prévention** : Scripts automatiques déjà en place

**Le nettoyage est en cours, l'app devrait se compiler correctement maintenant !** 🚀

