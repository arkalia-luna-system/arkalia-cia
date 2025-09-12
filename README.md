# 🌟 Arkalia CIA - Assistant Personnel

**Application mobile pour la gestion de documents et rappels de santé**

## 📱 Vue d'ensemble

Arkalia CIA est une application mobile Flutter conçue pour simplifier la gestion des documents médicaux, rappels de santé et contacts d'urgence. L'application fonctionne entièrement en local sur le téléphone, garantissant la confidentialité et la simplicité d'utilisation.

## 🎯 Objectif

Créer une application simple et fiable pour Patricia qui fonctionne sur son téléphone sans internet, en utilisant les outils natifs qu'elle connaît déjà.

## 🏗️ Architecture

### Approche Local-First
- **Stockage local** : Toutes les données sont stockées directement sur le téléphone
- **Intégration native** : Utilise le calendrier et les contacts du système
- **Sécurité** : Chiffrement local des données sensibles
- **Hors-ligne** : Fonctionne sans connexion internet

### Structure du projet
```
arkalia-cia/
├── arkalia_cia/                    # Application Flutter (Frontend)
│   ├── lib/
│   │   ├── main.dart              # Point d'entrée
│   │   ├── screens/               # Écrans de l'application
│   │   │   ├── home_page.dart
│   │   │   ├── documents_screen.dart
│   │   │   ├── health_screen.dart
│   │   │   ├── reminders_screen.dart
│   │   │   └── emergency_screen.dart
│   │   └── services/              # Services locaux
│   │       ├── api_service.dart   # Service API (Phase 3)
│   │       └── local_storage_service.dart  # Stockage local
│   ├── android/                   # Configuration Android
│   ├── ios/                       # Configuration iOS
│   └── pubspec.yaml              # Dépendances Flutter
├── arkalia_cia_python_backend/    # Backend Python (Phase 3)
│   ├── api.py                    # API FastAPI
│   ├── database.py               # Gestion base de données
│   ├── pdf_processor.py          # Traitement PDF
│   └── security_dashboard.py     # Tableau de bord sécurité
├── docs/                         # Documentation complète
├── tests/                        # Tests unitaires
├── requirements.txt              # Dépendances Python
├── pyproject.toml               # Configuration Python
└── Makefile                     # Commandes de développement
```

## 🚀 Fonctionnalités

### 4 Modules Principaux

#### 📄 Documents
- Import et stockage de documents PDF
- Organisation par catégories
- Recherche et filtrage
- Partage sécurisé

#### 🏥 Santé
- Portails de santé rapides
- Raccourcis médicaux
- Informations de contact médecins
- Historique des consultations

#### 🔔 Rappels
- Intégration calendrier natif
- Notifications personnalisées
- Rappels récurrents
- Gestion des rendez-vous

#### 🚨 Urgence
- Contacts ICE (In Case of Emergency)
- Appel d'urgence rapide
- Fiche médicale d'urgence
- Informations vitales

## 🛠️ Installation et Démarrage

### Prérequis
- Flutter SDK 3.0+
- Dart 3.0+
- Android Studio / Xcode (pour mobile)

### Installation rapide
```bash
# Cloner le projet
git clone https://github.com/arkalia-luna-system/arkalia-cia.git
cd arkalia-cia

# Installer les dépendances Flutter
cd arkalia_cia
flutter pub get

# Lancer l'application
flutter run
```

### Commandes de développement
```bash
# Tests
make test

# Linting et formatage
make lint
make format

# Construction
make build

# Nettoyage
make clean
```

## 📱 Plateformes supportées

- **iOS** : 12.0+
- **Android** : API 21+ (Android 5.0)
- **Web** : Chrome, Firefox, Safari (mode développement)

## 🔐 Sécurité et Confidentialité

- **Chiffrement local** : AES-256 pour les données sensibles
- **Aucune donnée cloud** : Tout reste sur le téléphone
- **Permissions minimales** : Seulement les permissions nécessaires
- **Code open source** : Transparence totale

## 📊 État du projet

### Phase 1 : MVP Local (✅ TERMINÉE)
- ✅ Structure de base Flutter
- ✅ 4 écrans principaux
- ✅ Navigation entre écrans
- ✅ Intégration stockage local
- ✅ Service de stockage sécurisé
- ✅ Écran Documents adapté (local)
- ✅ Tests unitaires complets (12 tests)
- ✅ Tests d'intégration (8 tests)
- ✅ Code propre (Black + Ruff)
- ✅ CI/CD fonctionnel

### Phase 2 : Intelligence locale (🔄 EN COURS)
- ✅ Service calendrier natif (CalendarService)
- ✅ Service contacts natif (ContactsService)
- ✅ Écran Rappels adapté (calendrier natif)
- ✅ Écran Contacts adapté (carnet natif)
- 🔄 Écran Urgence avec fiche d'urgence
- ⏳ Écran Santé pour portails
- ⏳ UX Senior-first (gros boutons, textes)
- ⏳ Tests avec Patricia

### Phase 3 : Écosystème connecté (Planifiée)
- ⏳ Synchronisation optionnelle
- ⏳ Partage familial sécurisé
- ⏳ Intégration robot Reachy Mini
- ⏳ API publique


## 📚 Documentation

- [Architecture](docs/ARCHITECTURE.md) - Détails techniques
- [API](docs/API.md) - Documentation des services
- [Déploiement](docs/DEPLOYMENT.md) - Guide d'installation
- [Contribution](docs/CONTRIBUTING.md) - Guide de développement

## 🤝 Contribution

Voir [CONTRIBUTING.md](docs/CONTRIBUTING.md) pour les détails sur la contribution au projet.

## 📄 Licence

Ce projet est sous licence MIT. Voir [LICENSE](LICENSE) pour plus de détails.

## 📞 Support

- **Documentation** : [docs/](docs/)
- **Issues** : [GitHub Issues](https://github.com/arkalia-luna-system/arkalia-cia/issues)
- **Email** : contact@arkalia-luna.com

---

*Développé avec ❤️ par Arkalia Luna System*
