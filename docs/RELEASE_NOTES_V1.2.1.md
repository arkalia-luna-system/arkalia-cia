# Release Notes — Arkalia CIA v1.2.1

**Date de release** : 26 novembre 2025  
**Version** : 1.2.1  
**Statut** : Production-Ready (100%)

---

## Résumé

Cette version apporte des améliorations finales avec l'implémentation de fonctionnalités manquantes et la correction de tous les problèmes de lint.

---

## Nouvelles fonctionnalités

### Recherche avancée améliorée
- **Sélection médecin** : Filtre par médecin dans la recherche avancée avec dialog de sélection
- **Support doctorId** : Intégration complète du filtre médecin dans `SearchFilters` et `SearchService`

### Portails santé améliorés
- **Refresh token automatique** : Gestion automatique du rafraîchissement des tokens OAuth
- **Méthode `getValidAccessToken()`** : Vérification et refresh automatique des tokens
- **Stockage sécurisé** : Refresh tokens stockés dans SharedPreferences

---

## Améliorations

### Tests
- **508 tests Python passent** (71.98% coverage)
- **Suite complète security_utils** : 37 tests pour les utilitaires de sécurité
- **Correction test XSS** : Test de sanitization HTML corrigé

### Qualité code
- **0 erreur Flutter lint** ✅
- **0 erreur Python lint** ✅
- **Corrections type** : `CardTheme` → `CardThemeData`, `int?` → `int`
- **Variables non utilisées** : Toutes corrigées

### Documentation
- **Tous les fichiers MD mis à jour** avec statut final (26 novembre 2025)
- **CHANGELOG.md** : Ajout section v1.2.1
- **README.md** : Statut mis à jour (100% Production-Ready)
- **INDEX_DOCUMENTATION.md** : Date de mise à jour

---

## Corrections

### Lint
- ✅ Correction `CardTheme` → `CardThemeData` dans `theme_service.dart`
- ✅ Correction type `int?` → `int` dans `advanced_search_screen.dart`
- ✅ Correction variable non utilisée dans `health_portal_auth_service.dart`
- ✅ Correction tests `security_utils` (suppression None, correction test XSS)

### Tests
- ✅ 508 tests Python passent (71.98% coverage)
- ✅ Tous les tests auth passent
- ✅ Tous les tests security_utils passent

---

## Métriques

| Métrique | Valeur |
|----------|--------|
| **Tests** | 508 passed (Python) |
| **Coverage** | 71.98% (Python) |
| **Erreurs Flutter lint** | 0 |
| **Erreurs Python lint** | 0 |
| **Statut Production** | 100% Ready |

---

## Migration

Aucune migration nécessaire. Cette version est rétrocompatible avec v1.2.0.

---

## Voir aussi

- **[CHANGELOG.md](./CHANGELOG.md)** — Historique complet des changements
- **[STATUT_FINAL_CONSOLIDE.md](./STATUT_FINAL_CONSOLIDE.md)** — Statut final consolidé
- **[TODOS_DOCUMENTES.md](./TODOS_DOCUMENTES.md)** — TODOs documentés

---

*Release préparée le 26 novembre 2025*

