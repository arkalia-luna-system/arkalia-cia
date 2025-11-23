# 🎯 MÉGA PROMPT POUR PERPLEXITY - TEST COMPLET ARKALIA CIA

**Date** : 23 novembre 2025  
**Version Application** : 1.3.0  
**Objectif** : **TESTER L'APPLICATION EN DIRECT** dans le navigateur Comet avec les outils browser de Perplexity

---

## ⚠️ INSTRUCTIONS CRITIQUES - LIS-MOI EN PREMIER !

### 🚨 CE QUE TU DOIS FAIRE - TEST EN DIRECT OBLIGATOIRE

**TU ES PERPLEXITY ASSISTANT DANS COMET - TU AS ACCÈS AUX OUTILS BROWSER !**

1. ✅ **Utilise `browser_navigate`** pour aller à `http://localhost:8080` (ou `http://localhost:8081`)
2. ✅ **Utilise `browser_snapshot`** pour capturer l'état de la page après chaque action importante
3. ✅ **Utilise `browser_click`** pour cliquer sur TOUS les boutons et tester TOUTES les fonctionnalités
4. ✅ **Utilise `browser_type`** pour remplir TOUS les formulaires avec des données réalistes
5. ✅ **Utilise `browser_take_screenshot`** pour capturer des screenshots des problèmes ou des écrans importants
6. ✅ **OBSERVE ATTENTIVEMENT** avec `browser_snapshot` :
   - Ce qui fonctionne
   - Ce qui ne fonctionne pas
   - Les temps de chargement
   - Les messages d'erreur
   - Les problèmes visuels (couleurs, textes, espacements)
   - Les problèmes d'accessibilité (contraste, taille des textes)
   - Les bugs (crashes, comportements inattendus)
7. ✅ **TESTE À FOND** :
   - Ne te contente PAS de survoler
   - Clique sur CHAQUE module avec `browser_click`
   - Remplis des formulaires complets avec `browser_type`
   - Teste les cas limites (champs vides, valeurs invalides)
   - Teste les cas d'erreur
8. ✅ **NOTE TOUT** :
   - Problèmes critiques (bloquants) 🔴
   - Problèmes élevés (majeurs) 🟠
   - Problèmes moyens (UX) 🟡
   - Problèmes mineurs (cosmétiques) 🟢
   - Points forts ✅
   - Suggestions d'amélioration 💡

### ❌ CE QUE TU NE DOIS PAS FAIRE

- ❌ **NE PAS** juste analyser le code sur GitHub
- ❌ **NE PAS** juste lire les fichiers de documentation
- ❌ **NE PAS** faire une analyse statique du code
- ❌ **NE PAS** supposer comment ça fonctionne
- ❌ **NE PAS** te contenter de survoler l'interface
- ❌ **NE PAS** ignorer les petits détails (ils sont importants !)

**TU DOIS UTILISER TES OUTILS BROWSER POUR TESTER L'APP EN DIRECT COMME UN UTILISATEUR RÉEL !**

---

## 🌐 ACCÈS À L'APPLICATION

### URL de l'Application
```
http://localhost:8080
```
ou si le port est occupé :
```
http://localhost:8081
```

### Première Action
**Utilise `browser_navigate` pour aller à l'URL :**
```
browser_navigate: http://localhost:8080
```

### Vérification Initiale
1. Utilise `browser_snapshot` pour voir l'état initial
2. Tu devrais voir l'interface de l'application Arkalia CIA
3. Si tu vois une erreur ou une page blanche, note-le dans ton rapport

### Backend API (optionnel pour tests avancés)
```
http://localhost:8000/docs
```
Pour tester les endpoints API si nécessaire.

---

## 👤 PROFIL UTILISATEUR À CRÉER

### Informations Personnelles
- **Nom** : Patricia
- **Âge** : 68 ans (utilisatrice senior)
- **Pathologies** : Endométriose, Arthrose, Ostéoporose
- **Médecins** : 
  - Dr. Martin Dubois (Gynécologue, Bruxelles, 02 123 45 67)
  - Dr. Sophie Laurent (Rhumatologue, Liège, 04 234 56 78)
  - Dr. Jean-Pierre Moreau (Généraliste, Namur, 081 23 45 67)
- **Médicaments** :
  - Levothyrox 75µg (matin, 8h, tous les jours)
  - Dafalgan 500mg (si douleur, 2x/jour max)
  - Calcium + Vitamine D (soir, 20h, tous les jours)
- **Contacts Urgence** :
  - Fille : Marie (06 12 34 56 78)
  - Fils : Thomas (06 98 76 54 32)
  - Médecin traitant : Dr. Moreau (081 23 45 67)

