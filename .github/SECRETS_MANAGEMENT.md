# 🔐 Gestion des secrets - Arkalia CIA

## Secrets GitHub configurés

### Secrets de production
- `CODECOV_TOKEN` : Token pour Codecov (coverage)
- `SECURITY_EMAIL` : Email pour les alertes de sécurité
- `GPG_PRIVATE_KEY` : Clé privée GPG pour la signature
- `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` : ⏳ **À configurer** - Compte de service Google Play pour déploiement automatique

### Variables d'environnement
- `PYTHON_VERSION` : Version Python (3.11)
- `NODE_VERSION` : Version Node.js (18)
- `FLUTTER_VERSION` : Version Flutter (3.0+)

## Bonnes pratiques

### ✅ À faire
- Utiliser des secrets GitHub pour les tokens
- Chiffrer les données sensibles
- Rotation régulière des secrets
- Audit des accès aux secrets
- Utiliser des variables d'environnement pour la config

### ❌ À éviter
- Commiter des secrets en dur
- Partager des secrets par email/chat
- Utiliser des secrets en production non testés
- Ignorer les alertes de sécurité
- Stocker des secrets dans le code

## Rotation des secrets

### Calendrier
- **Tokens API** : Tous les 90 jours
- **Clés GPG** : Tous les 6 mois
- **Mots de passe** : Tous les 60 jours
- **Certificats** : Avant expiration

### Processus
1. Générer nouveau secret
2. Tester en environnement de dev
3. Mettre à jour en production
4. Révoquer l'ancien secret
5. Documenter le changement

## Monitoring des secrets

### Alertes automatiques
- Détection de secrets exposés
- Tentatives d'accès non autorisées
- Rotation des secrets en retard
- Utilisation de secrets obsolètes

### Logs d'audit
- Accès aux secrets
- Modifications des secrets
- Utilisation des secrets
- Échecs d'authentification

---

*Gestion des secrets maintenue par l'équipe Arkalia Luna System*
