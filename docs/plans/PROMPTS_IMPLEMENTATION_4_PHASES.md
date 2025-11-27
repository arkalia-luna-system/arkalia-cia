# Prompts d'Implémentation — 4 Phases

**Date** : 27 novembre 2025  
**Version** : 1.0  
**Objectif** : Prompts détaillés pour implémentation autonome de chaque phase

---

## 📋 INSTRUCTIONS GÉNÉRALES (À APPLIQUER À CHAQUE PHASE)

Avant de commencer chaque phase, lire ces instructions :

1. **Analyser l'existant** : Lire les fichiers mentionnés dans les références
2. **Implémenter proprement** : Code archi-propre, commentaires, documentation
3. **Créer les tests** : Tests unitaires pour toutes les nouvelles fonctionnalités
4. **Vérifier le lint** : 0 erreur Flutter, 0 erreur Python
5. **Mettre à jour la doc** : Mettre à jour les MD existants (ne pas en créer de nouveaux)
6. **Vérifier tout** : Tests passent, lint OK, doc à jour
7. **Commit et push** : Quand tout est parfait, commit avec message descriptif et push sur develop

**Date de référence** : 27 novembre 2025

---

## 🎨 PHASE 1 : Codes Couleur, Encadrement Calendrier, Extraction Enrichie

### Prompt Phase 1

```
Je dois implémenter la Phase 1 des améliorations pour Arkalia CIA selon le document BESOINS_MERE_23_NOVEMBRE_2025.md.

OBJECTIFS DE LA PHASE 1 :
1. Codes couleur par spécialité de médecin
2. Encadrement visuel dans le calendrier pour les RDV
3. Extraction enrichie (adresse, téléphone, email) des médecins depuis PDF

TÂCHES DÉTAILLÉES :

1. CODES COULEUR PAR SPÉCIALITÉ
   - Modifier arkalia_cia/lib/models/doctor.dart :
     * Ajouter méthode statique getColorForSpecialty(String? specialty) qui retourne une Color
     * Mapping spécialité → couleur (Cardiologue: rouge, Dermatologue: orange, Gynécologue: rose, etc.)
     * Couleur par défaut si spécialité inconnue
   - Modifier arkalia_cia/lib/screens/doctors_list_screen.dart :
     * Ajouter un Container coloré (badge) à côté du nom de chaque médecin
     * Utiliser doctor.getColorForSpecialty() pour la couleur
     * Badge de 12x12 pixels, arrondi
   - Modifier arkalia_cia/lib/services/calendar_service.dart :
     * Utiliser la couleur du médecin pour les événements calendrier
     * Si RDV avec médecin, utiliser sa couleur
   - Créer arkalia_cia/lib/screens/calendar_screen.dart :
     * Écran calendrier dédié avec vue mensuelle
     * Utiliser package table_calendar ou syncfusion_flutter_calendar
     * Afficher les RDV avec encadrement coloré selon le médecin
     * En cliquant sur un RDV, popup avec détails (médecin, adresse, documents à apporter)
   - Ajouter bouton "Calendrier" dans home_page.dart

2. EXTRACTION ENRICHIE MÉDECINS
   - Modifier arkalia_cia_python_backend/pdf_parser/metadata_extractor.py :
     * Ajouter méthode _extract_address() : patterns pour adresses belges (rue, avenue, numéro, code postal)
     * Ajouter méthode _extract_phone() : patterns pour téléphones belges (04XX/XX.XX.XX, +32, etc.)
     * Ajouter méthode _extract_email() : pattern email standard
     * Modifier extract_metadata() pour inclure ces nouvelles données
   - Modifier arkalia_cia/lib/screens/documents_screen.dart ou upload flow :
     * Après upload PDF, si médecin détecté, afficher dialog "Médecin détecté : Dr. X. Voulez-vous l'ajouter à l'annuaire ?"
     * Pré-remplir le formulaire avec les données extraites
     * Permettre à l'utilisateur de modifier avant de sauvegarder

3. DÉDUPLICATION INTELLIGENTE
   - Modifier arkalia_cia/lib/services/doctor_service.dart :
     * Ajouter méthode findSimilarDoctors(Doctor doctor) qui cherche des médecins similaires
     * Comparer nom + spécialité (tolérance aux variations d'orthographe)
     * Si doublon détecté, proposer de fusionner ou compléter les infos

TESTS À CRÉER :
- tests/unit/test_doctor_colors.py : Tester le mapping couleur par spécialité
- tests/unit/test_metadata_extractor_enriched.py : Tester extraction adresse, téléphone, email
- tests/unit/test_doctor_deduplication.py : Tester la détection de doublons

VÉRIFICATIONS :
- Flutter analyze : 0 erreur
- Python lint (ruff, mypy) : 0 erreur
- Tests : Tous passent
- Coverage : Maintenir ou améliorer

DOCUMENTATION À METTRE À JOUR :
- docs/BESOINS_MERE_23_NOVEMBRE_2025.md : Marquer Phase 1 comme terminée
- docs/STATUT_FINAL_CONSOLIDE.md : Ajouter Phase 1 dans améliorations
- docs/TODOS_DOCUMENTES.md : Mettre à jour les TODOs concernés

QUAND TOUT EST PARFAIT :
- git add tous les fichiers modifiés/créés
- git commit -m "feat(phase1): Codes couleur médecins, encadrement calendrier, extraction enrichie"
- git push origin develop

Date : 27 novembre 2025
```