**UTILISE CES DONNÉES** pour créer un profil complet dans l'application et tester toutes les fonctionnalités avec des données réalistes.

---

## 📋 CHECKLIST COMPLÈTE DE TEST - MODULE PAR MODULE

### 🔐 1. PREMIÈRE OUVERTURE & ONBOARDING

#### Actions à Faire avec Browser Tools
1. **`browser_navigate`** vers `http://localhost:8080`
2. **`browser_snapshot`** pour voir l'écran initial
3. **Observe l'écran de chargement** :
   - Combien de temps ça prend ? (utilise `browser_wait_for` si nécessaire)
   - Y a-t-il un message de chargement ?
   - Les couleurs sont-elles agréables ?
4. **Si c'est la première fois** :
   - Y a-t-il un écran de bienvenue ?
   - Les explications sont-elles claires ?
   - Peux-tu choisir d'importer des données ou commencer vide ?
5. **Teste l'import PDF** (si disponible) :
   - **`browser_click`** sur "Importer des PDF" ou bouton similaire
   - **`browser_snapshot`** pour voir le résultat
   - Les fichiers s'importent-ils correctement ?
   - Vois-tu une barre de progression ?

#### Points à Noter
- ✅ Temps de chargement initial
- ✅ Clarté des instructions
- ✅ Facilité d'utilisation pour un senior
- ✅ Problèmes visuels (couleurs, textes, espacements)

#### Problèmes à Détecter
- ❌ Chargement trop long (> 5 secondes)
- ❌ Instructions confuses
- ❌ Boutons trop petits ou difficiles à cliquer
- ❌ Textes illisibles (trop petits, contraste insuffisant)

---

### 🏠 2. PAGE D'ACCUEIL (HOME PAGE)

#### Actions à Faire avec Browser Tools
1. **`browser_snapshot`** pour voir la page d'accueil complète
2. **Identifie tous les modules disponibles** :
   - Documents (vert)
   - Santé (rouge)
   - Rappels (orange)
   - Urgence (violet)
   - ARIA (rouge)
   - Sync (bleu)
   - Médecins (teal)
   - Pathologies (violet)
   - Hydratation (cyan)
   - Calendrier (bleu)
   - Recherche Avancée
   - Assistant IA
   - Patterns
   - Partage Familial
   - Statistiques
   - Paramètres
3. **Vérifie le design** :
   - Les couleurs sont-elles cohérentes ?
   - Les boutons sont-ils assez grands ?
   - Les textes sont-ils lisibles ?
   - Y a-t-il des icônes claires ?

#### Points Visuels à Vérifier
- ✅ **Couleurs** : Chaque module a-t-il sa couleur distinctive ?
- ✅ **Icônes** : Les icônes sont-elles claires et compréhensibles ?
- ✅ **Textes** : Les textes sont-ils lisibles (taille ≥ 16px) ?
- ✅ **Espacements** : Y a-t-il assez d'espace entre les éléments ?
- ✅ **Boutons** : Les boutons sont-ils assez grands pour cliquer facilement (≥ 44x44px) ?

---

### 📄 3. GESTION DOCUMENTS

#### Actions à Faire avec Browser Tools
1. **`browser_click`** sur le bouton "Documents" (vert)
2. **`browser_snapshot`** pour voir l'écran Documents
3. **Importe des PDF** :
   - **`browser_click`** sur le bouton "+" ou "Importer"
   - **`browser_snapshot`** pour voir le dialogue
   - Note si tu peux sélectionner des fichiers
   - Observe le processus d'import
4. **Vérifie l'affichage** :
   - **`browser_snapshot`** pour voir la liste des documents
   - Les documents apparaissent-ils dans la liste ?
   - Les noms sont-ils corrects ?
   - Y a-t-il des badges de type (ordonnance, résultat, etc.) ?
   - Les couleurs des badges sont-elles visibles ?
5. **Teste la recherche** :
   - **`browser_click`** sur la barre de recherche
   - **`browser_type`** pour entrer un terme de recherche
   - **`browser_snapshot`** pour voir les résultats
   - Les résultats apparaissent-ils rapidement ?
6. **Teste les filtres** (si disponibles) :
   - **`browser_click`** sur les filtres
   - Les filtres fonctionnent-ils correctement ?
7. **Ouvre un document** :
   - **`browser_click`** sur un document
   - **`browser_snapshot`** pour voir le résultat
   - S'ouvre-t-il correctement ?
8. **Teste le partage** (si disponible) :
   - **`browser_click`** sur le bouton de partage
   - Fonctionne-t-il ?

