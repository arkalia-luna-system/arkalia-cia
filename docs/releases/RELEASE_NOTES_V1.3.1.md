# Release Notes — Arkalia CIA v1.3.1

**Date de release** : 12 décembre 2025  
**Version** : 1.3.1+6  
**Statut** : Production-Ready ✅

---

## Résumé

Cette version apporte des améliorations majeures de la qualité du code, de la stabilité du CI/CD, et de la documentation. Tous les warnings Flutter ont été corrigés, le pipeline CI/CD a été refactorisé en 3 phases robustes, et la documentation a été complètement réorganisée.

---

## Nouvelles fonctionnalités

### Tests supplémentaires
- **Tests ThemeService** : 7 tests pour la gestion des thèmes (clair/sombre/système)
- **Tests BackendConfigService** : 5 tests pour la configuration backend
- **Tests CategoryService** : 8 tests pour la gestion des catégories de documents
- **Tests PDF améliorés** : Amélioration des tests d'extraction de métadonnées PDF

---

## Améliorations

### CI/CD et Build
- ✅ **CI/CD refactorisé en 3 phases séparées** : Configuration flutter.source, Nettoyage macOS, Build APK
- ✅ **Configuration flutter.source robuste** : init.gradle, settings.gradle.kts, build.gradle.kts
- ✅ **Nettoyage automatique fichiers macOS** : Suppression `._*` et `.DS_Store` avant build
- ✅ **Vérification permissions gradlew** : Permissions d'exécution vérifiées automatiquement
- ✅ **local.properties retiré du suivi Git** : Fichier local ne doit pas être versionné
- ✅ **Scripts CI améliorés** : Compatibilité macOS/Linux, fallback gradlew direct

### Qualité code
- ✅ **0 erreur lint Flutter** : `flutter analyze` passe sans erreur
- ✅ **0 erreur lint Python** : `ruff check` et `mypy` passent sans erreur
- ✅ **Warnings Flutter corrigés** :
  - `withOpacity` → `withValues(alpha: ...)`
  - `Share.share` → `SharePlus.instance.share(ShareParams(...))`
  - `Color.blue` → `Colors.blue`
- ✅ **BuildContext across async gaps** : Correction dans `settings_screen.dart`
- ✅ **Tests widget corrigés** : `widget_test.dart` utilise `pump()` avec timeout

### Documentation
- ✅ **Organisation complète** : Documentation réorganisée en sous-dossiers (guides/, deployment/, audits/, etc.)
- ✅ **Toutes les dates mises à jour** : 69 fichiers MD synchronisés à 27 novembre 2025
- ✅ **Liens corrigés** : Tous les liens internes mis à jour après réorganisation
- ✅ **Fichiers redondants archivés** : Nettoyage et archivage des fichiers obsolètes
- ✅ **README.md créé** : Index principal de la documentation dans `docs/`

### Tests
- ✅ **Tests Flutter** : 19 tests créés (ThemeService, BackendConfigService, CategoryService, OnboardingService, AuthService)
- ✅ **Tests PDF améliorés** : Amélioration de la couverture des tests d'extraction
- ✅ **352 tests Python passent** (70.83% coverage)

---

## Corrections

### Build et CI/CD
- ✅ Correction configuration `flutter.source` dans app/build.gradle.kts
- ✅ Correction scripts CI pour compatibilité macOS/Linux
- ✅ Correction indentation dans script Phase 1
- ✅ Ajout fallback gradlew direct si flutter build échoue
- ✅ Amélioration gestion permissions gradlew

### Code Flutter
- ✅ Correction `withOpacity` deprecated → `withValues(alpha: ...)`
- ✅ Correction `Share.share` → `SharePlus.instance.share(ShareParams(...))`
- ✅ Correction `Color.blue` → `Colors.blue`
- ✅ Correction BuildContext across async gaps dans `settings_screen.dart`
- ✅ Correction tests widget avec timeout approprié

### Audit et qualité
- ✅ **Logging vérifié** : Tous les fichiers utilisent `AppLogger` (pas de `print()` en production)
- ✅ **Code mort nettoyé** : Commentaires obsolètes corrigés
- ✅ **Imports optimisés** : Import unused supprimé dans `documents_screen.dart`
- ✅ **Commentaires améliorés** : Clarté améliorée pour maintenance future

---

## Métriques

| Métrique | Valeur |
|----------|--------|
| **Tests Python** | 352 passed (70.83% coverage) |
| **Tests Flutter** | 19 tests créés |
| **Erreurs Flutter lint** | 0 ✅ |
| **Erreurs Python lint** | 0 ✅ |
| **Warnings Flutter** | 0 ✅ |
| **Statut Production** | 100% Ready ✅ |

---

## Organisation Documentation

### Nouvelle structure
```
docs/
├── analysis/          # Analyses et besoins
├── audits/            # Audits et rapports
├── deployment/        # Guides de déploiement
├── guides/            # Guides utilisateur
├── integrations/      # Intégrations (ARIA, portails santé)
├── meta/              # Métadonnées et vérifications
├── optimizations/    # Optimisations
├── plans/             # Plans d'implémentation
├── releases/          # Notes de release
├── status/            # Statuts et versions
└── troubleshooting/   # Dépannage
```

### Fichiers archivés
- Fichiers redondants avec dates anciennes
- Anciens audits consolidés
- Fichiers de corrections obsolètes

---

## Migration

Aucune migration nécessaire. Cette version est rétrocompatible avec v1.3.0.

**Recommandations** :
- Mettre à jour Flutter vers 3.24.0+ si nécessaire
- Vérifier que les permissions gradlew sont correctes
- Nettoyer les fichiers macOS si présents (`._*`, `.DS_Store`)

---

## Voir aussi

- **[CHANGELOG.md](../CHANGELOG.md)** — Historique complet des changements
- **[plans/STATUT_COMPLET_27_DECEMBRE_2025.md](../plans/STATUT_COMPLET_27_DECEMBRE_2025.md)** — Statut complet consolidé
- **[INSTRUCTIONS_RELEASE_V1.3.1.md](../deployment/INSTRUCTIONS_RELEASE_V1.3.1.md)** — Instructions de release
- **[TODO_RESTANT_1.3.1.md](../meta/TODO_RESTANT_1.3.1.md)** — TODOs restants

---

*Release préparée le 27 novembre 2025*

