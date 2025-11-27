# Cas d'Usage - Arkalia CIA

**Version** : 1.0.0  
**Date** : 27 novembre 2025  
**Statut** : Documentation Utilisateur

---

## Vue d'ensemble

Ce document présente des **cas d'usage concrets** pour différents profils d'utilisateurs d'Arkalia CIA. Chaque scénario montre comment l'application résout un problème réel de gestion de santé.

---

## 👤 Profil 1 : Senior Autonome (65-80 ans)

### Scénario : Gestion quotidienne de la santé

**Problème** : Marie, 72 ans, a plusieurs rendez-vous médicaux, prend des médicaments régulièrement, et doit garder ses documents médicaux organisés. Elle n'est pas à l'aise avec les technologies complexes.

**Solution avec Arkalia CIA** :

#### 1. **Organisation des documents médicaux**

**Avant** :
- Documents PDF éparpillés dans les emails
- Difficulté à retrouver un examen spécifique
- Pas de vue d'ensemble

**Avec CIA** :
1. Marie reçoit un PDF médical par email
2. Elle ouvre CIA → Documents → Bouton "+"
3. Elle sélectionne le PDF (ou le glisse-dépose)
4. Le document est automatiquement :
   - Chiffré et stocké localement
   - Organisé par catégorie (examen, ordonnance, etc.)
   - Indexé pour recherche rapide

**Résultat** : Marie trouve n'importe quel document en 2 clics, tout est sécurisé sur son téléphone.

#### 2. **Rappels médicaux intelligents**

**Avant** :
- Oubli de prendre ses médicaments
- Confusion sur les horaires
- Pas de rappel pour les RDV

**Avec CIA** :
1. Marie crée un rappel "Prendre médicament X" → Quotidien 8h
2. CIA :
   - Ajoute au calendrier natif du téléphone
   - Envoie une notification à 8h
   - Répète automatiquement chaque jour
3. Pour un RDV : "Consultation Dr. Martin" → 15/12/2025 14h
4. CIA rappelle 1 jour avant et 2h avant

**Résultat** : Marie ne rate plus ses médicaments ni ses rendez-vous.

#### 3. **Accès rapide aux portails santé**

**Avant** :
- Doit se souvenir des URLs des sites santé
- Connexion compliquée à chaque fois
- Perd du temps à chercher

**Avec CIA** :
1. Marie ouvre CIA → Santé
2. Voit tous les portails belges pré-configurés :
   - eHealth
   - Inami
   - Sciensano
   - SPF Santé Publique
   - Andaman 7
   - MaSanté
3. Un clic → Le portail s'ouvre dans le navigateur

**Résultat** : Accès instantané à tous les services santé belges.

---

## 👨‍⚕️ Profil 2 : Patient avec Douleur Chronique

### Scénario : Suivi douleur avec intégration ARIA

**Problème** : Jean, 45 ans, souffre de douleurs chroniques au genou. Il doit suivre ses douleurs quotidiennement mais oublie souvent. Il a du mal à expliquer ses douleurs au médecin lors des consultations.

**Solution avec CIA + ARIA** :

#### 1. **Suivi quotidien de la douleur**

**Avant** :
- Oublie de noter ses douleurs
- Pas de contexte (météo, activité, sommeil)
- Données dispersées

**Avec ARIA (intégré dans CIA)** :
1. Jean ouvre CIA → ARIA
2. Note sa douleur :
   - Intensité : 7/10 (curseur)
   - Localisation : Genou droit
   - Déclencheur : Activité physique
   - Contexte : Sommeil 6h, stress élevé, météo froide
3. ARIA enregistre automatiquement avec timestamp

**Résultat** : Historique complet et structuré de toutes les douleurs.

#### 2. **Détection de patterns**

**Avant** :
- Ne réalise pas que ses douleurs sont liées au sommeil
- Ne voit pas les corrélations

