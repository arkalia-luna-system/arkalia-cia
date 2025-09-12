# 🚀 Déploiement - Arkalia CIA

## Vue d'ensemble

Arkalia CIA est déployée comme une application mobile native. Le déploiement suit une approche progressive avec 3 phases distinctes.

## Phase 1 : MVP Local

### Prérequis

#### Développement
- Flutter SDK 3.0+
- Dart 3.0+
- Android Studio (Android)
- Xcode (iOS)
- Git

#### Production
- Compte développeur Apple (iOS)
- Compte développeur Google (Android)
- Certificats de signature

### Configuration

#### Variables d'environnement
```bash
# .env
FLUTTER_SDK_PATH=/path/to/flutter
ANDROID_SDK_PATH=/path/to/android/sdk
IOS_SDK_PATH=/path/to/ios/sdk
```

#### Configuration Flutter
```yaml
# pubspec.yaml
name: arkalia_cia
description: "Arkalia CIA - Assistant personnel"
version: 1.0.0+1

environment:
  sdk: ">=3.0.0 <4.0.0"
```

### Build et déploiement

#### Android
```bash
# Build APK
flutter build apk --release

# Build App Bundle (recommandé)
flutter build appbundle --release

# Installer sur appareil
flutter install
```

#### iOS
```bash
# Build iOS
flutter build ios --release

# Ouvrir dans Xcode
open ios/Runner.xcworkspace

# Archiver et uploader via Xcode
```

### Distribution

#### TestFlight (iOS)
1. Uploader l'archive via Xcode
2. Configurer les métadonnées
3. Soumettre pour review
4. Inviter les testeurs

#### Google Play (Android)
1. Créer l'application dans Google Play Console
2. Uploader l'AAB
3. Configurer les métadonnées
4. Soumettre pour review

#### APK direct
1. Générer l'APK
2. Signer avec clé de production
3. Distribuer via lien direct

## Phase 2 : Intelligence locale

### Nouvelles dépendances
```yaml
# pubspec.yaml
dependencies:
  # Phase 2
  speech_to_text: ^6.6.0
  flutter_tts: ^3.8.5
  home_widget: ^0.2.0
  shared_preferences: ^2.2.2
```

### Configuration vocale
```dart
// Configuration reconnaissance vocale
await SpeechToText.instance.initialize(
  onError: (error) => print('Erreur: $error'),
  onStatus: (status) => print('Statut: $status'),
);
```

### Widgets système
```dart
// Configuration widget Android
await HomeWidget.setAppGroupId('group.arkalia.cia');
await HomeWidget.saveWidgetData('next_appointment', nextAppointment);
```

## Phase 3 : Écosystème connecté

### Backend Python

#### Déploiement local
```bash
# Installation
pip install -r requirements.txt

# Configuration
cp .env.example .env
# Éditer .env avec les bonnes valeurs

# Lancement
uvicorn api:app --host 0.0.0.0 --port 8000
```

#### Déploiement cloud
```bash
# Docker
docker build -t arkalia-cia-backend .
docker run -p 8000:8000 arkalia-cia-backend

# Heroku
heroku create arkalia-cia-backend
git push heroku main

# AWS/GCP/Azure
# Suivre les guides spécifiques des providers
```

### Base de données
```sql
-- Configuration PostgreSQL
CREATE DATABASE arkalia_cia;
CREATE USER arkalia_user WITH PASSWORD 'secure_password';
GRANT ALL PRIVILEGES ON DATABASE arkalia_cia TO arkalia_user;
```

### Configuration synchronisation
```dart
// Configuration sync
class SyncService {
  static const String baseUrl = 'https://api.arkalia-cia.com';
  static const String apiKey = 'your_api_key';
  
  static Future<void> syncData() async {
    // Logique de synchronisation
  }
}
```

## Monitoring et maintenance

### Logs
```dart
// Configuration logging
import 'package:logger/logger.dart';

final logger = Logger(
  printer: PrettyPrinter(),
  level: Level.debug,
);
```

### Métriques
```dart
// Configuration analytics
import 'package:firebase_analytics/firebase_analytics.dart';

final analytics = FirebaseAnalytics.instance;

// Événements personnalisés
await analytics.logEvent(
  name: 'document_uploaded',
  parameters: {'file_type': 'pdf'},
);
```

### Crash reporting
```dart
// Configuration crash reporting
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

FirebaseCrashlytics.instance.recordError(
  error,
  stackTrace,
  reason: 'Erreur critique',
);
```

## Sécurité

### Chiffrement
```dart
// Configuration chiffrement
import 'package:encrypt/encrypt.dart';

final key = Key.fromBase64('your_32_character_base64_key');
final iv = IV.fromLength(16);
final encrypter = Encrypter(AES(key));
```

### Certificats
```bash
# Génération clé Android
keytool -genkey -v -keystore arkalia-cia-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias arkalia-cia

# Configuration iOS
# Utiliser Xcode pour gérer les certificats
```

### Permissions
```xml
<!-- Android permissions -->
<uses-permission android:name="android.permission.READ_CALENDAR" />
<uses-permission android:name="android.permission.WRITE_CALENDAR" />
<uses-permission android:name="android.permission.READ_CONTACTS" />
<uses-permission android:name="android.permission.CALL_PHONE" />
```

```xml
<!-- iOS permissions -->
<key>NSCalendarsUsageDescription</key>
<string>Accès au calendrier pour les rappels</string>
<key>NSContactsUsageDescription</key>
<string>Accès aux contacts pour les urgences</string>
```

## Tests

### Tests unitaires
```bash
# Lancer les tests
flutter test

# Tests avec couverture
flutter test --coverage
```

### Tests d'intégration
```bash
# Tests d'intégration
flutter test integration_test/
```

### Tests de performance
```bash
# Tests de performance
flutter test --coverage --reporter=json
```

## Rollback

### Version précédente
```bash
# Rollback Flutter
git checkout previous-version
flutter build apk --release

# Rollback backend
git checkout previous-version
docker build -t arkalia-cia-backend:previous .
```

### Données
```dart
// Sauvegarde données locales
await LocalStorageService.backupData();

// Restauration
await LocalStorageService.restoreData(backupData);
```

## Troubleshooting

### Problèmes courants

#### Build Android
```bash
# Nettoyer
flutter clean
flutter pub get

# Rebuild
flutter build apk --release
```

#### Build iOS
```bash
# Nettoyer
flutter clean
cd ios
rm -rf Pods
pod install
cd ..
flutter build ios --release
```

#### Synchronisation
```dart
// Vérifier connexion
bool isConnected = await Connectivity().checkConnectivity() != ConnectivityResult.none;

// Retry automatique
await SyncService.syncWithRetry(maxRetries: 3);
```

### Logs de debug
```bash
# Android
adb logcat | grep arkalia

# iOS
# Utiliser Xcode Console
```

## Support

### Documentation
- [Architecture](ARCHITECTURE.md)
- [API](API.md)
- [Contribution](CONTRIBUTING.md)

### Contact
- **Email** : contact@arkalia-luna.com
- **GitHub** : [Issues](https://github.com/arkalia-luna-system/arkalia-cia/issues)
- **Discord** : [Serveur communautaire](https://discord.gg/arkalia)
