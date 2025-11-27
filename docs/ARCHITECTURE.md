# Architecture

**Version** : 1.3.1
**Dernière mise à jour** : 20 novembre 2025
**Statut** : Production Ready

Documentation technique de l'architecture et de la conception système d'Arkalia CIA.

---

## Vue d'ensemble

Arkalia CIA implémente une **architecture local-first** privilégiant la simplicité, la fiabilité et la confidentialité des données. L'application fonctionne entièrement sur l'appareil sans dépendances externes pour les fonctionnalités principales.

### Principes architecturaux

1. **Local-First** : Toutes les données stockées localement
2. **Offline-First** : Fonctionnalités principales disponibles hors ligne
3. **Sécurité par conception** : Chiffrement AES-256, authentification JWT
4. **Intégration native** : Calendrier, contacts, biométrie
5. **Performance** : Cache intelligent, pagination, optimisations mémoire

---

## Architecture système

```mermaid
graph TB
    subgraph "Couche Présentation"
        A[Flutter UI] --> B[HomePage]
        A --> C[DocumentsScreen]
        A --> D[DoctorsListScreen]
        A --> E[ConversationalAIScreen]
        A --> F[PatternsDashboardScreen]
        A --> G[FamilySharingScreen]
    end

    subgraph "Couche Services"
        H[LocalStorageService] --> I[(SQLite Local)]
        J[ApiService] --> K[Backend API]
        L[DoctorService] --> I
        M[SearchService] --> I
        N[ConversationalAIService] --> K
        O[FamilySharingService] --> I
        P[CalendarService] --> Q[Calendrier Système]
        R[ContactsService] --> S[Contacts Système]
    end

    subgraph "Backend Python"
        K --> T[FastAPI]
        T --> U[api.py<br/>20+ endpoints]
        T --> V[PDFProcessor]
        T --> W[ConversationalAI]
        T --> X[PatternAnalyzer]
        T --> Y[ARIAIntegration]
        U --> Z[(PostgreSQL/SQLite)]
    end

    subgraph "Sécurité"
        AA[AES-256 Encryption]
        AB[Keychain/Keystore]
        AC[JWT Authentication]
        AD[Biometric Auth]
    end

    B --> H
    C --> H
    D --> L
    E --> N
    F --> N
    G --> O

    H --> AA
    AA --> AB
    K --> AC
    A --> AD
```

---

## Structure des composants

### Frontend Flutter

```
arkalia_cia/lib/
├── main.dart                    # Point d'entrée application
├── models/                      # Modèles de données
│   └── doctor.dart             # Modèle Doctor et Consultation
├── screens/                     # Écrans UI (25 écrans)
│   ├── home_page.dart          # Dashboard principal
│   ├── documents_screen.dart   # Gestion documents
│   ├── doctors_list_screen.dart # Liste médecins
│   ├── conversational_ai_screen.dart # Chat IA
│   ├── patterns_dashboard_screen.dart # Patterns IA
│   ├── family_sharing_screen.dart # Partage familial
│   ├── advanced_search_screen.dart # Recherche avancée
│   ├── onboarding/             # Onboarding intelligent
│   └── auth/                   # Authentification
│       ├── login_screen.dart
│       └── register_screen.dart
├── services/                    # Services métier (21 services)
│   ├── api_service.dart         # Communication backend
│   ├── local_storage_service.dart # Stockage local
│   ├── doctor_service.dart      # Gestion médecins
│   ├── search_service.dart      # Recherche
│   ├── conversational_ai_service.dart # IA conversationnelle
│   ├── family_sharing_service.dart # Partage familial
│   ├── auth_api_service.dart    # Authentification JWT
│   └── ...
└── utils/                       # Utilitaires
    ├── encryption_helper.dart   # Chiffrement AES-256
    ├── error_helper.dart        # Gestion erreurs
    └── validation_helper.dart   # Validation données
```

### Backend Python

