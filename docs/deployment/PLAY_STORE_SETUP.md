# 🚀 Configuration Google Play Store - Arkalia CIA

**Date de création** : 24 novembre 2025  
**Statut** : ⏳ **Vérification en cours**  
**Version** : 1.3.0+1

---

## 📊 État Actuel du Compte Développeur

### ✅ Compte Créé et Configuré

| Élément | Valeur | Statut |
|---------|--------|--------|
| **Compte développeur** | Créé le 24 novembre 2025 | ✅ Actif |
| **Type de compte** | Personnel | ✅ Configuré |
| **Nom développeur** | Arkalia Luna System | ✅ Configuré |
| **Site web** | https://github.com/arkalia-luna-system | ✅ Configuré |
| **Email développeur** | arkalia.luna.system@gmail.com | ✅ Configuré |
| **Email contact** | siwekathalia@gmail.com | ✅ Configuré |
| **Téléphone** | +32472875694 | ✅ Configuré |
| **Langue préférée** | Français | ✅ Configuré |
| **Nombre d'apps prévues** | 6-10 | ✅ Configuré |
| **Monétisation** | Don't know (à décider plus tard) | ✅ Configuré |

### ⏳ Vérifications en Cours

| Vérification | Statut | Détails |
|--------------|--------|---------|
| **Identité** | ⏳ En attente | Documents uploadés, validation Google en cours (1-3 jours) |
| **Téléphone** | ⏸️ Bloquée | Attend validation identité |
| **Appareil Android** | ⏸️ Bloquée | Attend validation identité |

**Timeline attendue** :
- **24 novembre 2025** : Documents uploadés
- **25-27 novembre 2025** : Validation Google (en cours)
- **Après validation** : Déblocage vérifications téléphone et appareil

---

## 📱 Configuration Application

### Application ID

```
com.arkalia.cia
```

**Fichier** : `arkalia_cia/android/app/build.gradle.kts` (ligne 31)

### Version Actuelle

```
1.3.0+1
```

**Fichier** : `arkalia_cia/pubspec.yaml` (ligne 3)

**Format** : `MAJOR.MINOR.PATCH+BUILD_NUMBER`
- **1.3.0** = Version de l'application
- **+1** = Numéro de build

---

## 🔐 Signature Release (À FAIRE)

### ⚠️ État Actuel

**Problème** : La signature release n'est **PAS encore configurée**.

**Fichier** : `arkalia_cia/android/app/build.gradle.kts` (lignes 40-45)

```kotlin
buildTypes {
    release {
        // TODO: Add your own signing config for the release build.
        // Signing with the debug keys for now, so `flutter run --release` works.
        signingConfig = signingConfigs.getByName("debug")
    }
}
```

### ✅ À Faire : Créer la Signature Release

**Étape 1 : Générer le Keystore**

```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia/android/app

keytool -genkey -v \
  -keystore arkalia-cia-release.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias arkalia-cia
```

**Questions à répondre** :
- Nom et prénom : Athalia Siwek
- Nom de l'unité organisationnelle : Arkalia Luna System
- Nom de l'organisation : Arkalia Luna System
- Nom de la ville : Bruxelles
- Nom de l'état ou de la province : Bruxelles
- Code pays à deux lettres : BE

**⚠️ IMPORTANT** : Sauvegarder les mots de passe dans un gestionnaire de mots de passe sécurisé !

**Étape 2 : Créer le fichier `key.properties`**

```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia/android

# Créer le fichier key.properties
cat > key.properties << EOF
storePassword=TON_MOT_DE_PASSE_STORE
keyPassword=TON_MOT_DE_PASSE_KEY
keyAlias=arkalia-cia
storeFile=app/arkalia-cia-release.jks
EOF
```

**⚠️ IMPORTANT** : Ajouter `key.properties` et `*.jks` au `.gitignore` !

**Étape 3 : Modifier `build.gradle.kts`**

```kotlin
// Au début du fichier, après les imports
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = java.util.Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(java.io.FileInputStream(keystorePropertiesFile))
}

android {
    // ... configuration existante ...
    
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
    
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```

---

## 📦 Build App Bundle (Après Validation)

### Commande de Build

```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia

# Nettoyer les builds précédents
flutter clean
flutter pub get

# Build App Bundle (requis pour Play Store)
flutter build appbundle --release
```

