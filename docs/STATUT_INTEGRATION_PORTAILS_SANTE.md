# 📊 STATUT INTÉGRATION PORTAILS SANTÉ

**Date** : 26 novembre 2025  
**Version** : 1.3.0

---

## ✅ CE QUI EST FAIT

### 1. Structure OAuth ✅

- ✅ Service `HealthPortalAuthService` créé
- ✅ Authentification OAuth implémentée
- ✅ Gestion refresh token implémentée
- ✅ Gestion expiration tokens implémentée
- ✅ Callback OAuth géré

### 2. Configuration eHealth ✅

- ✅ URLs OAuth réelles mises à jour :
  - Authorize : `https://iam.ehealth.fgov.be/iam-connect/oidc/authorize`
  - Token : `https://iam.ehealth.fgov.be/iam-connect/oidc/token`
- ✅ Scopes réels eHealth configurés :
  - `ehealthbox.read`
  - `consultations.read`
  - `labresults.read`
- ✅ Documentation complète créée : `INTEGRATION_EHEALTH_DETAILLEE.md`

### 3. Backend ✅

- ✅ Endpoint `/api/v1/health-portals/import` existe
- ✅ Structure de parsing basique en place
- ⚠️ Parsing réel manquant (nécessite accès API)

---

## ⏸️ CE QUI MANQUE

### 1. Accréditation eHealth ⚠️ CRITIQUE

**Statut** : En attente

**Actions nécessaires** :
- [ ] Contacter integration-support@ehealth.fgov.be
- [ ] Préparer dossier d'enregistrement
- [ ] Obtenir certificat eHealth (sandbox puis production)
- [ ] Obtenir client_id et client_secret
- [ ] Configurer callback URL dans eHealth

**Temps estimé** : 2-4 semaines (procédure administrative)

**Blocage** : Impossible de tester sans accréditation

---

### 2. Services Backend Manquants ⏸️

**Fichiers à créer** :

- [ ] `arkalia_cia_python_backend/services/health_portal_parsers.py`
  - Parser eHealth
  - Parser Andaman 7 (quand info disponible)
  - Parser MaSanté (quand info disponible)

- [ ] `arkalia_cia_python_backend/services/health_portal_fetchers.py`
  - Fetcher eHealth (appels API réels)
  - Fetcher Andaman 7 (quand info disponible)
  - Fetcher MaSanté (quand info disponible)

**Temps estimé** : 1 semaine (une fois accès obtenu)

---

### 3. Endpoints Backend Spécifiques ⏸️

**Endpoints à créer** :

- [ ] `/api/v1/health-portals/ehealth/fetch`
  - Récupère données depuis API eHealth
  - Utilise access_token OAuth
  - Retourne documents, consultations, examens

- [ ] `/api/v1/health-portals/andaman7/fetch` (quand info disponible)
- [ ] `/api/v1/health-portals/masante/fetch` (quand info disponible)

**Temps estimé** : 3-4 jours (une fois accès obtenu)

---

### 4. Parsing Réel des Données ⏸️

**Actuellement** : Structure vide, pas de parsing réel

**À implémenter** :
- [ ] Parser documents eHealthBox (format JSON eHealth)
- [ ] Parser consultations (format JSON eHealth)
- [ ] Parser examens labresults (format JSON eHealth)
- [ ] Sauvegarde dans base de données
- [ ] Téléchargement fichiers PDF depuis URLs

**Temps estimé** : 1 semaine (une fois accès obtenu)

---

### 5. Andaman 7 et MaSanté ⏸️

**Statut** : ❌ **Pas d'API publique disponible**

**Réalité** :
- ❌ Andaman 7 : Pas d'API publique, pas d'OAuth
- ❌ MaSanté : Pas d'API publique, pas d'OAuth
- ✅ **Solution** : Import manuel (PDF/CSV) + Parsing backend

**Actions** :
- [ ] Créer écran import manuel
- [ ] Implémenter parser PDF Andaman 7
- [ ] Implémenter parser CSV Andaman 7
- [ ] Implémenter parser PDF MaSanté
- [ ] Créer endpoint backend import manuel
- [ ] Tests avec fichiers réels

**Temps estimé** : 3-4 semaines (parsing PDF complexe)

**Voir** : `INTEGRATION_ANDAMAN7_MASANTE.md` pour détails complets

---

## 📋 CHECKLIST COMPLÈTE

### Phase 1 : Accréditation (2-4 semaines)

- [ ] Contacter eHealth
- [ ] Préparer dossier
- [ ] Obtenir certificat sandbox
- [ ] Obtenir client_id/secret
- [ ] Tester OAuth en sandbox

### Phase 2 : Développement Backend (1-2 semaines)

- [ ] Créer `health_portal_parsers.py`
- [ ] Créer `health_portal_fetchers.py`
- [ ] Créer endpoints spécifiques
- [ ] Implémenter parsing réel
- [ ] Tester avec données sandbox

### Phase 3 : Tests et Validation (1 semaine)

- [ ] Tests complets sandbox
- [ ] Passer tests conformité
- [ ] Livrer rapport tests
- [ ] Obtenir validation production

### Phase 4 : Andaman 7 et MaSanté (1-2 semaines)

- [ ] Rechercher documentation
- [ ] Adapter code
- [ ] Implémenter parsers
- [ ] Tester

---

## 🎯 PROCHAINES ÉTAPES IMMÉDIATES

1. **Contacter eHealth** (URGENT)
   - Email : integration-support@ehealth.fgov.be
   - Demander accès sandbox
   - Demander documentation complète

2. **Préparer dossier**
   - Description application
   - Cas d'usage
   - Justification accès données

3. **En attendant accréditation**
   - Implémenter alternative (export PDF + parsing)
   - Rechercher Andaman 7 et MaSanté
   - Préparer structure code

---

## 📊 PROGRESSION

| Étape | Statut | Progression |
|-------|--------|-------------|
| Structure OAuth | ✅ Fait | 100% |
| Configuration eHealth | ✅ Fait | 100% |
| Documentation eHealth | ✅ Fait | 100% |
| Accréditation eHealth | ⏸️ En attente | 0% |
| Services Backend | ⏸️ En attente | 0% |
| Parsing Réel | ⏸️ En attente | 0% |
| Andaman 7 | ⏸️ Import manuel | 0% (pas d'API) |
| MaSanté | ⏸️ Import manuel | 0% (pas d'API) |

**Progression globale** : **30%** (structure prête, accès manquant)

---

## ⚠️ BLOCAGES

1. **Accréditation eHealth** : Nécessaire pour continuer
2. **Documentation Andaman 7/MaSanté** : À rechercher
3. **Certificat eHealth** : Procédure longue

---

## 🔀 ALTERNATIVES

Si accréditation eHealth impossible :

1. **Export PDF manuel** : Utilisateurs exportent depuis portail, upload dans app
2. **Partenariat** : Avec éditeur agréé (CareConnect, Medispring)
3. **Portails patients hôpitaux** : APIs moins contraintes

---

**Dernière mise à jour** : 26 novembre 2025

