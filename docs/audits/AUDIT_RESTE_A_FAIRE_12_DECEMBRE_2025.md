# 🔍 Audit Reste à Faire - 12 Décembre 2025

<div align="center">

**Date** : 12 décembre 2025 | **Version** : 1.3.1+5

[![Statut](https://img.shields.io/badge/statut-en%20cours-yellow)]()
[![Problèmes](https://img.shields.io/badge/problèmes%20restants-17-orange)]()
[![Critiques](https://img.shields.io/badge/critiques-5-red)]()

</div>

Audit complet des problèmes restants après corrections du 12 décembre 2025.

---

## 📊 RÉSUMÉ EXÉCUTIF

**Total problèmes identifiés** : 20  
**Problèmes résolus** : 3 (Biométrie, PDF, Connexion)  
**Problèmes restants** : 17  
**Critiques restants** : 5  
**Élevés restants** : 7  
**Moyens restants** : 5

---

## ✅ PROBLÈMES RÉSOLUS (12 décembre 2025)

### 1. ✅ Biométrie ne s'affiche pas
- ✅ `biometricOnly: true` dans `auth_service.dart`
- ✅ Dialog après inscription
- ✅ Amélioration vérification disponibilité

### 5. ✅ Documents PDF - Permission "voir"
- ✅ Permissions ajoutées dans `AndroidManifest.xml`
- ✅ Demande runtime avant ouverture

### 8. ✅ Bug connexion après création compte
- ✅ Réinitialisation session
- ✅ Vérification état après login

---

## 🔴 PROBLÈMES CRITIQUES RESTANTS (5)

### 2. Pas de profil utilisateur multi-appareil 🔴 **CRITIQUE**

**Problème** : Impossible de passer mobile → ordi avec synchronisation

**Complexité** : 🔴 **TRÈS ÉLEVÉE** (Architecture complète à créer)

**Méthode recommandée** :
1. **Phase 1** : Créer modèle `UserProfile` et `Device` (1-2 jours)
2. **Phase 2** : Service `UserProfileService` pour gestion profil (2-3 jours)
3. **Phase 3** : Service `MultiDeviceSyncService` avec sync E2E (3-5 jours)
4. **Phase 4** : UI pour gestion appareils (2-3 jours)
5. **Phase 5** : Tests et validation (2-3 jours)

**Total estimé** : 10-16 jours

**Fichiers à créer** :
- `arkalia_cia/lib/models/user_profile.dart`
- `arkalia_cia/lib/models/device.dart`
- `arkalia_cia/lib/services/user_profile_service.dart`
- `arkalia_cia/lib/services/multi_device_sync_service.dart`
- `arkalia_cia/lib/screens/user_profile_screen.dart`

**Priorité** : 🔴 **CRITIQUE** mais complexe → À planifier sur 2-3 semaines

---

### 3. Page connexion/inscription à revoir complètement 🔴 **CRITIQUE**

**Problème** : Layout cassé, texte superposé, pas de proposition claire

**Complexité** : 🟡 **MOYENNE** (UI/UX redesign)

**Méthode recommandée** :
1. **Étape 1** : Créer `welcome_auth_screen.dart` avec 2 boutons clairs (2-3 heures)
2. **Étape 2** : Améliorer `pin_entry_screen.dart` layout (2-3 heures)
3. **Étape 3** : Améliorer `pin_setup_screen.dart` layout (2-3 heures)
4. **Étape 4** : Utiliser couleurs BBIA (gradients) (1-2 heures)
5. **Étape 5** : Tests et validation (1-2 heures)

**Total estimé** : 1-2 jours

**Fichiers à créer/modifier** :
- `arkalia_cia/lib/screens/auth/welcome_auth_screen.dart` (NOUVEAU)
- `arkalia_cia/lib/screens/auth/pin_entry_screen.dart` (AMÉLIORER)
- `arkalia_cia/lib/screens/auth/pin_setup_screen.dart` (AMÉLIORER)
- `arkalia_cia/lib/main.dart` (Modifier pour utiliser welcome_auth_screen)

**Priorité** : 🔴 **CRITIQUE** → À faire en priorité (1-2 jours)

---

### 4. Partage famille ne fonctionne pas 🔴 **CRITIQUE**

**Problème** : Partage envoyé mais rien reçu

**Complexité** : 🟠 **ÉLEVÉE** (Notifications + Backend)

**Méthode recommandée** :
1. **Étape 1** : Vérifier `NotificationService.initialize()` est appelé (30 min)
2. **Étape 2** : Ajouter logs détaillés dans `FamilySharingService` (1-2 heures)
3. **Étape 3** : Améliorer feedback utilisateur (confirmation partage) (1-2 heures)
4. **Étape 4** : Tester sur 2 appareils différents (1-2 heures)
5. **Étape 5** : Implémenter système d'invitation par email (si backend disponible) (2-3 jours)

**Total estimé** : 1-2 jours (sans email) ou 3-5 jours (avec email)

**Fichiers à modifier** :
- `arkalia_cia/lib/services/family_sharing_service.dart`
- `arkalia_cia/lib/services/notification_service.dart`
- `arkalia_cia/lib/screens/family_sharing_screen.dart`

**Priorité** : 🔴 **CRITIQUE** → À faire rapidement (1-2 jours)

---

### 5. Calendrier ne note pas les rappels 🔴 **CRITIQUE**

**Problème** : Rappels créés mais pas dans calendrier système

**Complexité** : 🟡 **MOYENNE** (Permissions + Sync)

**Méthode recommandée** :
1. **Étape 1** : Vérifier `requestCalendarPermission()` est appelé (30 min)
2. **Étape 2** : Améliorer synchronisation rappels → calendrier système (2-3 heures)
3. **Étape 3** : Ajouter codes couleur pathologie dans calendrier (1-2 heures)
4. **Étape 4** : Afficher rappels partout où nom médecin apparaît (1-2 heures)
5. **Étape 5** : Tests sur appareil réel (1-2 heures)

**Total estimé** : 1-2 jours

**Fichiers à modifier** :
- `arkalia_cia/lib/services/calendar_service.dart`
- `arkalia_cia/lib/screens/calendar_screen.dart`
- `arkalia_cia/lib/screens/reminders_screen.dart`

**Priorité** : 🔴 **CRITIQUE** → À faire rapidement (1-2 jours)

---

### 7. ARIA serveur non disponible 🔴 **CRITIQUE**

**Problème** : Serveur ARIA doit tourner sur Mac (pas disponible 24/7)

**Complexité** : 🟡 **MOYENNE** (Hébergement)

**Méthode recommandée** :
1. **Option 1 (Recommandée)** : Héberger sur Render.com free tier (2-3 heures)
   - Créer compte Render.com
   - Configurer variables d'environnement
   - Déployer backend ARIA
   - Tester connexion depuis CIA

2. **Option 2** : Héberger sur Railway.app free tier (2-3 heures)
   - Alternative à Render.com

3. **Option 3** : Instructions claires pour démarrer serveur ARIA local (1 heure)
   - Documenter démarrage local
   - Scripts automatiques

4. **Option 4 (Futur)** : Intégrer ARIA directement dans CIA (1-2 semaines)
   - Pas de serveur séparé
   - Plus complexe mais meilleure solution long terme

**Total estimé** : 2-3 heures (Option 1 ou 2) ou 1-2 semaines (Option 4)

**Fichiers à créer/modifier** :
- `docs/deployment/DEPLOIEMENT_ARIA_RENDER.md` (NOUVEAU)
- `arkalia_cia/lib/services/aria_service.dart` (Modifier URL si hébergé)

**Priorité** : 🔴 **CRITIQUE** → À faire rapidement (2-3 heures avec Option 1)

---

## 🟠 PROBLÈMES ÉLEVÉS RESTANTS (7)

### 9. Couleurs pathologie ≠ couleurs spécialités 🟠 **ÉLEVÉE**

**Complexité** : 🟡 **MOYENNE** (Mapping + UI)

**Méthode recommandée** :
1. Créer `pathology_colors.json` avec mapping standardisé (1-2 heures)
2. Modifier `Pathology` pour utiliser couleur standardisée (1-2 heures)
3. Utiliser couleur pathologie dans calendrier (1 heure)
4. Permettre personnalisation dans "Autres" (1-2 heures)

**Total estimé** : 1 jour

---

### 10. Portails santé - Pas d'épinglage 🟠 **ÉLEVÉE**

**Complexité** : 🟡 **MOYENNE** (Favoris + UI)

**Méthode recommandée** :
1. Ajouter système favoris/épinglage (2-3 heures)
2. Filtrer affichage pour montrer seulement favoris (1-2 heures)
3. Détecter si app portail installée → proposer ouverture app (2-3 heures)

**Total estimé** : 1-2 jours

---

### 11. Hydratation - Bugs visuels 🟠 **ÉLEVÉE**

**Complexité** : 🟡 **MOYENNE** (UI redesign)

**Méthode recommandée** :
1. Améliorer contraste boutons (1-2 heures)
2. Remplacer icônes barres par icônes bouteille ludiques (2-3 heures)
3. Animation progressive : bouteille se remplit (3-4 heures)
4. Déplacer statistiques en paramètres (1 heure)

**Total estimé** : 1-2 jours

---

### 12. Paramètres - Accessibilité 🟠 **ÉLEVÉE**

**Complexité** : 🟡 **MOYENNE** (UI + Service)

**Méthode recommandée** :
1. Créer `AccessibilityService` (2-3 heures)
2. Ajouter slider taille texte (2-3 heures)
3. Ajouter slider taille icônes (2-3 heures)
4. Prévisualisation en temps réel (2-3 heures)
5. Mode simplifié (2-3 heures)

**Total estimé** : 2-3 jours

---

### 13. Contacts urgence - Personnalisation 🟠 **ÉLEVÉE**

**Complexité** : 🟠 **ÉLEVÉE** (Intégration contacts)

**Méthode recommandée** :
1. Intégrer contacts téléphone (3-4 heures)
2. Permettre personnalisation : nom, emoji, couleur (2-3 heures)
3. ONE-TAP calling + SMS (2-3 heures)

**Total estimé** : 2-3 jours

---

### 14. Rappels - Pas modifiables 🟠 **ÉLEVÉE**

**Complexité** : 🟢 **FAIBLE** (UI simple)

**Méthode recommandée** :
1. Ajouter bouton "Modifier" sur chaque rappel (1-2 heures)
2. Créer `EditReminderDialog` (2-3 heures)
3. Permettre modification date, heure, récurrence (2-3 heures)

**Total estimé** : 1 jour

---

### 15. Pathologies - Sous-catégories 🟠 **ÉLEVÉE**

**Complexité** : 🟡 **MOYENNE** (Structure hiérarchique)

**Méthode recommandée** :
1. Ajouter système sous-catégories dans modèle (2-3 heures)
2. Permettre choix couleur dans "Autres" (1-2 heures)
3. Améliorer organisation visuelle (2-3 heures)

**Total estimé** : 1-2 jours

---

## 🟡 PROBLÈMES MOYENS RESTANTS (5)

### 16. Médecins - Détection auto 🟡 **MOYENNE**

**Complexité** : 🟢 **FAIBLE** (Dialog simple)

**Méthode recommandée** :
1. Après upload PDF → détecter médecin (1-2 heures)
2. Dialog : "Voulez-vous ajouter Dr. X ?" (1-2 heures)
3. Pré-remplir formulaire (1 heure)

**Total estimé** : 1 jour

---

### 17. Patterns - Erreur non spécifiée 🟡 **MOYENNE**

**Complexité** : 🟢 **FAIBLE** (Gestion erreurs)

**Méthode recommandée** :
1. Améliorer gestion erreurs avec messages clairs (1-2 heures)
2. Vérifier disponibilité ARIA avant analyse (1 heure)
3. Mode dégradé si ARIA indisponible (1-2 heures)

**Total estimé** : 1 jour

---

### 18. Statistiques - Placement UI 🟡 **MOYENNE**

**Complexité** : 🟢 **FAIBLE** (Déplacement UI)

**Méthode recommandée** :
1. Déplacer statistiques en paramètres (1-2 heures)
2. Garder indicateurs simples dans écrans principaux (1-2 heures)

**Total estimé** : 0.5 jour

---

### 19. Partage famille - Dialog peu lisible 🟡 **MOYENNE**

**Complexité** : 🟢 **FAIBLE** (UI amélioration)

**Méthode recommandée** :
1. Améliorer contraste dialog révoquer (1-2 heures)
2. Utiliser couleurs plus visibles en mode sombre (1 heure)

**Total estimé** : 0.5 jour

---

### 20. BBIA - Vérifier implémentation 🟡 **MOYENNE**

**Complexité** : 🟢 **FAIBLE** (Audit + Documentation)

**Méthode recommandée** :
1. Auditer ce qui est vraiment implémenté (1-2 heures)
2. Documenter ce qui manque (1-2 heures)
3. Clarifier roadmap BBIA (1 heure)

**Total estimé** : 0.5 jour

---

## 📋 PLAN D'ACTION RECOMMANDÉ

### 🔴 Semaine 1 - Critiques Urgents (5-7 jours)

**Jour 1-2** : Page connexion/inscription redesign
- Créer `welcome_auth_screen.dart`
- Améliorer `pin_entry_screen.dart` et `pin_setup_screen.dart`

**Jour 3-4** : Partage famille + Calendrier rappels
- Fix notifications partage famille
- Fix permissions calendrier + sync

**Jour 5** : ARIA serveur
- Héberger sur Render.com ou Railway.app

**Jour 6-7** : Tests et validation

---

### 🟠 Semaine 2 - Élevés Importants (7-10 jours)

**Jour 1-2** : Couleurs pathologie + Portails épinglage
- Mapping pathologie → couleur
- Système favoris portails

**Jour 3-4** : Hydratation UI + Paramètres accessibilité
- Redesign hydratation
- Sliders accessibilité

**Jour 5-6** : Contacts urgence + Rappels modifiables
- Personnalisation contacts
- Modification rappels

**Jour 7** : Pathologies sous-catégories

**Jour 8-10** : Tests et validation

---

### 🟡 Semaine 3 - Moyens (3-5 jours)

**Jour 1** : Médecins auto + Patterns erreurs
- Détection auto médecins
- Gestion erreurs patterns

**Jour 2** : Statistiques + Dialog partage
- Déplacer statistiques
- Améliorer dialog

**Jour 3** : BBIA audit
- Documenter état réel

**Jour 4-5** : Tests finaux

---

### 🔴 Semaine 4+ - Profil Multi-Appareil (10-16 jours)

**Complexe** : Architecture complète à créer
- Modèles UserProfile et Device
- Services sync E2E
- UI gestion appareils
- Tests complets

**Note** : Peut être fait en parallèle ou après les autres corrections.

---

## 🎯 PRIORISATION RECOMMANDÉE

### Phase 1 - Urgents (Semaine 1)
1. ✅ Biométrie (FAIT)
2. ✅ PDF permissions (FAIT)
3. ✅ Bug connexion (FAIT)
4. 🔴 Page connexion redesign
5. 🔴 Partage famille
6. 🔴 Calendrier rappels
7. 🔴 ARIA serveur

### Phase 2 - Importants (Semaine 2)
8. 🟠 Couleurs pathologie
9. 🟠 Portails épinglage
10. 🟠 Hydratation UI
11. 🟠 Paramètres accessibilité
12. 🟠 Contacts urgence
13. 🟠 Rappels modifiables
14. 🟠 Pathologies sous-catégories

### Phase 3 - Améliorations (Semaine 3)
15. 🟡 Médecins auto
16. 🟡 Patterns erreurs
17. 🟡 Statistiques placement
18. 🟡 Dialog partage
19. 🟡 BBIA audit

### Phase 4 - Complexe (Semaine 4+)
20. 🔴 Profil multi-appareil

---

## 📊 ESTIMATION TOTALE

**Critiques restants** : 5 problèmes → 5-7 jours  
**Élevés restants** : 7 problèmes → 7-10 jours  
**Moyens restants** : 5 problèmes → 3-5 jours  
**Profil multi-appareil** : 1 problème → 10-16 jours

**Total** : 25-38 jours (5-7.5 semaines)

**Avec priorisation** :
- **Phase 1** (Urgents) : 5-7 jours
- **Phase 2** (Importants) : 7-10 jours
- **Phase 3** (Améliorations) : 3-5 jours
- **Phase 4** (Complexe) : 10-16 jours (peut être fait en parallèle)

---

<div align="center">

**Dernière mise à jour** : 12 décembre 2025  
**Prochaines étapes** : Phase 1 - Urgents (Semaine 1)

**Problèmes résolus** : 3/20 | **Problèmes restants** : 17/20

</div>

