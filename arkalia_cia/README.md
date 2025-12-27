# 📱❤️🔐 Arkalia CIA - Flutter Mobile App

> **Assistant Mobile Santé** - Application Flutter pour la gestion sécurisée de documents médicaux et rappels santé

## 🎯 Vue d'ensemble

Arkalia CIA est une application mobile Flutter conçue pour les seniors et leurs familles, offrant une gestion sécurisée des documents médicaux et des rappels de santé en mode 100% hors-ligne.

## ✨ Fonctionnalités principales

### 📄 **Gestion de Documents**
- Import et stockage sécurisé de PDF médicaux
- Organisation par catégories
- Recherche en texte intégral
- Chiffrement AES-256 local

### 🏥 **Module Santé**
- Accès rapide aux portails de santé
- Gestion des contacts médicaux
- Suivi des consultations
- Tableau de bord d'informations santé

### 🔔 **Rappels Intelligents**
- Intégration calendrier natif
- Notifications personnalisées
- Rappels récurrents
- Gestion des rendez-vous

### 🚨 **Contacts d'Urgence**
- Contacts ICE (In Case of Emergency)
- Appel d'urgence en un clic
- Carte d'urgence médicale
- Informations de santé critiques

## 🏗️ Architecture Technique

### **Stack Technologique**
- **Framework** : Flutter 3.35.3
- **Langage** : Dart 3.0+
- **Stockage** : SQLite local avec chiffrement
- **Sécurité** : AES-256-GCM, authentification PIN (web uniquement)
- **Intégration** : APIs natives iOS/Android

### **Structure du Projet**
```
lib/
├── main.dart                     # Point d'entrée de l'application
├── screens/                      # Écrans de l'interface utilisateur
│   ├── home_page.dart            # Tableau de bord principal
│   ├── documents_screen.dart     # Gestion des documents
│   ├── health_screen.dart        # Module santé
│   ├── reminders_screen.dart     # Rappels et calendrier
│   └── emergency_screen.dart     # Contacts d'urgence
├── services/                     # Services métier
│   ├── local_storage_service.dart # Stockage local sécurisé
│   ├── calendar_service.dart     # Intégration calendrier
│   ├── contacts_service.dart     # Gestion des contacts
│   └── api_service.dart          # Communication backend
├── widgets/                      # Composants UI réutilisables
│   ├── document_tile.dart        # Tuile de document
│   ├── emergency_contact_card.dart # Carte contact urgence
│   └── emergency_info_card.dart  # Carte info urgence
└── utils/                        # Utilitaires
    └── storage_helper.dart       # Aide au stockage
```

## 🚀 Démarrage Rapide

### **Prérequis**
```bash
Flutter SDK: 3.35.3+
Dart SDK: >=3.0.0 <4.0.0
```

### **Installation**
```bash
# Cloner le repository
git clone https://github.com/arkalia-luna-system/arkalia-cia.git
cd arkalia-cia/arkalia_cia

# Installer les dépendances
flutter pub get

# Lancer l'application
flutter run
```

### **Commandes de Développement**
```bash
# Analyse du code
flutter analyze

# Tests
flutter test

# Build pour Android
flutter build apk --release

# Build pour iOS
flutter build ios --release

# Build pour Web
flutter build web --release
```

## 🔒 Sécurité et Confidentialité

### **Chiffrement des Données**
- **Algorithme** : AES-256-GCM
- **Stockage** : Keychain (iOS) / Keystore (Android)
- **Clés** : Dérivation PBKDF2
- **Données** : Chiffrement local uniquement

### **Permissions Minimales**
- **Calendrier** : Lecture/écriture des événements
- **Contacts** : Lecture des informations de contact
- **Stockage** : Fichiers spécifiques à l'application
- **Notifications** : Livraison des alertes

## 📱 Support des Plateformes

| Plateforme | Version Minimum | Statut |
|------------|----------------|--------|
| **iOS** | 12.0+ | ✅ Production |
| **Android** | API 21 (5.0+) | ✅ Production |
| **Web** | Navigateurs modernes | 🧪 Développement |

## 🎨 Interface Utilisateur

### **Design Senior-Friendly**
- Boutons larges et accessibles
- Texte haute lisibilité
- Navigation intuitive
- Contraste élevé
- Feedback audio optionnel

### **Accessibilité**
- Support des lecteurs d'écran
- Navigation au clavier
- Tailles de police ajustables
- Couleurs adaptatives

## 🧪 Tests et Qualité

### **Couverture de Tests**
- **Tests unitaires** : Services et utilitaires
- **Tests d'intégration** : Flux complets
- **Tests widget** : Composants UI
- **Couverture** : 85% (218 tests Python)

### **Qualité du Code**
- **Analyse statique** : Dart analyzer
- **Formatage** : Dart format
- **Linting** : Flutter lints
- **Standards** : Conventions Flutter/Dart

## 🔄 Intégration Continue

### **Pipeline CI/CD**
- **Analyse** : Vérification automatique du code
- **Tests** : Exécution de la suite de tests
- **Sécurité** : Scan des vulnérabilités
- **Build** : Génération des artefacts
- **Déploiement** : Publication automatique

## 📚 Documentation

- **Guide d'architecture** : [ARCHITECTURE.md](../docs/ARCHITECTURE.md)
- **Référence API** : [API.md](../docs/API.md)
- **Guide de déploiement** : [DEPLOYMENT.md](../docs/DEPLOYMENT.md)
- **Guide de contribution** : [CONTRIBUTING.md](../docs/CONTRIBUTING.md)

## 🤝 Contribution

Nous accueillons les contributions ! Consultez notre [Guide de Contribution](../docs/CONTRIBUTING.md) pour :
- Standards de code
- Processus de contribution
- Guidelines de test
- Workflow de développement

## 📄 Licence

Ce projet est sous licence MIT - voir le fichier [LICENSE](../LICENSE) pour plus de détails.

## 🆘 Support

- **Documentation** : [docs/](../docs/)
- **Issues** : [GitHub Issues](https://github.com/arkalia-luna-system/arkalia-cia/issues)
- **Contact** : arkalia.luna.system@gmail.com

---

**Développé par Arkalia Luna System** | [Site Web](https://arkalia-luna.com) | [GitHub](https://github.com/arkalia-luna-system)
