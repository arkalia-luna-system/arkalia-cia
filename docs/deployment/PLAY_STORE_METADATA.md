# Métadonnées Google Play Store — statut

**Dernière mise à jour** : 4 novembre 2026

## Statut

**Google Play Store n'est pas utilisé** pour Arkalia CIA.

Le dépôt a été rejeté le 9 décembre 2025 (restrictions pour applications de santé). Ne pas traiter ce fichier comme une checklist « prêt à publier » sur Play Console.

## Où trouver le déploiement réel

Voir **[DEPLOYMENT.md](./DEPLOYMENT.md)** :

- déploiement PWA / GitHub Pages
- builds locaux Android / sideload
- note explicite sur l'abandon Play Store

## Workflow CI

Le fichier `.github/workflows/deploy-play-store.yml` est **OBSOLÈTE / dormant** :
triggers `push`/`tags` retirés, job court-circuité (`if: false`).
Ne pas le réactiver sans décision Athalia. Pas de correction code pour les messages Play Console (« unreviewed / 0 testers / production inactive »).

## Contenu historique

D'anciennes descriptions, assets et checklists Play Console ont été retirés de ce document pour éviter les fausses promesses. Si besoin d'archives, consulter l'historique Git de ce fichier.
