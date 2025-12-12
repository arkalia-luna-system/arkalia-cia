# CE QUI RESTE À FAIRE POUR CIA - 12 Décembre 2025

**Date** : 12 décembre 2025  
**Version** : 1.3.1+6  
**Statut** : 14/20 problèmes résolus (70%)

---

## IMPORTANT - ARIA est séparé

ARIA n'est pas développé dans ce projet :
- CIA : Ce projet (`arkalia-cia`) - Assistant santé généraliste
- ARIA : Projet séparé (`arkalia-aria`) - Laboratoire personnel douleur/mental
- Communication : Via API HTTP (CIA ↔ ARIA)
- Déploiement ARIA : Sur Render.com (voir `docs/deployment/DEPLOIEMENT_ARIA_RENDER.md`)

Ne pas développer ARIA ici - Utiliser le projet ARIA séparé.

---

## RÉSUMÉ

**Problèmes résolus** : 14/20 (70%)  
**Problèmes restants** : 5/20 (25%) - ARIA géré dans projet séparé

- **Critiques** : 6/8 résolus (1 restant : Profil multi-appareil - fonctionnalité future)
- **Élevés** : 7/7 résolus (100%)
- **Moyens** : 1/5 résolus (4 restants)

Note : ARIA serveur est géré dans le projet ARIA séparé, pas dans CIA.

---

## PROBLÈMES CRITIQUES RESTANTS (1)

### Profil multi-appareil

**Problème** : Impossible de passer mobile → ordi avec synchronisation

**Statut** : Fonctionnalité future complexe (10-16 jours de développement), pas un bug bloquant

**Ce qui reste à faire** :
- Créer système profil utilisateur + sync E2E
- Architecture complète à créer (modèles UserProfile, Device, services sync)
- Nécessite backend avec authentification multi-appareil
- Chiffrement E2E pour synchronisation sécurisée

**Priorité** : Fonctionnalité future (non-bloquant pour usage actuel)