#### Points Visuels à Vérifier
- ✅ **Couleurs** : Les badges de type sont-ils colorés et visibles ?
- ✅ **Icônes** : Les icônes sont-elles claires ?
- ✅ **Textes** : Les textes sont-ils lisibles (taille ≥ 16px) ?
- ✅ **Espacements** : Y a-t-il assez d'espace entre les éléments ?
- ✅ **Contraste** : Le contraste est-il suffisant (mode clair/sombre) ?
- ✅ **Boutons** : Les boutons sont-ils assez grands pour cliquer facilement ?

#### Problèmes à Détecter
- ❌ Documents qui disparaissent après import
- ❌ Métadonnées incorrectes
- ❌ Recherche qui ne trouve pas les documents
- ❌ Performance lente
- ❌ Badges de type manquants ou incorrects
- ❌ Textes trop petits ou illisibles

---

### 👨‍⚕️ 4. GESTION MÉDECINS

#### Actions à Faire avec Browser Tools
1. **`browser_click`** sur "Médecins" (teal)
2. **`browser_snapshot`** pour voir l'écran Médecins
3. **Ajoute des médecins** :
   - **`browser_click`** sur "Ajouter un médecin" ou bouton "+"
   - **`browser_snapshot`** pour voir le formulaire
   - **`browser_type`** pour remplir le formulaire :
     - Prénom : "Martin"
     - Nom : "Dubois"
     - Spécialité : "Gynécologue"
     - Téléphone : "02 123 45 67"
     - Email : "martin.dubois@example.com"
     - Adresse : "Rue de la Santé 123"
     - Ville : "Bruxelles"
     - Code postal : "1000"
   - **`browser_click`** sur "Enregistrer" ou "Sauvegarder"
   - **`browser_snapshot`** pour voir le résultat
   - **VÉRIFIE** : Le médecin apparaît-il dans la liste ?
4. **Répète** pour les autres médecins (Dr. Laurent, Dr. Moreau)
5. **Vérifie les codes couleur** :
   - **`browser_snapshot`** pour voir la liste
   - Chaque spécialité a-t-elle une couleur ?
   - Y a-t-il des badges colorés dans la liste ?
6. **Teste la recherche** :
   - **`browser_click`** sur la barre de recherche
   - **`browser_type`** pour entrer "Dubois"
   - **`browser_snapshot`** pour voir les résultats
7. **Ouvre un médecin** :
   - **`browser_click`** sur un médecin dans la liste
   - **`browser_snapshot`** pour voir les détails
   - Vois-tu ses détails ?
   - Y a-t-il un historique de consultations ?
8. **Ajoute une consultation** :
   - **`browser_click`** sur "Ajouter consultation" (si disponible)
   - Remplis le formulaire
   - **`browser_click`** sur "Enregistrer"
   - La consultation apparaît-elle dans l'historique ?

#### Points Visuels à Vérifier
- ✅ **Badges couleur** : Les badges 16x16px sont-ils visibles ?
- ✅ **Légende** : Y a-t-il une légende des couleurs par spécialité ?
- ✅ **Liste** : La liste est-elle claire et organisée ?
- ✅ **Formulaire** : Le formulaire est-il intuitif ?
- ✅ **Couleurs** : Les couleurs sont-elles cohérentes et agréables ?

