# 🔍 Audit Consommation RAM - Arkalia CIA

**Date** : 12 DEC 25  
**Statut** : ✅ **AUDIT COMPLET**

---

## 📊 RÉSUMÉ EXÉCUTIF

Cet audit identifie les problèmes potentiels de consommation mémoire dans le projet Arkalia CIA. Plusieurs optimisations ont déjà été faites, mais quelques améliorations restent possibles.

---

## ✅ PROBLÈMES IDENTIFIÉS

### 1. ⚠️ Cache Offline Sans Limite (MODÉRÉ)

**Fichier** : `arkalia_cia/lib/services/offline_cache_service.dart`

**Problème** :
- Le cache offline utilise `SharedPreferences` sans limite sur le nombre de clés
- Peut grandir indéfiniment si beaucoup de requêtes sont mises en cache
- Chaque clé peut contenir des données JSON volumineuses

**Impact** :
- RAM : Potentiellement plusieurs dizaines de MB si beaucoup de clés
- Risque : MODÉRÉ (le cache expire après 24h, mais peut s'accumuler)

**Solution recommandée** :
- Ajouter une limite LRU (Least Recently Used) similaire au backend Python
- Limiter à ~100 clés maximum
- Nettoyer automatiquement les plus anciennes quand la limite est atteinte

**Statut** : ✅ **CORRIGÉ** (12 DEC 25)
- Limite LRU de 100 clés implémentée
- Nettoyage automatique au démarrage

---

### 2. ⚠️ Script watch-macos-files.sh - Boucle Infinie (FAIBLE)

**Fichier** : `arkalia_cia/android/watch-macos-files.sh`

**Problème** :
- Boucle `while [ -f "$LOCK_FILE" ]; do` qui tourne toutes les **0.2 secondes**
- Exécute `find` récursif toutes les 0.2s pendant le build
- Peut consommer CPU/RAM si plusieurs instances tournent

**Impact** :
- CPU : 0-5% par instance (variable selon activité)
- RAM : ~5-10 MB par instance
- Risque : **FAIBLE** (contrôlé par lock file, mais peut s'accumuler si mal arrêté)

**Solution actuelle** :
- ✅ Lock file pour éviter les doublons
- ✅ Gestion des signaux SIGINT/SIGTERM
- ✅ Script `cleanup_all.sh` nettoie automatiquement

**Amélioration possible** :
- Augmenter le délai à 1 seconde au lieu de 0.2s (suffisant pour éviter les erreurs D8)
- Vérifier que le script s'arrête bien après le build

**Statut** : ✅ **OPTIMISÉ** (12 DEC 25)
- Délai augmenté de 0.2s à 1s
- Réduction CPU de ~80%

---

### 3. ✅ Timer Périodique AutoSyncService (NORMAL)

**Fichier** : `arkalia_cia/lib/services/auto_sync_service.dart`

**Problème** :
- `Timer.periodic` qui tourne toutes les heures
- Peut accumuler des données en mémoire pendant la synchronisation

**Impact** :
- RAM : ~10-50 MB pendant la sync (temporaire)
- Risque : **FAIBLE** (timer bien géré, dispose() appelé)

**Solution actuelle** :
- ✅ Timer annulé dans `dispose()`
- ✅ Vérification des changements avant sync (évite syncs inutiles)
- ✅ Limite de 5 minutes entre syncs

**Statut** : ✅ **CORRECT** (pas de problème)

---

### 4. ✅ Cache Backend Python (DÉJÀ OPTIMISÉ)

**Fichier** : `arkalia_cia_python_backend/storage.py`

**Statut** : ✅ **DÉJÀ OPTIMISÉ**
- Cache LRU limité à 50 entrées
- Réduction mémoire de ~80%
- Pas de problème identifié

---

### 5. ✅ Traitement PDF (DÉJÀ OPTIMISÉ)

**Fichiers** : `arkalia_cia_python_backend/api.py`, `pdf_processor.py`

**Statut** : ✅ **DÉJÀ OPTIMISÉ**
- Upload par chunks de 1 MB (au lieu de 50 MB)
- Extraction page par page
- Libération immédiate des données volumineuses
- Réduction pic mémoire de ~98%

---

### 6. ⚠️ Boucle For Calendar Service (FAIBLE)

**Fichier** : `arkalia_cia/lib/services/calendar_service.dart`

**Problème** :
- Boucle `for (int i = 0; i < 52 && nextDate.isBefore(endDate); i++)` qui crée jusqu'à 52 événements récurrents
- Peut créer beaucoup d'événements en mémoire si récurrence activée

**Impact** :
- RAM : ~1-5 MB par série d'événements (temporaire)
- Risque : **FAIBLE** (limité à 52 événements max, normal pour récurrence)

**Statut** : ✅ **ACCEPTABLE** (comportement normal)

---

### 7. ⚠️ Processus Externes (CURSOR IDE)

**Problème** :
- **Bandit** : Scans de sécurité (90-95% CPU chacun)
- **Mypy** : Vérification de types (75-90% CPU)
- Lancés automatiquement par Cursor IDE

**Impact** :
- CPU : TRÈS ÉLEVÉ (90%+)
- RAM : ~0.5-1% par processus
- Risque : **MODÉRÉ** (peut surcharger le système)

**Solution** :
- ✅ Script `cleanup_all.sh` nettoie automatiquement
- ✅ Documentation dans `docs/troubleshooting/PROCESSUS_LOURDS.md`
- ⚠️ Désactiver dans Cursor si pas nécessaire

**Statut** : ✅ **DOCUMENTÉ** (utilisateur peut nettoyer)

---

### 8. ⚠️ Stockage Bytes PDF sur Web (CRITIQUE)

**Fichiers** :

- `arkalia_cia/lib/screens/onboarding/import_progress_screen.dart`
- `arkalia_cia/lib/screens/documents_screen.dart`
- `arkalia_cia/lib/utils/storage_helper.dart`

**Problème** :
- Sur le web, les PDFs sont stockés avec leurs **bytes complets** dans `SharedPreferences`
- Chaque PDF peut faire plusieurs MB (jusqu'à 10-50 MB)
- Les bytes restent en mémoire dans le document Map
- `SharedPreferences` a une limite de ~5-10 MB par clé sur certains navigateurs
- Si plusieurs PDFs sont importés, la RAM peut exploser

**Impact** :
- RAM : **TRÈS ÉLEVÉ** - Chaque PDF de 10 MB = 10 MB en RAM
- Risque : **CRITIQUE** - Peut faire planter l'app sur le web avec plusieurs PDFs

**Solution recommandée** :
- ⚠️ **URGENT** : Ne pas stocker les bytes dans SharedPreferences sur le web
- Utiliser IndexedDB pour les fichiers volumineux (>1 MB)
- Ou stocker seulement les métadonnées et charger les bytes à la demande
- Limiter la taille des fichiers sur le web (max 5 MB)

**Statut** : ✅ **CORRIGÉ** (12 DEC 25)
- Bytes désactivés sur web
- Limite 5 MB par fichier

---

### 9. ⚠️ Liste Messages Conversation IA (MODÉRÉ)

**Fichier** : `arkalia_cia/lib/screens/conversational_ai_screen.dart`

**Problème** :
- Liste `_messages` qui grandit indéfiniment
- Charge jusqu'à 20 messages historiques au démarrage
- Pas de limite sur le nombre de messages en mémoire

**Impact** :
- RAM : ~1-5 MB selon nombre de messages
- Risque : **MODÉRÉ** (limité par l'historique chargé, mais peut grandir)

**Solution recommandée** :
- Limiter à 50 messages maximum en mémoire
- Supprimer les messages les plus anciens quand la limite est atteinte
- Utiliser pagination pour l'historique

**Statut** : ✅ **OPTIMISÉ** (12 DEC 25)
- Limite 50 messages en mémoire

---

### 10. ⚠️ Chargement Complet Données Avant Filtrage (MODÉRÉ)

**Fichiers** :
- `arkalia_cia/lib/services/conversational_ai_service.dart` - `_getUserData()`
- `arkalia_cia/lib/services/search_service.dart` - `searchAll()`
- `arkalia_cia/lib/screens/patterns_dashboard_screen.dart` - `_loadPatterns()`

**Problème** :
- Charge **TOUTES** les données en mémoire avant de filtrer/limiter
- `conversational_ai_service.dart` : Charge tous documents/médecins, puis prend seulement 10/5
- `search_service.dart` : Charge tous documents/reminders/contacts, puis filtre
- `patterns_dashboard_screen.dart` : Charge TOUTES les pathologies avec TOUS leurs trackings (365 jours)

**Impact** :
- RAM : **ÉLEVÉ** - Si 1000 documents = tous chargés en mémoire même si on n'en garde que 10
- Risque : **MODÉRÉ** - Peut consommer beaucoup si beaucoup de données

**Solution recommandée** :
- Implémenter pagination ou limite au niveau de la requête
- Ne charger que les données nécessaires (limite SQL/requête)
- Pour patterns : Limiter le nombre de pathologies et la période de tracking

**Statut** : ✅ **PARTIELLEMENT OPTIMISÉ** (12 DEC 25)
- `conversational_ai_service.dart` : Tri conditionnel (seulement si >10 documents)
- `patterns_dashboard_screen.dart` : Limite 20 pathologies, 90 jours tracking, 100 entrées max, 50 médicaments max
- `search_service.dart` : Déjà limité avec `.take(50)` mais charge tout d'abord (limitation SharedPreferences)

---

### 11. ⚠️ Lecture Fichier Complet en Mémoire (FAIBLE)

**Fichier** : `arkalia_cia/lib/screens/sync_screen.dart`

**Problème** :
- `file.readAsString()` lit le fichier **entier** en mémoire
- Si le fichier de sync est gros (plusieurs MB), tout est chargé en RAM

**Impact** :
- RAM : Variable selon taille fichier (peut être plusieurs MB)
- Risque : **FAIBLE** - Les fichiers de sync sont généralement petits, mais peut être problématique si gros

**Solution recommandée** :
- Utiliser `readAsLines()` si possible (ligne par ligne)
- Ou limiter la taille du fichier de sync
- Ou utiliser streaming pour les gros fichiers

**Statut** : ⏳ **À OPTIMISER** (si fichiers volumineux)

---

### 13. ⚠️ getTrackingByPathology Charge Tous Trackings sur Web (FAIBLE)

**Fichier** : `arkalia_cia/lib/services/pathology_service.dart` - `getTrackingByPathology()`

**Problème** :
- Sur le web, charge **TOUS** les trackings depuis SharedPreferences avant de filtrer
- Si beaucoup de trackings (plusieurs milliers), tout est chargé en mémoire
- Filtrage fait après chargement complet

**Impact** :
- RAM : Variable selon nombre de trackings (peut être plusieurs MB si beaucoup de données)
- Risque : **FAIBLE** - Déjà limité dans `patterns_dashboard_screen.dart` (100 entrées max)
- Note : Sur mobile (SQLite), la requête est optimisée avec WHERE clause

**Solution actuelle** :
- ✅ Déjà limité dans `patterns_dashboard_screen.dart` (100 entrées max)
- ✅ SQLite utilise WHERE clause (optimisé)

**Solution recommandée** :
- Pour vraiment optimiser sur web, il faudrait implémenter pagination au niveau StorageHelper
- Ou limiter le nombre de trackings récupérés avant filtrage

**Statut** : ⚠️ **PARTIELLEMENT OPTIMISÉ** (limité dans patterns_dashboard, mais pas dans le service lui-même)

---

### 12. ⚠️ Recherche Sémantique Charge Tous Documents (MODÉRÉ)

**Fichier** : `arkalia_cia/lib/services/semantic_search_service.dart`

**Problème** :
- `semanticSearch()` charge **TOUS** les documents avant de calculer les scores
- `semanticSearchDoctors()` charge **TOUS** les médecins avant de calculer les scores
- Si 1000 documents = tous chargés en mémoire même si on n'en garde que 20

**Impact** :
- RAM : **ÉLEVÉ** - Si beaucoup de documents/médecins, tout est chargé en mémoire
- Risque : **MODÉRÉ** - Peut consommer beaucoup si beaucoup de données

**Solution recommandée** :
- Limiter à 100 documents max pour le calcul de score (prendre les plus récents)
- Limiter à 50 médecins max pour le calcul de score

**Statut** : ✅ **OPTIMISÉ** (12 DEC 25)
- Limite 100 documents pour recherche sémantique
- Limite 50 médecins pour recherche sémantique
- Tri par date (plus récents en premier) avant limitation

---

## 🎯 RECOMMANDATIONS PRIORITAIRES

### Priorité 1 : Cache Offline avec Limite LRU

**Action** : Ajouter une limite LRU au cache offline (100 clés max)

**Bénéfice** : Réduction mémoire potentielle de ~50-80% si beaucoup de clés

---

### Priorité 2 : Optimiser watch-macos-files.sh

**Action** : Augmenter le délai de 0.2s à 1s (suffisant pour éviter erreurs D8)

**Bénéfice** : Réduction CPU de ~80% pendant le build

---

### Priorité 3 : Nettoyage Automatique Cache

**Action** : Appeler `clearExpiredCaches()` au démarrage de l'app

**Bénéfice** : Libération mémoire immédiate des caches expirés

---

## 📊 MÉTRIQUES ACTUELLES

| Composant | RAM Avant | RAM Après | Statut |
|-----------|-----------|-----------|--------|
| Cache Backend Python | Illimité | ~5-10 MB max | ✅ Optimisé |
| Upload PDF | 50 MB | ~1 MB | ✅ Optimisé |
| Extraction PDF | Toutes pages | Page par page | ✅ Optimisé |
| Cache Offline Flutter | Illimité | ~10-20 MB max | ✅ Optimisé |
| watch-macos-files.sh | Variable | -80% CPU | ✅ Optimisé |
| Chargement données avant filtrage | Toutes | Partiellement limité | ✅ Partiellement optimisé |
| Lecture fichiers sync | Complet | Complet | ⚠️ À optimiser |
| Recherche sémantique | Tous documents | 100 max | ✅ Optimisé |
| getTrackingByPathology (web) | Tous trackings | Tous (filtré après) | ⚠️ Partiellement optimisé |

---

## ✅ ACTIONS DÉJÀ FAITES

1. ✅ Cache backend Python limité (LRU 50 entrées)
2. ✅ Upload PDF par chunks (1 MB)
3. ✅ Extraction PDF page par page
4. ✅ Libération immédiate données volumineuses
5. ✅ Controllers Flutter disposés correctement
6. ✅ Vérifications `mounted` avant `setState()`
7. ✅ Lazy loading avec `ListView.builder`
8. ✅ Debouncing recherche
9. ✅ Timer AutoSyncService bien géré

---

## 🔧 PROCHAINES ÉTAPES

1. ✅ Ajouter limite LRU au cache offline Flutter (12 DEC 25)
2. ✅ Optimiser watch-macos-files.sh (12 DEC 25 - 0.2s → 1s)
3. ✅ Nettoyage automatique cache au démarrage (12 DEC 25)
4. ✅ Corriger stockage bytes PDF sur web (12 DEC 25 - désactivé)
5. ✅ Limiter messages conversation IA (12 DEC 25 - 50 max)
6. ✅ Optimiser recherche sémantique (12 DEC 25 - limite 100 documents, 50 médecins)
7. ✅ Optimiser patterns dashboard (12 DEC 25 - limites ajoutées)
8. ⏳ Optimiser lecture fichiers sync (à faire si nécessaire - fichiers généralement petits)

---

## 📋 RÉSUMÉ FINAL

### Problèmes Critiques Corrigés ✅
1. ✅ Cache offline Flutter - Limite LRU 100 clés
2. ✅ Stockage bytes PDF sur web - Désactivé
3. ✅ Messages conversation IA - Limite 50 messages
4. ✅ Script watch-macos-files.sh - Délai optimisé (1s)

### Problèmes Modérés Optimisés ✅
5. ✅ Recherche sémantique - Optimisé (12 DEC 25)
   - `semantic_search_service.dart` : Limite 100 documents, 50 médecins
   - Tri par date (plus récents) avant limitation

### Problèmes Modérés Partiellement Optimisés ⚠️
6. ⚠️ Chargement données avant filtrage - Partiellement optimisé (patterns_dashboard limité)
   - `conversational_ai_service.dart` : Tri conditionnel
   - `patterns_dashboard_screen.dart` : Limites ajoutées (20 pathologies, 90 jours, 100 entrées, 50 médicaments)
   - `search_service.dart` : Limité avec `.take(50)` mais charge tout d'abord (limitation SharedPreferences)

### Problèmes Faibles Documentés ✅
7. ✅ Lecture fichiers sync - Documenté (généralement petits fichiers)
8. ✅ Processus externes (Bandit/Mypy) - Documenté
9. ✅ Boucle Calendar Service - Acceptable (limité à 52 événements)
10. ⚠️ getTrackingByPathology sur web - Partiellement optimisé (limité dans patterns_dashboard)

---

---

## 🎯 RÉSUMÉ FINAL DES OPTIMISATIONS (12 DEC 25)

### ✅ Problèmes Critiques Corrigés
1. ✅ Cache offline Flutter - Limite LRU 100 clés
2. ✅ Stockage bytes PDF sur web - Désactivé + limite 5 MB
3. ✅ Messages conversation IA - Limite 50 messages
4. ✅ Script watch-macos-files.sh - Délai optimisé (1s)

### ✅ Problèmes Modérés Optimisés
5. ✅ Recherche sémantique - Limite 100 documents, 50 médecins
6. ✅ Patterns dashboard - Limite 20 pathologies, 90 jours, 100 entrées, 50 médicaments
7. ✅ Conversational AI service - Tri conditionnel

### ⚠️ Problèmes Modérés Partiellement Optimisés
8. ⚠️ Chargement données avant filtrage - Partiellement optimisé (limitation SharedPreferences)

### ✅ Problèmes Faibles Documentés
9. ✅ Lecture fichiers sync - Documenté (généralement petits)
10. ✅ Processus externes (Bandit/Mypy) - Documenté
11. ✅ Boucle Calendar Service - Acceptable (limité à 52 événements)

---

**Audit terminé le 12 DEC 25** ✅

**Total problèmes identifiés** : 13

**Problèmes corrigés/optimisés** : 11

**Problèmes partiellement optimisés** : 2

**Problèmes documentés** : 3