**Fichier généré** : `build/app/outputs/bundle/release/app-release.aab`

**Taille attendue** : 15-30 MB

### Vérification du Build

```bash
# Vérifier que le fichier existe
ls -lh build/app/outputs/bundle/release/app-release.aab

# Vérifier la signature
jarsigner -verify -verbose -certs build/app/outputs/bundle/release/app-release.aab
```

---

## 🎯 Plan d'Action Post-Validation

### Phase 1 : Immédiatement après Validation (Jour 1)

#### Étape 1 : Finaliser les Vérifications

- [ ] Vérifier le numéro de téléphone (débloqué après validation identité)
- [ ] Vérifier l'appareil Android (débloqué après validation identité)
- [ ] Confirmer que le compte est 100% validé

#### Étape 2 : Créer la Signature Release

- [ ] Générer le keystore (voir section ci-dessus)
- [ ] Créer le fichier `key.properties`
- [ ] Modifier `build.gradle.kts` pour utiliser la signature release
- [ ] Tester le build avec la nouvelle signature

#### Étape 3 : Préparer les Métadonnées

- [ ] Titre de l'app : "Arkalia CIA"
- [ ] Description courte (80 caractères max) : "Assistant santé mobile sécurisé pour gérer documents médicaux et rappels"
- [ ] Description complète (voir `DEPLOYMENT.md`)
- [ ] Icône 512x512 pixels
- [ ] Feature graphic 1024x500 pixels
- [ ] Screenshots (minimum 2, voir `SCREENSHOTS_GUIDE.md`)

### Phase 2 : Création de l'App sur Play Console (Jour 1-2)

#### Étape 1 : Créer la Fiche App