---

## 💊 PHASE 2 : Rappels Médicaments et Hydratation

### Prompt Phase 2

```
Je dois implémenter la Phase 2 des améliorations pour Arkalia CIA selon le document BESOINS_MERE_23_NOVEMBRE_2025.md.

OBJECTIFS DE LA PHASE 2 :
1. Module rappels médicaments intelligents
2. Module rappels hydratation

TÂCHES DÉTAILLÉES :

1. MODULE MÉDICAMENTS
   - Créer arkalia_cia/lib/models/medication.dart :
     * Classe Medication avec : id, name, dosage, frequency (daily, twice_daily, etc.), times (List<TimeOfDay>), startDate, endDate, notes
     * Méthodes toMap() et fromMap()
   - Créer arkalia_cia/lib/services/medication_service.dart :
     * CRUD complet pour médicaments (SQLite)
     * Méthode scheduleReminders(Medication) : programmer les rappels
     * Méthode markAsTaken(int medicationId, DateTime date) : marquer comme pris
     * Méthode getMissedDoses(DateTime date) : obtenir médicaments non pris
     * Méthode checkInteractions(List<Medication>) : vérifier interactions (basique)
   - Créer arkalia_cia/lib/screens/medication_reminders_screen.dart :
     * Liste des médicaments avec statut (pris/non pris)
     * Bouton "J'ai pris mon médicament" pour chaque médicament
     * Formulaire d'ajout/modification médicament
     * Graphique de suivi (combien de fois pris dans la semaine)
   - Modifier arkalia_cia/lib/services/calendar_service.dart :
     * Intégrer les rappels médicaments dans le calendrier
     * Rappels adaptatifs : si non pris, rappeler 30min après
   - Créer arkalia_cia/lib/widgets/medication_reminder_widget.dart :
     * Widget pour afficher un rappel médicament
     * Bouton "Pris" / "Ignorer"

2. MODULE HYDRATATION
   - Créer arkalia_cia/lib/models/hydration_tracking.dart :
     * Classe HydrationEntry avec : id, date, amount (ml), time
     * Classe HydrationGoal avec : dailyGoal (ml, default 2000ml = 8 verres)
   - Créer arkalia_cia/lib/services/hydration_service.dart :
     * CRUD pour entrées hydratation
     * Méthode getDailyProgress(DateTime date) : progression quotidienne
     * Méthode scheduleReminders() : rappels toutes les 2h (8h-20h)
     * Méthode markAsDrank(int amount) : enregistrer consommation
   - Créer arkalia_cia/lib/screens/hydration_reminders_screen.dart :
     * Affichage objectif quotidien (ex: 8 verres)
     * Barre de progression visuelle
     * Boutons rapides "1 verre", "2 verres", etc.
     * Graphique consommation sur la semaine
     * Badge "Hydratation parfaite" si objectif atteint
   - Modifier arkalia_cia/lib/services/calendar_service.dart :
     * Intégrer rappels hydratation (toutes les 2h)
     * Si pas de prise enregistrée, rappeler plus souvent

3. INTÉGRATION CALENDRIER
   - Modifier arkalia_cia/lib/screens/calendar_screen.dart :
     * Afficher les rappels médicaments avec icône 💊
     * Afficher les rappels hydratation avec icône 💧
     * Distinction visuelle : RDV (encadré coloré), médicaments (icône), hydratation (icône)

TESTS À CRÉER :
- tests/unit/test_medication_service.py : Tester CRUD, rappels, suivi prise
- tests/unit/test_hydration_service.py : Tester suivi, rappels, objectifs
- tests/unit/test_medication_interactions.py : Tester détection interactions (basique)

VÉRIFICATIONS :
- Flutter analyze : 0 erreur
- Python lint : 0 erreur
- Tests : Tous passent
- Coverage : Maintenir ou améliorer

DOCUMENTATION À METTRE À JOUR :
- docs/BESOINS_MERE_23_NOVEMBRE_2025.md : Marquer Phase 2 comme terminée
- docs/STATUT_FINAL_CONSOLIDE.md : Ajouter Phase 2 dans améliorations
- docs/TODOS_DOCUMENTES.md : Mettre à jour les TODOs concernés

QUAND TOUT EST PARFAIT :
- git add tous les fichiers modifiés/créés
- git commit -m "feat(phase2): Module rappels médicaments et hydratation intelligents"
- git push origin develop

Date : 27 novembre 2025
```

