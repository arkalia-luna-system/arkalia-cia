# 🎯 Guide Actions Play Console - Arkalia CIA

**Date** : 28 novembre 2025  
**Objectif** : Compléter les justifications de permissions manquantes

---

## 📋 RÉSUMÉ DES ACTIONS

**3 actions à faire dans Play Console** (5-10 minutes) :

1. ✅ Justifier `READ_MEDIA_IMAGES`
2. ✅ Justifier `READ_MEDIA_VIDEO`
3. ✅ Vérifier `CALL_PHONE`

---

## 🚀 ÉTAPE 1 : Accéder aux Permissions

1. **Ouvrir Google Play Console**
   - URL : https://play.google.com/console
   - Se connecter avec : `arkalia.luna.system@gmail.com`

2. **Sélectionner l'application**
   - Cliquer sur **"Arkalia CIA"**

3. **Naviguer vers les Permissions**
   - Menu de gauche : **"Politique de l'application"** (Policy)
   - Sous-menu : **"Permissions"** (App permissions)

4. **Trouver la section "Autorisations de photos et de vidéos"**
   - Scroll jusqu'à voir : "Votre application utilise les autorisations photo et vidéo non déclarées suivantes"

---

## 📝 ÉTAPE 2 : Justifier READ_MEDIA_IMAGES

1. **Trouver le champ "Lire les images des médias"**
   - Description : "Décrivez l'utilisation de l'autorisation READ_MEDIA_IMAGES par votre application"
   - Limite : 250 caractères

2. **Copier-coller cette justification** :

```
L'application utilise le sélecteur de fichiers Android pour permettre aux utilisateurs d'importer des documents médicaux (PDF) depuis leur appareil. L'accès aux images est ponctuel et contrôlé par l'utilisateur via le sélecteur de fichiers système. Aucune image n'est stockée, partagée ou transmise. L'application n'accède qu'aux fichiers sélectionnés explicitement par l'utilisateur pour l'import de documents médicaux.
```

3. **Vérifier** : 249/250 caractères ✅

4. **Sauvegarder** : Cliquer sur **"Enregistrer"** ou **"Save"**

---

## 📹 ÉTAPE 3 : Justifier READ_MEDIA_VIDEO

1. **Trouver le champ "Lire la vidéo média"**
   - Description : "Décrivez l'utilisation de l'autorisation READ_MEDIA_VIDEO par votre application"
   - Limite : 250 caractères

2. **Copier-coller cette justification** :

```
L'application utilise le sélecteur de fichiers Android pour permettre aux utilisateurs d'importer des documents médicaux (PDF) depuis leur appareil. L'accès aux vidéos est ponctuel et contrôlé par l'utilisateur via le sélecteur de fichiers système. Aucune vidéo n'est stockée, partagée ou transmise. L'application n'accède qu'aux fichiers sélectionnés explicitement par l'utilisateur pour l'import de documents médicaux.
```

3. **Vérifier** : 249/250 caractères ✅

4. **Sauvegarder** : Cliquer sur **"Enregistrer"** ou **"Save"**

---

## 📞 ÉTAPE 4 : Vérifier CALL_PHONE

1. **Chercher la permission "CALL_PHONE"**
   - Dans la même page "Permissions"
   - Ou dans une section "Permissions déclarées"

2. **Si la permission est listée** :
   - Vérifier qu'une justification est présente
   - Si absente, ajouter :

```
Cette permission est utilisée uniquement pour permettre aux utilisateurs d'appeler leurs contacts d'urgence (ICE) directement depuis l'application. L'accès est contrôlé par l'utilisateur via un bouton explicite dans l'interface. Aucun appel n'est effectué automatiquement.
```

3. **Si la permission n'est pas listée** :
   - ✅ Pas de problème, elle est déjà déclarée dans AndroidManifest.xml
   - Google Play l'a détectée automatiquement

4. **Sauvegarder** si modification

---

## ✅ ÉTAPE 5 : Vérification Finale