#### Problèmes à Détecter
- ❌ **CRITIQUE** : Form submission qui échoue (message d'erreur)
- ❌ Doublons non détectés
- ❌ Couleurs manquantes pour certaines spécialités
- ❌ Données qui ne se sauvegardent pas
- ❌ Interface confuse

---

### 📋 5. MODULE PATHOLOGIES

#### Actions à Faire avec Browser Tools
1. **`browser_click`** sur "Pathologies" (violet)
2. **`browser_snapshot`** pour voir l'écran Pathologies
3. **Crée une pathologie** :
   - **`browser_click`** sur "Ajouter une pathologie" ou bouton "+"
   - **`browser_snapshot`** pour voir le formulaire
   - Choisis un template (endométriose, arthrose, etc.)
   - **`browser_type`** pour remplir les informations
   - **`browser_click`** sur "Enregistrer"
   - **`browser_snapshot`** pour voir le résultat
   - **VÉRIFIE** : La pathologie apparaît-elle dans la liste ?
4. **Ajoute des entrées de suivi** :
   - **`browser_click`** sur une pathologie
   - **`browser_click`** sur "Ajouter suivi" ou similaire
   - Remplis plusieurs entrées de suivi
   - **`browser_snapshot`** pour voir les graphiques
5. **Vérifie les graphiques** :
   - Les graphiques s'affichent-ils correctement ?
   - Sont-ils lisibles et clairs ?
   - Les couleurs sont-elles cohérentes ?

#### Points Visuels à Vérifier
- ✅ **Graphiques** : Les graphiques sont-ils clairs et lisibles ?
- ✅ **Couleurs** : Les couleurs sont-elles cohérentes ?
- ✅ **Formulaires** : Les formulaires sont-ils adaptatifs selon la pathologie ?

#### Problèmes à Détecter
- ❌ **CRITIQUE** : Form submission qui échoue
- ❌ Graphiques qui ne s'affichent pas
- ❌ Données qui se perdent
- ❌ Interface confuse

---

### 💊 6. RAPPELS MÉDICAMENTS

#### Actions à Faire avec Browser Tools
1. **`browser_click`** sur "Rappels" (orange)
2. **`browser_snapshot`** pour voir l'écran Rappels
3. **Ajoute des médicaments** :
   - **`browser_click`** sur "Ajouter médicament" ou bouton "+"
   - **`browser_snapshot`** pour voir le formulaire
   - **`browser_type`** pour remplir :
     - Nom : "Levothyrox"
     - Dosage : "75µg"
     - Heure : "8h"
     - Fréquence : "Tous les jours"
   - **`browser_click`** sur "Enregistrer"
   - **`browser_snapshot`** pour voir le résultat
   - **VÉRIFIE** : Le médicament apparaît-il dans la liste ?
4. **Répète** pour les autres médicaments
5. **Teste le suivi** :
   - **`browser_click`** sur "Marquer comme pris" (si disponible)
   - Les statistiques se mettent-elles à jour ?

#### Points Visuels à Vérifier
- ✅ **Icônes** : Les icônes 💊 sont-elles visibles ?
- ✅ **Liste** : La liste est-elle organisée par heure ?
- ✅ **Notifications** : Les notifications sont-elles claires ?

#### Problèmes à Détecter
- ❌ **CRITIQUE** : Form submission qui échoue
- ❌ Données qui ne se sauvegardent pas
- ❌ Rappels qui ne se déclenchent pas
- ❌ Interface confuse

---

### 💧 7. MODULE HYDRATATION

#### Actions à Faire avec Browser Tools
1. **`browser_click`** sur "Hydratation" (cyan)
2. **`browser_snapshot`** pour voir l'écran Hydratation
3. **Configure l'objectif** :
   - **`browser_click`** sur "Configurer objectif" (si disponible)
   - **`browser_type`** pour définir un objectif (ex: 1.5L)
   - **`browser_click`** sur "Enregistrer"
4. **Ajoute des entrées** :
   - **`browser_click`** sur "Ajouter" ou bouton "+"
   - Remplis plusieurs entrées d'hydratation
   - **`browser_snapshot`** pour voir la barre de progression
5. **Vérifie la barre de progression** :
   - La barre de progression se met-elle à jour ?
   - Est-elle claire et colorée ?

#### Points Visuels à Vérifier
- ✅ **Barre de progression** : Est-elle claire et colorée ?
- ✅ **Icônes** : Les icônes 💧 sont-elles visibles ?
- ✅ **Objectifs** : Les objectifs sont-ils affichés clairement ?

#### Problèmes à Détecter
- ❌ **CRITIQUE** : Form submission qui échoue
- ❌ Données qui ne se sauvegardent pas
- ❌ Progression qui ne se met pas à jour

---

### 📅 8. CALENDRIER

#### Actions à Faire avec Browser Tools
1. **`browser_click`** sur "Calendrier" (bleu)
2. **`browser_snapshot`** pour voir le calendrier complet
3. **Observe l'affichage** :
   - Vois-tu un calendrier mensuel ?
   - Y a-t-il des marqueurs colorés sur les dates ?
   - Les marqueurs sont-ils distincts (médecin, médicament, hydratation) ?
4. **Clique sur une date** :
   - **`browser_click`** sur une date avec des événements
   - **`browser_snapshot`** pour voir le popup
   - Y a-t-il un popup avec les détails ?
   - Les détails sont-ils clairs ?
5. **Vérifie l'encadrement coloré** :
   - Les rendez-vous médicaux sont-ils encadrés par couleur selon le médecin ?
   - Les couleurs sont-elles visibles et distinctes ?

#### Points Visuels à Vérifier
- ✅ **Encadrement coloré** : Les RDV sont-ils encadrés par couleur ?
- ✅ **Marqueurs** : Les marqueurs sont-ils visibles et distincts ?
- ✅ **Popup** : Le popup est-il clair et informatif ?
- ✅ **Icônes** : Les icônes 💊💧 sont-elles visibles ?

#### Problèmes à Détecter
- ❌ Marqueurs qui ne s'affichent pas
- ❌ Couleurs manquantes ou incorrectes
- ❌ Popup qui ne s'affiche pas

---

### 🔍 9. RECHERCHE AVANCÉE

#### Actions à Faire avec Browser Tools
1. **`browser_click`** sur "Recherche Avancée" ou icône de recherche
2. **`browser_snapshot`** pour voir l'écran de recherche
3. **Teste la recherche multi-critères** :
   - **`browser_type`** dans la barre de recherche
   - **`browser_click`** sur les filtres (date, type, médecin)
   - **`browser_snapshot`** pour voir les résultats
   - Les résultats apparaissent-ils correctement ?
4. **Teste les suggestions** :
   - **`browser_type`** quelques lettres
   - Y a-t-il des suggestions qui apparaissent ?

#### Points Visuels à Vérifier
- ✅ **Interface** : L'interface est-elle intuitive ?
- ✅ **Filtres** : Les filtres sont-ils clairs (chips, dropdowns) ?
- ✅ **Résultats** : Les résultats sont-ils bien présentés ?

#### Problèmes à Détecter
- ❌ Recherche qui ne trouve pas les résultats
- ❌ Filtres qui ne fonctionnent pas
- ❌ Performance lente

---

### 🤖 10. ASSISTANT IA CONVERSATIONNEL

#### Actions à Faire avec Browser Tools
1. **`browser_click`** sur "Assistant IA" ou "Chat IA"
2. **`browser_snapshot`** pour voir l'interface de chat
3. **Pose des questions** :
   - **`browser_type`** : "Quels sont mes médicaments ?"
   - **`browser_click`** sur "Envoyer" ou appuie sur Entrée
   - **`browser_wait_for`** pour attendre la réponse
   - **`browser_snapshot`** pour voir la réponse
4. **Pose d'autres questions** :
   - "Quand ai-je vu mon médecin la dernière fois ?"
   - "Quels sont mes rendez-vous cette semaine ?"
   - "Quelles sont mes pathologies ?"
5. **Observe les réponses** :
   - Les réponses sont-elles pertinentes ?
   - Y a-t-il des erreurs ?
   - Les réponses sont-elles claires ?

#### Points Visuels à Vérifier
- ✅ **Interface chat** : L'interface est-elle claire (bulles, couleurs) ?
- ✅ **Typing indicator** : Y a-t-il un indicateur de frappe ?
- ✅ **Historique** : L'historique est-il accessible ?

#### Problèmes à Détecter
- ❌ Réponses qui ne sont pas pertinentes
- ❌ Erreurs dans les réponses
- ❌ Performance lente

---

### 📊 11. IA PATTERNS

#### Actions à Faire avec Browser Tools
1. **`browser_click`** sur "Patterns" ou "IA Patterns"
2. **`browser_snapshot`** pour voir le dashboard Patterns
3. **Observe les patterns détectés** :
   - Y a-t-il des patterns récurrents détectés ?
   - Les patterns sont-ils clairs et compréhensibles ?
4. **Vérifie les graphiques** :
   - Les graphiques s'affichent-ils correctement ?
   - Sont-ils interactifs ?
   - Les couleurs sont-elles cohérentes ?

#### Points Visuels à Vérifier
- ✅ **Graphiques** : Les graphiques sont-ils clairs et interactifs ?
- ✅ **Couleurs** : Les couleurs sont-elles cohérentes ?
- ✅ **Légendes** : Y a-t-il des légendes claires ?

#### Problèmes à Détecter
- ❌ Patterns non détectés
- ❌ Graphiques qui ne s'affichent pas
- ❌ Interface confuse

---

### 👨‍👩‍👧 12. PARTAGE FAMILIAL

#### Actions à Faire avec Browser Tools
1. **`browser_click`** sur "Partage" ou "Partage Familial"
2. **`browser_snapshot`** pour voir l'écran Partage
3. **Ajoute des membres** :
   - **`browser_click`** sur "Ajouter membre"
   - Remplis le formulaire
   - **`browser_click`** sur "Enregistrer"
   - Les membres sont-ils ajoutés correctement ?
4. **Vérifie le dashboard** :
   - Y a-t-il un onglet "Statistiques" ?
   - Les statistiques sont-elles affichées ?

#### Points Visuels à Vérifier
- ✅ **Dashboard** : Le dashboard est-il clair et informatif ?
- ✅ **Onglets** : Les onglets "Partager" et "Statistiques" sont-ils visibles ?

#### Problèmes à Détecter
- ❌ Partage qui échoue
- ❌ Interface confuse

---

### 🚨 13. CONTACTS D'URGENCE

#### Actions à Faire avec Browser Tools
1. **`browser_click`** sur "Urgence" (violet)
2. **`browser_snapshot`** pour voir l'écran Urgence
3. **Ajoute des contacts** :
   - **`browser_click`** sur "Ajouter contact"
   - **`browser_type`** pour remplir :
     - Nom : "Marie"
     - Téléphone : "06 12 34 56 78"
     - Relation : "Fille"
   - **`browser_click`** sur "Enregistrer"
   - **VÉRIFIE** : Le contact apparaît-il dans la liste ?
4. **Teste l'appel rapide** :
   - **`browser_click`** sur un contact
   - L'appel fonctionne-t-il ? (ou au moins l'interface)
