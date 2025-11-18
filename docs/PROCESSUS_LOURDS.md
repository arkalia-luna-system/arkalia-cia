# 🔥 Guide - Processus Lourds en Arrière-Plan

**Date**: 18 Novembre 2025  
**Problème**: Processus qui consomment beaucoup de CPU/RAM en arrière-plan

---

## 🎯 Problèmes Identifiés

### 1. **Bandit** (Scans de Sécurité) - ⚠️ TRÈS LOURD

**Symptômes**:
- 2 processus Bandit qui consomment **90-95% CPU chacun**
- Scans complets du projet en continu
- RAM: ~0.5-0.8% par processus

**Cause**:
- Lancé automatiquement par **Cursor IDE** (extension Python)
- Ou lancé par **pre-commit hooks** lors des commits
- Scans récursifs de tout le projet (`bandit -r /Volumes/T7/arkalia-cia`)

**Solution**:
```bash
# Arrêter tous les processus Bandit
./cleanup_all.sh

# Ou manuellement
pkill -f "bandit"
```

**Désactiver dans Cursor**:
1. Ouvrir les paramètres Cursor
2. Chercher "Python > Analysis: Bandit Enabled"
3. Désactiver si pas nécessaire en temps réel

---

### 2. **Mypy** (Vérification de Types) - ⚠️ LOURD

**Symptômes**:
- Processus Mypy qui consomme **75-90% CPU**
- RAM: ~1% par processus
- Vérifie tous les types Python en continu

**Cause**:
- Lancé automatiquement par **Cursor IDE** (extension mypy-type-checker)
- Vérifie les fichiers Python modifiés en temps réel

**Solution**:
```bash
# Arrêter tous les processus Mypy
./cleanup_all.sh

# Ou manuellement (attention: arrête aussi le serveur LSP de Cursor)
pkill -f "mypy.*arkalia"
```

**Désactiver dans Cursor**:
1. Ouvrir les paramètres Cursor
2. Chercher "Python > Analysis: Type Checking Mode"
3. Changer de "basic" à "off" si pas nécessaire

---

### 3. **Boucle Infinie Flutter** - ⚠️ MODÉRÉ

**Symptômes**:
- Processus `while true; do find build -name "._*" -delete; sleep 0.5; done`
- Nettoie les fichiers macOS toutes les 0.5 secondes
- CPU: Variable (0-5% selon activité)

**Cause**:
- Lancé automatiquement lors du build Flutter
- Nettoie les fichiers macOS cachés (`._*`) pendant le build
- **Problème**: Ne s'arrête pas toujours correctement

**Solution**:
```bash
# Arrêter toutes les boucles de nettoyage
./cleanup_all.sh

# Ou trouver et tuer manuellement
ps aux | grep "while true.*find build"
kill <PID>
```

**Prévention**:
- Utiliser `start_flutter_safe.sh` au lieu de `start_flutter.sh`
- Le script safe gère correctement l'arrêt des processus enfants

---

### 4. **Pytest/Coverage** - ⚠️ MODÉRÉ

**Symptômes**:
- Processus pytest qui restent en arrière-plan
- Coverage qui continue à collecter des données

**Cause**:
- Tests interrompus (Ctrl+C) qui ne nettoient pas correctement
- Coverage qui reste actif après les tests

**Solution**:
```bash
# Nettoyer pytest et coverage
./cleanup_all.sh

# Ou manuellement
pkill -f "pytest|coverage"
```

---

## 🛠️ Script de Nettoyage Complet

Le script `cleanup_all.sh` nettoie automatiquement **tous** ces processus :

```bash
./cleanup_all.sh
```

**Ce qui est nettoyé**:
1. ✅ pytest et coverage
2. ✅ bandit (scans de sécurité)
3. ✅ mypy (vérification de types)
4. ✅ watch-macos-files.sh
5. ✅ FastAPI/uvicorn
6. ✅ Flutter et boucles infinies
7. ✅ Gradle daemons (optionnel avec `--include-gradle`)
8. ✅ Kotlin daemons

---

## 📊 Vérifier les Processus Lourds

```bash
# Voir tous les processus Python/Flutter lourds
ps aux | grep -E "(bandit|mypy|pytest|coverage|flutter)" | grep -v grep

# Voir l'utilisation CPU/RAM
top -o cpu | head -20

# Voir les processus les plus lourds
ps aux | sort -rk 3,3 | head -10
```

---

## 💡 Recommandations

### Pour le Développement Quotidien

1. **Désactiver les vérifications automatiques dans Cursor** si pas nécessaires :
   - Bandit: Désactiver si vous ne faites pas de sécurité en temps réel
   - Mypy: Mettre en "basic" au lieu de "strict" pour moins de CPU

2. **Utiliser les scripts "safe"** :
   - `start_backend_safe.sh` au lieu de `start_backend.sh`
   - `start_flutter_safe.sh` au lieu de `start_flutter.sh`

3. **Nettoyer régulièrement** :
   ```bash
   # Avant de commencer à travailler
   ./cleanup_all.sh
   ```

### Pour les Tests

1. **Nettoyer avant les tests** :
   ```bash
   ./cleanup_all.sh
   ./run_tests.sh
   ```

2. **Nettoyer après les tests** :
   ```bash
   ./cleanup_all.sh
   ```

---

## 🚨 Si la RAM/CPU est Surchargée

1. **Arrêter tous les processus lourds** :
   ```bash
   ./cleanup_all.sh
   ```

2. **Vérifier ce qui reste** :
   ```bash
   ps aux | grep -E "(python|flutter)" | grep -v grep
   ```

3. **Si nécessaire, forcer l'arrêt** :
   ```bash
   # ATTENTION: Arrête TOUS les processus Python
   pkill -9 python
   ```

4. **Redémarrer Cursor** si les extensions continuent à lancer des processus

---

## 📝 Notes

- **Bandit** et **Mypy** sont lancés par Cursor IDE pour vous aider, mais ils sont très lourds
- C'est normal qu'ils consomment beaucoup de CPU pendant les scans
- Si vous ne faites pas de sécurité/types en temps réel, désactivez-les dans Cursor
- Les boucles infinies Flutter sont un bug connu - utilisez les scripts "safe"

---

**Dernière mise à jour**: 18 Novembre 2025

