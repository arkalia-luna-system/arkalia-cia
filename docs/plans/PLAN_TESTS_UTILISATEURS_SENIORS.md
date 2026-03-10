## 🧪 Plan de tests utilisateurs seniors – Arkalia CIA

**Objectif** : Valider que l’application est réellement utilisable, compréhensible et confortable pour des utilisateurs seniors (65–85 ans), sur les parcours clés prévus pour ta mère et d’autres familles.

**Public cible** :  
- Utilisatrices/eurs seniors (vue, motricité, mémoire variables).  
- Proches aidants (en soutien, mais sans prendre la main en permanence).  

---

## 1. Parcours à tester (scénarios concrets)

Chaque scénario doit être testé **de bout en bout**, sans aide technique directe, en observant :
- le temps nécessaire,
- le nombre d’erreurs / blocages,
- le niveau de stress perçu,
- la satisfaction à chaud.

### Scénario A – Gestion de documents médicaux
- A1. Ouvrir l’app depuis l’icône (PWA installée).
- A2. Aller sur `Documents`.
- A3. Importer un nouveau PDF médical.
- A4. Retrouver un document existant via la recherche.
- A5. Ouvrir ce document et le lire.
- A6. Supprimer un document inutile.

### Scénario B – Rappels et calendrier
- B1. Créer un rappel simple pour un rendez-vous médical.
- B2. Vérifier que le rappel apparaît dans le calendrier.
- B3. Modifier l’heure du rappel.
- B4. Marquer un rappel comme terminé.
- B5. Comprendre la vue calendrier (légende, couleurs, icônes).

### Scénario C – Urgence et contacts
- C1. Ouvrir l’écran `Urgence`.
- C2. Ajouter un contact ICE (nom + téléphone).
- C3. Démarrer un appel d’urgence en un tap (sans se tromper de contact).
- C4. Accéder / modifier les informations médicales d’urgence.

### Scénario D – Médecins & pathologies
- D1. Ajouter un nouveau médecin avec la bonne spécialité (codes couleur).
- D2. Retrouver rapidement un médecin existant.
- D3. Ajouter une pathologie à partir d’un template.
- D4. Comprendre un graphique de suivi simple (sans explication orale).

### Scénario E – Rapport pré‑consultation & partage
- E1. Depuis les documents, préparer les éléments pour un prochain rendez‑vous.
- E2. Générer un rapport pré‑consultation (CIA/ARIA si dispo).
- E3. Partager ce rapport ou des documents clés avec un membre de la famille.
- E4. Vérifier que la famille a bien reçu / peut ouvrir ce qui a été partagé.

### Scénario F – Recherche avancée
- F1. Utiliser la barre de recherche pour retrouver “les examens de sang de l’année dernière”.
- F2. Appliquer au moins un filtre (date ou médecin).
- F3. Comprendre la différence entre résultats “pertinents” et “exact match” si affichée.

---

## 2. Métriques à collecter

Pour chaque participant et chaque scénario :
- ⏱️ **Temps de réalisation** (du début à la fin du scénario).
- ❌ **Nombre d’erreurs** (taps au mauvais endroit, retours en arrière non voulus, incompréhensions).
- 🆘 **Demandes d’aide** (combien de fois la personne demande “je ne comprends pas / aide‑moi”).
- 🙂 **Satisfaction** (note 1–5 à chaud après chaque scénario).
- 🧠 **Charge mentale perçue** (question : “Était‑ce simple, moyen ou compliqué ?”).

Objectifs cibles (pour considérer “market ready” sur ce périmètre) :
- Au moins **80 % des tâches réussies sans aide** au deuxième essai.  
- Temps de réalisation global raisonnable (par ex. **< 5 min** pour un scénario complet A, B ou C).  
- Satisfaction moyenne **≥ 4/5** sur les parcours A–C.  

---

## 3. Méthode de test

### 3.1. Préparation
- Choisir 3 à 5 personnes seniors (dont ta mère) avec profils variés.
- Préparer un **script d’observation** (liste des scénarios + cases à cocher).
- Installer la PWA à l’avance sur leurs appareils (ou sur un appareil de test dédié).

### 3.2. Conduite de session
- Expliquer que **ce n’est pas la personne qui est testée, mais l’app**.
- Laisser la personne faire, sans l’interrompre, en notant uniquement :
  - ce qu’elle dit spontanément,
  - où elle se bloque,
  - ce qu’elle ne comprend pas.
- N’aider que si elle est vraiment bloquée, en notant clairement le moment d’aide.

### 3.3. Debrief à chaud
- Après chaque scénario, poser 3 questions simples :
  1. “Est‑ce que c’était facile, moyen ou compliqué ?”
  2. “Qu’est‑ce qui t’a gênée ou stressée ?”
  3. “Qu’est‑ce qui t’a plu / rassurée ?”
- Noter les réponses mot à mot quand c’est possible.

---

## 4. Journalisation et suivi

Créer un fichier par participante (par ex. `tests_utilisateurs/logs/maman-YYYY-MM-DD.md`) contenant :
- Contexte (date, appareil, version app).
- Tableau des scénarios avec :
  - statut (réussi / échoué / avec aide),
  - temps,
  - erreurs,
  - commentaires notables.
- Synthèse par personne (forces, difficultés récurrentes).

Ensuite, consolider dans un document global (par ex. `tests_utilisateurs/RESULTATS_GLOBALS.md`) :
- problèmes communs entre plusieurs personnes,
- améliorations prioritaires à faire,
- points qui fonctionnent très bien (à préserver).

---

## 5. Lien avec le plan d’amélioration existant

Les retours de ces tests doivent alimenter directement :
- les tâches “Guidance première utilisation” et “Guide interactif” du `PLAN_FUTUR_AMELIORATIONS.md`,
- les priorités dans `CE_QUI_RESTE_A_FAIRE.md` (par exemple si la recherche avancée est jugée trop complexe),
- les choix de wording et de taille de texte dans l’UI.

**But final** : après 1–2 itérations de tests + corrections, avoir des données concrètes montrant que les seniors réussissent les parcours critiques avec peu d’aide, et que l’app est perçue comme simple et rassurante.

