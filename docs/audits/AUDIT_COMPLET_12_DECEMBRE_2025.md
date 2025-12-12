# 🔍 Audit Complet CIA - 12 Décembre 2025

<div align="center">

**Date** : 12 décembre 2025 | **Version** : 1.3.1+6

[![Statut](https://img.shields.io/badge/statut-audit%20en%20cours-yellow)]()
[![Problèmes](https://img.shields.io/badge/problèmes-20-orange)]()
[![Critiques](https://img.shields.io/badge/critiques-8-red)]()

</div>

Audit complet basé sur les tests utilisateur du 12 décembre 2025 et analyse approfondie du code.

---

## 📊 RÉSUMÉ EXÉCUTIF

**Total problèmes identifiés** : 20  
**Critiques** : 8  
**Élevés** : 7  
**Moyens** : 5

---

## 🔴 PROBLÈMES CRITIQUES

### 1. Biométrie ne s'affiche pas

**Problème** : L'empreinte est notifiée dans les paramètres mais ne vient pas du tout.

**Analyse code** :
- ✅ `AuthService.isBiometricAvailable()` existe
- ✅ `LockScreen` vérifie la disponibilité
- ⚠️ **Problème probable** : Permissions Android/iOS non demandées au runtime
- ⚠️ **Problème probable** : `biometricOnly: false` dans `AuthService.authenticate()` → système propose PIN au lieu de biométrie

**Fichiers concernés** :
- `arkalia_cia/lib/services/auth_service.dart` (ligne 60-67)
- `arkalia_cia/lib/screens/lock_screen.dart` (ligne 111-157)
- `arkalia_cia/android/app/src/main/AndroidManifest.xml` (ligne 8)
- `arkalia_cia/ios/Runner/Info.plist` (ligne 48-49)

**Solution** :
1. Vérifier permissions runtime Android (`permission_handler`)
2. Vérifier que `biometricOnly: true` est proposé d'abord
3. Ajouter demande explicite biométrie après inscription
4. Améliorer UI pour proposer biométrie clairement

**Priorité** : 🔴 **CRITIQUE**

---

### 2. Pas de profil utilisateur multi-appareil

**Problème** : Impossible de passer de mobile à ordi et conserver session. Pas de synchronisation des données.

**Analyse code** :
- ❌ Pas de système de profil utilisateur centralisé
- ❌ Pas de synchronisation multi-appareil
- ✅ `AutoSyncService` existe mais seulement pour backend local
- ⚠️ **Problème fondamental** : Pas de base de données utilisateur partagée

**Solution** :
1. Créer système de profil utilisateur avec email comme identifiant
2. Implémenter synchronisation chiffrée E2E entre appareils
3. Confirmation email obligatoire pour nouveau device
4. Stockage local + sync optionnel (utilisateur choisit)

**Architecture proposée** :
```dart
class UserProfile {
  String userId;        // UUID unique
  String email;         // Identifiant principal
  String displayName;
  List<Device> devices;  // Appareils connectés
  DateTime createdAt;
  DateTime lastSync;
}

class Device {
  String deviceId;      // UUID appareil
  String deviceName;    // "iPhone de Maman", "iPad"
  String platform;      // iOS, Android, Web
  DateTime lastSeen;
  bool isActive;
}
```

**Priorité** : 🔴 **CRITIQUE**

---

### 3. Page connexion/inscription à revoir complètement

**Problème** : "Le cadran avec écrit code dedans, écriture semi lune sur l'autre fin cette page est complètement à revoir"

**Analyse code** :
- ⚠️ `pin_entry_screen.dart` existe mais layout peut être cassé
- ⚠️ Pas de proposition claire "Créer compte" vs "Se connecter"
- ⚠️ Biométrie pas proposée après inscription

**Solution** :
1. Redesign complet page d'accueil avec 2 boutons clairs
2. Améliorer `PinEntryScreen` avec meilleur layout
3. Proposer biométrie après inscription réussie
4. Utiliser couleurs BBIA (gradients, mat/brillant)

**Priorité** : 🔴 **CRITIQUE**

---

### 4. Partage famille ne fonctionne pas

**Problème** : "Je me suis envoyé à moi-même rien reçu du tout"

**Analyse code** :
- ✅ `FamilySharingService.shareDocumentWithMembers()` existe
- ✅ `NotificationService.notifyDocumentShared()` existe
- ⚠️ **Problème probable** : Service email/notification pas configuré
- ⚠️ **Problème probable** : Notifications locales seulement (pas d'email/SMS)

**Solution** :
1. Vérifier configuration notifications locales
2. Implémenter système d'invitation par email (si backend disponible)
3. Améliorer feedback utilisateur (confirmation partage)
4. Ajouter logs pour débugger

**Priorité** : 🔴 **CRITIQUE**

---

### 5. Calendrier ne note pas les rappels

**Problème** : "Le calendrier ne note pas les rappels"

**Analyse code** :
- ✅ `CalendarService.addReminder()` existe
- ✅ `calendar_screen.dart` charge les événements
- ⚠️ **Problème probable** : Rappels créés mais pas synchronisés avec calendrier système
- ⚠️ **Problème probable** : Permissions calendrier non demandées

**Solution** :
1. Vérifier permissions calendrier (`requestCalendarPermission()`)
2. Améliorer synchronisation rappels → calendrier système
3. Ajouter codes couleur pathologie dans calendrier
4. Afficher rappels partout où nom médecin apparaît

**Priorité** : 🔴 **CRITIQUE**

---

### 6. Documents PDF - Permission "voir" ne fonctionne pas

**Problème** : "Quand on télécharge un PDF il y a un icône yeux pour les voir mais une alert vient qui dit que peut pas voir"

**Analyse code** :
- ✅ `documents_screen.dart` utilise `OpenFilex.open()`
- ⚠️ **Problème probable** : Permission `READ_EXTERNAL_STORAGE` manquante sur Android
- ⚠️ **Problème probable** : Chemin fichier incorrect ou fichier supprimé

**Solution** :
1. Ajouter permission `READ_EXTERNAL_STORAGE` dans `AndroidManifest.xml`
2. Demander permission au runtime avec `permission_handler`
3. Vérifier existence fichier avant ouverture
4. Améliorer gestion erreurs avec messages clairs

**Priorité** : 🔴 **CRITIQUE**

---

### 7. ARIA serveur non disponible

**Problème** : "Il serait temps de la rendre le serveur disponible"

**Analyse code** :
- ✅ `ARIAIntegration` existe dans backend
- ✅ `ARIAService` existe dans Flutter
- ⚠️ **Problème** : Serveur ARIA doit tourner sur `localhost:8001` (Mac doit être allumé)
- ⚠️ **Problème** : Pas de solution hébergement gratuite 24/7

**Solution** :
1. **Option 1 (Gratuit)** : Render.com free tier (limité mais fonctionne)
2. **Option 2 (Gratuit)** : Railway.app free tier
3. **Option 3 (Local)** : Instructions claires pour démarrer serveur ARIA
4. **Option 4 (Futur)** : Intégrer ARIA directement dans CIA (pas de serveur séparé)

**Priorité** : 🔴 **CRITIQUE**

---

### 8. Bug connexion après création compte

**Problème** : "Après les paramètres pour essayer de créer un compte maintenant il ne veut plus que je me connecte à l'app"

**Analyse code** :
- ⚠️ **Problème probable** : État session mal géré après création compte
- ⚠️ **Problème probable** : Flag `isLoggedIn` ou `onboardingCompleted` mal mis à jour

**Solution** :
1. Vérifier gestion état après création compte
2. Réinitialiser session correctement
3. Améliorer logs pour débugger
4. Tester flow complet inscription → connexion

**Priorité** : 🔴 **CRITIQUE**

---

## 🟠 PROBLÈMES ÉLEVÉS

### 9. Couleurs pathologie ≠ couleurs spécialités

**Problème** : "Les couleurs des pathologie ne sont pas les mêmes que elles devraient correspondre au spécialisé des médecins"

**Analyse code** :
- ✅ `Doctor.getColorForSpecialty()` existe (13 spécialités)
- ✅ `Pathology.color` existe mais pas de mapping standardisé
- ⚠️ **Problème** : Endométriose (couleur X) traité par Gynécologue (couleur Y) → confusion

**Solution** :
1. Créer mapping pathologie → couleur standardisée
2. Utiliser couleur pathologie (pas spécialité) dans calendrier
3. Créer fichier JSON de référence pathologie → couleur → spécialité
4. Permettre personnalisation couleur dans "Autres"

**Fichier référence proposé** :
```json
{
  "Endométriose": {
    "color": "#E91E8C",
    "specialization": "Gynécologue",
    "icd10": "N80"
  },
  "TDAH": {
    "color": "#3498DB",
    "specialization": "Psychiatre",
    "icd10": "F90"
  }
}
```

**Priorité** : 🟠 **ÉLEVÉE**

---

### 10. Portails santé - Pas d'épinglage

**Problème** : "On devrait pouvoir épingle pour ne voir que ceux que on voudrait"

**Analyse code** :
- ✅ `HealthPortalAuthScreen` existe
- ❌ Pas de système d'épinglage/favoris
- ❌ Pas d'intégration app (si client a l'app du portail)

**Solution** :
1. Ajouter système favoris/épinglage portails
2. Filtrer affichage pour montrer seulement favoris
3. Intégration app : Détecter si app portail installée → proposer ouverture app
4. Sinon → ouvrir web comme actuellement

**Priorité** : 🟠 **ÉLEVÉE**

---

### 11. Hydratation - Bugs visuels

**Problèmes** :
- Bouton "OK" devient bleu sur fond bleu (invisible)
- Icônes barres sur écriture "Hydration"
- Statistiques peu utiles

**Analyse code** :
- ✅ `hydration_reminders_screen.dart` existe
- ⚠️ **Problème** : Contraste insuffisant en mode sombre
- ⚠️ **Problème** : UI peu intuitive pour seniors

**Solution** :
1. Améliorer contraste boutons (toujours vérifier TextColor vs Background)
2. Remplacer icônes barres par icônes bouteille ludiques
3. Animation progressive : bouteille se remplit
4. Déplacer statistiques en paramètres (pas au même niveau)

**Idée révolutionnaire** :
- Animation gamifiée : chaque verre = bouteille qui se remplit
- Son doux optionnel
- Streak : "7 jours consécutifs 💪"
- Intégration smartwatch (futur)

**Priorité** : 🟠 **ÉLEVÉE**

---

### 12. Paramètres - Manque accessibilité

**Problème** : "Dans les paramètres qu'il puisse changer la taille de l'écriture ou des icônes"

**Analyse code** :
- ✅ `settings_screen.dart` existe
- ❌ Pas d'option taille texte
- ❌ Pas d'option taille icônes
- ❌ Pas de mode simplifié

**Solution** :
1. Ajouter slider taille texte (Petit/Normal/Grand/Très Grand)
2. Ajouter slider taille icônes
3. Prévisualisation en temps réel
4. Mode simplifié (cacher fonctionnalités avancées)
5. Réorganiser paramètres par catégories

**Priorité** : 🟠 **ÉLEVÉE**

---

### 13. Contacts urgence - Pas assez personnalisable

**Problème** : "Que le contacte d'urgence soit plus perso"

**Analyse code** :
- ✅ `emergency_contacts_screen.dart` existe (à vérifier)
- ⚠️ **Problème** : Pas d'intégration contacts téléphone
- ⚠️ **Problème** : Pas de personnalisation (noms, emojis, couleurs)

**Solution** :
1. Intégrer contacts téléphone (WhatsApp, SMS)
2. Permettre personnalisation : nom affiché, emoji, couleur
3. ONE-TAP calling + SMS
4. Proposer auto depuis contacts système

**Priorité** : 🟠 **ÉLEVÉE**

---

### 14. Rappels - Pas modifiables

**Problème** : "On ne sait pas modifier un rappel fait"

**Analyse code** :
- ✅ `reminders_screen.dart` existe
- ⚠️ **Problème probable** : Pas de fonction modifier dans UI
- ⚠️ **Problème probable** : Seulement création et suppression

**Solution** :
1. Ajouter bouton "Modifier" sur chaque rappel
2. Permettre modification date, heure, récurrence
3. Améliorer UI pour rendre modification évidente

**Priorité** : 🟠 **ÉLEVÉE**

---

### 15. Pathologies - Manque sous-catégories

**Problème** : "Que les pathologie soit un peu plus grande avec des sous catégorie"

**Analyse code** :
- ✅ `Pathology` model existe
- ⚠️ **Problème** : Structure plate, pas de hiérarchie
- ⚠️ **Problème** : "Autres" permet ajout mais pas d'organisation

**Solution** :
1. Ajouter système sous-catégories
2. Permettre choix couleur dans "Autres"
3. Fichier intelligent qui propose couleur selon spécialité
4. Améliorer organisation visuelle

**Priorité** : 🟠 **ÉLEVÉE**

---

## 🟡 PROBLÈMES MOYENS

### 16. Médecins - Détection auto depuis documents

**Problème** : "Quand le client a transféré des documents médicaux que les médecins remarqués soit demander à l'utilisateur si il veut le rajouter"

**Analyse code** :
- ✅ `pdf_processor.py` extrait métadonnées
- ✅ `metadata_extractor.py` extrait médecin
- ⚠️ **Problème** : Pas de dialog pour proposer ajout médecin

**Solution** :
1. Après upload PDF → détecter médecin
2. Dialog : "Voulez-vous ajouter Dr. X à vos contacts?"
3. Pré-remplir formulaire avec données extraites
4. Permettre modification avant validation

**Priorité** : 🟡 **MOYENNE**

---

### 17. Patterns - Erreur "Une erreur est survenue"

**Problème** : "Les patterns ne veut pas fonctionner non plus un erreur est survenue qu'il dit"

**Analyse code** :
- ✅ `AdvancedPatternAnalyzer` existe
- ⚠️ **Problème** : Erreur non spécifiée, difficile à débugger
- ⚠️ **Problème probable** : ARIA non disponible ou données insuffisantes

**Solution** :
1. Améliorer gestion erreurs avec messages clairs
2. Vérifier disponibilité ARIA avant analyse
3. Ajouter logs détaillés
4. Mode dégradé si ARIA indisponible

**Priorité** : 🟡 **MOYENNE**

---

### 18. Statistiques - Placement dans UI

**Problème** : "Les stats est-ce que c'est important pour le client au point de le mettre dans les même bouton cadran que tout le reste ou un truc plus discret"

**Analyse code** :
- ✅ Statistiques existent dans plusieurs écrans
- ⚠️ **Problème** : Placement peut être trop visible

**Solution** :
1. Déplacer statistiques en paramètres (section discrète)
2. Garder seulement indicateurs visuels simples dans écrans principaux
3. Statistiques détaillées accessibles mais pas intrusives

**Priorité** : 🟡 **MOYENNE**

---

### 19. Partage famille - Cadran peu lisible

**Problème** : "Il y a un cadran un peu organisé qui dit que on peut révoquer le partage à tout instant peut lisible le cadran pas bonne couleur su tout en tout cas pr le sombre"

**Analyse code** :
- ✅ `family_sharing_screen.dart` existe
- ⚠️ **Problème** : Contraste insuffisant en mode sombre
- ⚠️ **Problème** : Dialog révoquer partage peu lisible

**Solution** :
1. Améliorer contraste dialog révoquer
2. Utiliser couleurs plus visibles en mode sombre
3. Améliorer typographie et espacement

**Priorité** : 🟡 **MOYENNE**

---

### 20. BBIA - Vérifier ce qui est fait

**Problème** : "BBIA est noter dedans mais j'aimerais que on vérifie si l'entièreté de se qui est noter est déjà fait ou non"

**Analyse code** :
- ✅ `bbia_integration_screen.dart` existe (placeholder)
- ⚠️ **Problème** : Écran placeholder seulement, pas d'intégration réelle
- ⚠️ **Problème** : Pas de connexion avec BBIA-SIM

**Solution** :
1. Auditer ce qui est vraiment implémenté
2. Documenter ce qui manque
3. Clarifier roadmap BBIA
4. Ne pas faire espérer le client si pas prêt

**Priorité** : 🟡 **MOYENNE**

---

## 📋 PLAN D'ACTION DÉTAILLÉ

### 🔴 Semaine 1 - Critiques (Priorité absolue)

#### 1. Biométrie ne s'affiche pas
**Fichiers à modifier** :
- `arkalia_cia/lib/services/auth_service.dart` : Vérifier `biometricOnly: true` d'abord
- `arkalia_cia/lib/screens/lock_screen.dart` : Améliorer UI proposition biométrie
- `arkalia_cia/android/app/src/main/AndroidManifest.xml` : Vérifier permissions
- `arkalia_cia/lib/screens/auth/register_screen.dart` : Proposer biométrie après inscription

**Actions** :
1. Ajouter demande permission runtime Android (`permission_handler`)
2. Changer `biometricOnly: false` → `true` pour forcer biométrie d'abord
3. Dialog après inscription : "Voulez-vous activer l'empreinte digitale?"
4. Améliorer message erreur si biométrie refusée

**Tests** : Vérifier sur appareil réel Android/iOS

---

#### 2. Redesign page connexion/inscription
**Fichiers à créer/modifier** :
- `arkalia_cia/lib/screens/auth/welcome_auth_screen.dart` : Nouvelle page d'accueil
- `arkalia_cia/lib/screens/auth/pin_entry_screen.dart` : Améliorer layout
- `arkalia_cia/lib/screens/auth/pin_setup_screen.dart` : Améliorer layout

**Actions** :
1. Créer écran d'accueil avec 2 boutons clairs (Créer / Se connecter)
2. Utiliser couleurs BBIA (gradients, mat/brillant)
3. Améliorer `PinEntryScreen` : layout centré, pas de texte superposé
4. Animations subtiles (gradient, transitions)

**Design proposé** :
```
┌─────────────────────────────┐
│      🏥 ARKALIA CIA         │
│    Votre Carnet de Santé    │
│                             │
│  ┌─────────────────────┐   │
│  │ SE CONNECTER        │   │
│  └─────────────────────┘   │
│                             │
│  ┌─────────────────────┐   │
│  │ CRÉER UN COMPTE     │   │
│  └─────────────────────┘   │
└─────────────────────────────┘
```

---

#### 3. Fix partage famille
**Fichiers à modifier** :
- `arkalia_cia/lib/services/family_sharing_service.dart` : Vérifier envoi notifications
- `arkalia_cia/lib/services/notification_service.dart` : Vérifier configuration
- `arkalia_cia/lib/screens/family_sharing_screen.dart` : Améliorer feedback

**Actions** :
1. Vérifier que `NotificationService.initialize()` est appelé
2. Ajouter logs pour débugger envoi notifications
3. Améliorer feedback utilisateur (confirmation partage)
4. Implémenter système d'invitation par email (si backend disponible)

**Tests** : Tester partage sur 2 appareils différents

---

#### 4. Fix calendrier rappels
**Fichiers à modifier** :
- `arkalia_cia/lib/services/calendar_service.dart` : Vérifier permissions
- `arkalia_cia/lib/screens/calendar_screen.dart` : Ajouter codes couleur pathologie
- `arkalia_cia/lib/screens/reminders_screen.dart` : Améliorer sync

**Actions** :
1. Vérifier `requestCalendarPermission()` est appelé
2. Améliorer synchronisation rappels → calendrier système
3. Ajouter barre latérale colorée (couleur pathologie) sur événements
4. Afficher rappels partout où nom médecin apparaît

---

#### 5. Fix permissions PDF
**Fichiers à modifier** :
- `arkalia_cia/android/app/src/main/AndroidManifest.xml` : Ajouter `READ_EXTERNAL_STORAGE`
- `arkalia_cia/lib/screens/documents_screen.dart` : Demander permission runtime
- `arkalia_cia/pubspec.yaml` : Ajouter `permission_handler` si pas présent

**Actions** :
1. Ajouter `<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />`
2. Demander permission au runtime avant ouverture PDF
3. Vérifier existence fichier avant ouverture
4. Améliorer messages erreur

---

### 🟠 Semaine 2 - Critiques + Élevés

#### 6. Profil multi-appareil
**Fichiers à créer** :
- `arkalia_cia/lib/models/user_profile.dart` : Modèle profil utilisateur
- `arkalia_cia/lib/services/user_profile_service.dart` : Service gestion profil
- `arkalia_cia/lib/services/multi_device_sync_service.dart` : Service sync multi-appareil

**Architecture** :
```dart
class UserProfile {
  String userId;        // UUID
  String email;         // Identifiant
  String displayName;
  List<Device> devices;
  DateTime createdAt;
  DateTime? lastSync;
}

class Device {
  String deviceId;
  String deviceName;
  String platform;      // iOS, Android, Web
  DateTime lastSeen;
  bool isActive;
}
```

**Actions** :
1. Créer système profil avec email comme identifiant
2. Implémenter sync chiffrée E2E entre appareils
3. Confirmation email obligatoire pour nouveau device
4. Stockage local + sync optionnel (utilisateur choisit)

---

#### 7. Fix bug connexion après création compte
**Fichiers à modifier** :
- `arkalia_cia/lib/screens/auth/register_screen.dart` : Corriger gestion état
- `arkalia_cia/lib/services/auth_api_service.dart` : Vérifier flags session

**Actions** :
1. Vérifier que `isLoggedIn` est correctement mis à jour
2. Réinitialiser session correctement après création compte
3. Améliorer logs pour débugger
4. Tester flow complet inscription → connexion

---

#### 8. ARIA serveur
**Options** :
1. **Render.com** (gratuit) : Héberger ARIA backend
2. **Railway.app** (gratuit) : Alternative Render
3. **Local** : Instructions claires pour démarrer serveur ARIA
4. **Futur** : Intégrer ARIA directement dans CIA (pas de serveur séparé)

**Actions** :
1. Créer guide déploiement ARIA sur Render/Railway
2. Configurer variables d'environnement
3. Tester connexion depuis CIA
4. Documenter solution choisie

---

#### 9. Couleurs pathologie vs spécialités
**Fichiers à créer/modifier** :
- `arkalia_cia/lib/data/pathology_colors.json` : Mapping pathologie → couleur
- `arkalia_cia/lib/services/pathology_service.dart` : Utiliser mapping
- `arkalia_cia/lib/models/pathology.dart` : Méthode `getStandardColor()`

**Mapping proposé** :
```json
{
  "Endométriose": {
    "color": "#E91E8C",
    "specialization": "Gynécologue"
  },
  "TDAH": {
    "color": "#3498DB",
    "specialization": "Psychiatre"
  }
}
```

**Actions** :
1. Créer fichier JSON de référence
2. Modifier `Pathology` pour utiliser couleur standardisée
3. Utiliser couleur pathologie (pas spécialité) dans calendrier
4. Permettre personnalisation dans "Autres"

---

#### 10. Épinglage portails santé
**Fichiers à modifier** :
- `arkalia_cia/lib/services/health_portal_auth_service.dart` : Ajouter favoris
- `arkalia_cia/lib/screens/health_portal_auth_screen.dart` : UI épinglage
- `arkalia_cia/lib/screens/health_portals_screen.dart` : Filtrer favoris

**Actions** :
1. Ajouter système favoris/épinglage
2. Filtrer affichage pour montrer seulement favoris
3. Détecter si app portail installée → proposer ouverture app
4. Sinon → ouvrir web comme actuellement

---

### 🟡 Semaine 3 - Élevés + Moyens

#### 11. Hydratation - UI révolutionnaire
**Fichiers à modifier** :
- `arkalia_cia/lib/screens/hydration_reminders_screen.dart` : Redesign complet
- `arkalia_cia/lib/widgets/hydration_bottle_widget.dart` : Nouveau widget (à créer)

**Idée révolutionnaire** :
- Animation gamifiée : bouteille se remplit goutte par goutte
- Chaque verre = icône bouteille animée
- Son doux optionnel
- Streak : "7 jours consécutifs 💪"
- Intégration smartwatch (futur)

**Actions** :
1. Créer widget bouteille animée
2. Améliorer contraste boutons (toujours vérifier TextColor vs Background)
3. Remplacer icônes barres par icônes bouteille ludiques
4. Déplacer statistiques en paramètres

---

#### 12. Accessibilité paramètres
**Fichiers à modifier** :
- `arkalia_cia/lib/screens/settings_screen.dart` : Ajouter sliders
- `arkalia_cia/lib/services/accessibility_service.dart` : Nouveau service (à créer)

**Actions** :
1. Ajouter slider taille texte (Petit/Normal/Grand/Très Grand)
2. Ajouter slider taille icônes
3. Prévisualisation en temps réel
4. Mode simplifié (cacher fonctionnalités avancées)
5. Réorganiser paramètres par catégories

---

#### 13. Contacts urgence - Personnalisation
**Fichiers à modifier** :
- `arkalia_cia/lib/screens/emergency_screen.dart` : Améliorer UI
- `arkalia_cia/lib/services/contacts_service.dart` : Intégrer contacts téléphone
- `arkalia_cia/lib/models/emergency_contact.dart` : Ajouter personnalisation

**Actions** :
1. Intégrer contacts téléphone (WhatsApp, SMS)
2. Permettre personnalisation : nom affiché, emoji, couleur
3. ONE-TAP calling + SMS
4. Proposer auto depuis contacts système

---

#### 14. Modification rappels
**Fichiers à modifier** :
- `arkalia_cia/lib/screens/reminders_screen.dart` : Ajouter bouton modifier
- `arkalia_cia/lib/widgets/edit_reminder_dialog.dart` : Nouveau widget (à créer)

**Actions** :
1. Ajouter bouton "Modifier" sur chaque rappel
2. Permettre modification date, heure, récurrence
3. Améliorer UI pour rendre modification évidente

---

#### 15. Pathologies - Sous-catégories
**Fichiers à modifier** :
- `arkalia_cia/lib/models/pathology.dart` : Ajouter hiérarchie
- `arkalia_cia/lib/screens/pathology_list_screen.dart` : Améliorer organisation
- `arkalia_cia/lib/services/pathology_service.dart` : Gérer sous-catégories

**Actions** :
1. Ajouter système sous-catégories
2. Permettre choix couleur dans "Autres"
3. Fichier intelligent qui propose couleur selon spécialité
4. Améliorer organisation visuelle

---

### 🟢 Semaine 4 - Moyens + Tests

#### 16. Détection auto médecins
**Fichiers à modifier** :
- `arkalia_cia/lib/screens/documents_screen.dart` : Dialog après upload
- `arkalia_cia/lib/widgets/add_doctor_from_document_dialog.dart` : Nouveau widget

**Actions** :
1. Après upload PDF → détecter médecin
2. Dialog : "Voulez-vous ajouter Dr. X à vos contacts?"
3. Pré-remplir formulaire avec données extraites
4. Permettre modification avant validation

---

#### 17. Patterns - Gestion erreurs
**Fichiers à modifier** :
- `arkalia_cia_python_backend/ai/pattern_analyzer.py` : Améliorer erreurs
- `arkalia_cia/lib/screens/patterns_dashboard_screen.dart` : Messages clairs

**Actions** :
1. Améliorer gestion erreurs avec messages clairs
2. Vérifier disponibilité ARIA avant analyse
3. Ajouter logs détaillés
4. Mode dégradé si ARIA indisponible

---

#### 18. Statistiques - Placement
**Fichiers à modifier** :
- `arkalia_cia/lib/screens/settings_screen.dart` : Section statistiques
- `arkalia_cia/lib/screens/hydration_reminders_screen.dart` : Déplacer stats

**Actions** :
1. Déplacer statistiques en paramètres (section discrète)
2. Garder seulement indicateurs visuels simples dans écrans principaux
3. Statistiques détaillées accessibles mais pas intrusives

---

#### 19. Dialog partage famille
**Fichiers à modifier** :
- `arkalia_cia/lib/screens/family_sharing_screen.dart` : Améliorer dialog

**Actions** :
1. Améliorer contraste dialog révoquer
2. Utiliser couleurs plus visibles en mode sombre
3. Améliorer typographie et espacement

---

#### 20. BBIA - Audit
**Fichiers à vérifier** :
- `arkalia_cia/lib/screens/bbia_integration_screen.dart` : Placeholder seulement
- Documentation BBIA : Vérifier ce qui est vraiment fait

**Actions** :
1. Auditer ce qui est vraiment implémenté
2. Documenter ce qui manque
3. Clarifier roadmap BBIA
4. Ne pas faire espérer le client si pas prêt

**Conclusion** : BBIA est actuellement un **placeholder** (écran d'info seulement). Pas d'intégration réelle avec BBIA-SIM. Roadmap à clarifier.

---

## 📝 NOTES IMPORTANTES

### Questions pour clarification

1. **Backend** : Render.com suffisant ou tu veux une vraie DB chiffrée?
2. **ARIA** : Tu veux que ce soit local ou cloud?
3. **Biométrie** : Pourquoi elle n'apparaît pas? L'as-tu implémentée?
4. **Email service** : T'as un service pour envoyer les notifications?
5. **Reachy** : Vraiment pour tous ou juste prototype/ta mère?
6. **Timeline** : Quand tu veux ça prêt pour présentation?

### Recommandations

**Ta direction est bonne** mais incomplète. Tu dois implémenter un vrai système de profil AVANT de permettre la synchronisation multi-appareil. Sinon c'est ingérable et très risqué pour la confidentialité.

**Pour ARIA** : Je recommande Render.com free tier (limité mais fonctionne) ou intégrer ARIA directement dans CIA (pas de serveur séparé).

**Pour BBIA** : Actuellement c'est un placeholder. Ne pas faire espérer le client si pas prêt. Clarifier roadmap.

---

## 🔗 Voir aussi

- **[CE_QUI_MANQUE_10_DECEMBRE_2025.md](./../CE_QUI_MANQUE_10_DECEMBRE_2025.md)** — Liste mise à jour avec nouveaux problèmes
- **[CORRECTIONS_NAVIGATION_AUTH_10_DEC.md](./../deployment/CORRECTIONS_NAVIGATION_AUTH_10_DEC.md)** — Corrections précédentes
- **[AUDIT_SECURITE_PERFECTION_DECEMBRE_2025.md](./AUDIT_SECURITE_PERFECTION_DECEMBRE_2025.md)** — Audit sécurité (10/10)

---

<div align="center">

**Dernière mise à jour** : 12 décembre 2025  
**Prochaine étape** : Implémentation corrections critiques (Semaine 1)

**Total problèmes** : 20 | **Critiques** : 8 | **Élevés** : 7 | **Moyens** : 5

**Corrections appliquées** : 3/8 critiques (Biométrie, PDF, Connexion) + Tests corrigés (15/15 passent)

</div>
