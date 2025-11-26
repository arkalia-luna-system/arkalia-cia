# 🔐 INTÉGRATION EHEALTH BELGIQUE - GUIDE COMPLET

**Date** : 26 novembre 2025  
**Statut** : Documentation complète - En attente d'accréditation

---

## 📊 RÉSUMÉ EXÉCUTIF

L'API eHealth belge est **officiellement disponible** mais strictement réservée aux acteurs autorisés du secteur santé. 

**Complexité** : ⚠️ **ÉLEVÉE**
- Enregistrement administratif requis ("software integrator")
- Validation légale nécessaire
- Certificat eHealth obligatoire
- Processus d'onboarding encadré (non automatisé)

**Coût** : Gratuit mais procédure longue (plusieurs semaines/mois)

**Accès** : Sandbox disponible pour tests, production après validation

---

## 🔗 URLs EXACTES

### OAuth / OIDC (I.AM Connect)

- **Authorize endpoint** :
  ```
  https://iam.ehealth.fgov.be/iam-connect/oidc/authorize
  ```

- **Token endpoint** :
  ```
  https://iam.ehealth.fgov.be/iam-connect/oidc/token
  ```

### API Gateway

- **Base URL** :
  ```
  https://api.ehealth.fgov.be/<service>
  ```

- **Documents médicaux (eHealthBox)** :
  ```
  https://api.ehealth.fgov.be/ehealthbox/v1/messages
  ```

- **Consultations** :
  ```
  https://api.ehealth.fgov.be/rnconsult/v1/getConsultations
  ```
  ⚠️ Dépend du scope d'accès et du contrat d'intégration

- **Examens (Lab Results)** :
  ```
  https://api.ehealth.fgov.be/labresults/v1/getResults
  ```
  ⚠️ Selon contrat d'intégration

