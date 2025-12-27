# 🔧 Activer People API - Google Sign-In Web

**Date** : 25 janvier 2025  
**Erreur** : `Erreur 403 : People API has not been used`  
**Statut** : ✅ **SOLUTION**

---

## 🎯 PROBLÈME

Lors de la connexion Google sur le web, vous obtenez l'erreur :
```
Erreur 403 : People API has not been used in project 1062485264410 before or it is disabled
```

**Cause** : L'API People API n'est pas activée dans Google Cloud Console. Google Sign-In sur le web utilise cette API pour récupérer les informations du profil.

---

## ✅ SOLUTION RAPIDE (1 minute)

### Étape 1 : Activer People API

👉 **Cliquez directement sur ce lien** :
https://console.developers.google.com/apis/api/people.googleapis.com/overview?project=1062485264410

Ou allez manuellement :
1. Aller sur : https://console.cloud.google.com/apis/library?project=arkalia-cia
2. Chercher "People API" dans la barre de recherche
3. Cliquer sur "People API"
4. Cliquer sur "ACTIVER" (bouton bleu)

### Étape 2 : Attendre la propagation

- ⏰ Attendre **1-2 minutes** pour que l'API soit activée
- Les changements peuvent prendre jusqu'à 5 minutes

### Étape 3 : Tester

1. Recharger complètement l'application web (Ctrl+F5)
2. Cliquer sur "Continuer avec Google"
3. ✅ Ça devrait fonctionner maintenant !

---

## 📋 VÉRIFICATION

Pour vérifier que People API est activée :

1. Aller sur : https://console.cloud.google.com/apis/library?project=arkalia-cia
2. Chercher "People API"
3. Vérifier que le statut est **"ACTIVÉE"** (badge vert)

---

## ⚠️ NOTES IMPORTANTES

1. **Gratuit** : L'API People API est gratuite pour les utilisations normales
2. **Propagation** : Les changements peuvent prendre 1-5 minutes
3. **Nécessaire** : Cette API est requise pour Google Sign-In sur le web avec les scopes `email` et `profile`

---

**Date** : 25 janvier 2025

