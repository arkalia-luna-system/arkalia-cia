# AGENTS — Arkalia CIA

Pont court pour les agents travaillant dans ce dépôt. Le circuit détaillé (rôles, preuves, audit) est fourni par le **plugin** Arkalia Agent Core — ne pas le recopier ici.

## Invariants projet

- **Privacy-first** : aucune collecte de données ; chiffrement local.
- **Offline-first** : pas de cloud obligatoire.
- **Accessibilité seniors** : textes ≥ 14px, interface simple et claire.
- **Ne jamais supprimer de fonctionnalités** sans vérification d’usage et décision Athalia.
- **Sécurité** : ne pas lire ni committer de secrets (keystore, `key.properties`, credentials).

## Documents de référence

- `README.md` — vue d’ensemble et statut
- `arkalia_cia/pubspec.yaml` — version
- `docs/POUR_MAMAN.md` — guide utilisateur
- `docs/deployment/DEPLOYMENT.md` — déploiement
- `docs/deployment/PLAY_STORE_METADATA.md` — métadonnées Play Store
- `docs/integrations/ARIA_INTEGRATION.md` — ARIA
- `docs/integrations/ECOSYSTEM_VISION.md` — vision écosystème

## Circuit (plugin)

1. Audit / question → agent approprié du plugin  
2. **Oui explicite d’Athalia** avant toute écriture  
3. Exécutant (`/executant`) — un domaine, périmètre fichier clair  
4. Vérificateur (`/verificateur`) — lecture seule, pas de correction  

Git (commit, push, merge) : ordre distinct, jamais inclus dans le seul « oui » code.

## Décisions

Athalia décide. En cas de doute sur le périmètre ou le dépôt : demander confirmation, ne pas élargir.
