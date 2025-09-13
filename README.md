# Arkalia CIA

> **Personal Health Assistant** - Local-first mobile application for document management and health reminders

[![Flutter](https://img.shields.io/badge/Flutter-3.35.3-blue.svg?logo=flutter)](https://flutter.dev)
[![Python](https://img.shields.io/badge/Python-3.10.14-green.svg?logo=python)](https://python.org)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![CI/CD](https://img.shields.io/badge/CI%2FCD-Passing-brightgreen.svg)](https://github.com/arkalia-luna-system/arkalia-cia/actions)
[![Coverage](https://img.shields.io/badge/Coverage-66%25-green.svg)](https://github.com/arkalia-luna-system/arkalia-cia/actions)
[![Phase](https://img.shields.io/badge/Phase-2%20Enhanced%20Features-orange.svg)](https://github.com/arkalia-luna-system/arkalia-cia/tree/develop)

## Overview

> 🔄 **Project Status**: Phase 2 - Enhanced Features **IN PROGRESS** (develop branch)

**Arkalia CIA** is a production-ready mobile application built with Flutter, designed to manage medical documents, health reminders, and emergency contacts. 

**🎯 Key Benefits**: 100% offline operation, military-grade encryption, senior-friendly design, and zero cloud dependency for maximum privacy and reliability.

## Architecture

```mermaid
graph TB
    subgraph "Mobile App (Flutter)"
        A[Main App] --> B[Documents Module]
        A --> C[Health Module]
        A --> D[Reminders Module]
        A --> E[Emergency Module]
    end

    subgraph "Local Services"
        B --> F[Local Storage]
        C --> G[Health Portals]
        D --> H[Calendar Integration]
        E --> I[Contacts Integration]
    end

    subgraph "Backend (Optional)"
        J[FastAPI Server]
        K[PDF Processor]
        L[Security Dashboard]
    end

    F --> M[(SQLite DB)]
    H --> N[System Calendar]
    I --> O[System Contacts]
```

### Technical Stack

| Component | Technology | Version | Status | Quality |
|-----------|------------|---------|--------|---------|
| **Frontend** | Flutter | 3.35.3 | ✅ Production | 100% Tests Pass |
| **Language** | Dart | 3.0+ | ✅ Production | 0 Linting Issues |
| **Backend** | FastAPI | 0.116.1 | ✅ Production | 66% Coverage |
| **Runtime** | Python | 3.10.14 | ✅ Production | Black+Ruff Clean |
| **Database** | SQLite | Built-in | ✅ Production | Encrypted AES-256 |
| **Storage** | Local encryption | AES-256 | ✅ Production | Security Verified |

### Code Quality by Module

| Module | Frontend Status | Backend Status | Test Coverage | Notes |
|--------|----------------|----------------|---------------|-------|
| **Documents** | ✅ Complete | ✅ Complete | 85% | Production ready |
| **Health** | 🔄 In Progress | ✅ Complete | 70% | UI enhancements ongoing |
| **Reminders** | ✅ Complete | ✅ Complete | 80% | Calendar integration stable |
| **Emergency** | ✅ Complete | ✅ Complete | 75% | ICE features fully functional |
| **API Services** | ✅ Complete | ✅ Complete | 90% | Communication layer stable |
| **Storage** | ✅ Complete | ✅ Complete | 95% | Encryption verified |

## Features

### Application Modules

| Module/Screen | Purpose | Key Features | Phase | Status |
|---------------|---------|--------------|-------|--------|
| **📱 Home Dashboard** | Navigation hub | Quick access, app overview | 1-2 | ✅ Complete |
| **📄 Documents** | PDF management | Upload, encrypt, organize, search | 1-2 | ✅ Complete |
| **🏥 Health** | Medical portals | Quick access to health services | 2 | 🔄 In Progress |
| **🔔 Reminders** | Calendar integration | Native calendar, notifications | 2 | ✅ Complete |
| **🚨 Emergency** | ICE contacts | One-tap calling, medical info | 2 | ✅ Complete |
| **⚙️ Backend API** | Cloud sync (optional) | Document sync, family sharing | 3 | 📋 Planned |

### Core Modules

#### 📄 Documents
- PDF import and secure storage
- Category-based organization
- Full-text search capabilities
- Encrypted local storage

#### 🏥 Health
- Quick access to health portals
- Medical contact management
- Consultation history tracking
- Health information dashboard

#### 🔔 Reminders
- Native calendar integration
- Custom notification system
- Recurring reminder support
- Appointment management

#### 🚨 Emergency
- ICE (In Case of Emergency) contacts
- One-tap emergency calling
- Medical emergency card
- Critical health information

## Quick Start

### Prerequisites

```bash
# Required versions
Flutter SDK: 3.35.3
Dart SDK: >=3.0.0 <4.0.0
Python: 3.10+
```

### Installation

```bash
# Clone repository
git clone https://github.com/arkalia-luna-system/arkalia-cia.git
cd arkalia-cia

# Setup Flutter dependencies
cd arkalia_cia
flutter pub get

# Run application
flutter run
```

### Development Commands

```bash
# Testing
make test                 # Run all tests
make test-coverage       # Generate coverage report

# Code Quality
make lint                # Run linting
make format              # Format code
make security-scan       # Security analysis

# Building
make build-android       # Build APK
make build-ios          # Build iOS
make build-web          # Build web version

# Maintenance
make clean              # Clean build artifacts
make deps-update        # Update dependencies
```

## Platform Support

| Platform | Minimum Version | Status |
|----------|----------------|--------|
| **iOS** | 12.0+ | ✅ Production |
| **Android** | API 21 (5.0+) | ✅ Production |
| **Web** | Modern browsers | 🧪 Development |

## Security & Privacy

- **Local-first architecture**: All data stored on device
- **AES-256 encryption**: Sensitive data protection
- **Zero cloud dependency**: Complete offline operation
- **Minimal permissions**: Only essential system access
- **Open source**: Full transparency and auditability

## Development Status

### ✅ Phase 1: Local MVP (Completed)
- [x] Flutter application structure
- [x] Four main modules implemented
- [x] Navigation system
- [x] Local storage integration
- [x] Secure data services
- [x] Comprehensive test suite (61 tests)
- [x] CI/CD pipeline (100% passing)
- [x] Code quality standards (Black + Ruff)

### ✅ Phase 2: Native Integration (Completed)
- [x] Calendar service integration
- [x] Contacts service integration
- [x] Reminders module (calendar-native)
- [x] Emergency contacts (system-native)
- [x] Health portals interface
- [x] Senior-friendly UX design
- [x] Robust error handling
- [x] Timezone support for notifications

### 🔄 Phase 3: Connected Ecosystem (Planned)
- [ ] Optional cloud synchronization
- [ ] Secure family sharing
- [ ] Robot integration (Reachy Mini)
- [ ] Public API endpoints

## Development Roadmap

```mermaid
graph LR
    A[Phase 1<br/>Local MVP<br/>✅ Complete] --> B[Phase 2<br/>Enhanced Features<br/>🔄 In Progress]
    B --> C[Phase 3<br/>Connected Ecosystem<br/>📋 Q1 2025]
    
    A1[Flutter App<br/>Local Storage<br/>Basic UI] --> A
    A2[Security<br/>AES-256<br/>Offline Mode] --> A
    
    B1[Native Integration<br/>Calendar/Contacts] --> B
    B2[Senior UX<br/>Accessibility] --> B
    B3[Advanced Features<br/>Voice/Widgets] --> B
    
    C1[Cloud Sync<br/>Optional] --> C
    C2[Family Sharing<br/>Secure] --> C
    C3[Robot Integration<br/>Reachy Mini] --> C
    
    style A fill:#90EE90
    style B fill:#FFD700
    style C fill:#FFB6C1
```

## Frequently Asked Questions

### For Users

**Q: Do I need internet to use the app?**  
A: No! Arkalia CIA works 100% offline. All your data stays on your phone.

**Q: What happens if I change phones?**  
A: Phase 3 will include optional cloud backup. Currently, use your phone's backup system.

**Q: Who can see my medical documents?**  
A: Only you. Documents are encrypted on your device with AES-256. No cloud storage.

**Q: Is it suitable for seniors?**  
A: Yes! Large buttons, clear text, and simple navigation designed for all ages.

**Q: How secure is my data?**  
A: Military-grade encryption (AES-256), no data transmission, local-only storage.

### For Developers

**Q: Can I contribute to the project?**  
A: Absolutely! See our [Contributing Guide](docs/CONTRIBUTING.md) for details.

**Q: What's the tech stack?**  
A: Flutter 3.35.3 (frontend), Python 3.10.14 (backend), SQLite (database).

**Q: How do I run the project locally?**  
A: `git clone`, `flutter pub get`, `flutter run`. See Quick Start section above.

## Testing

```bash
# Run test suite
pytest tests/ -v --cov=arkalia_cia_python_backend

# Coverage: 66.06% (61 tests passing)
# Integration tests: 30 scenarios
# Unit tests: 31 test cases
```

## Contributing

See [CONTRIBUTING.md](docs/CONTRIBUTING.md) for development guidelines, code standards, and contribution process.

## Documentation

| Document | Description |
|----------|-------------|
| [Architecture](docs/ARCHITECTURE.md) | Technical architecture and design decisions |
| [API Reference](docs/API.md) | Service APIs and integration guides |
| [Deployment](docs/DEPLOYMENT.md) | Installation and deployment procedures |
| [Security](SECURITY.md) | Security policies and vulnerability reporting |

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- **Documentation**: [docs/](docs/)
- **Issues**: [GitHub Issues](https://github.com/arkalia-luna-system/arkalia-cia/issues)
- **Contact**: contact@arkalia-luna.com

---

**Built by Arkalia Luna System** | [Website](https://arkalia-luna.com) | [GitHub](https://github.com/arkalia-luna-system)
