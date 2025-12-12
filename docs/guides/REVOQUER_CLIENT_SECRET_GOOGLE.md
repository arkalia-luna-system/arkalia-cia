# 🔐 Guide : Révoquer le Client Secret Google OAuth2

**Date** : 12 décembre 2025  
**Statut** : ⚠️ **ACTION URGENTE REQUISE**

---

## 🚨 PROBLÈME

GitGuardian a détecté que le **Client Secret Web Google OAuth2** était exposé dans le dépôt GitHub.

**Impact** :
- ⚠️ Le secret est compromis et doit être révoqué immédiatement
- ⚠️ Si quelqu'un utilise ce secret, il peut se faire passer pour ton application
- ✅ **Bonne nouvelle** : Le secret n'est pas utilisé dans l'app mobile (seulement pour backend web si nécessaire)

---

## 🎯 OBJECTIF

Révoquer le Client Secret exposé et en créer un nouveau si nécessaire.

---

## 📋 ÉTAPES DÉTAILLÉES

### 1. Accéder à Google Cloud Console

1. Aller sur : https://console.cloud.google.com/apis/credentials?project=arkalia-cia
2. Se connecter avec le compte Google associé au projet

### 2. Trouver le Client Web exposé

1. Dans la liste des **OAuth 2.0 Client IDs**, trouver :
   - **Nom** : `Client Web 1` (ou similaire)
   - **Client ID** : `1062485264410-mc24cenl8rq8qj71enrrp36mibrsep79.apps.googleusercontent.com`
   - **Type** : Application Web

2. Cliquer sur le client pour ouvrir les détails

### 3. Révoquer le Client Secret

**Option A : Réinitialiser le secret (RECOMMANDÉ)**

1. Dans la page de détails du client, trouver la section **Client secret**
2. Cliquer sur **"RESET SECRET"** ou **"Réinitialiser le secret"**
3. Confirmer l'action
4. **Copier le nouveau Client Secret** qui s'affiche
5. **⚠️ IMPORTANT** : Ne pas committer ce nouveau secret dans Git !

**Option B : Supprimer et recréer le client**

1. Cliquer sur **"DELETE"** ou **"Supprimer"**
2. Confirmer la suppression
3. Cliquer sur **"+ CREATE CREDENTIALS"** > **"OAuth client ID"**
4. Sélectionner **"Web application"**
5. Remplir :
   - **Name** : `Client Web 1` (ou un nom de ton choix)
   - **Authorized JavaScript origins** : (si nécessaire pour ton backend)
   - **Authorized redirect URIs** : (si nécessaire pour ton backend)
6. Cliquer sur **"CREATE"**
7. **Copier le nouveau Client Secret** qui s'affiche
8. **⚠️ IMPORTANT** : Ne pas committer ce nouveau secret dans Git !

---

## 💾 STOCKER LE NOUVEAU SECRET DE MANIÈRE SÉCURISÉE

### ✅ BONNES PRATIQUES

1. **Google Cloud Console** (recommandé)
   - Le secret est stocké de manière sécurisée dans Google Cloud Console
   - Tu peux le récupérer à tout moment depuis la console
   - Pas besoin de le stocker ailleurs

2. **Variables d'environnement** (si backend)
   ```bash
   # Dans .env (jamais commité)
   GOOGLE_OAUTH_CLIENT_SECRET=GOCSPX-[NOUVEAU_SECRET]
   ```

3. **GitHub Secrets** (si CI/CD)
   - Aller dans : Settings > Secrets and variables > Actions
   - Ajouter un nouveau secret : `GOOGLE_OAUTH_CLIENT_SECRET`
   - Coller le nouveau secret

4. **Gestionnaire de secrets** (pour équipes)
   - 1Password, LastPass, Bitwarden, etc.
   - Stocker le secret de manière sécurisée

### ❌ À ÉVITER

- ❌ Ne jamais committer le secret dans Git
- ❌ Ne jamais le mettre dans la documentation
- ❌ Ne jamais le partager par email/chat
- ❌ Ne jamais le mettre dans le code source

---

