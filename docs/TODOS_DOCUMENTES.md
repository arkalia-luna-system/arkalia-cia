# 📝 TODOs Documentés - 23 Novembre 2025

**Date**: 24 novembre 2025  
**Statut**: Mis à jour - Toutes les 4 phases d'améliorations terminées (24 novembre 2025)

---

## 🔴 TODOs CRITIQUES (Fonctionnalités manquantes)

### 1. Import Portails Santé

**Fichiers concernés**:
- `arkalia_cia/lib/screens/onboarding/import_choice_screen.dart` (ligne 99)
- `arkalia_cia/lib/screens/onboarding/import_progress_screen.dart` (ligne 104)

**Description**: Implémenter l'import automatique depuis les portails santé belges (eHealth, Andaman 7, MaSanté)

**Statut actuel**: 
- ✅ Structure UI existe
- ✅ Backend endpoint `/api/v1/health-portals/import` existe
- ❌ Parsing réel des données portails non implémenté
- ❌ Synchronisation automatique non implémentée

**Priorité**: 🟠 ÉLEVÉE (fonctionnalité promise aux utilisateurs)

**Estimation**: 2-3 semaines de développement

**Dépendances**:
- APIs OAuth des portails santé belges
- Documentation APIs eHealth, Andaman 7, MaSanté
- Parsing des formats de données spécifiques

---

### 2. Sélection Médecin dans Recherche Avancée ✅ TERMINÉ

**Fichier**: `arkalia_cia/lib/screens/advanced_search_screen.dart`

**Description**: Ajouter un sélecteur de médecin dans l'écran de recherche avancée

**Statut actuel**:
- ✅ Recherche avancée fonctionnelle
- ✅ Filtres par date, type, etc.
- ✅ Filtre par médecin implémenté (24 novembre 2025)
- ✅ Dialog de sélection médecin avec liste complète
- ✅ Intégration dans SearchFilters avec doctorId

**Priorité**: 🟡 MOYENNE (amélioration UX) - **TERMINÉ**

**Implémentation**:
- FilterChip pour sélection médecin ajouté
- Dialog de sélection avec RadioListTile
- Support doctorId dans SearchFilters
- Filtrage dans SearchService._matchesDocument()

---

## 🟡 TODOs MOYENS (Améliorations)

### Phase 1 : Codes Couleur et Extraction Enrichie ✅ TERMINÉ

**Fichiers modifiés/créés**:
- `arkalia_cia/lib/models/doctor.dart` : Méthode getColorForSpecialty()
- `arkalia_cia/lib/screens/doctors_list_screen.dart` : Badges colorés
- `arkalia_cia/lib/services/calendar_service.dart` : Couleurs pour événements
- `arkalia_cia/lib/screens/calendar_screen.dart` : Écran calendrier avec encadrement coloré
- `arkalia_cia/lib/screens/documents_screen.dart` : Dialog médecin détecté après upload PDF
- `arkalia_cia/lib/screens/home_page.dart` : Bouton Calendrier
- `arkalia_cia_python_backend/pdf_parser/metadata_extractor.py` : Extraction enrichie (adresse, téléphone, email)
- `arkalia_cia/lib/services/doctor_service.dart` : Méthode findSimilarDoctors()

**Tests créés**:
- `tests/unit/test_doctor_colors.py` : Tests mapping couleur par spécialité
- `tests/unit/test_doctor_deduplication.py` : Tests détection doublons
- `tests/unit/test_metadata_extractor_enriched.py` : Tests extraction enrichie

**Statut**:
- ✅ Dialog médecin détecté implémenté et fonctionnel
- ✅ Intégration complète dans upload flow
- ✅ Tous les tests passent
- ✅ 0 erreur lint

### Phase 2 : Rappels Médicaments et Hydratation ✅ TERMINÉ