**Note** : L'URL exacte dépend du service activé lors de l'onboarding. Chaque service = un endpoint spécifique. Voir [API Catalog](https://www.ehealth.fgov.be/api-catalog/) pour la liste complète.

---

## 💻 EXEMPLES DE CODE

### 1. Requête OAuth (Python)

```python
import requests

url = "https://iam.ehealth.fgov.be/iam-connect/oidc/token"

data = {
    "grant_type": "authorization_code",
    "code": "<code_reçu>",
    "redirect_uri": "arkaliacia://oauth/ehealth",
    "client_id": "<ton_client_id>",
    "client_secret": "<ton_client_secret>"
}

response = requests.post(url, data=data)
print(response.json())
```

**Méthode d'authentification** : Basic Auth ou dans le corps de la requête (`client_id`/`client_secret`)

### 2. Réponse OAuth

```json
{
  "access_token": "eyJraWQiOiJk...",
  "refresh_token": "8YJp1I...",
  "expires_in": 3600,
  "token_type": "Bearer",
  "scope": "ehealthbox.read consultations.read"
}
```

**Durée de vie** :
- Access token : ~1 heure (3600 secondes)
- Refresh token : Multi-usage (durée variable)

### 3. Requête API (Documents eHealthBox)

```python
import requests

headers = {
    "Authorization": "Bearer <access_token>",
    "Accept": "application/json"
}

url = "https://api.ehealth.fgov.be/ehealthbox/v1/messages"
response = requests.get(url, headers=headers)
print(response.json())
```

### 4. Réponse API (eHealthBox Messages)

```json
{
  "messages": [
    {
      "id": "271405ff42c48a85fb63a5239c44e260",
      "subject": "Ordonnance",
      "sender": {
        "nin": "xxxxxx",
        "nihii": "yyyyyy",
        "name": "Dr Nom"
      },
      "received_at": "2025-11-20T14:05:00+01:00",
      "attachments": [
        {
          "filename": "ordonnance.pdf",
          "url": "https://api.ehealth.fgov.be/ehealthbox/v1/messages/271405ff42c48a85fb63a5239c44e260/attachment/1"
        }
      ]
    }
  ]
}
```

---

## 📚 LIENS DOCUMENTATION

### Documentation officielle

- **OAuth / OIDC (I.AM Connect)** :
  https://www.ehealth.fgov.be/ehealthplatform/fr/service-i.am-identity-access-management

- **API Catalog** (liste & specs endpoints) :
  https://www.ehealth.fgov.be/api-catalog/

- **Procédure d'inscription développeur** :
  https://www.ehealth.fgov.be/ehealthplatform/fr/service-certificats-ehealth

- **Procédure de demande de certificat** :
  https://www.ehealth.fgov.be/ehealthplatform/fr/service-certificats-ehealth

### Support

- **Intégration/API** : integration-support@ehealth.fgov.be
- **Technique** : support@ehealth.fgov.be

---

## ⚠️ POINTS D'ATTENTION CRITIQUES

### 1. Accès restreint

- **Réservé aux entités agréées** :
  - Hôpitaux
  - Éditeurs logiciel médical certifié
  - Institutions avec numéro INAMI/NIHII

### 2. Procédure obligatoire

1. **Enregistrement "Application Registration"**
2. **Choix/passage des tests de conformité** (sandbox)
3. **Livraison d'un "rapport de tests"**
4. **Validation par l'équipe d'intégration**

### 3. Certificat eHealth

- **Pas juste client_id/secret** : Il faut un certificat logiciel
- **Configuration dans l'infrastructure** requise
- Voir documentation pour détails

### 4. Scopes

- Diffèrent fortement selon les services
- Exemples : `ehealthbox.read`, `consultations.read`, etc.
- Dépendent du contrat d'intégration

### 5. Callback URL

- Format URI custom accepté **si déclaré et validé au préalable** lors de l'onboarding
- Notre callback : `arkaliacia://oauth/ehealth`

### 6. Documentation

- Structure ("schema") et codes erreurs dans OpenAPI/Swagger
- Disponibles dans l'API Catalog **uniquement après enregistrement**

### 7. Limitations

- Pas d'accès sans justification métier + juridique
- Sandbox disponible (certificat de test à demander)
- Processus lent (plusieurs semaines/mois)

---

## 🔄 PROCESSUS D'INTÉGRATION

### Étape 1 : Préparation

1. Vérifier que tu as :
   - Numéro INAMI (si applicable)
   - Justification métier pour l'accès
   - Infrastructure sécurisée

2. Préparer la demande :
   - Description de l'application
   - Cas d'usage
   - Justification de l'accès aux données

### Étape 2 : Enregistrement

1. Contacter : integration-support@ehealth.fgov.be
2. Suivre la procédure d'enregistrement
3. Obtenir certificat de test (sandbox)

### Étape 3 : Développement

1. Configurer OAuth avec les vraies URLs
2. Implémenter les appels API
3. Tester en sandbox

### Étape 4 : Validation

1. Passer les tests de conformité
2. Livrer rapport de tests
3. Obtenir validation pour production

---

## 🔀 ALTERNATIVES SI PAS D'ACCRÉDITATION

### Option 1 : Export manuel + Parsing PDF

- Utilisateurs exportent manuellement leurs documents (PDF, XML) via le portail eHealth
- Upload dans l'app
- Parsing côté backend avec le parser PDF existant

### Option 2 : Partenariat

- Partenariat avec un éditeur agréé (ex: CareConnect, Medispring)
- Utiliser leur API comme intermédiaire

### Option 3 : Portails patients hôpitaux

- Certains hôpitaux proposent des "portails patients" moins contraints
- Vérifier les APIs spécifiques ou fichiers exportables

---

## 📋 CHECKLIST INTÉGRATION

### Prérequis

- [ ] Numéro INAMI (si applicable)
- [ ] Justification métier
- [ ] Infrastructure sécurisée
- [ ] Certificat eHealth (après enregistrement)

### Configuration

- [ ] URLs OAuth mises à jour dans le code
- [ ] URLs API mises à jour dans le code
- [ ] Callback URL déclaré lors de l'onboarding
- [ ] Certificat configuré dans l'infrastructure

### Développement

- [ ] Service de récupération eHealth implémenté
- [ ] Parser eHealth implémenté
- [ ] Gestion des tokens (refresh) fonctionnelle
- [ ] Gestion des erreurs complète

### Tests

- [ ] Tests en sandbox
- [ ] Tests de conformité passés
- [ ] Rapport de tests livré
- [ ] Validation production obtenue

---

## 🎯 PROCHAINES ÉTAPES

1. **Contacter eHealth** : integration-support@ehealth.fgov.be
2. **Demander accès sandbox** : Pour commencer les tests
3. **Adapter le code** : Avec les vraies URLs (déjà fait ci-dessous)
4. **Implémenter les parsers** : Une fois l'accès obtenu

---

**Dernière mise à jour** : 26 novembre 2025