---

## 🏥 PHASE 3 : Module Pathologies

### Prompt Phase 3

```
Je dois implémenter la Phase 3 des améliorations pour Arkalia CIA selon le document BESOINS_MERE_23_NOVEMBRE_2025.md.

OBJECTIFS DE LA PHASE 3 :
1. Structure de base pour le suivi de pathologies
2. Templates pour pathologies spécifiques (endométriose, cancer, myélome, ostéoporose, arthrose, arthrite, tendinite, spondylarthrite, Parkinson)

TÂCHES DÉTAILLÉES :

1. STRUCTURE DE BASE
   - Créer arkalia_cia/lib/models/pathology.dart :
     * Classe Pathology avec : id, name, description, symptoms (List<String>), treatments (List<String>), exams (List<String>), reminders (Map<String, ReminderConfig>), color
     * Classe ReminderConfig avec : type, frequency, times
   - Créer arkalia_cia/lib/models/pathology_tracking.dart :
     * Classe PathologyTracking avec : id, pathologyId, date, data (Map<String, dynamic>), notes
     * data peut contenir : symptoms, painLevel, measurements, etc.
   - Créer arkalia_cia/lib/services/pathology_service.dart :
     * CRUD pour pathologies
     * CRUD pour tracking entries
     * Méthode getPathologyStats(int pathologyId, DateTime startDate, DateTime endDate)
     * Méthode scheduleReminders(Pathology pathology)
   - Créer arkalia_cia/lib/screens/pathology_list_screen.dart :
     * Liste des pathologies suivies
     * Bouton pour ajouter une pathologie
     * Carte colorée par pathologie
   - Créer arkalia_cia/lib/screens/pathology_detail_screen.dart :
     * Détails d'une pathologie
     * Graphiques d'évolution (symptômes, douleurs, etc.)
     * Liste des entrées de tracking
     * Bouton "Ajouter entrée" pour enregistrer symptômes/mesures
   - Créer arkalia_cia/lib/screens/pathology_tracking_screen.dart :
     * Formulaire pour enregistrer une entrée de tracking
     * Champs adaptatifs selon la pathologie
     * Exemple : pour endométriose → cycle, douleurs, saignements

2. TEMPLATES PAR PATHOLOGIE
   Créer des templates prédéfinis dans pathology_service.dart :
   
   - ENDOMÉTRIOSE :
     * Symptoms : ["Douleurs pelviennes", "Règles douloureuses", "Saignements", "Fatigue"]
     * Exams : ["Échographie pelvienne", "IRM pelvienne", "Laparoscopie"]
     * Reminders : Rappels examens, suivi cycle
     * Tracking : cycle, douleurs (intensité 1-10), saignements, fatigue
   
   - CANCER :
     * Symptoms : ["Fatigue", "Nausées", "Douleurs", "Perte d'appétit"]
     * Exams : ["Scanner", "IRM", "Biopsie", "Analyses sanguines"]
     * Reminders : Rappels traitements (chimiothérapie, radiothérapie), examens
     * Tracking : traitements, effets secondaires, examens
   
   - MYÉLOME :
     * Symptoms : ["Douleurs osseuses", "Fatigue", "Infections"]
     * Exams : ["IRM", "Biopsie médullaire", "Analyses sanguines"]
     * Reminders : Rappels examens, traitements
     * Tracking : douleurs osseuses, analyses biologiques
   
   - OSTÉOPOROSE :
     * Symptoms : ["Douleurs", "Fractures"]
     * Exams : ["Densitométrie osseuse"]
     * Reminders : Rappels examens, activité physique, calcium/vitamine D
     * Tracking : fractures, activité physique
   
   - ARTHROSE / ARTHRITE / TENDINITE / SPONDYLARTHRITE :
     * Symptoms : ["Douleurs articulaires", "Raideur", "Gonflement"]
     * Exams : ["Radiographie", "Échographie articulaire", "IRM"]
     * Reminders : Rappels médicaments (anti-inflammatoires), kinésithérapie
     * Tracking : douleurs (localisation, intensité), mobilité, médicaments
     * Intégration ARIA : Lier avec suivi douleur ARIA
   
   - PARKINSON :
     * Symptoms : ["Tremblements", "Rigidité", "Bradykinésie", "Troubles de l'équilibre"]
     * Exams : ["Consultation neurologue"]
     * Reminders : Rappels médicaments (horaires stricts), kinésithérapie
     * Tracking : symptômes, médicaments, mobilité

3. INTÉGRATION AVEC EXISTANT
   - Modifier arkalia_cia/lib/screens/calendar_screen.dart :
     * Afficher les rappels spécifiques aux pathologies
     * Encadrement coloré selon la pathologie
   - Modifier arkalia_cia/lib/services/aria_integration.dart (si existe) :
     * Lier le suivi douleur ARIA avec les pathologies (arthrose, etc.)
   - Modifier arkalia_cia/lib/screens/home_page.dart :
     * Ajouter bouton "Pathologies" ou intégrer dans "Santé"

TESTS À CRÉER :
- tests/unit/test_pathology_service.py : Tester CRUD, templates, tracking
- tests/unit/test_pathology_tracking.py : Tester enregistrement entrées, statistiques
- tests/unit/test_pathology_templates.py : Tester chaque template de pathologie

VÉRIFICATIONS :
- Flutter analyze : 0 erreur
- Python lint : 0 erreur
- Tests : Tous passent
- Coverage : Maintenir ou améliorer

DOCUMENTATION À METTRE À JOUR :
- docs/BESOINS_MERE_23_NOVEMBRE_2025.md : Marquer Phase 3 comme terminée
- docs/STATUT_FINAL_CONSOLIDE.md : Ajouter Phase 3 dans améliorations
- docs/TODOS_DOCUMENTES.md : Mettre à jour les TODOs concernés

QUAND TOUT EST PARFAIT :
- git add tous les fichiers modifiés/créés
- git commit -m "feat(phase3): Module suivi pathologies avec templates spécifiques"
- git push origin develop

Date : 27 novembre 2025
```

