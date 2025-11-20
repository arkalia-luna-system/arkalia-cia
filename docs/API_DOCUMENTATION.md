# 📚 Documentation API Arkalia CIA

> **Version** : 1.2.0  
> **Date** : 20 novembre 2025  
> **Base URL** : `http://localhost:8000` (développement) ou configurée via `BackendConfigService`

## 🔐 Authentification

Tous les endpoints (sauf `/` et `/health`) nécessitent une authentification via token JWT.

### Obtenir un token

```http
POST /api/auth/login
Content-Type: application/json

{
  "username": "utilisateur",
  "password": "motdepasse"
}
```

**Réponse** :
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer"
}
```

### Utiliser le token

Ajouter dans les headers :
```
Authorization: Bearer <access_token>
```

---

## 📄 Endpoints Documents

### Upload Document

```http
POST /api/documents/upload
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
  "message": "Document uploadé avec succès"
}
```

### Liste Documents

```http
GET /api/documents?skip=0&limit=50
Authorization: Bearer <token>
```

**Paramètres** :
- `skip` (int, optionnel) : Nombre de documents à ignorer (défaut: 0)
- `limit` (int, optionnel) : Nombre maximum de documents (défaut: 50, max: 100)

**Réponse** :
```json
[
  {
    "id": 1,
    "original_name": "examen_sanguin.pdf",
    "file_path": "uploads/...",
    "category": "examen",
    "created_at": "2024-01-01T10:00:00"
  }
]
```

### Récupérer Document

```http
GET /api/documents/{doc_id}
Authorization: Bearer <token>
```

### Supprimer Document

```http
DELETE /api/documents/{doc_id}
Authorization: Bearer <token>
```

---

## 🤖 Endpoints IA

### Chat Conversationnel

```http
POST /api/ai/chat
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
  "related_documents": ["doc1", "doc2"],
  "suggestions": ["Question 1", "Question 2"],
  "patterns_detected": {},
  "question_type": "exam"
}
```

### Préparer Rendez-vous

```http
POST /api/ai/prepare-appointment
Content-Type: application/json
Authorization: Bearer <token>

{
  "doctor_id": "doc123",
  "user_data": {
    "consultations": [...],
    "doctors": [...]
  }
}
```

**Réponse** :
```json
{
  "questions": [
    "Quels sont vos symptômes actuels ?",
    "Y a-t-il eu des changements depuis votre dernière visite ?"
  ]
}
```

### Historique Conversations

```http
GET /api/ai/conversations?limit=50
Authorization: Bearer <token>
```

**Paramètres** :
- `limit` (int, optionnel) : Nombre maximum de conversations (défaut: 50, max: 100)

---

## 📊 Endpoints Patterns

### Analyser Patterns

```http
POST /api/patterns/analyze
Content-Type: application/json
Authorization: Bearer <token>

{
  "data": [
    {"date": "2024-01-01", "value": 5, "type": "document"},
    {"date": "2024-01-15", "value": 6, "type": "document"}
  ]
}
```

**Réponse** :
```json
{
  "recurring_patterns": [
    {
      "type": "document",
      "frequency_days": 14,
      "confidence": 0.85
    }
  ],
  "trends": {
    "direction": "increasing",
    "strength": 0.5,
    "slope": 0.1
  },
  "seasonality": {
    "peak_month": 1,
    "peak_count": 5
  },
  "predictions": {
    "periods": 30,
    "predictions": [
      {
        "date": "2024-02-15T00:00:00",
        "predicted_value": 7.0,
        "lower_bound": 5.0,
        "upper_bound": 9.0
      }
    ],
    "trend": {
      "direction": "increasing",
      "strength": 0.5
    }
  }
}
```

### Prédire Événements Futurs

```http
POST /api/patterns/predict-events
Content-Type: application/json
Authorization: Bearer <token>

{
  "data": [
    {"date": "2024-01-01", "value": 1, "type": "document"},
    {"date": "2024-01-15", "value": 1, "type": "document"}
  ],
  "event_type": "document",
  "days_ahead": 30
}
```

**Réponse** :
```json
{
  "predicted_dates": [
    "2024-02-01T00:00:00",
    "2024-02-15T00:00:00"
  ],
  "confidence": 0.85,
  "pattern_based": true
}
```

---

## 🏥 Endpoints Portails Santé

### Créer Portail

```http
POST /api/health-portals
Content-Type: application/json
Authorization: Bearer <token>

{
  "name": "eHealth",
  "url": "https://www.ehealth.fgov.be",
  "description": "Portail santé belge",
  "category": "officiel"
}
```

### Liste Portails

```http
GET /api/health-portals?skip=0&limit=50
Authorization: Bearer <token>
```

### Importer Données Portail

```http
POST /api/health-portals/import
Content-Type: application/json
Authorization: Bearer <token>

{
  "portal": "eHealth",
  "data": {
    "documents": [
      {
        "name": "Document 1",
        "date": "2024-01-01",
        "type": "examen"
      }
    ],
    "consultations": [],
    "exams": []
  },
  "access_token": "token_oauth_optional"
}
```

**Réponse** :
```json
{
  "success": true,
  "imported_count": 1,
  "portal": "ehealth",
  "errors": [],
  "message": "1 élément(s) importé(s) depuis ehealth"
}
```

---

## 📅 Endpoints Rappels

### Créer Rappel

```http
POST /api/reminders
Content-Type: application/json
Authorization: Bearer <token>

{
  "title": "Rendez-vous médecin",
  "description": "Consultation cardiologue",
  "reminder_date": "2024-12-01T10:00:00",
  "category": "consultation"
}
```

### Liste Rappels

```http
GET /api/reminders?skip=0&limit=50
Authorization: Bearer <token>
```

---

## 🚨 Endpoints Contacts Urgence

### Créer Contact

```http
POST /api/emergency-contacts
Content-Type: application/json
Authorization: Bearer <token>

{
  "name": "Jean Dupont",
  "phone": "+32123456789",
  "relationship": "conjoint",
  "is_primary": true
}
```

### Liste Contacts

```http
GET /api/emergency-contacts?skip=0&limit=50
Authorization: Bearer <token>
```

---

## ⚠️ Codes d'Erreur

- `400` : Requête invalide
- `401` : Non authentifié
- `403` : Accès interdit
- `404` : Ressource non trouvée
- `422` : Erreur de validation
- `429` : Trop de requêtes (rate limit)
- `500` : Erreur serveur

---

## 🔒 Rate Limiting

- `/api/documents/upload` : 10/minute
- `/api/ai/chat` : 30/minute
- `/api/patterns/analyze` : 30/minute
- `/api/health-portals/import` : 10/minute
- Autres endpoints : 60/minute

---

## 📝 Notes

- Tous les timestamps sont au format ISO 8601
- Les dates sont en UTC
- Les fichiers PDF sont limités à 10MB par défaut
- La pagination est recommandée pour les grandes listes

---

*Documentation générée le 20 novembre 2025*

