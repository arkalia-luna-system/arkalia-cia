# 📋 TODO - CORRECTIONS AUDIT COMPLET

**Date création** : 27 novembre 2025  
**Basé sur** : `AUDIT_COMPLET_PROJET_2025.md`  
**Statut global** : 🔄 En cours

---

## ✅ DÉJÀ FAIT

### 🔴 URGENT - Complété
- [x] **Remplacer `print()` par `AppLogger` dans `error_helper.dart`** ✅
- [x] **Remplacer `print()` par `AppLogger` dans `main.dart`** ✅

---

## 🔴 URGENT (À faire maintenant - 1-2 heures)

### 1. Nettoyer le code mort et commentaires obsolètes

**Fichiers à nettoyer** :
- [ ] `arkalia_cia/lib/screens/reminders_screen.dart` ligne 153
  - Commentaire : `// sur value deprecated`
  - **Action** : Supprimer ou documenter clairement
  
- [ ] `arkalia_cia/lib/screens/patterns_dashboard_screen.dart` ligne 152
  - Code : `// ignore: unused_element`
  - **Action** : Vérifier si l'élément est vraiment inutilisé, sinon supprimer l'ignore

**Temps estimé** : 30 minutes

---

### 2. Vérifier et nettoyer les TODOs non documentés

**À faire** :
- [ ] Scanner tous les fichiers Dart pour trouver les TODOs
- [ ] Vérifier s'ils sont documentés dans `TODOS_DOCUMENTES.md`
- [ ] Documenter ceux qui ne le sont pas
- [ ] Supprimer ceux qui sont obsolètes

**Temps estimé** : 30 minutes

---

### 3. Nettoyer les scripts obsolètes

**Fichier** :
- [ ] `scripts/cleanup_memory.sh`
  - **Action** : Supprimer le script (il redirige vers `cleanup_all.sh`)
  - **Alternative** : Documenter clairement qu'il est obsolète

**Temps estimé** : 5 minutes

---

## 🟠 IMPORTANT (Cette semaine - 1-2 semaines)

### 4. Documenter les dépendances optionnelles

**Fichier** :
- [ ] `arkalia_cia_python_backend/security_dashboard.py`
  - **Action** : Documenter clairement que `athalia_core` est optionnel
  - **Action** : Ajouter un fallback clair si les dépendances sont absentes
  - **Action** : Documenter dans le README les dépendances optionnelles

**Temps estimé** : 1 heure

---

### 5. Vérifier la duplication de logique de recherche

**Services à analyser** :
- [ ] `arkalia_cia/lib/services/search_service.dart`
- [ ] `arkalia_cia/lib/services/semantic_search_service.dart`

**Actions** :
- [ ] Analyser les deux services pour identifier les duplications
- [ ] Fusionner si possible ou documenter pourquoi ils sont séparés
- [ ] Créer un diagramme de responsabilités

**Temps estimé** : 2-3 heures

---

### 6. Documenter les responsabilités des services

**Services à documenter** :
- [ ] `LocalStorageService` vs `StorageHelper` vs `FileStorageService`
- [ ] Tous les autres services (20+ services)

**Actions** :
- [ ] Créer un document `docs/ARCHITECTURE_SERVICES.md`
- [ ] Documenter les responsabilités de chaque service
- [ ] Identifier les chevauchements et les justifier ou les corriger

**Temps estimé** : 3-4 heures

---

### 7. Utiliser `ErrorHelper` partout

**Actions** :
- [ ] Scanner tous les fichiers pour trouver les `try/catch` avec messages hardcodés
- [ ] Remplacer par `ErrorHelper.getUserFriendlyMessage()`
- [ ] Utiliser `ErrorHelper.logError()` pour le logging

**Temps estimé** : 2-3 heures

---

## 🟡 IMPORTANT - FONCTIONNALITÉS (2-3 semaines)

### 8. Compléter l'intégration Portails Santé ⚠️ CRITIQUE

**Statut actuel** : 3% seulement (structure OAuth mais parsing réel manquant)

**Fichiers concernés** :
- `arkalia_cia/lib/screens/onboarding/import_choice_screen.dart`
- `arkalia_cia/lib/screens/onboarding/import_progress_screen.dart`
- `arkalia_cia/lib/services/health_portal_auth_service.dart`
- `arkalia_cia_python_backend/api.py` (endpoint `/api/v1/health-portals/import`)