**Voir** : [AUDIT_COMPLET_12_DECEMBRE_2025.md](./AUDIT_COMPLET_12_DECEMBRE_2025.md#2-pas-de-profil-utilisateur-multi-appareil)

---

## PROBLÈMES ÉLEVÉS RESTANTS (0)

Tous les problèmes élevés ont été résolus.

---

## PROBLÈMES MOYENS RESTANTS (5)

### Médecins - Détection auto

**Problème** : Pas de proposition auto ajout médecin après upload PDF

**Ce qui reste à faire** :
1. Détecter nom médecin dans PDF uploadé
2. Dialog proposition après détection
3. Permettre ajout rapide depuis dialog

**Fichiers à modifier** :
- `arkalia_cia/lib/services/document_service.dart` : Détection médecin
- `arkalia_cia/lib/screens/documents_screen.dart` : Dialog proposition

**Priorité** : Moyenne

**Voir** : [AUDIT_COMPLET_12_DECEMBRE_2025.md](./AUDIT_COMPLET_12_DECEMBRE_2025.md#16-médecins---détection-auto-depuis-documents)

---

### Patterns - Erreur non spécifiée

**Problème** : "Une erreur est survenue" sans détails

**Ce qui reste à faire** :
1. Améliorer gestion erreurs dans `pattern_analyzer.py`
2. Messages d'erreur clairs et spécifiques
3. Logging détaillé pour debugging
4. Fallback gracieux si analyse échoue

**Fichiers à modifier** :
- `arkalia_cia_python_backend/ai/pattern_analyzer.py` : Gestion erreurs
- `arkalia_cia/lib/screens/patterns_screen.dart` : Affichage erreurs

**Priorité** : Moyenne

**Voir** : [AUDIT_COMPLET_12_DECEMBRE_2025.md](./AUDIT_COMPLET_12_DECEMBRE_2025.md#17-patterns---erreur-une-erreur-est-survenue)

---

### Statistiques - Placement UI

**Problème** : Trop visible ou pas assez selon contexte

**Ce qui reste à faire** :
1. Déplacer statistiques détaillées en paramètres
2. Garder indicateurs simples sur écrans principaux
3. Section "Statistiques" dans paramètres avec graphiques

**Fichiers à modifier** :
- `arkalia_cia/lib/screens/settings_screen.dart` : Ajouter section statistiques
- `arkalia_cia/lib/screens/home_page.dart` : Simplifier indicateurs

**Priorité** : Moyenne

**Voir** : [AUDIT_COMPLET_12_DECEMBRE_2025.md](./AUDIT_COMPLET_12_DECEMBRE_2025.md#18-statistiques---placement-dans-ui)

---

### Dialog partage - Pas de feedback

**Problème** : Pas de confirmation visuelle après partage

**Ce qui reste à faire** :
1. SnackBar avec confirmation après partage
2. Indicateur visuel (icône check) pendant partage
3. Compteur documents partagés

**Fichiers à modifier** :
- `arkalia_cia/lib/screens/family_sharing_screen.dart` : Améliorer feedback

**Priorité** : Moyenne

**Voir** : [AUDIT_COMPLET_12_DECEMBRE_2025.md](./AUDIT_COMPLET_12_DECEMBRE_2025.md#19-dialog-partage---pas-de-feedback)

---

### BBIA - Placeholder uniquement

**Problème** : BBIA est juste un placeholder, pas d'intégration réelle

**Statut** : Fonctionnalité future (Phase 4), pas prioritaire

**Ce qui reste à faire** :
- Intégration complète BBIA (robot compagnon cognitif)
- Communication CIA ↔ BBIA
- Interface émotionnelle robotique

**Priorité** : Fonctionnalité future (Phase 4)

**Voir** : [AUDIT_COMPLET_12_DECEMBRE_2025.md](./AUDIT_COMPLET_12_DECEMBRE_2025.md#20-bbia---placeholder-uniquement)

---

## RÉCAPITULATIF PAR PRIORITÉ

### Critique (1)
1. Profil multi-appareil - Fonctionnalité future (10-16 jours)

Note : ARIA serveur est géré dans le projet ARIA séparé, pas dans CIA.

### Élevé (0)
Tous les problèmes élevés ont été résolus.

### Moyen (4)
1. Patterns - Erreur non spécifiée
2. Statistiques - Placement UI
3. Dialog partage - Feedback
4. BBIA - Placeholder (futur)

---

## RECOMMANDATIONS

### Priorité immédiate
1. Patterns - Erreur non spécifiée (1 jour)

### Après
2. Statistiques - Placement UI (1 jour)
3. Dialog partage - Feedback (1 jour)

### Futur
5. Profil multi-appareil (10-16 jours) - Fonctionnalité majeure
6. BBIA (Phase 4) - Fonctionnalité future

---

## CE QUI EST DÉJÀ FAIT

### Critiques résolus (6/8)
- Biométrie
- Permissions PDF
- Page connexion/inscription
- Partage famille
- Calendrier rappels
- Bug connexion après création compte

### Élevés résolus (7/7)
- Rappels modifiables
- Couleurs pathologie
- Hydratation bugs visuels
- Paramètres accessibilité
- Portails santé épinglage
- Contacts urgence personnalisation
- Pathologies sous-catégories (12 décembre 2025)

### Moyens résolus (1/5)
- Médecins - Détection auto (12 décembre 2025)

### Documentation créée
- Guide déploiement ARIA (Render.com)
- Explication GitHub Pages vs Render.com
- Prompt audit ARIA complet

---

**Dernière mise à jour** : 12 décembre 2025  
**Prochaine étape recommandée** : Patterns - Erreur non spécifiée (1 jour)

Note : ARIA serveur est géré dans le projet ARIA séparé. Ce document liste uniquement les problèmes à résoudre dans le projet CIA.