**Avec ARIA** :
1. Après 30 jours de suivi, ARIA détecte :
   - "Douleur ↑ de 40% les jours où sommeil <6h" (corrélation 0.78)
   - "Douleur ↑ en temps froid/humide" (corrélation 0.65)
2. ARIA envoie ces patterns à CIA
3. CIA peut maintenant :
   - Suggérer des rappels pour améliorer le sommeil
   - Avertir : "Attention, tu n'as dormi que 5h30. D'après tes patterns, tu risques d'avoir plus de douleur aujourd'hui."

**Résultat** : Jean comprend mieux ses douleurs et peut agir en prévention.

#### 3. **Préparation consultation médicale**

**Avant** :
- Arrive chez le médecin sans pouvoir se souvenir précisément
- "Je ne sais pas trop, ça fait mal de temps en temps"

**Avec CIA + ARIA** :
1. Avant le RDV, Jean ouvre CIA → Générer rapport médical
2. CIA combine automatiquement :
   - Documents médicaux pertinents (CIA)
   - Timeline douleur 30 derniers jours (ARIA)
   - Patterns détectés (ARIA)
   - Résumé consultations précédentes (CIA)
3. Génère un PDF structuré :
   ```
   RAPPORT MÉDICAL - Consultation du 23/11/2025
   ============================================
   
   DOCUMENTS MÉDICAUX
   - Radiographie genou du 20/09/2025
   - Ordonnance médicaments actuelle
   
   TIMELINE DOULEUR (30 derniers jours)
   - Intensité moyenne : 6.2/10
   - Pic douleur : 8/10 (12/11/2025, 14h30)
   - Localisation : Genou droit (78% des entrées)
   
   PATTERNS DÉTECTÉS
   - Corrélation forte : Douleur ↑ après sommeil <6h
   - Saisonnalité : Douleur ↑ en automne/hiver
   ```

**Résultat** : Le médecin reçoit un document structuré, consultation plus efficace.

---

## 👨‍👩‍👧 Profil 3 : Famille avec Parent Âgé

### Scénario : Partage sécurisé de santé familiale

**Problème** : Sophie, 50 ans, s'occupe de sa mère de 78 ans qui vit seule. Elle veut pouvoir l'aider à gérer sa santé sans violer sa vie privée.

**Solution avec CIA** :

#### 1. **Partage familial sécurisé**

**Avant** :
- Sophie ne sait pas quels médicaments sa mère prend
- Pas d'accès aux documents en cas d'urgence
- Inquiétude constante

**Avec CIA (Partage Familial)** :
1. La mère active le partage familial dans CIA
2. Choisit ce qu'elle veut partager :
   - Documents médicaux : ✅ Oui
   - Rappels : ✅ Oui
   - Contacts urgence : ✅ Oui
   - Détails intimes : ❌ Non
3. Invite Sophie via lien sécurisé
4. Sophie accède à un dashboard avec :
   - Vue d'ensemble santé
   - Documents partagés
   - Rappels importants
   - Contacts urgence

**Résultat** : Sophie peut aider sa mère tout en respectant sa vie privée.

#### 2. **Gestion d'urgence**

**Avant** :
- En cas d'urgence, pas d'accès aux infos médicales
- Doit appeler plusieurs personnes

**Avec CIA** :
1. La mère configure ses contacts ICE (In Case of Emergency) :
   - Sophie (fille) - Priorité 1
   - Dr. Martin (médecin) - Priorité 2
   - Frère - Priorité 3
2. En cas d'urgence, un clic sur "Urgence" dans CIA :
   - Affiche les contacts ICE
   - Appel en un clic
   - Affiche les infos médicales critiques (allergies, médicaments, groupe sanguin)

**Résultat** : Réaction rapide en cas d'urgence.

---

## 🏥 Profil 4 : Professionnel de Santé

### Scénario : Réception de rapports structurés