**Actions** :
- [ ] Documenter les APIs des portails santé belges (eHealth, Andaman 7, MaSanté)
- [ ] Implémenter le parsing réel des données depuis les APIs
- [ ] Tester avec les APIs réelles (ou mocks si pas d'accès)
- [ ] Gérer les erreurs et cas limites
- [ ] Ajouter des tests unitaires

**Temps estimé** : 2-3 semaines

**Priorité** : 🔴 **CRITIQUE** - Fonctionnalité promise aux utilisateurs

---

### 9. Améliorer l'exploitation ARIA

**Statut actuel** : 40% (structure existe mais sync limitée)

**Actions** :
- [ ] Enrichir la sync CIA ↔ ARIA
  - [ ] Synchroniser plus de données ARIA (métriques santé, patterns détaillés)
  - [ ] Améliorer la fréquence de sync
  - [ ] Gérer les conflits de données
  
- [ ] Utiliser plus de données ARIA dans l'IA conversationnelle
  - [ ] Intégrer les patterns ARIA dans les réponses
  - [ ] Utiliser les métriques santé pour le contexte
  - [ ] Améliorer les suggestions basées sur ARIA

**Temps estimé** : 1 semaine

---

### 10. Améliorer l'UI Recherche Avancée

**Statut actuel** : 50% (fonctionnelle mais UI pas intuitive)

**Fichier** : `arkalia_cia/lib/screens/advanced_search_screen.dart`

**Actions** :
- [ ] Rendre l'interface plus intuitive
  - [ ] Ajouter des exemples de recherche
  - [ ] Améliorer les labels et descriptions
  - [ ] Ajouter des tooltips d'aide
  
- [ ] Améliorer l'UX
  - [ ] Ajouter des suggestions de recherche
  - [ ] Historique de recherches
  - [ ] Recherche rapide depuis la barre de recherche principale

**Temps estimé** : 3-4 jours

---

## 🟢 SOUHAITABLE (Ce mois - 1-2 semaines)

### 11. Ajouter notifications push pour Partage Familial

**Statut actuel** : 40% (implémenté mais pas de notifications)

**Actions** :
- [ ] Implémenter les notifications push
  - [ ] Notifier les membres famille des nouveaux partages
  - [ ] Notifier les modifications de permissions
  - [ ] Gérer les préférences de notification par membre
  
- [ ] Tester les notifications
  - [ ] Tests unitaires
  - [ ] Tests d'intégration
  - [ ] Tests sur différents appareils

**Temps estimé** : 2-3 jours

---

### 12. Enrichir les visualisations IA Patterns

**Statut actuel** : 60% (détection fonctionne mais visualisations limitées)

**Fichier** : `arkalia_cia/lib/screens/patterns_dashboard_screen.dart`

**Actions** :
- [ ] Graphiques plus détaillés
  - [ ] Graphiques interactifs
  - [ ] Zoom et filtres temporels
  - [ ] Comparaisons multi-périodes
  
- [ ] Export PDF des patterns
  - [ ] Générer des rapports PDF avec les patterns
  - [ ] Inclure les graphiques et analyses
  - [ ] Partage des rapports

**Temps estimé** : 1 semaine

---

### 13. Dashboard Analytics

**Statut actuel** : 0% (pas de dashboard)

**Actions** :
- [ ] Créer un dashboard analytics
  - [ ] Métriques d'usage (documents ajoutés, recherches, etc.)
  - [ ] Métriques de performance (temps de chargement, etc.)
  - [ ] Graphiques d'évolution
  
- [ ] Intégrer dans l'app
  - [ ] Écran dédié ou widget dans home
  - [ ] Export des métriques
  - [ ] Partage avec développeurs (optionnel)

**Temps estimé** : 1 semaine

---

### 14. Améliorer l'exploitation Pathologies

**Statut actuel** : 70% (templates peu utilisés, graphiques basiques)

**Actions** :
- [ ] Améliorer les graphiques
  - [ ] Graphiques plus détaillés par pathologie
  - [ ] Comparaisons entre pathologies
  - [ ] Export des graphiques
  
- [ ] Enrichir les templates
  - [ ] Ajouter plus de templates
  - [ ] Personnalisation des templates
  - [ ] Suggestions basées sur les templates

**Temps estimé** : 3-4 jours

---

### 15. Améliorer l'exploitation IA Conversationnelle

**Statut actuel** : 65% (fonctionne mais pas assez de patterns ARIA)

**Actions** :
- [ ] Intégrer plus de patterns ARIA
  - [ ] Utiliser les patterns détectés dans les réponses
  - [ ] Suggestions basées sur les patterns
  - [ ] Contexte enrichi avec ARIA
  
- [ ] Améliorer les suggestions
  - [ ] Suggestions plus pertinentes
  - [ ] Apprentissage des préférences utilisateur
  - [ ] Personnalisation des réponses

**Temps estimé** : 1 semaine

---

## 📊 RÉSUMÉ PAR PRIORITÉ

### 🔴 URGENT (1-2 heures)
- Nettoyer code mort
- Nettoyer TODOs
- Nettoyer scripts obsolètes

### 🟠 IMPORTANT - TECHNIQUE (1 semaine)
- Documenter dépendances optionnelles
- Vérifier duplication recherche
- Documenter services
- Utiliser ErrorHelper partout

### 🟠 IMPORTANT - FONCTIONNALITÉS (2-3 semaines)
- Compléter Portails Santé (CRITIQUE)
- Améliorer ARIA
- Améliorer UI Recherche

### 🟢 SOUHAITABLE (1-2 semaines)
- Notifications Partage Familial
- Visualisations IA Patterns
- Dashboard Analytics
- Améliorer Pathologies
- Améliorer IA Conversationnelle

---

## 📈 ESTIMATION TOTALE

| Priorité | Temps estimé |
|----------|--------------|
| 🔴 URGENT | 1-2 heures |
| 🟠 IMPORTANT - TECHNIQUE | 1 semaine |
| 🟠 IMPORTANT - FONCTIONNALITÉS | 2-3 semaines |
| 🟢 SOUHAITABLE | 1-2 semaines |
| **TOTAL** | **4-6 semaines** |

---

## 🎯 PROCHAINES ÉTAPES

1. **Commencer par l'URGENT** (1-2 heures)
   - Nettoyer le code mort
   - Nettoyer les TODOs
   - Nettoyer les scripts

2. **Puis l'IMPORTANT TECHNIQUE** (1 semaine)
   - Documenter les services
   - Utiliser ErrorHelper partout

3. **Ensuite l'IMPORTANT FONCTIONNALITÉS** (2-3 semaines)
   - Compléter Portails Santé (CRITIQUE)
   - Améliorer ARIA et Recherche

4. **Enfin le SOUHAITABLE** (1-2 semaines)
   - Améliorer les fonctionnalités existantes

---

**Dernière mise à jour** : 27 novembre 2025