---

## 🤖 PHASE 4 : Améliorations IA

### Prompt Phase 4

```
Je dois implémenter la Phase 4 des améliorations pour Arkalia CIA selon le document BESOINS_MERE_23_NOVEMBRE_2025.md.

OBJECTIFS DE LA PHASE 4 :
1. Reconnaissance améliorée des examens et médecins
2. Suggestions intelligentes
3. IA conversationnelle améliorée pour pathologies

TÂCHES DÉTAILLÉES :

1. RECONNAISSANCE AMÉLIORÉE
   - Modifier arkalia_cia_python_backend/pdf_parser/metadata_extractor.py :
     * Enrichir exam_patterns avec plus de variantes (synonymes, abréviations)
     * Enrichir doctor_patterns avec plus de formats
     * Améliorer _extract_exam_type() avec scoring de confiance
     * Si confiance < 0.7, marquer comme "nécessite vérification"
   - Modifier arkalia_cia/lib/screens/documents_screen.dart :
     * Afficher badge "Type détecté : Scanner" avec icône
     * Si type non détecté ou confiance faible, afficher "Type suggéré : Scanner ?" avec bouton confirmer
     * Catégorisation visuelle : icônes différentes par type d'examen
   - Créer arkalia_cia/lib/widgets/exam_type_badge.dart :
     * Widget badge coloré avec icône selon type d'examen
     * Utiliser dans la liste des documents

2. SUGGESTIONS INTELLIGENTES
   - Modifier arkalia_cia_python_backend/ai/conversational_ai.py :
     * Ajouter méthode suggestExamType(String text) : suggère le type d'examen le plus probable
     * Ajouter méthode suggestDoctorCompletion(Doctor partialDoctor) : suggère de compléter les infos manquantes
     * Ajouter méthode detectDuplicates(List<Doctor> doctors) : détecte doublons avec scoring
   - Modifier arkalia_cia/lib/screens/add_edit_doctor_screen.dart :
     * Si médecin détecté depuis PDF, pré-remplir avec suggestions
     * Afficher "Suggestion : Adresse pourrait être..." avec bouton accepter
   - Modifier arkalia_cia/lib/services/search_service.dart :
     * Améliorer suggestions de recherche avec contexte
     * Si recherche "scanner", suggérer aussi "IRM", "tomodensitométrie"

3. IA CONVERSATIONNELLE PATHOLOGIES
   - Modifier arkalia_cia_python_backend/ai/conversational_ai.py :
     * Ajouter méthode answerPathologyQuestion(String question, List<Pathology> pathologies) :
       * Détecter quelle pathologie est mentionnée
       * Répondre avec informations spécifiques à la pathologie
       * Suggérer examens, traitements, rappels
     * Ajouter méthode suggestQuestionsForAppointment(int doctorId, List<Pathology> pathologies) :
       * Générer questions pertinentes selon pathologies suivies
       * Basé sur historique consultations et symptômes récents
   - Modifier arkalia_cia/lib/screens/conversational_ai_screen.dart :
     * Intégrer les pathologies dans le contexte de conversation
     * Afficher suggestions de questions selon pathologies
   - Créer arkalia_cia/lib/widgets/pathology_ai_suggestions.dart :
     * Widget affichant suggestions IA basées sur pathologies
     * Exemple : "Vous suivez l'arthrose. Questions à poser au rhumatologue : ..."

4. INTERFACE VISUELLE AMÉLIORÉE
   - Modifier arkalia_cia/lib/screens/documents_screen.dart :
     * Ajouter filtres rapides : "Voir tous les scanners", "Voir toutes les analyses"
     * Statistiques : Graphique répartition examens par type
     * Recherche par type d'examen avec autocomplétion
   - Modifier arkalia_cia/lib/screens/doctors_list_screen.dart :
     * Améliorer affichage avec badges colorés plus visibles
     * Légende des couleurs en bas de l'écran
     * Filtre par couleur (spécialité)

TESTS À CRÉER :
- tests/unit/test_metadata_extractor_improved.py : Tester améliorations extraction
- tests/unit/test_ai_suggestions.py : Tester suggestions IA
- tests/unit/test_pathology_ai.py : Tester IA conversationnelle pathologies

VÉRIFICATIONS :
- Flutter analyze : 0 erreur
- Python lint : 0 erreur
- Tests : Tous passent
- Coverage : Maintenir ou améliorer

DOCUMENTATION À METTRE À JOUR :
- docs/BESOINS_MERE_23_NOVEMBRE_2025.md : Marquer Phase 4 comme terminée, documenter toutes les améliorations
- docs/STATUT_FINAL_CONSOLIDE.md : Ajouter Phase 4 dans améliorations, mettre statut à 100%
- docs/TODOS_DOCUMENTES.md : Marquer tous les TODOs concernés comme terminés
- docs/CHANGELOG.md : Ajouter entrée pour toutes les phases

QUAND TOUT EST PARFAIT :
- git add tous les fichiers modifiés/créés
- git commit -m "feat(phase4): Améliorations IA - reconnaissance enrichie, suggestions intelligentes, IA pathologies"
- git push origin develop

Date : 27 novembre 2025
```

---

## 📝 CHECKLIST FINALE (À VÉRIFIER APRÈS CHAQUE PHASE)

- [ ] Code implémenté proprement avec commentaires
- [ ] Tests créés et tous passent
- [ ] Flutter analyze : 0 erreur
- [ ] Python lint (ruff, mypy) : 0 erreur
- [ ] Coverage maintenu ou amélioré
- [ ] Documentation MD mise à jour (pas de nouveaux fichiers créés)
- [ ] Tous les fichiers ajoutés au commit
- [ ] Message de commit descriptif
- [ ] Push sur develop effectué
- [ ] Date : 27 novembre 2025 dans les commits

---

## 🎯 UTILISATION

Pour chaque phase :
1. Copier le prompt de la phase
2. Le donner à l'IA qui va implémenter
3. L'IA travaille de manière autonome
4. Vérifier que tout est conforme
5. Passer à la phase suivante

Les phases peuvent être faites en parallèle par différentes IA si besoin, mais il est recommandé de les faire séquentiellement pour éviter les conflits.

---

*Document créé le 27 novembre 2025*

