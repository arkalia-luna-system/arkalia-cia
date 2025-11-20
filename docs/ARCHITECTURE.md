# Architecture

**Version** : 1.2.0  
**Dernière mise à jour** : 19 novembre 2025  
**Statut** : Production Ready

Documentation technique de l'architecture et de la conception système d'Arkalia CIA.

---

## Table des matières

1. [Overview](#overview)
2. [Architectural Principles](#architectural-principles)
3. [System Architecture](#system-architecture)
4. [Component Structure](#component-structure)
5. [Data Flow Patterns](#data-flow-patterns)
6. [Service Specifications](#service-specifications)
7. [Security Architecture](#security-architecture)
8. [Performance Considerations](#performance-considerations)
9. [Deployment Architecture](#deployment-architecture)
10. [Testing Strategy](#testing-strategy)
11. [Future Roadmap](#future-roadmap)
12. [Monitoring and Observability](#monitoring-and-observability)

---

## Overview

Arkalia CIA implements a **local-first architecture** prioritizing simplicity, reliability, and data privacy. The application operates entirely on-device without external dependencies for core functionality.

## Architectural Principles

### 1. Local-First Design

| Principle | Implementation | Benefit |
|-----------|---------------|---------|
| **Local Storage** | All data stored locally on device | Zero network dependency |
| **Offline-First** | Core operations work offline | Maximum reliability |
| **Optional Sync** | Synchronization in Phase 3 | Progressive enhancement |
| **Data Privacy** | No cloud dependency required | Complete user control |

### 2. Native Integration

| Integration | Platform | Purpose |
|------------|----------|---------|
| **System Calendar** | iOS/Android | Reminder functionality |
| **System Contacts** | iOS/Android | Emergency contacts |
| **Biometric Auth** | iOS/Android | Secure access |
| **Notifications** | iOS/Android | Reminder alerts |

### 3. Security by Design

| Security Layer | Implementation | Status |
|----------------|---------------|--------|
| **Encryption** | AES-256 for sensitive data | ✅ Active |
| **Key Management** | Keychain/Keystore | ✅ Active |
| **Permissions** | Minimal requirements | ✅ Configured |
| **Data Storage** | No plaintext storage | ✅ Enforced |

## System Architecture

```mermaid
graph TB
    subgraph "Presentation Layer"
        A[Flutter UI] --> B[Home Screen]
        A --> C[Documents Screen]
        A --> D[Health Screen]
        A --> E[Reminders Screen]
        A --> F[Emergency Screen]
    end

    subgraph "Service Layer"
        G[LocalStorageService] --> H[Encrypted Storage]
        I[CalendarService] --> J[System Calendar]
        K[ContactsService] --> L[System Contacts]
        M[APIService] --> N[Backend API]
    end

    subgraph "Data Layer"
        H --> O[(SQLite)]
        J --> P[Calendar DB]
        L --> Q[Contacts DB]
        N --> R[(Backend DB)]
    end

    subgraph "Security Layer"
        S[AES-256 Encryption]
        T[Keychain/Keystore]
        U[Permission Manager]
    end

    B --> G
    C --> G
    D --> G
    E --> I
    F --> K

    G --> S
    S --> T
    A --> U
```

## Component Structure

### Frontend (Flutter)

```
lib/
├── main.dart                     # Application entry point
├── screens/                      # UI screens
│   ├── home_page.dart            # Main dashboard
│   ├── documents_screen.dart     # Document management
│   ├── health_screen.dart        # Health portals
│   ├── reminders_screen.dart     # Calendar integration
│   └── emergency_screen.dart     # Emergency contacts
└── services/                     # Business logic
    ├── api_service.dart          # Backend communication
    ├── calendar_service.dart     # Calendar integration
    ├── contacts_service.dart     # Contacts management
    └── local_storage_service.dart # Local data persistence
```

### Backend (Python)

```
arkalia_cia_python_backend/
├── api.py                        # FastAPI endpoints
├── auto_documenter.py            # Documentation generator
├── database.py                   # Database operations
├── pdf_processor.py              # PDF handling
├── security_dashboard.py         # Security monitoring
└── storage.py                    # File management
```

## Data Flow Patterns

### Phase 1: Local Operations

```mermaid
sequenceDiagram
    participant U as User
    participant UI as Flutter UI
    participant S as Service Layer
    participant D as Data Layer
    participant N as Native APIs

    U->>UI: User Action
    UI->>S: Service Call
    S->>D: Data Operation
    D-->>S: Data Response
    S->>N: Native Integration
    N-->>S: Native Response
    S-->>UI: Service Response
    UI-->>U: UI Update
```

### Phase 3: Hybrid Operations

```mermaid
sequenceDiagram
    participant U as User
    participant UI as Flutter UI
    participant LS as Local Service
    participant RS as Remote Service
    participant BE as Backend

    U->>UI: User Action
    UI->>LS: Local Check
    alt Data Available Locally
        LS-->>UI: Local Data
    else Sync Required
        UI->>RS: Remote Request
        RS->>BE: API Call
        BE-->>RS: API Response
        RS->>LS: Cache Update
        RS-->>UI: Remote Data
    end
    UI-->>U: Response
```

## Service Specifications

### LocalStorageService

**Purpose**: Secure local data persistence

**Key Features**:
- AES-256 encryption for sensitive data
- SQLite database operations
- Document metadata management
- User preference storage

**Methods**:
```dart
Future<void> saveDocument(Document doc);
Future<List<Document>> getDocuments();
Future<void> saveReminder(Reminder reminder);
Future<List<Reminder>> getReminders();
```

### CalendarService

**Purpose**: System calendar integration

**Key Features**:
- Native calendar API integration
- Event creation and management
- Notification scheduling
- Timezone handling

**Methods**:
```dart
Future<void> createEvent(CalendarEvent event);
Future<List<CalendarEvent>> getEvents();
Future<void> scheduleNotification(Reminder reminder);
```

### ContactsService

**Purpose**: System contacts integration

**Key Features**:
- Native contacts API access
- Emergency contact management
- Direct calling functionality
- Contact synchronization

**Methods**:
```dart
Future<List<Contact>> getContacts();
Future<void> addContact(Contact contact);
Future<bool> makeCall(String phoneNumber);
```

### APIService

**Purpose**: Backend communication (Phase 3)

**Key Features**:
- FastAPI endpoint communication
- Document upload/download
- Synchronization management
- Error handling and retry logic

## Security Architecture

### Encryption Strategy

```mermaid
graph LR
    A[Raw Data] --> B[AES-256 Encryption]
    B --> C[Encrypted Data]
    C --> D[SQLite Storage]

    E[Encryption Key] --> F[Keychain/Keystore]
    E --> B

    G[User Authentication] --> H[Biometric/PIN]
    H --> I[Key Access]
    I --> E
```

### Permission Model

| Permission | Purpose | Justification | Platform |
|------------|---------|---------------|----------|
| **Calendar** | Read/Write events | Reminder functionality | iOS/Android |
| **Contacts** | Read contact info | Emergency contacts | iOS/Android |
| **Storage** | App-specific files | Document storage | iOS/Android |
| **Notifications** | Alert delivery | Reminder notifications | iOS/Android |
| **Biometric** | Device authentication | Secure access | iOS/Android |

### Data Classification

| Data Type | Sensitivity | Encryption | Storage | Sync |
|-----------|-------------|------------|---------|------|
| **Documents** | High | AES-256 | Local only | Optional |
| **Health Info** | High | AES-256 | Local only | Optional |
| **Reminders** | Medium | Metadata only | Calendar sync | System |
| **Contacts** | Medium | Reference only | System contacts | System |
| **Preferences** | Low | None | Local storage | No |

## Performance Considerations

### Optimization Strategies

1. **Lazy Loading**: Load data on-demand
2. **Local Caching**: Cache frequently accessed data
3. **Document Compression**: Compress large files
4. **Background Processing**: Handle heavy operations asynchronously

### Performance Metrics

| Operation | Target Response Time | Max File Size |
|-----------|---------------------|---------------|
| Document Load | < 500ms | 10MB |
| Search Query | < 200ms | N/A |
| Calendar Sync | < 1s | N/A |
| Contact Access | < 100ms | N/A |

## Deployment Architecture

### Mobile Deployment

```mermaid
graph TB
    subgraph "Development"
        A[Flutter Source]
        B[Dart Analysis]
        C[Unit Tests]
    end

    subgraph "CI/CD Pipeline"
        D[GitHub Actions]
        E[Security Scan]
        F[Build Process]
    end

    subgraph "Distribution"
        G[App Store]
        H[Google Play]
        I[Enterprise Deploy]
    end

    A --> B
    B --> C
    C --> D
    D --> E
    E --> F
    F --> G
    F --> H
    F --> I
```

### Backend Deployment (Phase 3)

```mermaid
graph TB
    subgraph "Infrastructure"
        A[Load Balancer]
        B[API Gateway]
        C[Container Orchestration]
    end

    subgraph "Application"
        D[FastAPI Instances]
        E[Background Workers]
        F[File Storage]
    end

    subgraph "Data"
        G[(Primary DB)]
        H[(Replica DB)]
        I[Redis Cache]
    end

    A --> B
    B --> C
    C --> D
    C --> E
    D --> G
    E --> H
    D --> I
    F --> G
```

## Testing Strategy

### Test Pyramid

```mermaid
graph TB
    A[Unit Tests<br/>Fast, Isolated] --> B[Integration Tests<br/>Service Interactions]
    B --> C[Widget Tests<br/>UI Components]
    C --> D[End-to-End Tests<br/>Complete Workflows]

    style A fill:#90EE90
    style B fill:#FFD700
    style C fill:#FFA500
    style D fill:#FF6347
```

### Coverage Targets

| Test Type | Coverage Target | Current Status | Codecov Flag | Status |
|-----------|----------------|----------------|--------------|--------|
| **Unit Tests** | 80% | 85% | `python` | ✅ Exceeded |
| **Integration** | 70% | 85% | `python` | ✅ Exceeded |
| **Widget Tests** | 60% | 45% | `flutter` | 🟡 In Progress |
| **E2E Tests** | 50% | 30% | `flutter` | 🟡 In Progress |

#### Codecov Integration

Le projet utilise **Codecov** pour le suivi continu de la couverture :
- **Configuration**: `.codecov.yml` avec flags séparés pour Python et Flutter
- **CI/CD**: Upload automatique des rapports de couverture
- **Dashboard**: Suivi en temps réel sur [codecov.io](https://codecov.io)
- **Seuils**: 70% pour le projet global, 60% pour les patches

## Future Roadmap

### Phase 1: Local MVP ✅
- Core Flutter application
- Local storage implementation
- Native service integration
- Basic security measures

### Phase 2: Enhanced Features ✅
- Advanced calendar integration
- Improved contact management
- Enhanced UI/UX
- Comprehensive testing

### Phase 3: Connected Ecosystem 🔄
- Backend API development
- Cloud synchronization
- Multi-device support
- Advanced security features

### Phase 4: Intelligence Layer 📋
- AI-powered suggestions
- Predictive reminders
- Voice integration
- Advanced analytics

## Monitoring and Observability

### Metrics Collection

```mermaid
graph LR
    A[App Events] --> B[Local Analytics]
    B --> C[Aggregated Metrics]
    C --> D[Performance Dashboard]

    E[Error Events] --> F[Crash Reporting]
    F --> G[Error Dashboard]

    H[User Actions] --> I[Usage Analytics]
    I --> J[Behavior Insights]
```

### Key Performance Indicators

- **Reliability**: 99.9% uptime target
- **Performance**: <500ms average response time
- **Security**: Zero data breaches
- **User Experience**: <3 taps for core actions

---

## 📚 Related Documentation

- **[API.md](API.md)** - Complete API reference
- **[DEPLOYMENT.md](DEPLOYMENT.md)** - Deployment procedures
- **[SECURITY.md](../SECURITY.md)** - Security policies
- **[INDEX_DOCUMENTATION.md](INDEX_DOCUMENTATION.md)** - Full documentation index

---

**Last Updated**: November 19, 2025  
*This architecture documentation is maintained alongside code changes and reviewed quarterly for accuracy and relevance.*
