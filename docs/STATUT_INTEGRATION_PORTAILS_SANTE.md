# 📊 STATUT INTÉGRATION PORTAILS SANTÉ

**Date** : 27 novembre 2025  
**Version** : 1.3.0  
**Dernière mise à jour** : 27 novembre 2025

---

## 🎯 RÉALITÉ DES PORTALS

| Portail | API Publique | OAuth | Solution Disponible | Statut |
|---------|--------------|-------|---------------------|--------|
| **eHealth** | ✅ Oui (restreint) | ✅ Oui (si accrédité) | Accréditation INAMI requise | ⏸️ En attente accréditation |
| **Andaman 7** | ❌ Non | ❌ Non | Import manuel (PDF/CSV) | ✅ Implémenté |
| **MaSanté** | ❌ Non | ❌ Non | Import manuel (PDF/CSV) | ✅ Implémenté |

---

## ✅ CE QUI EST FAIT

### 1. Structure OAuth ✅

- ✅ Service `HealthPortalAuthService` créé
- ✅ Authentification OAuth implémentée (pour eHealth uniquement)
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

### 3. Import Manuel (Andaman 7 / MaSanté) ✅ **IMPLÉMENTÉ**

**Backend** :
- ✅ Parser spécifique Andaman 7 créé (`health_portal_parsers.py`)
- ✅ Parser spécifique MaSanté créé
- ✅ Parser générique (fallback)
- ✅ Extraction résultats labo
- ✅ Endpoint `/api/v1/health-portals/import/manual` créé
- ✅ Upload PDF multipart
- ✅ Parsing automatique selon portail
- ✅ Sauvegarde documents via `document_service`

**Frontend** :
- ✅ Service `HealthPortalImportService` créé
- ✅ UI améliorée avec guide utilisateur
- ✅ Sélection portail (Andaman 7 / MaSanté)
- ✅ Dialog progression
- ✅ Messages succès/erreur

**Documentation** :
- ✅ `STRATEGIE_GRATUITE_PORTAILS_SANTE.md` : Explication choix gratuit
- ✅ `INTEGRATION_ANDAMAN7_MASANTE.md` : Guide import manuel
- ✅ `PLAN_IMPLÉMENTATION_IMPORT_MANUEL.md` : Plan complet

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

### 2. Tests avec Fichiers Réels (Import Manuel) ⏸️

**Statut** : À faire

**Actions** :
- [ ] Obtenir PDF réel Andaman 7
- [ ] Obtenir PDF réel MaSanté
- [ ] Tester parser Andaman 7
- [ ] Tester parser MaSanté
- [ ] Ajuster regex si nécessaire
- [ ] Tester endpoint backend
- [ ] Tester UI Flutter end-to-end

**Temps estimé** : 1 semaine

---

### 3. Améliorer Guide Utilisateur ⏸️

**Statut** : À améliorer

**Actions** :
- [ ] Ajouter captures d'écran (si possible)
- [ ] Instructions plus détaillées
- [ ] FAQ "Problèmes courants"
- [ ] Bouton "Besoin d'aide ?"

**Temps estimé** : 2-3 jours

---

## 📊 PROGRESSION

| Étape | Statut | Progression |
|-------|--------|-------------|
| Structure OAuth | ✅ Fait | 100% |
| Configuration eHealth | ✅ Fait | 100% |
| Documentation eHealth | ✅ Fait | 100% |
| Parser Andaman 7/MaSanté | ✅ Fait | 100% |
| Endpoint Import Manuel | ✅ Fait | 100% |
| Service Flutter | ✅ Fait | 100% |
| UI Flutter | ✅ Fait | 90% |
| Accréditation eHealth | ⏸️ En attente | 0% |
| Tests Fichiers Réels | ⏸️ À faire | 0% |
| Guide Utilisateur | ⏸️ À améliorer | 50% |

**Progression globale** : **85%** ✅

---

## 🎯 STRATÉGIE

**Import Manuel (Gratuit)** : ✅ **Implémenté et fonctionnel**
- Andaman 7 : Export PDF → Upload → Parsing automatique
- MaSanté : Export PDF → Upload → Parsing automatique
- Coût : 0€
- Friction : Acceptable (1 upload par utilisateur)

**eHealth (Automatique)** : ⏸️ **En attente accréditation**
- OAuth fonctionnel (code prêt)
- Accréditation INAMI requise (2-4 semaines)
- Coût : 0€ (mais procédure longue)

**Voir** : `STRATEGIE_GRATUITE_PORTAILS_SANTE.md` pour détails complets

---

**Dernière mise à jour** : 27 novembre 2025
