# 🏗️ Architecture — Arkalia CIA

<div align="center">

**Version** : 1.3.1+6 | **Dernière mise à jour** : 12 décembre 2025

[![Statut](https://img.shields.io/badge/statut-production--ready-success)]()
[![Architecture](https://img.shields.io/badge/architecture-local--first-blue)]()

</div>

Documentation technique de l'architecture système.

---

## Vue d'ensemble

Architecture **local-first** : simplicité, fiabilité, confidentialité.  
Fonctionne entièrement sur l'appareil, sans dépendances externes.

### Principes

1. **Local-First** : Données stockées localement
2. **Offline-First** : Fonctionnalités hors ligne
3. **Sécurité** : AES-256, JWT, biométrie
4. **Intégration native** : Calendrier, contacts
5. **Performance** : Cache, pagination, optimisations

---

## Architecture système

```mermaid
graph TB
    subgraph UI["📱 Interface Flutter"]
        A[Flutter UI] --> B[HomePage]
        A --> C[DocumentsScreen]
        A --> D[DoctorsListScreen]
        A --> E[ConversationalAIScreen]
        A --> F[PatternsDashboardScreen]
        A --> G[FamilySharingScreen]
    end

    subgraph Services["⚙️ Services Locaux"]
        H[LocalStorageService] --> I[(SQLite)]
        J[ApiService] --> K[Backend API]
        L[DoctorService] --> I
        M[SearchService] --> I
        N[ConversationalAIService] --> K
        O[FamilySharingService] --> I
        P[CalendarService] --> Q[Calendrier]
        R[ContactsService] --> S[Contacts]
    end

    subgraph Backend["🐍 Backend Python"]
        K --> T[FastAPI]
        T --> U["api.py<br/>36 endpoints"]
        T --> V[PDFProcessor]
        T --> W[ConversationalAI]
        T --> X[PatternAnalyzer]
        T --> Y[ARIAIntegration]
        U --> Z[(SQLite/PostgreSQL)]
    end

    subgraph Security["🔒 Sécurité"]
        AA[AES-256]
        AB[Keychain]
        AC[JWT]
        AD[Biométrie]
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

    style UI fill:#e1f5ff
    style Services fill:#fff4e1
    style Backend fill:#ffe1f5
    style Security fill:#e1ffe1
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
├── api.py                       # FastAPI - 28 endpoints
├── aria_integration/api.py      # ARIA Integration - 8 endpoints
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
    autonumber
    participant U as 👤 Utilisateur
    participant UI as 📱 Flutter UI
    participant API as 🔌 ApiService
    participant BE as 🐍 Backend API
    participant PDF as 📄 PDFProcessor
    participant DB as 💾 Database

    U->>UI: Sélectionne PDF
    UI->>API: uploadDocument(file)
    API->>BE: POST /api/v1/documents/upload
    BE->>PDF: extractTextFromPdf()
    PDF->>PDF: extractMetadata()
    PDF->>DB: saveDocument()
    DB-->>BE: document_id
    BE-->>API: ✅ success + document_id
    API-->>UI: Document uploadé
    UI-->>U: ✅ Confirmation
```

### Recherche avancée

```mermaid
sequenceDiagram
    autonumber
    participant U as 👤 Utilisateur
    participant UI as 🔍 AdvancedSearchScreen
    participant SS as 🔎 SearchService
    participant SC as 🧠 SemanticSearchService
    participant LS as 💾 LocalStorageService
    participant BE as 🐍 Backend API

    U->>UI: Saisit requête
    UI->>SS: performSearch(query, filters)
    SS->>SC: semanticSearch(query)
    SC->>LS: getDocuments()
    LS-->>SC: documents[]
    SC-->>SS: résultats sémantiques
    SS->>BE: GET /api/v1/documents?query=...
    BE-->>SS: résultats API
    SS-->>UI: résultats combinés
    UI-->>U: ✅ Affiche résultats
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
    users ||--o{ documents : "possède"
    users ||--o{ reminders : "possède"
    users ||--o{ emergency_contacts : "possède"
    users ||--o{ doctors : "possède"
    users ||--o{ consultations : "possède"
    documents ||--o{ document_metadata : "contient"
    documents ||--o{ shared_documents : "partage"
    doctors ||--o{ consultations : "a"
    ai_conversations }o--|| users : "appartient à"

    users {
        int id PK "Identifiant"
        string username "Nom utilisateur"
        string email "Email"
        string password_hash "Hash mot de passe"
        datetime created_at "Date création"
    }
    documents {
        int id PK "Identifiant"
        int user_id FK "Propriétaire"
        string original_name "Nom original"
        string file_path "Chemin fichier"
        string category "Catégorie"
        datetime created_at "Date création"
    }
    document_metadata {
        int id PK "Identifiant"
        int document_id FK "Document"
        string doctor_name "Médecin"
        string document_date "Date document"
        string exam_type "Type examen"
        text extracted_text "Texte extrait"
    }
    doctors {
        int id PK "Identifiant"
        int user_id FK "Propriétaire"
        string first_name "Prénom"
        string last_name "Nom"
        string specialty "Spécialité"
        string phone "Téléphone"
        string email "Email"
    }
    consultations {
        int id PK "Identifiant"
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
    A[📱 CIA] --> B[🔗 ARIAIntegration]
    B --> C[🌐 ARIA API]
    C --> D[📊 Pain Data]
    C --> E[📈 Patterns]
    C --> F[💚 Health Metrics]
    D --> G[🤖 ConversationalAI]
    E --> G
    F --> G
    G --> H[✨ Enhanced Responses]

    style A fill:#e1f5ff
    style B fill:#fff4e1
    style C fill:#ffe1f5
    style G fill:#e1ffe1
    style H fill:#fff9e1
```

### Portails santé

```mermaid
graph TB
    A[📱 HealthPortalAuthScreen] --> B[🔐 HealthPortalAuthService]
    B --> C[🔄 OAuth Flow]
    C --> D[🏥 eHealth]
    C --> E[📱 Andaman 7]
    C --> F[💚 MaSanté]
    D --> G[📥 Import Data]
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
- **[audits/CHECKLIST_FINALE_SECURITE.md](./audits/CHECKLIST_FINALE_SECURITE.md)** — Checklist sécurité
- **[INDEX_DOCUMENTATION.md](./INDEX_DOCUMENTATION.md)** — Index complet de la documentation

---

*Dernière mise à jour : 12 décembre 2025*
