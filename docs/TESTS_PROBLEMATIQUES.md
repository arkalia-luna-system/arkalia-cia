# Tests Problématiques - Analyse Manuelle

## 🔴 Tests qui consomment trop de mémoire ou bouclent

### 1. `test_auto_documenter.py` - Tests qui scannent tout le projet

**Problèmes identifiés :**
- `test_scan_project_structure()` - Scanne tout le répertoire temporaire
- `test_analyze_python_files()` - Analyse tous les fichiers Python
- `test_perform_full_documentation()` - Documentation complète du projet
- `test_document_project()` - Documente tout le projet

**Impact :** Ces tests peuvent scanner des milliers de fichiers et consommer beaucoup de RAM.

### 2. `test_security_dashboard.py` - Tests qui déclenchent des scans complets

**Problèmes identifiés :**
- `test_collect_security_data()` - Déclenche un scan de sécurité complet avec Athalia
- `test_generate_security_dashboard()` - Génère un dashboard complet avec scan
- `test_collect_security_data_with_athalia_components()` - Initialise tous les composants Athalia

**Impact :** Ces tests peuvent déclencher des scans bandit/radon qui consomment beaucoup de CPU/RAM.

### 3. Tests d'intégration - Boucles répétitives

**Problèmes identifiés :**
- `test_performance_under_load()` - Boucle de 100 itérations (acceptable mais peut être optimisé)
- `test_concurrent_operations_simulation()` - Crée plusieurs objets en mémoire

**Impact :** Moins grave mais peut accumuler de la mémoire.

## ✅ Solutions recommandées

1. **Mock les scans complets** dans les tests unitaires
2. **Limiter la portée** des scans aux répertoires de test uniquement
3. **Ajouter des timeouts** aux tests longs
4. **Nettoyer la mémoire** après chaque test avec `gc.collect()`
5. **Utiliser des fixtures** pytest pour éviter les duplications

