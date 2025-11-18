# Solution aux Doublons pytest

**Voir**: [AUDIT_ET_OPTIMISATIONS.md](AUDIT_ET_OPTIMISATIONS.md) pour la documentation complète.

## 🔴 Problème Identifié

Quand pytest est lancé une fois, il crée des processus qui ne se terminent pas correctement, empêchant de relancer pytest car il détecte des doublons et consomme beaucoup de RAM.

## ✅ Solution Principale

**Script `run_tests.sh`** qui nettoie automatiquement tous les processus pytest avant de lancer.

**Utilisation :**
```bash
./run_tests.sh              # Lancer tous les tests
./run_tests.sh tests/unit/test_security_dashboard.py -v  # Test spécifique
make test                   # Via Makefile
```

## ⚠️ RÈGLE IMPORTANTE

**TOUJOURS utiliser `./run_tests.sh` ou `make test` au lieu de `pytest` directement** pour éviter les problèmes de doublons.