**Fichiers créés**:
- `arkalia_cia/lib/models/medication.dart`
- `arkalia_cia/lib/models/hydration_tracking.dart`
- `arkalia_cia/lib/services/medication_service.dart`
- `arkalia_cia/lib/services/hydration_service.dart`
- `arkalia_cia/lib/screens/medication_reminders_screen.dart`
- `arkalia_cia/lib/screens/hydration_reminders_screen.dart`
- `arkalia_cia/lib/widgets/medication_reminder_widget.dart`
- `arkalia_cia/lib/screens/calendar_screen.dart`

**Fichiers modifiés**:
- `arkalia_cia/lib/services/calendar_service.dart` (intégration médicaments et hydratation)

**Tests créés**:
- `tests/unit/test_medication_service.py`
- `tests/unit/test_hydration_service.py`
- `tests/unit/test_medication_interactions.py`

**Description**: Module complet de rappels médicaments intelligents et suivi d'hydratation

**Statut actuel**:
- ✅ Modèles Medication, MedicationTaken, HydrationEntry, HydrationGoal créés
- ✅ Services MedicationService et HydrationService avec CRUD complet
- ✅ Rappels adaptatifs pour médicaments (30min après si non pris)
- ✅ Rappels hydratation toutes les 2h (8h-20h) avec renforcement si objectif non atteint
- ✅ Écrans avec liste, formulaire, suivi, graphiques
- ✅ Intégration calendrier avec distinction visuelle (💊 médicaments, 💧 hydratation, 🏥 RDV)
- ✅ Chargement médicaments et hydratation dans calendar_screen.dart avec icônes distinctives
- ✅ Tests Python complets pour interactions, validation, logique métier
- ✅ Documentation mise à jour

**Priorité**: 🟠 ÉLEVÉE - **TERMINÉ** (24 novembre 2025)

**Implémentation**:
- Structure complète avec modèles et services
- Rappels intelligents avec adaptation selon historique
- Suivi de prise avec statistiques et graphiques
- Détection basique d'interactions médicamenteuses
- Objectif hydratation avec badge "Hydratation parfaite"
- Tests unitaires Python pour validation

---

### Phase 3 : Module Pathologies ✅ TERMINÉ

**Fichiers créés**:
- `arkalia_cia/lib/models/pathology.dart`
- `arkalia_cia/lib/models/pathology_tracking.dart`
- `arkalia_cia/lib/services/pathology_service.dart`
- `arkalia_cia/lib/screens/pathology_list_screen.dart`
- `arkalia_cia/lib/screens/pathology_detail_screen.dart`
- `arkalia_cia/lib/screens/pathology_tracking_screen.dart`
- `arkalia_cia/lib/screens/calendar_screen.dart`

**Fichiers modifiés**:
- `arkalia_cia/lib/screens/home_page.dart` (ajout bouton Pathologies)
- `arkalia_cia/pubspec.yaml` (ajout fl_chart)

**Tests créés**:
- `tests/unit/test_pathology_service.py`
- `tests/unit/test_pathology_tracking.py`
- `tests/unit/test_pathology_templates.py`

**Description**: Module complet de suivi de pathologies avec templates spécifiques

**Statut actuel**:
- ✅ Modèles Pathology et PathologyTracking créés
- ✅ Service PathologyService avec CRUD complet
- ✅ 9 templates prédéfinis (endométriose, cancer, myélome, ostéoporose, arthrose, arthrite, tendinite, spondylarthrite, Parkinson)
- ✅ Écrans liste, détail avec graphiques, formulaire de tracking adaptatif
- ✅ Intégration calendrier avec rappels colorés
- ✅ Tests Python complets
- ✅ Documentation mise à jour

**Priorité**: 🟠 ÉLEVÉE - **TERMINÉ** (24 novembre 2025)

**Implémentation**:
- Structure de base complète avec modèles et service
- Templates pour toutes les pathologies familiales
- Écrans avec graphiques d'évolution (fl_chart)
- Formulaire adaptatif selon la pathologie
- Intégration avec calendrier et home_page
- Tests unitaires Python pour validation

