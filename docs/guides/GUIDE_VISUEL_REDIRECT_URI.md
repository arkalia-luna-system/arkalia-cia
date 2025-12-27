# 🎯 Guide Visuel - Configurer URI de Redirection Google Sign-In

**Date** : 25 janvier 2025  
**Erreur** : `Erreur 400 : redirect_uri_mismatch`  
**Temps requis** : 2 minutes

---

## 🚀 SOLUTION RAPIDE (2 minutes)

### Étape 1 : Ouvrir Google Cloud Console

👉 **Cliquez sur ce lien** : https://console.cloud.google.com/apis/credentials?project=arkalia-cia

Ou allez manuellement :
1. https://console.cloud.google.com/
2. Sélectionner le projet : **arkalia-cia**
3. Menu gauche : **APIs & Services** > **Credentials**

---

### Étape 2 : Trouver "Client Web 1"

Dans la liste **"OAuth 2.0 Client IDs"**, vous verrez :
- ✅ Client Android 1
- ✅ Client iOS 1
- ✅ **Client Web 1** ← **CLIQUER ICI**

---

### Étape 3 : Ajouter les URI de redirection

1. **Cliquer sur "Client Web 1"** pour l'éditer
2. **Faire défiler** jusqu'à la section **"URIs de redirection autorisées"**
3. **Cliquer sur "+ AJOUTER UN URI"** (bouton en bas de la liste)
4. **Ajouter cette URI** : `http://localhost:8080`
5. **Cliquer à nouveau sur "+ AJOUTER UN URI"**
6. **Ajouter cette URI** : `http://localhost:8080/`

**Important** : Ajouter les DEUX (avec et sans slash final)

---

### Étape 4 : Enregistrer

1. **Cliquer sur "ENREGISTRER"** (bouton bleu en bas de la page)
2. **Attendre 1-2 minutes** pour que les changements soient propagés

---

### Étape 5 : Tester

1. **Recharger complètement** l'application web (Ctrl+F5 ou Cmd+Shift+R)
2. **Cliquer sur "Continuer avec Google"**
3. ✅ **Ça devrait fonctionner maintenant !**

---

## 📸 À QUOI ÇA RESSEMBLE

### Section "URIs de redirection autorisées"

Après avoir ajouté les URI, vous devriez voir :

```
URIs de redirection autorisées
┌─────────────────────────────┐
│ http://localhost:8080        │ [🗑️]
│ http://localhost:8080/      │ [🗑️]
└─────────────────────────────┘
[+ AJOUTER UN URI]
```

---

## ⚠️ ERREURS COURANTES

### ❌ "J'ai ajouté mais ça ne marche toujours pas"

**Solutions** :
1. Vérifier que vous avez ajouté les **DEUX** URI (avec et sans `/`)
2. Attendre **2 minutes** après avoir enregistré
3. **Recharger complètement** la page (Ctrl+F5)
4. Vérifier que vous êtes sur le bon port (8080)

### ❌ "Je ne trouve pas 'Client Web 1'"

**Solution** :
- Vérifier que vous êtes dans le bon projet : **arkalia-cia**
- Vérifier que vous êtes dans **APIs & Services** > **Credentials**
- Si "Client Web 1" n'existe pas, il faut le créer (voir guide complet)

---

## 🔍 VÉRIFICATION

Pour vérifier que c'est bien configuré :

1. Aller dans Google Cloud Console > Credentials
2. Cliquer sur "Client Web 1"
3. Vérifier que vous voyez bien :
   - `http://localhost:8080`
   - `http://localhost:8080/`
   
Dans la section "URIs de redirection autorisées"

---

## 📞 BESOIN D'AIDE ?

Si après avoir suivi ces étapes ça ne fonctionne toujours pas :

1. Vérifier que vous êtes connecté avec le bon compte Google
2. Vérifier que le projet est bien **arkalia-cia**
3. Vérifier que "Client Web 1" existe bien
4. Attendre 5 minutes et réessayer (parfois Google met du temps à propager)

---

**Date** : 25 janvier 2025

