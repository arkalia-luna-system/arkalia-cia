# 🛡️ Configuration des branches protégées - Arkalia CIA

## Règles de protection des branches

### Branche `main` (Production)
- ✅ **Require pull request reviews** : 1 approbation minimum
- ✅ **Dismiss stale reviews** : Rejeter les reviews obsolètes
- ✅ **Require review from code owners** : Review obligatoire des propriétaires
- ✅ **Require status checks to pass** : Tous les checks CI doivent passer
- ✅ **Require branches to be up to date** : Branche à jour avant merge
- ✅ **Require conversation resolution** : Toutes les conversations résolues
- ✅ **Require signed commits** : Commits signés obligatoires
- ✅ **Require linear history** : Historique linéaire
- ❌ **Allow force pushes** : Interdit
- ❌ **Allow deletions** : Interdit

### Branche `develop` (Développement)
- ✅ **Require pull request reviews** : 1 approbation minimum
- ✅ **Dismiss stale reviews** : Rejeter les reviews obsolètes
- ✅ **Require status checks to pass** : Tous les checks CI doivent passer
- ✅ **Require branches to be up to date** : Branche à jour avant merge
- ✅ **Require conversation resolution** : Toutes les conversations résolues
- ❌ **Allow force pushes** : Interdit
- ❌ **Allow deletions** : Interdit

### Branches `feature/*` (Fonctionnalités)
- ✅ **Require status checks to pass** : Checks CI obligatoires
- ❌ **Allow force pushes** : Interdit
- ❌ **Allow deletions** : Interdit

## Checks de statut requis

### Pour `main` et `develop`
- `CI_CD_Matrix_Ultra_Pro` : Pipeline principal
- `CodeQL Analysis` : Analyse de sécurité
- `Dependabot` : Vérification des dépendances

### Pour `feature/*`
- `CI_CD_Matrix_Ultra_Pro` : Pipeline principal

## Règles de merge

### Stratégie de merge
- **Squash and merge** : Recommandé pour les features
- **Merge commit** : Pour les releases
- **Rebase and merge** : Interdit

### Restrictions
- **Restrict pushes** : Seuls les membres de l'organisation
- **Restrict pushes that create files** : Interdit
- **Restrict pushes that create files** : Interdit

## Configuration via GitHub CLI

```bash
# Protection de la branche main
gh api repos/:owner/:repo/branches/main/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":["CI_CD_Matrix_Ultra_Pro","CodeQL Analysis"]}' \
  --field enforce_admins=true \
  --field required_pull_request_reviews='{"required_approving_review_count":1,"dismiss_stale_reviews":true,"require_code_owner_reviews":true}' \
  --field restrictions='{"users":[],"teams":["arkalia-luna-system"]}'

# Protection de la branche develop
gh api repos/:owner/:repo/branches/develop/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":["CI_CD_Matrix_Ultra_Pro"]}' \
  --field enforce_admins=false \
  --field required_pull_request_reviews='{"required_approving_review_count":1,"dismiss_stale_reviews":true}' \
  --field restrictions='{"users":[],"teams":["arkalia-luna-system"]}'
```

## Monitoring et alertes

### Notifications automatiques
- **Échec de CI** : Notification immédiate
- **Vulnérabilités détectées** : Alerte sécurité
- **Force push détecté** : Alerte immédiate
- **Suppression de branche** : Alerte immédiate

### Logs d'audit
- Tous les événements de protection sont loggés
- Rapports mensuels de sécurité
- Audit trimestriel des permissions

---

*Configuration maintenue par l'équipe Arkalia Luna System*
