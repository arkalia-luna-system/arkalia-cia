# Vue d'ensemble du projet — Arkalia CIA

**Version** : 1.3.1  
**Dernière mise à jour** : Janvier 2025

Document de synthèse visuelle présentant l'écosystème complet Arkalia CIA.

---

## Table des matières

1. [Architecture globale](#architecture-globale)
2. [Flux utilisateur principal](#flux-utilisateur-principal)
3. [Composants techniques](#composants-techniques)
4. [Intégrations](#intégrations)
5. [Flux de données](#flux-de-données)
6. [Voir aussi](#voir-aussi)

---

## Architecture globale

```mermaid
graph TB
    subgraph "Écosystème Arkalia"
        A[Arkalia CIA<br/>Mobile Santé]
        B[Arkalia ARIA<br/>Recherche Douleur]
        C[BBIA-SIM<br/>Robot Cognitif]
    end

    subgraph "Arkalia CIA — Composants"
        D[Flutter App<br/>25 écrans]
        E[Python Backend<br/>18 endpoints]
        F[SQLite Local<br/>Stockage sécurisé]
    end

    subgraph "Intégrations"
        G[ARIA API<br/>Données douleurs]
        H[Portails Santé<br/>eHealth, Andaman 7]
        I[Calendrier Système]
        J[Contacts Système]
    end

    A --> D
    A --> E
    D --> F
    E --> F
    E --> G
    E --> H
    D --> I
    D --> J
    A -.-> B
    A -.-> C
```

---

## Flux utilisateur principal

```mermaid
sequenceDiagram
    participant U as Utilisateur
    participant A as App Flutter
    participant B as Backend API
    participant D as Database
    participant ARIA as ARIA

    U->>A: Ouvre app
    A->>A: Vérifie authentification
    alt Non authentifié
        A->>U: Affiche LoginScreen
        U->>A: Saisit credentials
        A->>B: POST /api/v1/auth/login
        B->>D: Vérifie utilisateur
        D-->>B: Utilisateur valide
        B-->>A: JWT token
    end
    
    A->>U: Affiche HomePage
    
    U->>A: Upload document PDF
    A->>B: POST /api/v1/documents/upload
    B->>B: Traite PDF (OCR si besoin)
    B->>B: Extrait métadonnées
    B->>D: Sauvegarde document
    B-->>A: Document uploadé
    
    U->>A: Pose question IA
    A->>B: POST /api/v1/ai/chat
    B->>ARIA: Récupère données douleurs
    ARIA-->>B: Données douleurs
    B->>B: Analyse corrélations
    B->>D: Recherche documents liés
    D-->>B: Documents
    B-->>A: Réponse intelligente
    A->>U: Affiche réponse
```

---

## Structure des données

```mermaid
erDiagram
    users ||--o{ documents : owns
    users ||--o{ reminders : owns
    users ||--o{ emergency_contacts : owns
    users ||--o{ doctors : owns
    users ||--o{ consultations : owns
    users ||--o{ ai_conversations : has
    documents ||--o| document_metadata : has
    documents ||--o{ shared_documents : shares
    doctors ||--o{ consultations : has
    shared_documents }o--|| family_members : shared_with

    users {
        int id PK
        string username UK
        string email
        string password_hash
        string role
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
        string doctor_specialty
        string document_date
        string exam_type
        string document_type
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
        string question_type
        datetime created_at
    }
```

---

## Fonctionnalités par module

```mermaid
mindmap
  root((Arkalia CIA))
    Gestion Documents
      Upload PDF
      OCR automatique
      Extraction métadonnées
      Recherche avancée
    Gestion Médecins
      CRUD complet
      Historique consultations
      Recherche et filtres
    IA Conversationnelle
      Chat intelligent
      Intégration ARIA
      Analyse corrélations
      Préparation RDV
    IA Patterns
      Détection patterns
      Prédictions Prophet
      Analyse tendances
    Partage Familial
      Chiffrement AES-256
      Dashboard statistiques
      Gestion membres
    Recherche
      Multi-critères
      Sémantique
      Synonymes médicaux
      Cache intelligent
```

---

## Sécurité et confidentialité

```mermaid
graph TB
    subgraph "Couche Authentification"
        A[LoginScreen] --> B[JWT Token]
        B --> C[Backend Validation]
        C --> D[User Permissions]
    end

    subgraph "Couche Chiffrement"
        E[Données Sensibles] --> F[AES-256]
        F --> G[Keychain/Keystore]
        G --> H[Stockage Local]
    end

    subgraph "Protection API"
        I[Rate Limiting] --> J[IP + User ID]
        K[XSS Protection] --> L[bleach sanitization]
        M[Path Traversal] --> N[Validation paths]
    end

    subgraph "Isolation Données"
        O[User ID] --> P[Document Filtering]
        P --> Q[Seulement ses données]
    end
```

---

## Performance et optimisation

```mermaid
graph LR
    subgraph "Cache Intelligent"
        A[SearchService] --> B[Cache 1h]
        C[PatternsDashboard] --> D[Cache 6h]
        E[OfflineCacheService] --> F[Gestion TTL]
    end

    subgraph "Pagination"
        G[GET Endpoints] --> H[skip + limit]
        H --> I[Max 100 par requête]
    end

    subgraph "Optimisation Mémoire"
        J[IA Conversationnelle] --> K[Max 50 éléments]
        L[User Data] --> M[10 docs, 5 médecins]
        N[PDF Processing] --> O[À la demande]
    end
```

---

## Intégrations externes

### ARIA Integration

```mermaid
graph TB
    A[ConversationalAI] --> B[ARIAIntegration]
    B --> C[fetchPainData]
    B --> D[fetchPatterns]
    B --> E[fetchHealthMetrics]
    
    C --> F[Pain Records]
    D --> G[Patterns Data]
    E --> H[Sleep, Activity, Stress]
    
    F --> I[Enhanced AI Responses]
    G --> I
    H --> I
    
    I --> J[User Question]
    J --> K[Intelligent Answer]
```

### Portails Santé

```mermaid
sequenceDiagram
    participant U as Utilisateur
    participant UI as HealthPortalAuthScreen
    participant S as HealthPortalAuthService
    participant P as Portail Santé
    participant B as Backend API

    U->>UI: Sélectionne portail
    UI->>S: authenticatePortal()
    S->>P: OAuth Flow
    P-->>S: Access Token
    S->>S: saveAccessToken()
    S->>P: fetchPortalData()
    P-->>S: Documents, Consultations, Exams
    S->>B: POST /api/v1/health-portals/import
    B->>B: Traite données
    B->>B: Sauvegarde en base
    B-->>S: Import réussi
    S-->>UI: Confirmation
    UI-->>U: Données importées
```

---

## Statistiques du projet

### Code

- **Backend Python** : 18 endpoints, 8 modules principaux
- **Frontend Flutter** : 25 écrans, 21 services, 6 utils
- **Tests** : 206 tests Python (100% passent), 85% couverture
- **Documentation** : 94 fichiers MD organisés

### Fonctionnalités

- **Gestion Documents** : Upload, OCR, métadonnées, recherche
- **Gestion Médecins** : CRUD complet, historique, statistiques
- **IA Conversationnelle** : Chat intelligent avec ARIA
- **IA Patterns** : Détection patterns, prédictions Prophet
- **Partage Familial** : Chiffrement AES-256, dashboard
- **Recherche** : Multi-critères, sémantique, cache

---

## Roadmap

### Court terme (Q1 2026)
- Tests manuels sur devices réels
- Build release Android
- Screenshots iOS

### Moyen terme (Q2-Q3 2026)
- Import automatique portails santé (APIs externes)
- Recherche NLP avancée (modèles ML)
- Graphiques interactifs patterns

### Long terme (2027+)
- Intégration robotique BBIA
- Application web complémentaire
- Modèles ML supplémentaires (LSTM)

---

## Voir aussi

- **[ARCHITECTURE.md](./ARCHITECTURE.md)** — Architecture technique détaillée
- **[API_DOCUMENTATION.md](./API_DOCUMENTATION.md)** — Documentation complète de l'API
- **[STATUT_FINAL_CONSOLIDE.md](./STATUT_FINAL_CONSOLIDE.md)** — Statut final consolidé du projet
- **[ANALYSE_COMPLETE_BESOINS_MERE.md](./ANALYSE_COMPLETE_BESOINS_MERE.md)** — Analyse complète des besoins
- **[INDEX_DOCUMENTATION.md](./INDEX_DOCUMENTATION.md)** — Index complet de la documentation

---

*Dernière mise à jour : Janvier 2025*

