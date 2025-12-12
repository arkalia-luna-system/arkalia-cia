# 🚨 URGENT - Sécurisation Client Secret Google OAuth2

**Date** : 12 décembre 2025  
**Statut** : ⚠️ **ACTION REQUISE IMMÉDIATEMENT**

---

## 🚨 PROBLÈME DÉTECTÉ

GitGuardian a détecté que le **Client Secret Web Google OAuth2** était exposé dans le dépôt GitHub.

**Client Secret exposé** : `GOCSPX-***[SECRET_REVOQUE]`

**Fichiers concernés** :
- `docs/guides/CONFIGURATION_GOOGLE_SIGN_IN_COMPLETE.md` (ligne 39)
- `docs/guides/SECURITE_GOOGLE_SIGN_IN.md` (ligne 70)

---

## ✅ ACTIONS DÉJÀ EFFECTUÉES

1. ✅ **Client Secret retiré** des fichiers de documentation
2. ✅ **Remplacé par placeholder** (`GOCSPX-***`)
3. ✅ **Documentation mise à jour** avec avertissements de sécurité

---

## 🔐 ACTIONS À EFFECTUER IMMÉDIATEMENT

### 1. Révoquer le Client Secret exposé

**Dans Google Cloud Console** :

1. Aller sur : https://console.cloud.google.com/apis/credentials?project=arkalia-cia
2. Trouver le **Client Web 1** (Client ID : `1062485264410-mc24cenl8rq8qj71enrrp36mibrsep79`)
3. Cliquer sur le Client Web
4. Cliquer sur **"RESET SECRET"** ou **"DELETE"** puis recréer
5. **Copier le nouveau Client Secret** (ne pas le committer !)

**⚠️ IMPORTANT** : Si tu utilises ce Client Secret dans un backend, tu devras le mettre à jour.

### 2. Vérifier l'historique Git

Le Client Secret est toujours dans l'historique Git. Pour le retirer complètement :

```bash
# Option 1 : Utiliser git filter-branch (si nécessaire)
# ATTENTION : Cela réécrit l'historique Git
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch docs/guides/CONFIGURATION_GOOGLE_SIGN_IN_COMPLETE.md docs/guides/SECURITE_GOOGLE_SIGN_IN.md" \
  --prune-empty --tag-name-filter cat -- --all

# Option 2 : Utiliser BFG Repo-Cleaner (recommandé)
# Télécharger BFG : https://rtyley.github.io/bfg-repo-cleaner/
bfg --replace-text passwords.txt
# Où passwords.txt contient : GOCSPX-***[SECRET_REVOQUE]==>GOCSPX-***

# Option 3 : Forcer push (si dépôt privé et peu de contributeurs)
git push origin --force --all
```

**⚠️ ATTENTION** : Ces commandes réécrivent l'historique Git. À utiliser uniquement si :
- Le dépôt est privé OU
- Tu as peu de contributeurs et tu peux les avertir

### 3. Vérifier qu'aucun autre secret n'est exposé

```bash
# Rechercher d'autres occurrences
grep -r "GOCSPX" .
grep -r "client_secret" . --exclude-dir=.git
grep -r "CLIENT_SECRET" . --exclude-dir=.git
```

### 4. Mettre à jour .gitignore

Ajouter dans `.gitignore` :

```
# Secrets Google OAuth2
*_SECRETS.md
*_SECRETS.txt
*_CLIENT_SECRET*.md
*_CLIENT_SECRET*.txt
```

---

## 📋 BONNES PRATIQUES POUR L'AVENIR

### ✅ À FAIRE

1. **Ne jamais committer de secrets** dans Git
2. **Utiliser des placeholders** dans la documentation : `GOCSPX-***`
3. **Stocker les secrets** dans :
   - Google Cloud Console (pour OAuth)
   - GitHub Secrets (pour CI/CD)
   - Variables d'environnement (pour développement local)
4. **Utiliser des outils de détection** : GitGuardian, git-secrets, etc.

### ❌ À ÉVITER

1. ❌ Mettre des secrets en dur dans le code
2. ❌ Committer des secrets dans la documentation
3. ❌ Partager des secrets par email/chat
4. ❌ Ignorer les alertes de sécurité

---

## 🔍 VÉRIFICATION POST-ACTION

Après avoir révoqué et recréé le Client Secret :

- [ ] Client Secret révoqué dans Google Cloud Console
- [ ] Nouveau Client Secret créé
- [ ] Nouveau Client Secret stocké de manière sécurisée (pas dans Git)
- [ ] Historique Git nettoyé (si nécessaire)
- [ ] Aucun autre secret exposé
- [ ] Documentation mise à jour avec placeholders
- [ ] .gitignore mis à jour

---

## 📚 RESSOURCES

- **Google Cloud Console** : https://console.cloud.google.com/apis/credentials?project=arkalia-cia
- **GitGuardian** : https://dashboard.gitguardian.com/
- **BFG Repo-Cleaner** : https://rtyley.github.io/bfg-repo-cleaner/
- **Guide sécurité** : `docs/guides/SECURITE_GOOGLE_SIGN_IN.md`

---

## ⚠️ IMPACT

### Impact actuel

- **Client Secret exposé** : Oui
- **Utilisé dans l'app mobile** : ❌ Non (seulement pour backend web si nécessaire)
- **Risque immédiat** : Faible (pas utilisé dans l'app mobile)
- **Risque futur** : Moyen (si backend web utilise ce secret)

### Actions recommandées

1. **Immédiat** : Révoquer le Client Secret exposé
2. **Court terme** : Nettoyer l'historique Git (si possible)
3. **Long terme** : Mettre en place des outils de détection automatique

---

**Dernière mise à jour** : 12 décembre 2025  
**Statut** : ⚠️ Action requise