5. **Vérifie la carte d'urgence** :
   - Y a-t-il une carte d'urgence médicale ?
   - Les informations critiques sont-elles affichées ?

#### Points Visuels à Vérifier
- ✅ **Boutons** : Les boutons d'appel sont-ils grands et accessibles ?
- ✅ **Carte** : La carte d'urgence est-elle claire et lisible ?
- ✅ **Couleurs** : Les couleurs d'urgence (rouge) sont-elles visibles ?

#### Problèmes à Détecter
- ❌ Appels qui ne fonctionnent pas
- ❌ Informations manquantes
- ❌ Interface non accessible en urgence

---

### ⚙️ 14. PARAMÈTRES

#### Actions à Faire avec Browser Tools
1. **`browser_click`** sur "Paramètres" ou icône engrenage
2. **`browser_snapshot`** pour voir l'écran Paramètres
3. **Teste le thème** :
   - **`browser_click`** sur l'option thème
   - Change entre mode clair/sombre/système
   - **`browser_snapshot`** pour voir les changements
   - Les changements sont-ils immédiats ?
4. **Configure le backend** (si tu veux tester l'API) :
   - **`browser_click`** sur "Configuration Backend"
   - **`browser_type`** : "http://localhost:8000"
   - **`browser_click`** sur "Tester connexion"
   - **`browser_snapshot`** pour voir le résultat
5. **Vérifie les autres options** :
   - Cache, notifications, sécurité, etc.

#### Points Visuels à Vérifier
- ✅ **Interface** : L'interface est-elle organisée et claire ?
- ✅ **Sections** : Les sections sont-elles bien séparées ?
- ✅ **Switches** : Les switches sont-ils clairs et accessibles ?

#### Problèmes à Détecter
- ❌ Paramètres qui ne se sauvegardent pas
- ❌ Interface confuse

---

### 📊 15. STATISTIQUES

#### Actions à Faire avec Browser Tools
1. **`browser_click`** sur "Statistiques" ou "Stats"
2. **`browser_snapshot`** pour voir le dashboard Stats
3. **Observe les graphiques** :
   - Y a-t-il des graphiques ?
   - Sont-ils clairs et lisibles ?
   - Les données sont-elles correctes ?

#### Points Visuels à Vérifier
- ✅ **Graphiques** : Les graphiques sont-ils clairs ?
- ✅ **Couleurs** : Les couleurs sont-elles cohérentes ?

---

## 🎨 TEST VISUEL GLOBAL

### Mode Clair
1. **`browser_click`** pour changer en mode clair (si disponible)
2. **`browser_snapshot`** pour capturer l'état
3. **Observe** :
   - Les couleurs sont-elles agréables ?
   - Le contraste est-il suffisant ?
   - Les textes sont-ils lisibles ?
   - Les boutons sont-ils visibles ?

### Mode Sombre
1. **`browser_click`** pour changer en mode sombre
2. **`browser_snapshot`** pour capturer l'état
3. **Observe** :
   - Les couleurs sont-elles douces ?
   - Le contraste est-il suffisant ?
   - Les textes sont-ils lisibles ?

### Points à Vérifier Partout
- ✅ **Couleurs primaires** : Bleu pour actions principales
- ✅ **Couleurs documents** : Vert pour documents
- ✅ **Couleurs santé** : Rouge pour santé
- ✅ **Couleurs rappels** : Orange pour rappels
- ✅ **Couleurs urgence** : Violet pour urgence
- ✅ **Taille texte** : ≥ 16px partout
- ✅ **Boutons** : ≥ 44x44px pour faciliter le clic
- ✅ **Espacements** : Assez d'espace entre les éléments
- ✅ **Contraste** : Suffisant pour la lisibilité
- ✅ **Icônes** : Claires et compréhensibles

---

## ⚡ TEST DE PERFORMANCE

### À Mesurer avec Browser Tools
1. **Temps de démarrage** :
   - Utilise `browser_wait_for` pour mesurer le temps
   - Cible : < 3 secondes
2. **Navigation** :
   - Navigue entre les modules
   - Y a-t-il des saccades ou des ralentissements ?
3. **Recherche** :
   - **`browser_type`** dans la recherche
   - Combien de temps prend une recherche ?
   - Cible : < 1 seconde

### Problèmes à Détecter
- ❌ Chargement trop lent (> 5 secondes)
- ❌ Navigation saccadée
- ❌ Recherche lente (> 2 secondes)
- ❌ Interface qui freeze

---

## 🐛 TEST DES CAS LIMITES

### À Tester avec Browser Tools
1. **Champs vides** :
   - Essaie de soumettre un formulaire avec des champs obligatoires vides
   - **`browser_click`** sur "Enregistrer" sans remplir
   - **`browser_snapshot`** pour voir le message d'erreur
   - Y a-t-il un message d'erreur clair ?
2. **Données invalides** :
   - **`browser_type`** des données invalides (dates, numéros, etc.)
   - Y a-t-il une validation ?
3. **Actions multiples** :
   - Fais plusieurs actions rapidement
   - L'app gère-t-elle bien les actions simultanées ?

### Problèmes à Détecter
- ❌ Erreurs non gérées (crash)
- ❌ Messages d'erreur peu clairs
- ❌ Données perdues en cas d'erreur
- ❌ App qui freeze

---

## 🔴 TESTS CRITIQUES - FORM SUBMISSION

### ⚠️ TEST OBLIGATOIRE - FORMULAIRE MÉDECINS

**C'EST LE TEST LE PLUS IMPORTANT - LE PROBLÈME CRITIQUE DU RAPPORT D'AUDIT !**

1. **`browser_click`** sur "Médecins"
2. **`browser_click`** sur "Ajouter un médecin"
3. **`browser_snapshot`** pour voir le formulaire
4. **Remplis le formulaire COMPLET** :
   - **`browser_type`** dans chaque champ :
     - Prénom : "Test"
     - Nom : "Médecin"
     - Spécialité : "Généraliste"
     - Téléphone : "02 123 45 67"
     - Email : "test@example.com"
     - Adresse : "Rue Test 123"
     - Ville : "Bruxelles"
     - Code postal : "1000"
5. **`browser_click`** sur "Enregistrer" ou "Sauvegarder"
6. **`browser_wait_for`** pour attendre la réponse (2-3 secondes)
7. **`browser_snapshot`** pour voir le résultat
8. **VÉRIFIE CRITIQUEMENT** :
   - ✅ **SUCCÈS** : Le médecin apparaît dans la liste → **PROBLÈME CORRIGÉ !**
   - ❌ **ÉCHEC** : Message d'erreur "Base de données non disponible" → **PROBLÈME TOUJOURS PRÉSENT !**
   - ❌ **ÉCHEC** : Message d'erreur générique → **PROBLÈME TOUJOURS PRÉSENT !**
   - ❌ **ÉCHEC** : Le formulaire reste ouvert → **PROBLÈME TOUJOURS PRÉSENT !**

**NOTE PRÉCISÉMENT** ce qui se passe dans ton rapport !

### ⚠️ TEST OBLIGATOIRE - FORMULAIRE MÉDICAMENTS

1. **`browser_click`** sur "Rappels"
2. **`browser_click`** sur "Ajouter médicament"
3. Remplis le formulaire complet
4. **`browser_click`** sur "Enregistrer"
5. **VÉRIFIE** : Le médicament apparaît-il dans la liste ?

### ⚠️ TEST OBLIGATOIRE - FORMULAIRE PATHOLOGIES

1. **`browser_click`** sur "Pathologies"
2. **`browser_click`** sur "Ajouter pathologie"
3. Remplis le formulaire complet
4. **`browser_click`** sur "Enregistrer"
5. **VÉRIFIE** : La pathologie apparaît-elle dans la liste ?

---

## 📊 RAPPORT À GÉNÉRER

### Structure du Rapport

1. **Résumé Exécutif**
   - Score global (sur 10)
   - Points forts principaux
   - Points faibles principaux
   - **STATUS FORM SUBMISSION** : ✅ FONCTIONNE ou ❌ ÉCHOUE
   - Recommandations prioritaires

2. **Détail par Module Testé**
   - Score par module (sur 10)
   - Fonctionnalités testées
   - Problèmes détectés (graves 🔴, élevés 🟠, moyens 🟡, mineurs 🟢)
   - Screenshots des problèmes (si possible avec `browser_take_screenshot`)
   - Recommandations spécifiques

3. **Analyse Visuelle**
   - Design général
   - Accessibilité (seniors, malvoyants)
   - Cohérence des couleurs
   - Lisibilité
   - Recommandations

4. **Performance**
   - Temps de démarrage
   - Fluidité
   - Recommandations

5. **Sécurité & Robustesse**
   - Gestion des erreurs
   - Validation des données
   - Recommandations

6. **Comparaison avec Apps du Marché**
   - Fonctionnalités vs Apple Health, Google Fit, MyFitnessPal, etc.
   - Design vs concurrents
   - Points de différenciation
   - Opportunités d'amélioration

7. **Recommandations Prioritaires**
   - Top 10 améliorations à faire
   - Top 10 nouvelles fonctionnalités
   - Roadmap suggérée

---

## 🎯 INSTRUCTIONS FINALES POUR PERPLEXITY

### Workflow Recommandé

1. **Navigation Initiale** :
   ```
   browser_navigate: http://localhost:8080
   browser_snapshot: (pour voir l'état initial)
   ```

2. **Pour Chaque Module** :
   ```
   browser_click: (sur le bouton du module)
   browser_snapshot: (pour voir l'écran)
   browser_click: (sur les actions)
   browser_type: (pour remplir les formulaires)
   browser_snapshot: (pour voir les résultats)
   ```

3. **Pour Capturer des Problèmes** :
   ```
   browser_take_screenshot: (si problème visuel)
   browser_snapshot: (pour analyser l'état)
   ```

4. **Pour Tester les Formulaires** :
   ```
   browser_click: (sur "Ajouter")
   browser_snapshot: (voir le formulaire)
   browser_type: (remplir chaque champ)
   browser_click: (sur "Enregistrer")
   browser_wait_for: (attendre 2-3 secondes)
   browser_snapshot: (voir le résultat)
   ```

### Classification des Problèmes
- **🔴 GRAVE** : Bloque l'utilisation, crash, perte de données, form submission échoue
- **🟠 ÉLEVÉ** : Impacte l'expérience utilisateur, fonctionnalité partielle
- **🟡 MOYEN** : Amélioration UX, petit bug
- **🟢 MINEUR** : Cosmétique, suggestion

### Priorité des Améliorations
- **Priorité 1** : Critique, à faire immédiatement
- **Priorité 2** : Important, à faire bientôt
- **Priorité 3** : Amélioration, à faire plus tard

---

## 🚀 COMMENCE MAINTENANT !

**ÉTAPE 1** : Utilise `browser_navigate` pour aller à `http://localhost:8080`  
**ÉTAPE 2** : Utilise `browser_snapshot` pour voir l'état initial  
**ÉTAPE 3** : Commence à tester l'application avec `browser_click` et `browser_type` !  
**ÉTAPE 4** : Utilise `browser_snapshot` après chaque action importante !  
**ÉTAPE 5** : Note TOUT ce que tu observes !  
**ÉTAPE 6** : Génère un rapport complet avec screenshots si possible !

### ⚠️ IMPORTANT : TESTE LES FORMULAIRES EN PRIORITÉ

**LE TEST LE PLUS IMPORTANT** : Vérifie que les formulaires (Médecins, Médicaments, Pathologies) fonctionnent maintenant sur le web. C'était le problème critique du rapport d'audit.

**Si les formulaires fonctionnent** → Le problème est corrigé ! ✅  
**Si les formulaires échouent** → Le problème persiste ! ❌

### ⚠️ SOIS EXHAUSTIF MAIS EFFICACE

- **Teste TOUT** : Tous les modules, tous les boutons, tous les formulaires
- **Observe TOUT** : Couleurs, textes, espacements, performances
- **Note TOUT** : Problèmes, points forts, suggestions
- **MAIS** : Ne bloque pas sur un seul problème, teste toute l'app d'abord
- **PRIORITÉ** : Teste les formulaires en premier (c'est le problème critique)

**BONNE CHANCE ! 🎯**

---

## 📝 TEMPLATE DE RAPPORT

Utilise ce template pour structurer ton rapport :

```markdown
# RAPPORT DE TEST ARKALIA CIA - 23 NOVEMBRE 2025

## Résumé Exécutif
- Score global : X/10
- Form Submission : ✅ FONCTIONNE / ❌ ÉCHOUE
- Points forts : ...
- Points faibles : ...

## Tests Critiques - Form Submission
### Médecins
- Status : ✅ / ❌
- Détails : ...

### Médicaments
- Status : ✅ / ❌
- Détails : ...

### Pathologies
- Status : ✅ / ❌
- Détails : ...

## Détail par Module
[Pour chaque module testé]

## Problèmes Détectés
### 🔴 Graves
- ...

### 🟠 Élevés
- ...

## Recommandations
- ...
```