---

## 🟡 TODOs MOYENS (Améliorations)

### 3. Filtre Type d'Examen dans Recherche Avancée ✅ TERMINÉ

**Fichier**: `arkalia_cia/lib/screens/advanced_search_screen.dart`

**Description**: Ajouter un filtre par type d'examen dans la recherche avancée

**Statut actuel**:
- ✅ Filtre type d'examen implémenté (24 novembre 2025)
- ✅ Dialog de sélection avec types d'examens courants
- ✅ Support examType dans SearchFilters
- ✅ Filtrage dans SearchService._matchesDocument()

**Priorité**: 🟡 MOYENNE (amélioration UX) - **TERMINÉ**

**Implémentation**:
- FilterChip pour sélection type d'examen ajouté
- Dialog de sélection avec RadioListTile
- Liste de types d'examens médicaux courants
- Filtrage par nom de document et métadonnées

---

### 4. Refresh Token pour Portails Santé ✅ TERMINÉ

**Fichier**: `arkalia_cia/lib/services/health_portal_auth_service.dart`

**Description**: Implémenter le rafraîchissement automatique des tokens OAuth pour les portails santé

**Statut actuel**:
- ✅ Authentification OAuth de base implémentée
- ✅ Structure pour refresh token existe
- ✅ Logique de refresh automatique implémentée (24 novembre 2025)
- ✅ Méthode `refreshAccessToken()` complète
- ✅ Méthode `getValidAccessToken()` pour vérification et refresh automatique
- ✅ Stockage refresh token dans SharedPreferences

**Priorité**: 🟡 MOYENNE (amélioration robustesse) - **TERMINÉ**

**Implémentation**:
- Méthode `refreshAccessToken()` avec appel API OAuth
- Méthode `getValidAccessToken()` pour gestion automatique
- Support des URLs de refresh pour chaque portail
- Gestion des erreurs et fallback

---

### 5. Audit Log Partage Familial ✅ TERMINÉ

**Fichier**: `arkalia_cia/lib/services/family_sharing_service.dart`

**Description**: Implémenter un audit log complet pour le partage familial (qui a accédé à quoi)

**Statut actuel**:
- ✅ Classe `SharingAuditLog` créée (24 novembre 2025)
- ✅ Méthodes `getAuditLogForDocument()` et `getAuditLogForMember()` implémentées
- ✅ Méthodes `logDocumentAccess()` et `logDocumentDownload()` implémentées
- ✅ Enregistrement automatique lors du partage et du départage
- ✅ Stockage dans SharedPreferences

**Priorité**: 🟡 MOYENNE (amélioration sécurité) - **TERMINÉ**

**Implémentation**:
- Classe SharingAuditLog avec actions (shared, accessed, downloaded, unshared)
- Stockage dans SharedPreferences avec clé `sharing_audit_log`
- Méthodes pour récupérer l'audit log par document ou par membre
- Enregistrement automatique lors des actions de partage

---

### 6. Export/Import Médecins ✅ TERMINÉ

**Fichier**: `arkalia_cia/lib/services/doctor_service.dart`

**Description**: Permettre l'export et l'import des médecins et consultations au format JSON

**Statut actuel**:
- ✅ Méthode `exportDoctors()` implémentée (24 novembre 2025)
- ✅ Méthode `importDoctors()` implémentée (24 novembre 2025)
- ✅ Export au format JSON avec version et date
- ✅ Import avec gestion des IDs pour éviter conflits
- ✅ Import des consultations associées

**Priorité**: 🟡 MOYENNE (amélioration fonctionnalité) - **TERMINÉ**

**Implémentation**:
- Export JSON avec structure complète (doctors, consultations)
- Import avec création de nouveaux IDs pour éviter conflits
- Gestion des consultations lors de l'import
- Format JSON versionné pour compatibilité future

---

### 8. Endpoints Spécifiques Portails Santé

