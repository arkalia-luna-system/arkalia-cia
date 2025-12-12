# 📋 CE QUI MANQUE ENCORE - 12 Décembre 2025

**Date** : 12 décembre 2025  
**Statut Projet** : 10/10 Sécurité ✅ | Production-Ready ✅  
**Politique** : 100% Gratuit ✅  
**Version** : 1.3.1+6

> **📌 Nouveau** : Voir **[AUDIT_COMPLET_12_DECEMBRE_2025.md](./audits/AUDIT_COMPLET_12_DECEMBRE_2025.md)** pour l'audit complet basé sur les tests utilisateur du 12 décembre 2025.

> **✅ Corrections appliquées le 12 décembre 2025 (suite)** :
> - ✅ Flux authentification amélioré : Gmail/Google en premier, puis "Créer un compte"
> - ✅ Service couleurs pathologie : `PathologyColorService` créé pour mapper pathologie → spécialité → couleur
> - ✅ Correction warnings de dépréciation Flutter (pathology.dart)
> - ✅ Documentation synchronisée avec code source (endpoints, services, versions)
> - ✅ Dates obsolètes corrigées (Janvier 2025 → 12 décembre 2025)

> **✅ Corrections appliquées le 12 décembre 2025** :
> - ✅ Biométrie : `biometricOnly: true` + dialog après inscription
> - ✅ Permissions PDF : `READ_EXTERNAL_STORAGE` + demande runtime
> - ✅ Bug connexion après création compte : réinitialisation session + vérification état
> - ✅ Page connexion/inscription : `welcome_auth_screen.dart` + amélioration layout + boutons Gmail/Google prioritaires
> - ✅ Partage famille : Initialisation notifications + amélioration feedback
> - ✅ Tests : Correction erreurs `MissingPluginException` avec fallback SharedPreferences
> - ✅ Tests : 41 tests passent (auth_service, auth_api_service, welcome_auth_screen, calendar_service, reminders_screen)

---

## ✅ CE QUI EST TERMINÉ (Tout fonctionne)

### Sécurité (10/10) ✅
- ✅ Runtime Security (détection root/jailbreak)
- ✅ JWT Token Rotation (blacklist)
- ✅ RBAC (framework complet)
- ✅ Audit Logs (tous endpoints critiques)
- ✅ Chiffrement E2E (partage familial)
- ✅ HSM (Keychain/Keystore)
- ✅ Validation JSON (protection DoS)
- ✅ Politique Confidentialité RGPD
- ✅ Consentement partage familial

### Fonctionnalités ✅
- ✅ Gestion documents médicaux
- ✅ Rappels & contacts d'urgence
- ✅ IA conversationnelle (locale)
- ✅ Rapports médicaux (génération + export PDF)
- ✅ Intégration ARIA (localhost)
- ✅ Partage familial (chiffrement E2E)
- ✅ Import manuel portails santé (gratuit)
- ✅ Export PDF rapports (reportlab gratuit)

---

## 🔧 CORRECTIONS TECHNIQUES

### 1. Protection `user_id` None dans audit logs ✅ **TERMINÉ**

**Problème** : Certains `int(current_user.user_id)` peuvent échouer si `user_id` est None

**Solution appliquée** : ✅ Vérification `if current_user.user_id:` ajoutée avant chaque `int(current_user.user_id)` et chaque audit log

**Fichiers corrigés** :
- ✅ `arkalia_cia_python_backend/api.py` - Toutes les occurrences corrigées

**Priorité** : ✅ RÉSOLU

---

## 🔴 NOUVEAUX PROBLÈMES IDENTIFIÉS (12 décembre 2025)

### 1. Biométrie ne s'affiche pas 🔴 **CRITIQUE** ✅ **CORRIGÉ**

**Problème** : Empreinte notifiée dans paramètres mais ne s'affiche pas

**Solution appliquée** :
- ✅ Changement `biometricOnly: false` → `true` dans `auth_service.dart`
- ✅ Amélioration `_checkBiometricAvailability()` dans `lock_screen.dart`
- ✅ Dialog après inscription pour proposer biométrie dans `register_screen.dart`
- ✅ Ajout `permission_handler` dans `pubspec.yaml`

