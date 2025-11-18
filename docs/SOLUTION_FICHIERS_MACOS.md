# Solution Complète - Fichiers macOS Cachés

**Date**: 18 Novembre 2025  
**Statut**: ✅ **RÉSOLU**

---

## 🎯 Problème

macOS crée automatiquement des fichiers cachés (`._*`, `.DS_Store`) sur les volumes externes (exFAT), causant des erreurs AAPT avec Gradle/Android :
```
ERROR: AAPT: error: failed to read file: magic value is 0x07160500 but AAPT expects 0x54504141.
```

---

## ✅ Solution Recommandée : Build sur Disque Local

### **Solution Définitive**

Le problème persiste sur les volumes externes car macOS recrée les fichiers trop rapidement. La solution la plus fiable est d'utiliser le disque local pour le build.

**Configuration (une seule fois) :**
```bash
# Copier le projet sur disque local
cd /Volumes/T7/arkalia-cia
rsync -av --exclude='build' --exclude='.dart_tool' --exclude='.git' --exclude='*.log' arkalia_cia/ ~/arkalia-cia-build/arkalia_cia/
```

**Build depuis disque local :**
```bash
cd ~/arkalia-cia-build/arkalia_cia
flutter run --release -d 192.168.129.46:5555
```

**Avantages :**
- ✅ Pas de fichiers macOS cachés
- ✅ Build plus rapide
- ✅ Pas de nettoyage nécessaire
- ✅ Solution permanente

---

## 🔧 Solutions Alternatives (si build sur disque externe)

### 1. Scripts de Nettoyage

- **`find-all-macos-files.sh`** - Trouve tous les fichiers macOS
- **`prevent-macos-files.sh`** - Supprime avant build
- **`watch-macos-files.sh`** - Surveillance continue (avec lock file)
- **`disable-macos-files.sh`** - Configuration initiale

### 2. Configuration Gradle

- Exclusion dans `build.gradle.kts` (8 niveaux de protection)
- Exclusion dans toutes les tâches PatternFilterable
- Nettoyage automatique avant/après build

### 3. Configuration Git

- `.gitattributes` configuré
- Patterns exclus dans `.gitignore`

---

## 📋 Utilisation (Solutions Alternatives)

```bash
# Nettoyage manuel avant build
cd /Volumes/T7/arkalia-cia/arkalia_cia
find build -name "._*" -type f -delete 2>/dev/null
flutter clean
flutter run --release

# OU utiliser les scripts
./arkalia_cia/android/prevent-macos-files.sh
flutter run --release

# Surveillance continue (avec lock file)
./arkalia_cia/android/watch-macos-files.sh
```

---

## ⚠️ Recommandation

**Utilisez le disque local pour le build** (`~/arkalia-cia-build/arkalia_cia`) pour éviter complètement le problème. Les fichiers sources peuvent rester sur `/Volumes/T7/arkalia-cia/arkalia_cia`.

**Voir aussi**: [GRADLE_FIX_GUIDE.md](GRADLE_FIX_GUIDE.md) pour plus de détails.
