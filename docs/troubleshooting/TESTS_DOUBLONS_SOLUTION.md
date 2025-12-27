# Solution aux doublons pytest

**Version** : 1.0.0  
**Date** : 19 novembre 2025  
**Statut** : ✅ Résolu

---

## Vue d'ensemble

Ce document décrit la solution au problème des doublons pytest qui empêchent de relancer les tests.

---

## Problème identifié

Quand pytest est lancé une fois, il crée des processus qui ne se terminent pas correctement, empêchant de relancer pytest car il détecte des doublons et consomme beaucoup de RAM.

---

## Solution principale

**Script `run_tests.sh`** qui nettoie automatiquement tous les processus pytest avant de lancer.

**Utilisation :**

```bash
./run_tests.sh              # Lancer tous les tests
./run_tests.sh tests/unit/test_security_dashboard.py -v  # Test spécifique
make test                   # Via Makefile
```

---

## Règle importante

**TOUJOURS utiliser `./run_tests.sh` ou `make test` au lieu de `pytest` directement** pour éviter les problèmes de doublons.

---

## Voir aussi

- [audits/AUDIT_ET_OPTIMISATIONS.md](../audits/AUDIT_ET_OPTIMISATIONS.md) - Documentation complète de l'audit et des optimisations
- [troubleshooting/TESTS_PROBLEMATIQUES.md](troubleshooting/TESTS_PROBLEMATIQUES.md) - Tests problématiques
-  - Optimisations des tests
- [INDEX_DOCUMENTATION.md](../INDEX_DOCUMENTATION.md) - Index de la documentation

---