```
arkalia_cia_python_backend/
├── api.py                       # FastAPI - 18 endpoints
├── auth.py                      # Authentification JWT
├── database.py                  # Gestion base de données
├── pdf_processor.py             # Traitement PDF
├── security_utils.py            # Utilitaires sécurité
├── ai/                          # Modules IA
│   ├── conversational_ai.py     # IA conversationnelle
│   ├── pattern_analyzer.py      # Analyse patterns
│   └── aria_integration.py      # Intégration ARIA
├── pdf_parser/                  # Parsing PDF
│   ├── metadata_extractor.py    # Extraction métadonnées
│   ├── ocr_integration.py       # OCR Tesseract
│   └── ocr_processor.py         # Traitement OCR
└── aria_integration/            # Intégration ARIA
    └── api.py                   # API ARIA
```

---

## Flux de données

### Upload document

```mermaid
sequenceDiagram
    participant U as Utilisateur
    participant UI as Flutter UI
    participant API as ApiService
    participant BE as Backend API
    participant PDF as PDFProcessor
    participant DB as Database

    U->>UI: Sélectionne PDF
    UI->>API: uploadDocument(file)
    API->>BE: POST /api/v1/documents/upload
    BE->>PDF: extractTextFromPdf()
    PDF->>PDF: extractMetadata()
    PDF->>DB: saveDocument()
    DB-->>BE: document_id
    BE-->>API: success + document_id
    API-->>UI: Document uploadé
    UI-->>U: Confirmation
```

### Recherche avancée

```mermaid
sequenceDiagram
    participant U as Utilisateur
    participant UI as AdvancedSearchScreen
    participant SS as SearchService
    participant SC as SemanticSearchService
    participant LS as LocalStorageService
    participant BE as Backend API

    U->>UI: Saisit requête
    UI->>SS: performSearch(query, filters)
    SS->>SC: semanticSearch(query)
    SC->>LS: getDocuments()
    LS-->>SC: documents[]
    SC-->>SS: résultats sémantiques
    SS->>BE: GET /api/v1/documents?query=...
    BE-->>SS: résultats API
    SS-->>UI: résultats combinés
    UI-->>U: Affiche résultats
```

### IA conversationnelle

```mermaid
sequenceDiagram
    participant U as Utilisateur
    participant UI as ConversationalAIScreen
    participant CAS as ConversationalAIService
    participant BE as Backend API
    participant CAI as ConversationalAI
    participant ARIA as ARIAIntegration
    participant DB as Database

    U->>UI: Pose question
    UI->>CAS: askQuestion(question)
    CAS->>BE: POST /api/v1/ai/chat
    BE->>CAI: analyzeQuestion(question, userData)
    CAI->>ARIA: fetchPainData()
    ARIA-->>CAI: données douleurs
    CAI->>CAI: analyse corrélations
    CAI->>DB: findRelatedDocuments()
    DB-->>CAI: documents[]
    CAI-->>BE: réponse intelligente
    BE-->>CAS: réponse
    CAS-->>UI: réponse affichée
    UI-->>U: Affiche réponse
```

---

## Architecture de sécurité

```mermaid
graph TB
    subgraph "Authentification"
        A[LoginScreen] --> B[AuthApiService]
        B --> C[JWT Token]
        C --> D[Backend Auth]
        D --> E[bcrypt Password]
    end

    subgraph "Chiffrement"
        F[Données Sensibles] --> G[AES-256]
        G --> H[Keychain/Keystore]
        H --> I[Stockage Local]
    end

    subgraph "Autorisation"
        J[Request] --> K[JWT Validation]
        K --> L[User ID Extraction]
        L --> M[Permission Check]
        M --> N[Resource Access]
    end

    subgraph "Protection API"
        O[Rate Limiting] --> P[IP + User ID]
        Q[XSS Protection] --> R[bleach sanitization]
        S[Path Traversal] --> T[Validation paths]
    end
```

---

## Base de données

### Schéma principal