1. Aller sur [Google Play Console](https://play.google.com/console)
2. Cliquer sur "Créer une application"
3. Remplir les informations :
   - **Nom de l'app** : Arkalia CIA
   - **Langue par défaut** : Français (Belgique)
   - **Type d'app** : Application
   - **Gratuite ou payante** : Gratuite
   - **Déclaration de contenu** : Compléter le questionnaire

#### Étape 2 : Configurer le Store Listing

- [ ] Titre : Arkalia CIA
- [ ] Description courte : "Assistant santé mobile sécurisé pour gérer documents médicaux et rappels"
- [ ] Description complète : (voir `DEPLOYMENT.md` lignes 185-228)
- [ ] Icône : 512x512 pixels
- [ ] Feature graphic : 1024x500 pixels
- [ ] Screenshots téléphone : Minimum 2 (1080x1920 pixels)
- [ ] Catégorie : Santé et bien-être
- [ ] Contact email : arkalia.luna.system@gmail.com
- [ ] Site web : https://github.com/arkalia-luna-system/arkalia-cia
- [ ] Politique de confidentialité : (URL à héberger)

#### Étape 3 : Configurer la Distribution

- [ ] Mode de distribution : **Internal Testing** (pour commencer)
- [ ] Ajouter les testeurs :
  - Email de ta mère (testeuse principale)
  - Autres testeurs si nécessaire (max 100 en Internal Testing)

### Phase 3 : Upload et Publication (Jour 2-3)

#### Étape 1 : Build et Upload

```bash
# Build App Bundle
cd /Volumes/T7/arkalia-cia/arkalia_cia
flutter build appbundle --release

# Upload sur Play Console
# Via l'interface web : Production → Internal Testing → Créer une version
# Uploader : build/app/outputs/bundle/release/app-release.aab
```

#### Étape 2 : Notes de Version

**Première version (1.3.0)** :
```
Version 1.3.0 - Première version publique

✨ Fonctionnalités principales :
- Gestion sécurisée de documents médicaux (chiffrement AES-256)
- Rappels de médicaments et rendez-vous
- Contacts d'urgence (ICE)
- Interface adaptée aux seniors
- Fonctionnement 100% hors-ligne
- Intégration ARIA (suivi douleur et patterns)
- Génération de rapports médicaux pré-consultation

🔒 Sécurité :
- Chiffrement local AES-256
- Aucune collecte de données
- Stockage 100% local

👵 Accessibilité :
- Interface senior-friendly
- Textes lisibles (≥14px)
- Boutons larges et accessibles
```

#### Étape 3 : Soumettre pour Review

- [ ] Vérifier que toutes les sections sont complètes
- [ ] Soumettre pour review (Internal Testing)
- [ ] Attendre l'approbation (généralement 1-2 heures pour Internal Testing)

### Phase 4 : Distribution et Tests (Jour 3-7)

#### Étape 1 : Inviter les Testeurs

- [ ] Ajouter l'email de ta mère dans Internal Testing
- [ ] Elle recevra un email d'invitation
- [ ] Elle pourra installer l'app depuis le Play Store

#### Étape 2 : Collecter les Retours

- [ ] Créer un formulaire de feedback (Google Forms ou autre)
- [ ] Demander à ta mère de tester toutes les fonctionnalités
- [ ] Documenter les bugs et améliorations

#### Étape 3 : Corriger et Mettre à Jour

- [ ] Corriger les bugs identifiés
- [ ] Build nouvelle version (1.3.1)
- [ ] Upload nouvelle version
- [ ] Répéter jusqu'à satisfaction

### Phase 5 : Passage en Production (Après Tests)

#### Étape 1 : Passer en Closed Testing (Optionnel)

- [ ] Créer un groupe Closed Testing
- [ ] Ajouter plus de testeurs (illimité)
- [ ] Partager le lien d'inscription

#### Étape 2 : Passer en Production

- [ ] Quand tout est stable et testé
- [ ] Créer une version Production
- [ ] Upload App Bundle
- [ ] Soumettre pour review publique
- [ ] Attendre approbation (1-7 jours généralement)

---

## 📋 Checklist Complète

### Avant Validation Google

- [x] Compte Play Console créé
- [x] Informations compte complétées
- [x] Documents identité uploadés
- [ ] ⏳ Attendre validation Google (1-3 jours)

### Après Validation Google

- [ ] Vérifier numéro de téléphone
- [ ] Vérifier appareil Android
- [ ] Créer signature release (keystore)
- [ ] Configurer `build.gradle.kts` avec signature
- [ ] Tester build App Bundle avec signature release

### Création App sur Play Console

- [ ] Créer la fiche app
- [ ] Remplir Store Listing (titre, description, icône, screenshots)
- [ ] Configurer Internal Testing
- [ ] Ajouter testeurs (ta mère)

### Build et Upload

- [ ] Build App Bundle (`flutter build appbundle --release`)
- [ ] Vérifier signature du bundle
- [ ] Upload sur Play Console
- [ ] Rédiger notes de version
- [ ] Soumettre pour review

### Tests et Publication

- [ ] Tester l'installation depuis Play Store
- [ ] Collecter retours testeurs
- [ ] Corriger bugs identifiés
- [ ] Publier nouvelle version si nécessaire
- [ ] Passer en Production quand stable

---

## 🔄 Automation GitHub Actions (Optionnel)

### Workflow Automatique

Créer `.github/workflows/play-store-deploy.yml` :

```yaml
name: Deploy to Google Play Store

on:
  push:
    branches: [ main ]
    tags:
      - 'v*'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
      
      - name: Build App Bundle
        run: |
          cd arkalia_cia
          flutter build appbundle --release
      
      - name: Upload to Play Store
        uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.GOOGLE_PLAY_SERVICE_ACCOUNT_JSON }}
          packageName: com.arkalia.cia
          releaseFiles: arkalia_cia/build/app/outputs/bundle/release/app-release.aab
          track: internal
          status: completed
```

**Configuration requise** :
- Créer un compte de service Google Play
- Ajouter le JSON dans GitHub Secrets (`GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`)

---

## 📚 Documentation Associée

- **[DEPLOYMENT.md](./DEPLOYMENT.md)** - Guide de déploiement général
- **[BUILD_RELEASE_ANDROID.md](./BUILD_RELEASE_ANDROID.md)** - Guide build Android
- **[SCREENSHOTS_GUIDE.md](../SCREENSHOTS_GUIDE.md)** - Guide des screenshots
- **[RELEASE_CHECKLIST.md](../RELEASE_CHECKLIST.md)** - Checklist release complète

---

## 🆘 Support

**Email** : arkalia.luna.system@gmail.com  
**GitHub** : https://github.com/arkalia-luna-system/arkalia-cia

---

**Dernière mise à jour** : 24 novembre 2025  
**Statut** : ⏳ Vérification Google en cours

