# Documentation API — Arkalia CIA

**Version** : 1.3.1  
**Date** : Janvier 2025  
**Base URL** : `http://localhost:8000` (développement) ou configurée via `BackendConfigService`  
**Version API** : `/api/v1/`

Documentation complète de l'API REST d'Arkalia CIA.

**Total endpoints** : 18 endpoints avec préfixe `/api/v1/` + 2 endpoints système (`/` et `/health`) = 20 endpoints au total.

---

## Table des matières

1. [Authentification](#authentification)
2. [Endpoints Documents](#endpoints-documents)
3. [Endpoints Médecins](#endpoints-médecins)
4. [Endpoints Rappels](#endpoints-rappels)
5. [Endpoints Contacts Urgence](#endpoints-contacts-urgence)
6. [Endpoints Portails Santé](#endpoints-portails-santé)
7. [Endpoints IA](#endpoints-ia)
8. [Endpoints Patterns](#endpoints-patterns)
9. [Gestion d'erreurs](#gestion-derreurs)
10. [Rate Limiting](#rate-limiting)

---

## Authentification

Tous les endpoints (sauf `/`, `/health` et `/api/v1/auth/*`) nécessitent une authentification via token JWT.

### Flux d'authentification

```mermaid
sequenceDiagram
    participant C as Client
    participant API as Backend API
    participant DB as Database

    C->>API: POST /api/v1/auth/register
    API->>DB: Créer utilisateur
    DB-->>API: Utilisateur créé
    API-->>C: 201 Created

    C->>API: POST /api/v1/auth/login
    API->>DB: Vérifier credentials
    DB-->>API: Utilisateur valide
    API->>API: Générer JWT
    API-->>C: access_token + refresh_token

    C->>API: GET /api/v1/documents (avec token)
    API->>API: Valider JWT
    API->>DB: Récupérer documents
    DB-->>API: Documents
    API-->>C: 200 OK + données
```

### Inscription

```http
POST /api/v1/auth/register
Content-Type: application/json

{
  "username": "utilisateur",
  "email": "user@example.com",
  "password": "motdepasse123"
}
```

**Réponse** :
```json
{
  "id": 1,
  "username": "utilisateur",
  "email": "user@example.com",
  "created_at": "2025-01-20T10:00:00"
}
```

### Connexion

```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "username": "utilisateur",
  "password": "motdepasse123"
}
```

**Réponse** :
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer"
}
```

### Rafraîchir le token

```http
POST /api/v1/auth/refresh
Content-Type: application/json

{
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

### Utiliser le token

Ajouter dans les headers de toutes les requêtes authentifiées :

```
Authorization: Bearer <access_token>
```

---

## Endpoints Documents

### Upload document

```http
POST /api/v1/documents/upload
Content-Type: multipart/form-data
Authorization: Bearer <token>

file: <fichier PDF>
category: examen|ordonnance|consultation|autre
```

**Réponse** :
```json
{
  "success": true,
  "document_id": 123,
  "message": "Document uploadé avec succès",
  "metadata": {
    "doctor_name": "Dr. Dupont",
    "document_date": "2025-01-15",
    "exam_type": "Analyse sanguine"
  }
}
```

**Traitement** :
- Extraction texte PDF
- OCR automatique si PDF scanné
- Extraction métadonnées (médecin, date, type)
- Association automatique avec médecin si trouvé

### Liste documents

```http
GET /api/v1/documents?skip=0&limit=50
Authorization: Bearer <token>
```

**Paramètres** :
- `skip` (int, optionnel) : Nombre de documents à ignorer (défaut: 0)
- `limit` (int, optionnel) : Nombre maximum (défaut: 50, max: 100)

**Réponse** :
```json
[
  {
    "id": 1,
    "original_name": "examen_sanguin.pdf",
    "file_path": "uploads/user_1/doc_1.pdf",
    "category": "examen",
    "created_at": "2025-01-20T10:00:00",
    "metadata": {
      "doctor_name": "Dr. Martin",
      "document_date": "2025-01-15",
      "exam_type": "Analyse sanguine"
    }
  }
]
```

### Récupérer document

```http
GET /api/v1/documents/{doc_id}
Authorization: Bearer <token>
```

**Réponse** : Document complet avec métadonnées

### Supprimer document

```http
DELETE /api/v1/documents/{doc_id}
Authorization: Bearer <token>
```

**Réponse** :
```json
{
  "success": true,
  "message": "Document supprimé avec succès"
}
```

---

## Endpoints Médecins

Les médecins sont gérés côté client (Flutter) via `DoctorService` et stockés localement en SQLite. Pas d'endpoints backend dédiés actuellement.

---

## Endpoints Rappels

### Créer rappel

```http
POST /api/v1/reminders
Content-Type: application/json
Authorization: Bearer <token>

{
  "title": "Prise médicament",
  "description": "Prendre médicament X",
  "reminder_date": "2025-01-25T08:00:00",
  "is_recurring": true,
  "recurrence_pattern": "daily"
}
```

**Réponse** :
```json
{
  "id": 1,
  "title": "Prise médicament",
  "reminder_date": "2025-01-25T08:00:00",
  "is_recurring": true,
  "created_at": "2025-01-20T10:00:00"
}
```

### Liste rappels

```http
GET /api/v1/reminders?skip=0&limit=50
Authorization: Bearer <token>
```

**Paramètres** : `skip`, `limit` (pagination)

---

## Endpoints Contacts Urgence

### Créer contact urgence

```http
POST /api/v1/emergency-contacts
Content-Type: application/json
Authorization: Bearer <token>

{
  "name": "Jean Dupont",
  "phone": "+32470123456",
  "relationship": "Fils",
  "is_ice": true
}
```

### Liste contacts urgence

```http
GET /api/v1/emergency-contacts?skip=0&limit=50
Authorization: Bearer <token>
```

---

## Endpoints Portails Santé

### Créer portail santé

```http
POST /api/v1/health-portals
Content-Type: application/json
Authorization: Bearer <token>

{
  "name": "eHealth",
  "portal_type": "ehealth",
  "access_token": "token_oauth"
}
```

### Liste portails santé

```http
GET /api/v1/health-portals?skip=0&limit=50
Authorization: Bearer <token>
```

### Importer depuis portail

```http
POST /api/v1/health-portals/import
Content-Type: application/json
Authorization: Bearer <token>

{
  "portal": "eHealth",
  "data": {
    "documents": [...],
    "consultations": [...],
    "exams": [...]
  }
}
```

**Réponse** :
```json
{
  "success": true,
  "documents_imported": 15,
  "consultations_imported": 8,
  "exams_imported": 12
}
```

---

## Endpoints IA

### Chat conversationnel

```http
POST /api/v1/ai/chat
Content-Type: application/json
Authorization: Bearer <token>

{
  "question": "Quels sont mes derniers examens ?",
  "user_data": {
    "documents": [...],
    "doctors": [...],
    "consultations": [...],
    "pain_records": [...]
  }
}
```

**Réponse** :
```json
{
  "answer": "Voici vos derniers examens...",
  "related_documents": [1, 2, 3],
  "suggestions": [
    "Quand était mon dernier examen ?",
    "Quels médecins ai-je consultés récemment ?"
  ],
  "patterns_detected": {
    "type": "temporal",
    "description": "Examens plus fréquents en hiver"
  },
  "question_type": "exam"
}
```

**Types de questions supportées** :
- `exam` : Questions sur examens
- `doctor` : Questions sur médecins
- `pain` : Questions sur douleurs (avec intégration ARIA)
- `medication` : Questions sur médicaments
- `appointment` : Questions sur rendez-vous
- `cause_effect` : Analyse cause-effet (avec ARIA)

### Historique conversations

```http
GET /api/v1/ai/conversations?limit=20
Authorization: Bearer <token>
```

**Réponse** :
```json
[
  {
    "id": 1,
    "question": "Quels sont mes derniers examens ?",
    "answer": "Voici vos derniers examens...",
    "question_type": "exam",
    "created_at": "2025-01-20T10:00:00"
  }
]
```

### Préparer rendez-vous

```http
POST /api/v1/ai/prepare-appointment
Content-Type: application/json
Authorization: Bearer <token>

{
  "doctor_id": "doc123",
  "user_data": {
    "consultations": [...],
    "doctors": [...],
    "documents": [...]
  }
}
```

**Réponse** :
```json
{
  "questions": [
    "Quels sont vos symptômes actuels ?",
    "Avez-vous pris vos médicaments régulièrement ?",
    "Y a-t-il eu des changements depuis la dernière consultation ?"
  ],
  "suggestions": [
    "Apporter les derniers examens",
    "Noter les questions avant le rendez-vous"
  ]
}
```

---

## Endpoints Patterns

### Analyser patterns

```http
POST /api/v1/patterns/analyze
Content-Type: application/json
Authorization: Bearer <token>

{
  "data": {
    "pain_records": [...],
    "consultations": [...],
    "medications": [...]
  }
}
```

**Réponse** :
```json
{
  "patterns": [
    {
      "type": "temporal",
      "description": "Douleurs plus fréquentes en hiver",
      "confidence": 0.85,
      "frequency": "monthly"
    }
  ],
  "trends": {
    "direction": "increasing",
    "description": "Augmentation des consultations"
  },
  "seasonality": {
    "peak_months": [11, 12, 1],
    "description": "Pic en hiver"
  }
}
```

### Prédire événements futurs

```http
POST /api/v1/patterns/predict-events
Content-Type: application/json
Authorization: Bearer <token>

{
  "data": {
    "pain_records": [...],
    "consultations": [...]
  },
  "prediction_days": 30
}
```

**Réponse** :
```json
{
  "predictions": [
    {
      "date": "2025-02-15",
      "event_type": "pain_episode",
      "probability": 0.75,
      "confidence": 0.82
    }
  ],
  "model": "prophet",
  "accuracy": 0.78
}
```

---

## Gestion d'erreurs

### Codes de statut HTTP

| Code | Signification |
|------|--------------|
| `200` | Succès |
| `201` | Créé avec succès |
| `400` | Requête invalide |
| `401` | Non authentifié |
| `403` | Accès interdit |
| `404` | Ressource non trouvée |
| `422` | Erreur de validation |
| `429` | Trop de requêtes (rate limit) |
| `500` | Erreur serveur |

### Format d'erreur

```json
{
  "detail": "Message d'erreur détaillé",
  "error_code": "VALIDATION_ERROR",
  "field": "email"
}
```

---

## Rate Limiting

Tous les endpoints sont protégés par un rate limiting :

- **Par IP** : 100 requêtes/minute
- **Par utilisateur** : 200 requêtes/minute
- **Endpoints sensibles** : 10 requêtes/minute

En cas de dépassement, réponse `429 Too Many Requests` avec header `Retry-After`.

---

## Schéma de flux complet

```mermaid
graph TB
    subgraph "Client Flutter"
        A[Écran UI] --> B[Service]
        B --> C[ApiService]
    end

    subgraph "Backend API"
        C --> D[FastAPI Router]
        D --> E[Auth Middleware]
        E --> F[Rate Limiter]
        F --> G[Endpoint Handler]
    end

    subgraph "Traitement"
        G --> H[PDFProcessor]
        G --> I[ConversationalAI]
        G --> J[PatternAnalyzer]
        G --> K[ARIAIntegration]
    end

    subgraph "Données"
        H --> L[(Database)]
        I --> L
        J --> L
        K --> M[ARIA API]
    end

    L --> G
    G --> F
    F --> E
    E --> D
    D --> C
    C --> B
    B --> A
```

---

## Voir aussi

- **[API.md](./API.md)** — Documentation API (version simplifiée)
- **[ARCHITECTURE.md](./ARCHITECTURE.md)** — Architecture système détaillée
- **[guides/GUIDE_MISE_A_JOUR_FLUTTER.md](./guides/GUIDE_MISE_A_JOUR_FLUTTER.md)** — Guide mise à jour Flutter
- **[CHECKLIST_FINALE_SECURITE.md](./CHECKLIST_FINALE_SECURITE.md)** — Checklist sécurité
- **[INDEX_DOCUMENTATION.md](./INDEX_DOCUMENTATION.md)** — Index complet de la documentation

---

*Dernière mise à jour : Janvier 2025*