## 🔄 METTRE À JOUR LE BACKEND (si nécessaire)

Si tu utilises le Client Secret dans un backend :

### Backend Python (FastAPI)

```python
# Dans .env (jamais commité)
GOOGLE_OAUTH_CLIENT_SECRET=GOCSPX-[NOUVEAU_SECRET]

# Dans le code
import os
client_secret = os.getenv('GOOGLE_OAUTH_CLIENT_SECRET')
```

### Backend Node.js

```javascript
// Dans .env (jamais commité)
GOOGLE_OAUTH_CLIENT_SECRET=GOCSPX-[NOUVEAU_SECRET]

// Dans le code
const clientSecret = process.env.GOOGLE_OAUTH_CLIENT_SECRET;
```

### Backend autre

Utiliser les variables d'environnement de ton framework.

---

## ✅ VÉRIFICATION

Après avoir révoqué le secret :

- [ ] Ancien Client Secret révoqué dans Google Cloud Console
- [ ] Nouveau Client Secret créé (si nécessaire)
- [ ] Nouveau Client Secret stocké de manière sécurisée
- [ ] Backend mis à jour (si nécessaire)
- [ ] Aucun secret dans les fichiers Git
- [ ] Documentation mise à jour avec placeholders

---

## 🧪 TESTER

### Si backend utilise le secret

1. Mettre à jour la variable d'environnement avec le nouveau secret
2. Redémarrer le backend
3. Tester l'authentification OAuth
4. Vérifier que tout fonctionne

### Si app mobile uniquement

- ✅ **Aucune action nécessaire** : L'app mobile n'utilise pas le Client Secret Web
- ✅ La connexion Google continuera de fonctionner normalement

---

## 📊 IMPACT

### Impact de la révocation

- ✅ **App mobile** : Aucun impact (n'utilise pas le Client Secret Web)
- ⚠️ **Backend web** : Si tu utilises le secret, tu dois le mettre à jour
- ✅ **Sécurité** : Le secret compromis est maintenant inutilisable

### Timeline

- **Immédiat** : Révoquer le secret (5 minutes)
- **Court terme** : Mettre à jour le backend si nécessaire (10-15 minutes)
- **Long terme** : Nettoyer l'historique Git (optionnel, voir guide séparé)

---

## 🆘 EN CAS DE PROBLÈME

### Je ne trouve pas le Client Web dans Google Cloud Console

1. Vérifier que tu es connecté avec le bon compte Google
2. Vérifier que tu es dans le bon projet (`arkalia-cia`)
3. Aller dans : APIs & Services > Credentials
4. Chercher dans la liste des OAuth 2.0 Client IDs

### Je ne peux pas réinitialiser le secret

1. Vérifier les permissions du compte Google
2. Vérifier que tu es propriétaire ou éditeur du projet
3. Contacter l'administrateur du projet si nécessaire

### Le backend ne fonctionne plus après la révocation

1. Vérifier que le nouveau secret est correctement configuré
2. Vérifier que la variable d'environnement est chargée
3. Redémarrer le backend
4. Vérifier les logs d'erreur

---

## 📚 RESSOURCES

- **Google Cloud Console** : https://console.cloud.google.com/apis/credentials?project=arkalia-cia
- **Documentation Google OAuth** : https://developers.google.com/identity/protocols/oauth2
- **Guide nettoyer historique Git** : `docs/guides/NETTOYER_HISTORIQUE_GIT_SECRETS.md`
- **Guide sécurité** : `docs/guides/SECURITE_GOOGLE_SIGN_IN.md`

---

## 🎯 RÉSUMÉ

**Actions immédiates** :
1. ✅ Aller sur Google Cloud Console
2. ✅ Trouver le Client Web exposé
3. ✅ Réinitialiser le secret
4. ✅ Copier le nouveau secret
5. ✅ Stocker le nouveau secret de manière sécurisée
6. ✅ Mettre à jour le backend si nécessaire

**Temps estimé** : 5-15 minutes

---

**Dernière mise à jour** : 12 décembre 2025  
**Statut** : ⚠️ Action urgente requise