```mermaid
erDiagram
    users ||--o{ documents : owns
    users ||--o{ reminders : owns
    users ||--o{ emergency_contacts : owns
    users ||--o{ doctors : owns
    users ||--o{ consultations : owns
    documents ||--o{ document_metadata : has
    documents ||--o{ shared_documents : shares
    doctors ||--o{ consultations : has
    ai_conversations }o--|| users : belongs_to

    users {
        int id PK
        string username
        string email
        string password_hash
        datetime created_at
    }
    documents {
        int id PK
        int user_id FK
        string original_name
        string file_path
        string category
        datetime created_at
    }
    document_metadata {
        int id PK
        int document_id FK
        string doctor_name
        string document_date
        string exam_type
        text extracted_text
    }
    doctors {
        int id PK
        int user_id FK
        string first_name
        string last_name
        string specialty
        string phone
        string email
    }
    consultations {
        int id PK
        int doctor_id FK
        datetime date
        string reason
        text notes
    }
    ai_conversations {
        int id PK
        int user_id FK
        text question
        text answer
        datetime created_at
    }
```

---

## Intégrations externes

### ARIA Integration

```mermaid
graph LR
    A[CIA] --> B[ARIAIntegration Service]
    B --> C[ARIA API]
    C --> D[Pain Data]
    C --> E[Patterns]
    C --> F[Health Metrics]
    D --> G[ConversationalAI]
    E --> G
    F --> G
    G --> H[Enhanced Responses]
```

### Portails santé

```mermaid
graph TB
    A[HealthPortalAuthScreen] --> B[HealthPortalAuthService]
    B --> C[OAuth Flow]
    C --> D[eHealth]
    C --> E[Andaman 7]
    C --> F[MaSanté]
    D --> G[Import Data]
    E --> G
    F --> G
    G --> H[Backend API]
    H --> I[Database]
```

---

## Performance et optimisation

### Cache intelligent

- **OfflineCacheService** : Cache des résultats de recherche (1h)
- **PatternsDashboardScreen** : Cache des patterns (6h)
- **SearchService** : Cache des résultats sémantiques

### Pagination

- Tous les endpoints GET supportent `skip` et `limit`
- Limite par défaut : 50, maximum : 100
- Réduction de la consommation mémoire de ~60%

### Optimisations mémoire

- Limitation données utilisateur envoyées à l'IA (10 docs, 5 médecins)
- Mémoire IA limitée à 50 éléments
- Extraction métadonnées PDF à la demande

---

## Déploiement

### Architecture de déploiement

```mermaid
graph TB
    subgraph "Client Mobile"
        A[Flutter App iOS]
        B[Flutter App Android]
    end

    subgraph "Backend"
        C[FastAPI Server]
        D[SQLite/PostgreSQL]
        E[File Storage]
    end

    subgraph "Sécurité"
        F[JWT Tokens]
        G[AES-256 Encryption]
        H[Keychain/Keystore]
    end

    A --> C
    B --> C
    C --> D
    C --> E
    A --> F
    B --> F
    A --> G
    B --> G
    A --> H
    B --> H
```

---

## Tests

### Stratégie de tests

- **Tests unitaires** : 308 passed
- **Couverture** : 85% global
- **Tests Flutter** : Analyse statique (0 erreur)
- **Tests d'intégration** : Structure prête

---

## Roadmap future

### Court terme
- Import automatique portails santé (APIs externes)
- Recherche NLP avancée (modèles ML)

### Moyen terme
- Intégration robotique BBIA
- Modèles ML supplémentaires (LSTM)

### Long terme
- Application web complémentaire
- Export professionnel avancé

---

## Voir aussi

- **[API_DOCUMENTATION.md](./API_DOCUMENTATION.md)** — Documentation API complète
- **[VUE_ENSEMBLE_PROJET.md](./VUE_ENSEMBLE_PROJET.md)** — Vue d'ensemble visuelle
- **[DEPLOYMENT.md](./DEPLOYMENT.md)** — Guide de déploiement
- **[CHECKLIST_FINALE_SECURITE.md](./CHECKLIST_FINALE_SECURITE.md)** — Checklist sécurité
- **[INDEX_DOCUMENTATION.md](./INDEX_DOCUMENTATION.md)** — Index complet de la documentation

---

*Dernière mise à jour : Janvier 2025*