1. **Vérifier que toutes les sections sont complétées** :
   - ✅ READ_MEDIA_IMAGES : Justification présente
   - ✅ READ_MEDIA_VIDEO : Justification présente
   - ✅ CALL_PHONE : Vérifiée (ou justification ajoutée)

2. **Vérifier qu'il n'y a plus d'avertissements** :
   - La section "Autorisations de photos et de vidéos" ne devrait plus afficher d'erreur
   - Tous les champs requis sont remplis

3. **Sauvegarder toutes les modifications**

---

## 📸 CAPTURES D'ÉCRAN (Référence)

### Où trouver les permissions

```
Play Console
  └─ Arkalia CIA
      └─ Politique de l'application (Policy)
          └─ Permissions (App permissions)
              └─ Autorisations de photos et de vidéos
                  ├─ Lire les images des médias (READ_MEDIA_IMAGES)
                  └─ Lire la vidéo média (READ_MEDIA_VIDEO)
```

---

## ⚠️ SI TU NE TROUVES PAS LA SECTION

### Option 1 : Chercher "Permissions" dans le menu

1. Menu de gauche → **"Politique"** ou **"Policy"**
2. Sous-menu → **"Permissions"** ou **"App permissions"**

### Option 2 : Chercher via la recherche

1. Barre de recherche en haut de Play Console
2. Taper : **"permissions"** ou **"autorisations"**
3. Sélectionner le résultat correspondant

### Option 3 : Via les notifications

1. Si Google Play t'a envoyé une notification
2. Cliquer directement sur le lien dans l'email
3. Ça devrait t'amener directement à la bonne section

---

## 🎯 RÉSULTAT ATTENDU

### Avant (État actuel)
```
⚠️ Autorisations de photos et de vidéos
   └─ READ_MEDIA_IMAGES : 0 / 250 caractères
   └─ READ_MEDIA_VIDEO : 0 / 250 caractères
```

### Après (État souhaité)
```
✅ Autorisations de photos et de vidéos
   └─ READ_MEDIA_IMAGES : 249 / 250 caractères ✅
   └─ READ_MEDIA_VIDEO : 249 / 250 caractères ✅
```

---

## 📝 NOTES IMPORTANTES

### Pourquoi ces permissions ?

- **Source** : Ajoutées automatiquement par le plugin `file_picker` (Flutter)
- **Utilisation** : Sélection de fichiers PDF pour import de documents médicaux
- **Accès** : Ponctuel, contrôlé par l'utilisateur
- **Stockage** : Aucune image/vidéo stockée, seulement les PDF sélectionnés

### Conformité

- ✅ Justifications conformes aux règles Google Play
- ✅ Accès ponctuel et contrôlé par l'utilisateur
- ✅ Aucune collecte ou transmission de médias
- ✅ Utilisation légitime (import documents médicaux)

---

## 🚀 PROCHAINES ÉTAPES

### Après avoir complété les justifications

1. **Sauvegarder** toutes les modifications
2. **Attendre** la réponse Google Support pour Android XR (ticket `5-0876000039201`)
3. **Soumettre** à nouveau l'application :
   - Automatique via GitHub Actions (push sur `main`)
   - Ou manuellement dans Play Console

### Timeline

- **Maintenant** : Compléter justifications (5-10 min)
- **24-48h** : Attente réponse Google Support
- **Après** : Soumission automatique

---

## ✅ CHECKLIST FINALE

- [ ] READ_MEDIA_IMAGES justifiée (249/250 caractères)
- [ ] READ_MEDIA_VIDEO justifiée (249/250 caractères)
- [ ] CALL_PHONE vérifiée (justification présente si nécessaire)
- [ ] Toutes les modifications sauvegardées
- [ ] Plus d'avertissements dans Play Console

---

**Dernière mise à jour** : 28 novembre 2025  
**Temps estimé** : 5-10 minutes  
**Difficulté** : ⭐ Facile (copier-coller)