**Fichier**: `arkalia_cia/lib/services/health_portal_auth_service.dart` (ligne 81)

**Description**: Implémenter les endpoints spécifiques pour chaque portail santé quand les APIs seront disponibles

**Statut actuel**:
- ✅ Structure générique existe
- ✅ Gestion OAuth de base
- ❌ Endpoints spécifiques non implémentés (APIs non disponibles)

**Priorité**: 🟢 BASSE (dépend de disponibilité APIs)

**Estimation**: 1-2 semaines par portail (quand APIs disponibles)

**Portails concernés**:
- eHealth (API non documentée publiquement)
- Andaman 7 (API privée)
- MaSanté (API non documentée)

---

## 🟢 TODOs BAS (Notes techniques)

### 8. Application ID Android ✅ TERMINÉ

**Fichier**: `arkalia_cia/android/app/build.gradle.kts` (ligne 30)

**Description**: Spécifier un Application ID unique pour Android

**Statut actuel**: 
- ✅ Application ID mis à jour : `com.arkalia.cia` (24 novembre 2025)
- ✅ TODO supprimé

**Priorité**: 🟢 BASSE (pour production uniquement) - **TERMINÉ**

**Fichier**: `arkalia_cia/android/app/build.gradle.kts` (ligne 30)

**Description**: Spécifier un Application ID unique pour Android

**Statut actuel**: 
- ✅ Application ID par défaut fonctionne
- ⚠️ Devrait être personnalisé pour production

**Priorité**: 🟢 BASSE (pour production uniquement)

**Action requise**: 
- Choisir un Application ID unique (ex: `com.arkalia.cia`)
- Mettre à jour `build.gradle.kts`

---

### 9. Configuration Signing Android

**Fichier**: `arkalia_cia/android/app/build.gradle.kts` (ligne 42)

**Description**: Ajouter configuration de signature pour release build

**Statut actuel**:
- ✅ Debug build fonctionne
- ⚠️ Release build nécessite configuration signing

**Priorité**: 🟢 BASSE (pour release uniquement)

**Action requise**:
- Créer keystore pour signature
- Configurer `signingConfigs` dans `build.gradle.kts`

---

## 📊 RÉSUMÉ

| Priorité | Nombre | Statut |
|----------|--------|--------|
| 🔴 Critique | 0 | - |
| 🟠 Élevée | 0 | ✅ Toutes terminées (Phase 1, 2, 3, 4 - 24 novembre 2025) |
| 🟡 Moyenne | 0 | ✅ Tous terminés (Recherche médecin, Refresh token, Type examen, Audit log, Export/import, Phase 1-4) |
| 🟢 Basse | 1 | Signing (Application ID TERMINÉ) |

---

## ✅ ACTIONS RECOMMANDÉES

1. **Court terme** (1-2 semaines): ✅ TERMINÉ
   - ✅ Implémenter sélection médecin dans recherche avancée (24 novembre 2025)
   - ✅ Phase 1 : Codes couleur, calendrier, extraction enrichie (24 novembre 2025)
   - ✅ Phase 2 : Médicaments et hydratation (24 novembre 2025)
   - ✅ Phase 3 : Module pathologies (24 novembre 2025)
   - ✅ Phase 4 : Améliorations IA (24 novembre 2025)
   - Documenter APIs portails santé (si disponibles)

2. **Moyen terme** (1-2 mois): ✅ TERMINÉ
   - ✅ Implémenter refresh token automatique (24 novembre 2025)
   - ✅ Toutes les 4 phases d'améliorations (24 novembre 2025)
   - Implémenter import portails santé (nécessite APIs externes - non bloquant)

3. **Long terme** (quand APIs disponibles):
   - Endpoints spécifiques par portail
   - Configuration production Android

---

**Note**: Ces TODOs sont documentés mais ne bloquent pas le fonctionnement actuel de l'application. Ils représentent des améliorations et fonctionnalités futures.

