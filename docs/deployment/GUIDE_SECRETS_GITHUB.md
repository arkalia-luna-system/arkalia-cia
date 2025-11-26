# 🔐 Guide Complet : Secrets GitHub pour Arkalia CIA

**Date** : 26 novembre 2025  
**Statut** : ⏳ **À configurer**

---

## 📊 RÉSUMÉ RAPIDE

| Question | Réponse |
|----------|---------|
| **Combien de secrets ?** | **1 seul secret** |
| **Quel secret ?** | `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` |
| **Pourquoi ?** | Pour uploader automatiquement l'app sur Google Play Store |
| **Obligatoire ?** | Non, mais **recommandé** pour l'automatisation |
| **Temps de config ?** | ~10 minutes |

---

## 🎯 POURQUOI CE SECRET ?

### Sans le secret (Situation actuelle) :
```
Push sur main
  ↓
GitHub Actions build l'App Bundle ✅
  ↓
App Bundle uploadé comme "artifact" sur GitHub ✅
  ↓
❌ TU DOIS uploader manuellement sur Play Console
```

### Avec le secret (Automatisation complète) :
```
Push sur main
  ↓
GitHub Actions build l'App Bundle ✅
  ↓
GitHub Actions upload automatiquement sur Play Store ✅
  ↓
Publication automatique en "tests internes" ✅
  ↓
✅ TOUT EST AUTOMATIQUE - Tu n'as rien à faire !
```

---

## 📋 ÉTAPE PAR ÉTAPE

### Étape 1 : Créer le compte de service Google Play (5 minutes)

1. **Aller sur Google Play Console** :
   - URL : https://play.google.com/console
   - Se connecter avec ton compte Google Play Console

2. **Accéder aux paramètres** :
   - Cliquer sur l'icône ⚙️ **Paramètres** (en bas à gauche)
   - Cliquer sur **"Comptes de service"** dans le menu

3. **Créer un nouveau compte de service** :
   - Cliquer sur **"Créer un compte de service"** ou **"Create service account"**
   - Un nouvel onglet s'ouvre vers Google Cloud Console

4. **Dans Google Cloud Console** :
   - Cliquer sur **"Créer un compte de service"** ou **"Create Service Account"**
   - **Nom** : `arkalia-cia-github-actions` (ou ce que tu veux)
   - **Description** : `Compte de service pour déploiement automatique depuis GitHub Actions`
   - Cliquer sur **"Créer et continuer"** ou **"Create and Continue"**

5. **Attribuer le rôle** :
   - **Rôle** : Sélectionner **"Administrateur de publication"** ou **"Release Manager"**
   - Cliquer sur **"Continuer"** ou **"Continue"**
   - Cliquer sur **"Terminé"** ou **"Done"**

6. **Créer et télécharger la clé JSON** :
   - Dans la liste des comptes de service, cliquer sur celui que tu viens de créer
   - Aller dans l'onglet **"Clés"** ou **"Keys"**
   - Cliquer sur **"Ajouter une clé"** → **"Créer une nouvelle clé"** ou **"Add Key"** → **"Create new key"**
   - Sélectionner **JSON**
   - Cliquer sur **"Créer"** ou **"Create"**
   - ⚠️ **IMPORTANT** : Le fichier JSON se télécharge automatiquement - **GARDE-LE EN SÉCURITÉ !**

7. **Retourner sur Play Console** :
   - Retourner sur l'onglet Play Console
   - Dans **"Comptes de service"**, tu devrais voir ton nouveau compte
   - Cliquer sur **"Accorder l'accès"** ou **"Grant access"**
   - Cocher les permissions nécessaires (généralement **"Gérer les versions de production"** et **"Gérer les versions de test"**)
   - Cliquer sur **"Inviter"** ou **"Invite"**

---

### Étape 2 : Ajouter le secret dans GitHub (3 minutes)

1. **Aller sur GitHub** :
   - URL : https://github.com/arkalia-luna-system/arkalia-cia
   - Se connecter avec ton compte GitHub

2. **Accéder aux secrets** :
   - Cliquer sur l'onglet **"Settings"** (en haut du repo)
   - Dans le menu de gauche, cliquer sur **"Secrets and variables"** → **"Actions"**
   - Ou directement : https://github.com/arkalia-luna-system/arkalia-cia/settings/secrets/actions

3. **Créer le nouveau secret** :
   - Cliquer sur **"New repository secret"** ou **"Nouveau secret de dépôt"**