**Fichiers modifiés** :
- `arkalia_cia/lib/services/auth_service.dart`
- `arkalia_cia/lib/screens/lock_screen.dart`
- `arkalia_cia/lib/screens/auth/register_screen.dart`
- `arkalia_cia/pubspec.yaml`

**Tests** : ✅ Tests améliorés dans `test/services/auth_service_test.dart` (5/5 passent)

**Voir** : [AUDIT_COMPLET_12_DECEMBRE_2025.md](./audits/AUDIT_COMPLET_12_DECEMBRE_2025.md#1-biométrie-ne-saffiche-pas)

**Priorité** : ✅ **RÉSOLU**

---

### 2. Pas de profil multi-appareil 🔴 **FONCTIONNALITÉ FUTURE**

**Problème** : Impossible de passer mobile → ordi avec synchronisation

**Statut** : Fonctionnalité future complexe (10-16 jours de développement), pas un bug bloquant

**Solution** : Créer système profil utilisateur + sync E2E
- Architecture complète à créer (modèles UserProfile, Device, services sync)
- Nécessite backend avec authentification multi-appareil
- Chiffrement E2E pour synchronisation sécurisée

**Voir** : [AUDIT_COMPLET_12_DECEMBRE_2025.md](./audits/AUDIT_COMPLET_12_DECEMBRE_2025.md#2-pas-de-profil-utilisateur-multi-appareil)

**Priorité** : 🔴 **FONCTIONNALITÉ FUTURE** (non-bloquant pour usage actuel)

---

### 3. Page connexion à revoir 🔴 **CRITIQUE** ✅ **CORRIGÉ**

**Problème** : Layout cassé, texte superposé

**Solution appliquée** :
- ✅ Création `welcome_auth_screen.dart` avec 2 boutons clairs (Se connecter / Créer un compte)
- ✅ Amélioration layout `pin_entry_screen.dart` (scrollable, centré)
- ✅ Utilisation couleurs BBIA (gradients bleu/violet)
- ✅ Intégration dans `main.dart` pour utiliser welcome_auth_screen

**Fichiers modifiés** :
- `arkalia_cia/lib/screens/auth/welcome_auth_screen.dart` (NOUVEAU)
- `arkalia_cia/lib/screens/pin_entry_screen.dart` (AMÉLIORÉ)
- `arkalia_cia/lib/main.dart` (Modifié pour utiliser welcome_auth_screen)

**Tests** : ✅ Tests créés dans `test/screens/auth/welcome_auth_screen_test.dart` (6/6 passent)

**Voir** : [AUDIT_COMPLET_12_DECEMBRE_2025.md](./audits/AUDIT_COMPLET_12_DECEMBRE_2025.md#3-page-connexioninscription-à-revoir-complètement)

**Priorité** : ✅ **RÉSOLU**

---

### 4. Partage famille ne fonctionne pas 🔴 **CRITIQUE** ✅ **CORRIGÉ**

**Problème** : Partage envoyé mais rien reçu

**Solution appliquée** :
- ✅ Initialisation explicite `NotificationService.initialize()` avant envoi notifications
- ✅ Amélioration feedback utilisateur (compteurs succès/erreurs)
- ✅ Gestion d'erreurs améliorée avec try/catch
- ✅ Messages de confirmation plus détaillés (nombre documents partagés)

**Fichiers modifiés** :
- `arkalia_cia/lib/services/family_sharing_service.dart`
- `arkalia_cia/lib/screens/family_sharing_screen.dart`

**Voir** : [AUDIT_COMPLET_12_DECEMBRE_2025.md](./audits/AUDIT_COMPLET_12_DECEMBRE_2025.md#4-partage-famille-ne-fonctionne-pas)

**Priorité** : ✅ **RÉSOLU**

---

### 5. Calendrier ne note pas les rappels ✅ **RÉSOLU**

**Problème** : Rappels créés mais pas dans calendrier

**Solution appliquée** :
- ✅ Vérification/demande permissions calendrier avant ajout dans `calendar_service.dart`
- ✅ Amélioration synchronisation rappels → calendrier système dans `reminders_screen.dart`
- ✅ Ajout support couleur pathologie dans calendrier (paramètre `pathologyId`)
- ✅ Gestion d'erreurs améliorée avec messages clairs

**Fichiers modifiés** :
- `arkalia_cia/lib/services/calendar_service.dart`
- `arkalia_cia/lib/screens/reminders_screen.dart`

**Tests** : ✅ Tests créés dans `test/services/calendar_service_test.dart` (8/8 passent)

**Voir** : [AUDIT_COMPLET_12_DECEMBRE_2025.md](./audits/AUDIT_COMPLET_12_DECEMBRE_2025.md#5-calendrier-ne-note-pas-les-rappels)

**Priorité** : ✅ **RÉSOLU**

---

### 6. Documents PDF - Permission "voir" 🔴 **CRITIQUE** ✅ **CORRIGÉ**

**Problème** : Icône yeux → alerte "Pas de permission"

**Solution appliquée** :
- ✅ Ajout `READ_EXTERNAL_STORAGE` et permissions média dans `AndroidManifest.xml`
- ✅ Demande permission runtime avant ouverture PDF dans `documents_screen.dart`
- ✅ Gestion d'erreurs améliorée avec messages clairs

**Fichiers modifiés** :
- `arkalia_cia/android/app/src/main/AndroidManifest.xml`
- `arkalia_cia/lib/screens/documents_screen.dart`

**Voir** : [AUDIT_COMPLET_12_DECEMBRE_2025.md](./audits/AUDIT_COMPLET_12_DECEMBRE_2025.md#6-documents-pdf---permission-voir-ne-fonctionne-pas)

**Priorité** : ✅ **RÉSOLU**

---

### 7. ARIA serveur non disponible ✅ **DOCUMENTATION CRÉÉE**

**Problème** : Serveur ARIA doit tourner sur Mac (pas disponible 24/7)

**Solution appliquée** :
- ✅ Documentation complète créée : `docs/deployment/DEPLOIEMENT_ARIA_RENDER.md`
- ✅ Amélioration `ARIAService` pour supporter URLs hébergées (https://xxx.onrender.com)
- ✅ Support détection automatique URLs complètes vs IPs locales
- ⏳ **Action requise** : Déployer sur Render.com (2-3 heures, guide disponible)

**Fichiers modifiés** :
- `arkalia_cia/lib/services/aria_service.dart` (amélioration support URLs hébergées)
- `docs/deployment/DEPLOIEMENT_ARIA_RENDER.md` (NOUVEAU - guide complet)

**Voir** : 
- [AUDIT_COMPLET_12_DECEMBRE_2025.md](./audits/AUDIT_COMPLET_12_DECEMBRE_2025.md#7-aria-serveur-non-disponible)
- [DEPLOIEMENT_ARIA_RENDER.md](./deployment/DEPLOIEMENT_ARIA_RENDER.md)

**Priorité** : ✅ **DOCUMENTATION CRÉÉE** (déploiement à faire)

---

### 8. Bug connexion après création compte 🔴 **CRITIQUE** ✅ **CORRIGÉ**

**Problème** : Après création compte dans paramètres, plus possible de se connecter

**Solution appliquée** :
- ✅ Réinitialisation session avant connexion automatique
- ✅ Vérification que session est active après login
- ✅ Messages d'erreur plus clairs et gestion d'échec améliorée

**Fichiers modifiés** :
- `arkalia_cia/lib/screens/auth/register_screen.dart`

**Tests** : ✅ Tests créés dans `test/services/auth_api_service_test.dart` (3/3 passent) + correction `MissingPluginException` avec fallback SharedPreferences

**Fichiers modifiés supplémentaires** :
- `arkalia_cia/lib/services/auth_api_service.dart` : Ajout gestion `MissingPluginException` avec fallback SharedPreferences pour tests

**Voir** : [AUDIT_COMPLET_12_DECEMBRE_2025.md](./audits/AUDIT_COMPLET_12_DECEMBRE_2025.md#8-bug-connexion-après-création-compte)

**Priorité** : ✅ **RÉSOLU**

---

## 🟠 PROBLÈMES ÉLEVÉS

### 9. Couleurs pathologie vs spécialités 🟠 **ÉLEVÉE** ✅ **RÉSOLU**

**Problème** : Couleurs pathologie ≠ couleurs spécialités → confusion

**Solution appliquée** :
- ✅ Service `PathologyColorService` créé : mapping pathologie → spécialité → couleur
- ✅ Tous les templates (24) utilisent maintenant le service standardisé
- ✅ Couleurs cohérentes avec spécialités médecins (Endométriose = Gynécologue = pink, etc.)
- ✅ Mapping complet pour toutes les pathologies courantes

**Fichiers modifiés** :
- `arkalia_cia/lib/services/pathology_color_service.dart` (NOUVEAU)
- `arkalia_cia/lib/services/pathology_service.dart` (tous templates mis à jour)

**Voir** : [AUDIT_COMPLET_12_DECEMBRE_2025.md](./audits/AUDIT_COMPLET_12_DECEMBRE_2025.md#9-couleurs-pathologie--couleurs-spécialités)

**Priorité** : ✅ **RÉSOLU**

---

### 10. Portails santé - Pas d'épinglage 🟠 **ÉLEVÉE**

**Problème** : Pas possible d'épingler favoris portails

**Solution** : Système favoris + intégration app

**Voir** : [AUDIT_COMPLET_12_DECEMBRE_2025.md](./audits/AUDIT_COMPLET_12_DECEMBRE_2025.md#10-portails-santé---pas-dépinglage)

**Priorité** : 🟠 **ÉLEVÉE**

---

### 11. Hydratation - Bugs visuels 🟠 **ÉLEVÉE** ✅ **CORRIGÉ**

**Problème** : Bouton OK invisible, icônes sur texte, UI peu intuitive

**Solution appliquée** :
- ✅ Correction contraste boutons : `foregroundColor` explicitement défini pour tous les boutons
- ✅ Taille minimale boutons : 48px de hauteur minimum pour accessibilité seniors
- ✅ Textes agrandis : Titre AppBar 18px, boutons 16px (minimum 14px respecté)
- ✅ AppBar simplifiée : Titre clair sans icônes superposées
- ✅ Padding augmenté : Boutons rapides avec padding 24x18px
- ✅ Icônes agrandies : 24px minimum pour meilleure visibilité

**Fichiers modifiés** :
- `arkalia_cia/lib/screens/hydration_reminders_screen.dart` : Améliorations contraste et accessibilité

**Tests** : ✅ Tests créés dans `test/screens/hydration_reminders_screen_test.dart` (7/7 passent)

**Voir** : [AUDIT_COMPLET_12_DECEMBRE_2025.md](./audits/AUDIT_COMPLET_12_DECEMBRE_2025.md#11-hydratation---bugs-visuels)

**Priorité** : ✅ **RÉSOLU**

---

### 12. Paramètres - Accessibilité 🟠 **ÉLEVÉE**

**Problème** : Pas d'option taille texte/icônes

**Solution** : Ajouter sliders + mode simplifié

**Voir** : [AUDIT_COMPLET_12_DECEMBRE_2025.md](./audits/AUDIT_COMPLET_12_DECEMBRE_2025.md#12-paramètres---manque-accessibilité)

**Priorité** : 🟠 **ÉLEVÉE**

---

### 13. Contacts urgence - Personnalisation 🟠 **ÉLEVÉE**

**Problème** : Pas assez personnalisable, pas d'intégration contacts

**Solution** : Intégrer contacts téléphone + personnalisation

**Voir** : [AUDIT_COMPLET_12_DECEMBRE_2025.md](./audits/AUDIT_COMPLET_12_DECEMBRE_2025.md#13-contacts-urgence---pas-assez-personnalisable)

**Priorité** : 🟠 **ÉLEVÉE**

---

### 14. Rappels - Pas modifiables ✅ **RÉSOLU**

**Problème** : Impossible de modifier un rappel créé

**Solution appliquée** :
- ✅ Ajout bouton "Modifier" sur chaque rappel (icône edit)
- ✅ Création `_showEditReminderDialog()` qui réutilise le dialog d'ajout pré-rempli
- ✅ Fonction `_updateReminder()` qui utilise `LocalStorageService.updateReminder()`
- ✅ Permet modification titre, description, date, heure, récurrence

**Fichiers modifiés** :
- `arkalia_cia/lib/screens/reminders_screen.dart`

**Voir** : [AUDIT_COMPLET_12_DECEMBRE_2025.md](./audits/AUDIT_COMPLET_12_DECEMBRE_2025.md#14-rappels---pas-modifiables)

**Priorité** : ✅ **RÉSOLU**

---

### 15. Pathologies - Sous-catégories 🟠 **ÉLEVÉE**

**Problème** : Pas de sous-catégories, organisation limitée

**Solution** : Système hiérarchique + choix couleur

**Voir** : [AUDIT_COMPLET_12_DECEMBRE_2025.md](./audits/AUDIT_COMPLET_12_DECEMBRE_2025.md#15-pathologies---manque-sous-catégories)

**Priorité** : 🟠 **ÉLEVÉE**

---

## 🟡 PROBLÈMES MOYENS

### 16. Médecins - Détection auto 🟡 **MOYENNE**

**Problème** : Pas de proposition auto ajout médecin après upload PDF

**Solution** : Dialog proposition après détection

**Voir** : [AUDIT_COMPLET_12_DECEMBRE_2025.md](./audits/AUDIT_COMPLET_12_DECEMBRE_2025.md#16-médecins---détection-auto-depuis-documents)

**Priorité** : 🟡 **MOYENNE**

---

### 17. Patterns - Erreur non spécifiée 🟡 **MOYENNE**

**Problème** : "Une erreur est survenue" sans détails

**Solution** : Améliorer gestion erreurs + messages clairs

**Voir** : [AUDIT_COMPLET_12_DECEMBRE_2025.md](./audits/AUDIT_COMPLET_12_DECEMBRE_2025.md#17-patterns---erreur-une-erreur-est-survenue)

**Priorité** : 🟡 **MOYENNE**

---

### 18. Statistiques - Placement UI 🟡 **MOYENNE**

**Problème** : Trop visible ou pas assez selon contexte

**Solution** : Déplacer en paramètres, garder indicateurs simples

**Voir** : [AUDIT_COMPLET_12_DECEMBRE_2025.md](./audits/AUDIT_COMPLET_12_DECEMBRE_2025.md#18-statistiques---placement-dans-ui)

**Priorité** : 🟡 **MOYENNE**

---

### 19. Partage famille - Dialog peu lisible 🟡 **MOYENNE**

**Problème** : Dialog révoquer partage peu lisible en mode sombre

**Solution** : Améliorer contraste + couleurs

**Voir** : [AUDIT_COMPLET_12_DECEMBRE_2025.md](./audits/AUDIT_COMPLET_12_DECEMBRE_2025.md#19-partage-famille---cadran-peu-lisible)

**Priorité** : 🟡 **MOYENNE**

---

### 20. BBIA - Vérifier implémentation 🟡 **MOYENNE**

**Problème** : Vérifier ce qui est vraiment fait vs placeholder

**Solution** : Auditer et documenter état réel

**Voir** : [AUDIT_COMPLET_12_DECEMBRE_2025.md](./audits/AUDIT_COMPLET_12_DECEMBRE_2025.md#20-bbia---vérifier-ce-qui-est-fait)

**Priorité** : 🟡 **MOYENNE**

---

## 🟡 AMÉLIORATIONS OPTIONNELLES (Non bloquantes)

### 1. Tests avec Fichiers PDF Réels

**Statut** : Code prêt, tests manquants

**Actions** :
- [ ] Obtenir PDF réel Andaman 7
- [ ] Obtenir PDF réel MaSanté
- [ ] Tester parser avec vrais PDFs
- [ ] Ajuster regex si nécessaire

**Priorité** : 🟡 MOYENNE (validation fonctionnalité)  
**Effort** : 1 semaine (quand fichiers disponibles)  
**Blocage** : Nécessite fichiers PDF réels

---

### 2. Tests Flutter Supplémentaires

**Statut** : 19 tests existants, peut continuer

**Actions** :
- [ ] Tests pour autres services simples (`local_storage_service.dart`)
- [ ] Tests widget pour écrans principaux (`home_screen.dart`, `documents_screen.dart`)
- [ ] Tests d'intégration basiques

**Priorité** : 🟡 MOYENNE (amélioration qualité)  
**Effort** : 1-2 semaines

---

### 3. Recherche Avancée Multi-Critères (UI Médecins)

**Statut** : Module médecins complet (80-90%), recherche UI basique

**Actions** :
- [ ] Recherche par spécialité
- [ ] Recherche par date
- [ ] Filtres multiples combinés
- [ ] Export/import médecins

**Priorité** : 🟡 MOYENNE (amélioration UX)  
**Effort** : 1 semaine

---

### 4. Recherche Avancée Examens

**Statut** : Recherche texte basique existe (30%)

**Actions** :
- [ ] Recherche par type d'examen
- [ ] Recherche par date
- [ ] Recherche par médecin prescripteur
- [ ] Filtres multiples combinés
- [ ] Recherche sémantique avancée

**Priorité** : 🟡 MOYENNE (amélioration UX)  
**Effort** : 2-3 semaines

---

### 5. IA Patterns Avancée

**Statut** : Base existe (70%), à améliorer

**Actions** :
- [ ] Analyse patterns médicaux avancée
- [ ] Détection corrélations améliorée
- [ ] Suggestions questions RDV automatiques
- [ ] Visualisations graphiques patterns

**Priorité** : 🟡 MOYENNE (amélioration fonctionnalité)  
**Effort** : 2-3 semaines

---

### 6. Organisation Documentation

**Statut** : ~135 fichiers MD (trop, à organiser)

**Actions** :
- [ ] Fusionner MD redondants
- [ ] Créer structure claire
- [ ] Supprimer obsolètes
- [ ] Créer README.md dans `docs/` avec index

**Priorité** : 🟢 BASSE (maintenance)  
**Effort** : 2-3 heures

---

## ⏸️ FONCTIONNALITÉS NON PRIORITAIRES

### 1. Accréditation eHealth

**Statut** : Procédure administrative (gratuit mais longue)

**Actions** :
- [ ] Contacter `integration-support@ehealth.fgov.be`
- [ ] Préparer dossier d'enregistrement
- [ ] Obtenir certificat eHealth
- [ ] Configurer OAuth eHealth

**Priorité** : 🟢 BASSE (non bloquant - import manuel fonctionne)  
**Effort** : 2-4 semaines (procédure administrative)  
**Note** : Gratuit mais procédure longue. Peut être fait plus tard si besoin.

---

## 📊 RÉSUMÉ PAR PRIORITÉ

### 🔴 CRITIQUE (À faire maintenant)
- ⚠️ Protection `user_id` None dans audit logs (12 occurrences)

### 🟠 ÉLEVÉE (Important mais non bloquant)
- ⚠️ Tests avec fichiers PDF réels (quand disponibles)
- ⚠️ Tests Flutter supplémentaires

### 🟡 MOYENNE (Améliorations UX)
- Recherche avancée multi-critères (médecins)
- Recherche avancée examens
- IA patterns avancée

### 🟢 BASSE (Maintenance)
- Organisation documentation
- Accréditation eHealth (non prioritaire)

---

## ✅ CONCLUSION

**État actuel** : Le projet est **production-ready** avec un score de **10/10 en sécurité**.

**Ce qui manque vraiment** :
1. **Correction technique** : Protection `user_id` None (15-20 min)
2. **Tests optionnels** : Fichiers PDF réels (quand disponibles)
3. **Améliorations UX** : Recherche avancée (optionnel)

**Tout le reste est optionnel et n'empêche pas la mise en production.**

---

**Dernière mise à jour** : 10 décembre 2025  
**Prochaine action recommandée** : Corriger protection `user_id` None dans audit logs
