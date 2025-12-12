# 📋 CE QUI RESTE À FAIRE POUR CIA - 12 Décembre 2025

**Date** : 12 décembre 2025  
**Version** : 1.3.1+6  
**Statut** : 10/20 problèmes résolus (50%)

---

## ⚠️ IMPORTANT - ARIA est SÉPARÉ

**ARIA n'est PAS développé dans ce projet** :
- ✅ **CIA** : Ce projet (`arkalia-cia`) - Assistant santé généraliste
- ✅ **ARIA** : Projet séparé (`arkalia-aria`) - Laboratoire personnel douleur/mental
- ✅ **Communication** : Via API HTTP (CIA ↔ ARIA)
- ✅ **Déploiement ARIA** : Sur Render.com (voir `docs/deployment/DEPLOIEMENT_ARIA_RENDER.md`)

**⚠️ Ne pas développer ARIA ici** - Utiliser le projet ARIA séparé.

---

## 📊 RÉSUMÉ

**Problèmes résolus** : 10/20 (50%)  
**Problèmes restants** : 9/20 (45%) - **ARIA géré dans projet séparé**

- **Critiques** : 6/8 résolus (1 restant : Profil multi-appareil - fonctionnalité future)
- **Élevés** : 4/7 résolus (3 restants)
- **Moyens** : 0/5 résolus (5 restants)

**Note** : ARIA serveur est géré dans le projet ARIA séparé, pas dans CIA.

---

## 🔴 PROBLÈMES CRITIQUES RESTANTS (1)

### 1. Profil multi-appareil 🔴 **FONCTIONNALITÉ FUTURE**

**Problème** : Impossible de passer mobile → ordi avec synchronisation

**Statut** : Fonctionnalité future complexe (10-16 jours de développement), pas un bug bloquant

**Ce qui reste à faire** :
- Créer système profil utilisateur + sync E2E
- Architecture complète à créer (modèles UserProfile, Device, services sync)
- Nécessite backend avec authentification multi-appareil
- Chiffrement E2E pour synchronisation sécurisée

**Priorité** : 🔴 **FONCTIONNALITÉ FUTURE** (non-bloquant pour usage actuel)