4. **Remplir le formulaire** :
   - **Name** (Nom) : `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`
     - ⚠️ **ATTENTION** : Le nom doit être **EXACTEMENT** celui-ci (sensible à la casse)
   - **Secret** (Valeur) : 
     - Ouvrir le fichier JSON téléchargé (avec un éditeur de texte)
     - **Sélectionner TOUT le contenu** (Ctrl+A / Cmd+A)
     - **Copier** (Ctrl+C / Cmd+C)
     - **Coller** dans le champ "Secret"
     - ⚠️ **IMPORTANT** : Coller le JSON complet, de `{` jusqu'à `}`

5. **Sauvegarder** :
   - Cliquer sur **"Add secret"** ou **"Ajouter le secret"**
   - ✅ Le secret est maintenant configuré !

---

### Étape 3 : Vérifier que ça fonctionne (2 minutes)

1. **Tester le workflow** :
   - Faire un petit changement sur la branche `main` (ou créer un tag `v1.3.1`)
   - Le workflow GitHub Actions devrait se déclencher automatiquement

2. **Vérifier l'exécution** :
   - Aller sur l'onglet **"Actions"** de ton repo GitHub
   - Cliquer sur le workflow **"Deploy to Play Store (Internal Testing)"**
   - Vérifier que tous les steps passent au vert ✅

3. **Vérifier sur Play Console** :
   - Aller sur https://play.google.com/console
   - Aller dans **"Production"** → **"Tests internes"** ou **"Internal testing"**
   - Tu devrais voir la nouvelle version uploadée automatiquement !

---

## 🔍 VÉRIFICATION

### Comment savoir si le secret est bien configuré ?

1. **Dans GitHub** :
   - Aller sur Settings → Secrets and variables → Actions
   - Tu devrais voir `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` dans la liste
   - ⚠️ **Note** : GitHub ne montre jamais la valeur du secret (c'est normal, c'est pour la sécurité)

2. **Dans le workflow** :
   - Quand le workflow s'exécute, regarde le step **"Check if service account exists"**
   - Si le secret existe : `exists=true` ✅
   - Si le secret n'existe pas : `exists=false` ⚠️

3. **Dans les logs** :
   - Si le secret est configuré : Le step **"Upload to Play Store"** s'exécute ✅
   - Si le secret n'est pas configuré : Le step **"Upload artifact"** s'exécute à la place ⚠️

---

## ⚠️ SÉCURITÉ

### Bonnes pratiques :

✅ **À FAIRE** :
- Garder le fichier JSON en sécurité (ne jamais le commiter dans Git)
- Ne jamais partager le JSON par email/chat
- Utiliser uniquement pour le déploiement automatique
- Révoquer le compte de service si compromis

❌ **À ÉVITER** :
- Commiter le JSON dans le code
- Partager le JSON publiquement
- Utiliser le même compte pour plusieurs projets
- Laisser le JSON dans le dossier de téléchargements

---

## 🆘 DÉPANNAGE

### Problème : "Secret not found" ou "exists=false"

**Solutions** :
1. Vérifier que le nom du secret est **exactement** `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` (sensible à la casse)
2. Vérifier que le secret existe dans Settings → Secrets → Actions
3. Vérifier que le JSON est complet (commence par `{` et finit par `}`)

### Problème : "Authentication failed" lors de l'upload

**Solutions** :
1. Vérifier que le compte de service a bien les permissions dans Play Console
2. Vérifier que le JSON n'a pas été modifié
3. Vérifier que le compte de service a bien été invité dans Play Console

### Problème : "Package not found"

**Solutions** :
1. Vérifier que le `PACKAGE_NAME` dans le workflow correspond à l'ID de l'app dans Play Console (`com.arkalia.cia`)
2. Vérifier que l'app existe bien dans Play Console

---

## 📊 RÉSUMÉ FINAL

| Élément | Détails |
|---------|---------|
| **Nombre de secrets** | 1 seul |
| **Nom du secret** | `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` |
| **Type** | JSON (fichier de compte de service Google) |
| **Où l'obtenir** | Google Play Console → Paramètres → Comptes de service |
| **Où le configurer** | GitHub → Settings → Secrets → Actions |
| **Temps de config** | ~10 minutes |
| **Obligatoire** | Non, mais recommandé pour l'automatisation |

---

## ✅ CHECKLIST RAPIDE

- [ ] Compte de service créé dans Google Cloud Console
- [ ] Clé JSON téléchargée et sauvegardée en sécurité
- [ ] Compte de service invité dans Play Console avec les bonnes permissions
- [ ] Secret `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` créé dans GitHub
- [ ] JSON complet collé dans le secret GitHub
- [ ] Workflow testé et fonctionnel
- [ ] Version uploadée automatiquement sur Play Console

---

**Dernière mise à jour** : 26 novembre 2025  
**Prochaine action** : Configurer le secret `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`

