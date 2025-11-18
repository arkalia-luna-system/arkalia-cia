# 🔍 Audit Complet - Problèmes Similaires aux Doublons pytest

**Date**: 18 Novembre 2025  
**Statut**: ✅ Audit complet effectué

---

## 🔴 Problèmes Identifiés

### 1. ⚠️ Script `watch-macos-files.sh` - Boucle Infinie

**Fichier**: `arkalia_cia/android/watch-macos-files.sh`

**Problème**:
```bash
while true; do
    clean_macos_files
    sleep 0.5
done
```

**Impact**:
- ✅ Boucle infinie qui tourne en continu
- ✅ Consomme CPU en permanence (toutes les 0.5 secondes)
- ✅ Peut créer plusieurs instances si lancé plusieurs fois
- ✅ Pas de mécanisme d'arrêt propre

**Risque**: 🔴 **ÉLEVÉ** - Consommation CPU/RAM inutile

---

### 2. ⚠️ Scripts de Démarrage - Pas de Vérification de Doublons

**Fichiers**:
- `start_backend.sh`
- `start_flutter.sh`

**Problème**:
- Aucune vérification si le processus existe déjà
- Peut créer plusieurs instances de l'API ou de Flutter
- Pas de lock file pour éviter les doublons

**Impact**:
- Plusieurs serveurs FastAPI sur le même port (erreur)
- Plusieurs instances Flutter (consommation mémoire)

**Risque**: 🟡 **MOYEN** - Conflits de ports et consommation mémoire

---

### 3. ⚠️ AutoSyncService - Timer Périodique

**Fichier**: `arkalia_cia/lib/services/auto_sync_service.dart`

**Problème**:
- Timer périodique qui tourne toutes les heures
- Bien géré avec `dispose()` mais pourrait être amélioré
- Pas de vérification si le timer existe déjà avant de créer un nouveau

**Code actuel**:
```dart
static void _startPeriodicSync() {
    _stopPeriodicSync(); // ✅ Bon - arrête avant de créer
    _periodicTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      syncIfNeeded();
    });
}
```

**Impact**: 🟢 **FAIBLE** - Bien géré mais peut être amélioré

---

### 4. ⚠️ Gradle Daemons Multiples

**Problème**:
- Plusieurs processus Gradle daemon qui tournent en parallèle
- Consomment beaucoup de mémoire (8GB chacun)
- Ne se terminent pas automatiquement

**Processus détectés**:
- Gradle daemon 8.12 (plusieurs instances)
- Kotlin compiler daemon

**Impact**: 🟡 **MOYEN** - Consommation mémoire importante

---

### 5. ⚠️ Flutter - Processus Multiples

**Problème**:
- Plusieurs processus Flutter qui tournent en parallèle
- Chaque processus consomme de la mémoire
- Pas de nettoyage automatique

**Impact**: 🟡 **MOYEN** - Consommation mémoire

---

## ✅ Solutions Proposées

### Solution 1: Script de Nettoyage Complet

Créer un script `cleanup_all.sh` qui nettoie tous les processus problématiques.

### Solution 2: Wrapper pour Scripts de Démarrage

Créer des wrappers pour `start_backend.sh` et `start_flutter.sh` qui vérifient les doublons.

### Solution 3: Améliorer watch-macos-files.sh

Ajouter un mécanisme de lock file et un signal d'arrêt propre.

### Solution 4: Script de Nettoyage Gradle/Flutter

Créer un script pour arrêter les daemons Gradle et les processus Flutter.

---

## 📋 Priorités

1. 🔴 **URGENT**: `watch-macos-files.sh` - Boucle infinie
2. 🟡 **IMPORTANT**: Scripts de démarrage - Vérification doublons
3. 🟡 **IMPORTANT**: Nettoyage Gradle/Flutter
4. 🟢 **AMÉLIORATION**: AutoSyncService (déjà bien géré)