**Voir** : [AUDIT_COMPLET_12_DECEMBRE_2025.md](./AUDIT_COMPLET_12_DECEMBRE_2025.md#2-pas-de-profil-utilisateur-multi-appareil)

---

## 🟠 PROBLÈMES ÉLEVÉS RESTANTS (3)

### 3. Portails santé - Pas d'épinglage 🟠 **ÉLEVÉE**

**Problème** : "On devrait pouvoir épingle pour ne voir que ceux que on voudrait"

**Ce qui reste à faire** :
1. Ajouter système favoris/épinglage portails
2. Filtrer affichage pour montrer seulement favoris
3. Intégration app : Détecter si app portail installée → proposer ouverture app
4. Sinon → ouvrir web comme actuellement

**Fichiers à modifier** :
- `arkalia_cia/lib/services/health_portal_auth_service.dart` : Ajouter favoris
- `arkalia_cia/lib/screens/health_portal_auth_screen.dart` : UI épinglage
- `arkalia_cia/lib/screens/health_portals_screen.dart` : Filtrer favoris

**Priorité** : 🟠 **ÉLEVÉE**

**Voir** : [AUDIT_COMPLET_12_DECEMBRE_2025.md](./AUDIT_COMPLET_12_DECEMBRE_2025.md#10-portails-santé---pas-dépinglage)

---

### 4. Contacts urgence - Personnalisation 🟠 **ÉLEVÉE**

**Problème** : "Que le contacte d'urgence soit plus perso"

**Ce qui reste à faire** :
1. Intégrer contacts téléphone (WhatsApp, SMS)
2. Permettre personnalisation : nom affiché, emoji, couleur
3. ONE-TAP calling + SMS
4. Proposer auto depuis contacts système

**Fichiers à modifier** :
- `arkalia_cia/lib/screens/emergency_screen.dart` : Améliorer UI
- `arkalia_cia/lib/services/contacts_service.dart` : Intégrer contacts téléphone
- `arkalia_cia/lib/models/emergency_contact.dart` : Ajouter personnalisation

**Priorité** : 🟠 **ÉLEVÉE**

**Voir** : [AUDIT_COMPLET_12_DECEMBRE_2025.md](./AUDIT_COMPLET_12_DECEMBRE_2025.md#13-contacts-urgence---pas-assez-personnalisable)

---

### 5. Pathologies - Sous-catégories 🟠 **ÉLEVÉE**

**Problème** : Pas de sous-catégories, organisation limitée

**Ce qui reste à faire** :
1. Système hiérarchique (catégorie → sous-catégorie → pathologie)
2. Choix couleur personnalisée (en plus des couleurs spécialités)
3. Organisation par spécialité médicale
4. Filtres avancés

**Fichiers à modifier** :
- `arkalia_cia/lib/models/pathology.dart` : Ajouter catégories
- `arkalia_cia/lib/services/pathology_service.dart` : Gestion hiérarchie
- `arkalia_cia/lib/screens/pathologies_screen.dart` : UI catégories

**Priorité** : 🟠 **ÉLEVÉE**

**Voir** : [AUDIT_COMPLET_12_DECEMBRE_2025.md](./AUDIT_COMPLET_12_DECEMBRE_2025.md#15-pathologies---manque-sous-catégories)

---

## 🟡 PROBLÈMES MOYENS RESTANTS (5)

### 6. Médecins - Détection auto 🟡 **MOYENNE**

**Problème** : Pas de proposition auto ajout médecin après upload PDF

**Ce qui reste à faire** :
1. Détecter nom médecin dans PDF uploadé
2. Dialog proposition après détection
3. Permettre ajout rapide depuis dialog

**Fichiers à modifier** :
- `arkalia_cia/lib/services/document_service.dart` : Détection médecin
- `arkalia_cia/lib/screens/documents_screen.dart` : Dialog proposition

**Priorité** : 🟡 **MOYENNE**

**Voir** : [AUDIT_COMPLET_12_DECEMBRE_2025.md](./AUDIT_COMPLET_12_DECEMBRE_2025.md#16-médecins---détection-auto-depuis-documents)

---

### 7. Patterns - Erreur non spécifiée 🟡 **MOYENNE**

**Problème** : "Une erreur est survenue" sans détails

**Ce qui reste à faire** :
1. Améliorer gestion erreurs dans `pattern_analyzer.py`
2. Messages d'erreur clairs et spécifiques
3. Logging détaillé pour debugging
4. Fallback gracieux si analyse échoue

**Fichiers à modifier** :
- `arkalia_cia_python_backend/ai/pattern_analyzer.py` : Gestion erreurs
- `arkalia_cia/lib/screens/patterns_screen.dart` : Affichage erreurs

**Priorité** : 🟡 **MOYENNE**

**Voir** : [AUDIT_COMPLET_12_DECEMBRE_2025.md](./AUDIT_COMPLET_12_DECEMBRE_2025.md#17-patterns---erreur-une-erreur-est-survenue)

---

### 8. Statistiques - Placement UI 🟡 **MOYENNE**

**Problème** : Trop visible ou pas assez selon contexte

**Ce qui reste à faire** :
1. Déplacer statistiques détaillées en paramètres
2. Garder indicateurs simples sur écrans principaux
3. Section "Statistiques" dans paramètres avec graphiques

**Fichiers à modifier** :
- `arkalia_cia/lib/screens/settings_screen.dart` : Ajouter section statistiques
- `arkalia_cia/lib/screens/home_page.dart` : Simplifier indicateurs

**Priorité** : 🟡 **MOYENNE**

**Voir** : [AUDIT_COMPLET_12_DECEMBRE_2025.md](./AUDIT_COMPLET_12_DECEMBRE_2025.md#18-statistiques---placement-dans-ui)

---

### 9. Dialog partage - Pas de feedback 🟡 **MOYENNE**

**Problème** : Pas de confirmation visuelle après partage

**Ce qui reste à faire** :
1. SnackBar avec confirmation après partage
2. Indicateur visuel (icône check) pendant partage
3. Compteur documents partagés

**Fichiers à modifier** :
- `arkalia_cia/lib/screens/family_sharing_screen.dart` : Améliorer feedback

**Priorité** : 🟡 **MOYENNE**

**Voir** : [AUDIT_COMPLET_12_DECEMBRE_2025.md](./AUDIT_COMPLET_12_DECEMBRE_2025.md#19-dialog-partage---pas-de-feedback)

---

### 10. BBIA - Placeholder uniquement 🟡 **MOYENNE**

**Problème** : BBIA est juste un placeholder, pas d'intégration réelle

**Statut** : Fonctionnalité future (Phase 4), pas prioritaire

**Ce qui reste à faire** :
- Intégration complète BBIA (robot compagnon cognitif)
- Communication CIA ↔ BBIA
- Interface émotionnelle robotique

**Priorité** : 🟡 **FONCTIONNALITÉ FUTURE** (Phase 4)

**Voir** : [AUDIT_COMPLET_12_DECEMBRE_2025.md](./AUDIT_COMPLET_12_DECEMBRE_2025.md#20-bbia---placeholder-uniquement)

---

## 📊 RÉCAPITULATIF PAR PRIORITÉ

### 🔴 Critique (1)
1. 🔴 Profil multi-appareil - Fonctionnalité future (10-16 jours)

**Note** : ARIA serveur est géré dans le projet ARIA séparé, pas dans CIA.

### 🟠 Élevé (3)
1. Portails santé - Épinglage favoris
2. Contacts urgence - Personnalisation
3. Pathologies - Sous-catégories

### 🟡 Moyen (5)
1. Médecins - Détection auto
2. Patterns - Erreur non spécifiée
3. Statistiques - Placement UI
4. Dialog partage - Feedback
5. BBIA - Placeholder (futur)

---

## 🎯 RECOMMANDATIONS

### Priorité immédiate (CIA uniquement)
1. **Portails santé - Épinglage** (1-2 jours) - Impact utilisateur élevé
2. **Contacts urgence - Personnalisation** (2-3 jours) - Impact utilisateur élevé
3. **Pathologies - Sous-catégories** (2-3 jours) - Organisation améliorée

### Après
4. **Médecins - Détection auto** (1 jour) - Amélioration UX
5. **Patterns - Erreur** (1 jour) - Correction bug
6. **Statistiques - Placement** (1 jour) - Amélioration UI

### Futur
7. **Profil multi-appareil** (10-16 jours) - Fonctionnalité majeure
8. **BBIA** (Phase 4) - Fonctionnalité future

---

## ✅ CE QUI EST DÉJÀ FAIT

### Critiques résolus (6/8)
- ✅ Biométrie
- ✅ Permissions PDF
- ✅ Page connexion/inscription
- ✅ Partage famille
- ✅ Calendrier rappels
- ✅ Bug connexion après création compte

### Élevés résolus (4/7)
- ✅ Rappels modifiables
- ✅ Couleurs pathologie
- ✅ Hydratation bugs visuels
- ✅ Paramètres accessibilité

### Documentation créée
- ✅ Guide déploiement ARIA (Render.com)
- ✅ Explication GitHub Pages vs Render.com
- ✅ Prompt audit ARIA complet

---

**Dernière mise à jour** : 12 décembre 2025  
**Prochaine étape recommandée** : Portails santé - Épinglage (1-2 jours)

**Note importante** : ARIA serveur est géré dans le projet ARIA séparé. Ce document liste uniquement les problèmes à résoudre dans le projet CIA.