**Problème** : Dr. Martin reçoit souvent des patients qui arrivent sans documents, sans historique clair, et qui ont du mal à expliquer leurs symptômes.

**Solution avec CIA** :

#### 1. **Réception de rapports structurés**

**Avant** :
- Patient arrive sans documents
- "Je ne me souviens plus"
- Consultation inefficace

**Avec CIA (Export Médical)** :
1. Le patient génère un rapport médical dans CIA avant le RDV
2. Dr. Martin reçoit un PDF structuré avec :
   - Documents médicaux pertinents (scannés, organisés)
   - Timeline douleur/symptômes (si ARIA utilisé)
   - Patterns détectés (corrélations, tendances)
   - Historique consultations précédentes
   - Médicaments actuels
   - Allergies connues
3. Consultation plus efficace :
   - Dr. Martin a déjà le contexte
   - Peut poser des questions ciblées
   - Moins de temps perdu

**Résultat** : Consultations plus efficaces, meilleur suivi patient.

#### 2. **Format standardisé**

**Avant** :
- Chaque patient arrive avec des formats différents
- Difficile à intégrer dans le système du cabinet

**Avec CIA** :
- Format PDF standardisé
- Structure cohérente
- Facile à archiver dans le dossier patient du cabinet

**Résultat** : Intégration facile dans les systèmes médicaux existants.

---

## 🔄 Scénarios d'Intégration

### Scénario : Synchronisation CIA ↔ ARIA

**Contexte** : Utilisateur utilise à la fois CIA (documents, rappels) et ARIA (suivi douleur).

**Flux** :

1. **Quotidien** :
   - Utilisateur note douleur dans ARIA
   - ARIA détecte pattern : "Douleur ↑ après sommeil <6h"
   - ARIA envoie ce pattern à CIA
   - CIA suggère : "Veux-tu que je te rappelle d'améliorer ton sommeil ?"

2. **Avant RDV médical** :
   - Utilisateur ouvre CIA → Générer rapport
   - CIA récupère automatiquement :
     - Documents médicaux (CIA)
     - Timeline douleur 30 jours (ARIA)
     - Patterns détectés (ARIA)
   - Génère rapport combiné

3. **IA Conversationnelle enrichie** :
   - Utilisateur : "Pourquoi j'ai mal aujourd'hui ?"
   - CIA utilise contexte ARIA :
     - "Je vois que tu as noté une douleur de 7/10 au genou droit après une marche. D'après tes données ARIA, c'est similaire à ce que tu as ressenti il y a 2 semaines. À cette occasion, tu avais pris ton anti-inflammatoire et la douleur avait diminué en 2 heures. Veux-tu que je te rappelle de prendre ton médicament ?"

---

## 📊 Métriques de Succès

### Pour l'utilisateur

- **Temps gagné** : 2-3h/semaine (organisation documents, rappels)
- **Stress réduit** : Pas d'inquiétude sur les oublis
- **Meilleure compréhension** : Patterns détectés, corrélations visibles
- **Autonomie** : Gestion santé sans dépendre des autres

### Pour les professionnels de santé

- **Consultations plus efficaces** : 30% de temps gagné
- **Meilleur suivi** : Données structurées, historique complet
- **Décisions éclairées** : Patterns visibles, corrélations claires

---

## 🔗 Voir aussi

- **[POUR_MAMAN.md](./POUR_MAMAN.md)** — Guide simplifié pour utilisateurs seniors
- **[ARIA_INTEGRATION.md](./ARIA_INTEGRATION.md)** — Détails intégration CIA ↔ ARIA
- **[../integrations/ECOSYSTEM_VISION.md](../integrations/ECOSYSTEM_VISION.md)** — Vision écosystème Arkalia
- **[README.md](../README.md)** — Vue d'ensemble du projet

---

**Dernière mise à jour** : 27 novembre 2025  
**Maintenu par** : Arkalia Luna System

