# 🔧 Fix Erreur redirect_uri_mismatch - Google Sign-In Web

**Date** : 25 janvier 2025  
**Erreur** : `Erreur 400 : redirect_uri_mismatch`  
**Statut** : ✅ **SOLUTION**

---

## 🎯 PROBLÈME

Lors de la connexion Google sur le web, vous obtenez l'erreur :
```
Accès bloqué : la demande de cette appli n'est pas valide
Erreur 400 : redirect_uri_mismatch
```

**Cause** : Les URI de redirection ne sont pas configurées dans Google Cloud Console pour le Client Web.

---

## ✅ SOLUTION

### Étape 1 : Accéder à Google Cloud Console

1. Aller sur : https://console.cloud.google.com/apis/credentials?project=arkalia-cia
2. Se connecter avec le compte Google qui gère le projet

### Étape 2 : Configurer les Origines JavaScript (IMPORTANT)

1. Dans la page d'édition de **"Client Web 1"**, faire défiler jusqu'à **"Origines JavaScript autorisées"**
2. Cliquer sur **"+ AJOUTER UNE ORIGINE"**
3. Ajouter : `http://localhost:8080`
4. (Optionnel pour production) Ajouter aussi : `https://arkalia-luna-system.github.io`

### Étape 3 : Configurer les URI de redirection

1. Faire défiler jusqu'à la section **"URIs de redirection autorisées"**
2. Cliquer sur **"+ AJOUTER UN URI"** (bouton en bas de la liste)
3. Ajouter les URI suivantes (une par une, en cliquant sur "+ AJOUTER UN URI" pour chaque) :

#### Pour développement local :
```
http://localhost:8080
http://localhost:8080/
http://localhost:8081
http://localhost:8081/
```

#### Pour production (si déployé) :
```
https://votre-domaine.com
https://votre-domaine.com/
```

### Étape 4 : Enregistrer

1. Cliquer sur **"ENREGISTRER"** en bas de la page
2. Attendre quelques secondes pour que les changements soient propagés

### Étape 5 : Tester

1. Recharger l'application web
2. Cliquer sur "Continuer avec Google"
3. La connexion devrait maintenant fonctionner ✅

---

## 📋 URI À AJOUTER (Résumé)

**Minimum requis pour développement local** :
- `http://localhost:8080`
- `http://localhost:8080/`

**Si vous utilisez un autre port** :
- `http://localhost:8081`
- `http://localhost:8081/`
- etc.

**Pour production** :
- `https://votre-domaine.com`
- `https://votre-domaine.com/`

---

## ⚠️ NOTES IMPORTANTES

1. **Exactitude requise** : Les URI doivent correspondre EXACTEMENT (protocole, domaine, port, slash final)
2. **Propagation** : Les changements peuvent prendre 1-2 minutes pour être actifs
3. **Test** : Après avoir ajouté les URI, recharger complètement la page (Ctrl+F5)

---

## 🔍 VÉRIFICATION

Pour vérifier que c'est bien configuré :

1. Aller dans Google Cloud Console > Credentials
2. Cliquer sur "Client Web 1"
3. Vérifier que les URI apparaissent bien dans "URIs de redirection autorisées"

---

**Date** : 25 janvier 2025

