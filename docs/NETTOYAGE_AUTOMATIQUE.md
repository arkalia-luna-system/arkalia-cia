# 🧹 Nettoyage Automatique - Documentation Complète

**Date**: 2025-01-XX  
**Statut**: ✅ **IMPLÉMENTÉ ET TESTÉ**

---

## 📋 Vue d'Ensemble

Système de nettoyage automatique unifié qui nettoie :
- ✅ Les processus problématiques (pytest, bandit, mypy, FastAPI, Flutter, etc.)
- ✅ Les fichiers de cache (`.pytest_cache`, `.coverage`, etc.)
- ✅ **Les fichiers macOS cachés avec numéros** (`.!28431!._fichier.md`)
- ✅ Les fichiers macOS standards (`.DS_Store`, `._*`, `.AppleDouble`, etc.)
- ✅ La mémoire RAM (optionnel avec `--purge-memory`)

---

## 🎯 Script Principal : `cleanup_all.sh`

### Fonctionnalités

Le script `scripts/cleanup_all.sh` est maintenant **unifié** et remplace :
- `cleanup_memory.sh` (redirige maintenant vers `cleanup_all.sh`)
- `clean_macos_files.sh` (fonctionnalité intégrée)

### Utilisation

```bash
# Nettoyage complet (recommandé)
./scripts/cleanup_all.sh

# Nettoyage en gardant le fichier .coverage
./scripts/cleanup_all.sh --keep-coverage

# Nettoyage avec libération mémoire système macOS
./scripts/cleanup_all.sh --purge-memory

# Nettoyage avec daemons Gradle
./scripts/cleanup_all.sh --include-gradle

# Nettoyage complet avec toutes les options
./scripts/cleanup_all.sh --all
```

### Ce qui est nettoyé

1. **Processus** :
   - pytest et coverage
   - bandit (scans de sécurité)
   - mypy (vérification de types)
   - watch-macos-files
   - FastAPI/uvicorn
   - Flutter/Dart
   - Gradle daemons (optionnel)
   - Kotlin daemons

2. **Fichiers de cache** :
   - `.pytest_cache/`
   - `.coverage` (sauf si `--keep-coverage`)
   - `/tmp/watch-macos-files.lock`

3. **Fichiers macOS cachés** :
   - `._*` (fichiers AppleDouble standards)
   - `.!*!._*` (fichiers avec numéros comme `.!28431!._fichier.md`)
   - `.DS_Store`
   - `.AppleDouble/`
   - `.Spotlight-V100/`
   - `.Trashes/`

4. **Mémoire** :
   - Garbage collector Python (toujours)
   - Cache système macOS avec `purge` (si `--purge-memory`)

---

## 🔄 Nettoyage Automatique Après les Tests

### Scripts modifiés

1. **`scripts/run_tests.sh`** :
   - Nettoie automatiquement après chaque exécution de tests
   - Nettoie même si les tests échouent
   - Nettoie les fichiers macOS avec numéros

2. **`Makefile`** :
   - `make test` : nettoie avant et après
   - `make test-cov` : nettoie avant et après
   - `make flutter-test` : nettoie avant et après
   - `make flutter-deps` : nettoie avant installation

---

## 🐛 Problème Résolu : Fichiers macOS avec Numéros

### Problème

macOS crée automatiquement des fichiers cachés avec numéros sur les volumes externes (exFAT) :
```
.!28431!._PLAN_06_IA_CONVERSATIONNELLE.md
.!28432!._autre_fichier.md
```

Ces fichiers ne sont pas nettoyés par les patterns standards (`._*`).

### Solution

Le script `cleanup_all.sh` utilise maintenant **deux patterns** pour capturer ces fichiers :

1. Pattern standard : `.!*!._*`
2. Pattern alternatif avec grep : `\.![0-9]+!\._`

```bash
# Dans cleanup_all.sh
find . -type f -name ".!*!._*" ! -path "./.git/*" -delete
find . -type f | grep -E "\.![0-9]+!\._" | xargs rm -f
```

---

## 📝 Fichiers Modifiés

### Scripts

- ✅ `scripts/cleanup_all.sh` - Script unifié principal
- ✅ `scripts/run_tests.sh` - Nettoyage automatique après tests
- ✅ `scripts/cleanup_memory.sh` - Redirige vers `cleanup_all.sh`
- ✅ `Makefile` - Nettoyage automatique dans les commandes

### Fonctionnalités Ajoutées

1. **Détection des fichiers macOS avec numéros**
2. **Nettoyage automatique après tests**
3. **Gestion améliorée des options** (fonctionne dans n'importe quel ordre)
4. **Exclusion des répertoires** (`.git`, `arkalia_cia_venv`, `.dart_tool`, `build`)

---

## ✅ Tests de Validation

Tous les scripts ont été validés :

```bash
✅ cleanup_all.sh syntax OK
✅ run_tests.sh syntax OK
✅ cleanup_memory.sh syntax OK
```

---

## 💡 Astuces

### Nettoyage manuel rapide

```bash
# Nettoyage rapide (sans purge mémoire)
./scripts/cleanup_all.sh --keep-coverage

# Nettoyage complet avec purge mémoire
./scripts/cleanup_all.sh --purge-memory
```

### Vérifier les fichiers macOS cachés

```bash
# Compter les fichiers macOS cachés
find . -type f \( -name "._*" -o -name ".!*!._*" -o -name ".DS_Store" \) ! -path "./.git/*" ! -path "./arkalia_cia_venv/*" | wc -l

# Lister les fichiers macOS avec numéros
find . -type f | grep -E "\.![0-9]+!\._"
```

---

## 🔍 Dépannage

### Le nettoyage ne supprime pas tous les fichiers

Si certains fichiers macOS restent après le nettoyage :

1. Vérifiez les permissions :
   ```bash
   ls -la fichier_problématique
   ```

2. Essayez de supprimer manuellement :
   ```bash
   rm -f ".!28431!._fichier.md"
   ```

3. Vérifiez que le fichier n'est pas verrouillé :
   ```bash
   lsof fichier_problématique
   ```

### Le script échoue avec "Permission denied"

Si vous obtenez des erreurs de permission :

1. Vérifiez les permissions d'exécution :
   ```bash
   chmod +x scripts/cleanup_all.sh
   ```

2. Pour `purge` (libération mémoire système), vous aurez besoin de `sudo` :
   ```bash
   sudo ./scripts/cleanup_all.sh --purge-memory
   ```

---

## 📚 Voir Aussi

- [`scripts/cleanup_all.sh`](../../scripts/cleanup_all.sh) - Script principal
- [`scripts/run_tests.sh`](../../scripts/run_tests.sh) - Script de tests avec nettoyage automatique
- [`docs/troubleshooting/SOLUTION_FICHIERS_MACOS.md`](../troubleshooting/SOLUTION_FICHIERS_MACOS.md) - Solution complète pour fichiers macOS

---

**Tous les scripts sont maintenant unifiés et fonctionnent correctement !** ✅

