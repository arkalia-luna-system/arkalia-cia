#!/bin/bash

# Script de configuration iOS pour Arkalia CIA
# Ce script configure Xcode et prépare le projet pour tester sur iPad Pro

set -e  # Arrêter en cas d'erreur

echo "🚀 Configuration iOS pour Arkalia CIA"
echo "======================================"
echo ""

# Couleurs pour les messages
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Étape 1 : Configurer Xcode
echo -e "${YELLOW}📱 Étape 1/6 : Configuration de Xcode...${NC}"
echo "   Cette étape nécessite votre mot de passe administrateur"
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
echo -e "${GREEN}✅ Xcode configuré${NC}"
echo ""

# Étape 2 : Accepter la licence Xcode
echo -e "${YELLOW}📝 Étape 2/6 : Acceptation de la licence Xcode...${NC}"
sudo xcodebuild -license accept
echo -e "${GREEN}✅ Licence acceptée${NC}"
echo ""

# Étape 3 : Première configuration Xcode
echo -e "${YELLOW}⚙️  Étape 3/6 : Première configuration Xcode...${NC}"
sudo xcodebuild -runFirstLaunch
echo -e "${GREEN}✅ Configuration initiale terminée${NC}"
echo ""

# Étape 4 : Installer CocoaPods
echo -e "${YELLOW}📦 Étape 4/6 : Installation de CocoaPods...${NC}"
if ! command -v pod &> /dev/null; then
    echo "   Installation de CocoaPods..."
    sudo gem install cocoapods
    echo -e "${GREEN}✅ CocoaPods installé${NC}"
else
    echo -e "${GREEN}✅ CocoaPods déjà installé ($(pod --version))${NC}"
fi
echo ""

# Étape 5 : Préparer le projet Flutter
echo -e "${YELLOW}🔨 Étape 5/6 : Préparation du projet Flutter...${NC}"
cd /Volumes/T7/arkalia-cia/arkalia_cia

echo "   Récupération des dépendances Flutter..."
flutter pub get

echo "   Génération du projet iOS..."
flutter build ios --no-codesign

echo "   Installation des dépendances iOS (CocoaPods)..."
cd ios
pod install
cd ..

echo -e "${GREEN}✅ Projet Flutter préparé${NC}"
echo ""

# Étape 6 : Vérification finale
echo -e "${YELLOW}🔍 Étape 6/6 : Vérification finale...${NC}"
echo ""
echo "Vérification avec flutter doctor :"
flutter doctor -v
echo ""

echo "Vérification des devices connectés :"
flutter devices
echo ""

echo -e "${GREEN}======================================"
echo "✅ Configuration terminée !"
echo "======================================${NC}"
echo ""
echo "📋 Prochaines étapes :"
echo "1. Branchez votre iPad Pro au Mac via USB"
echo "2. Déverrouillez l'iPad"
echo "3. Autorisez le Mac sur l'iPad ('Faire confiance à cet ordinateur')"
echo "4. Ouvrez le projet dans Xcode :"
echo "   cd /Volumes/T7/arkalia-cia/arkalia_cia/ios"
echo "   open Runner.xcworkspace"
echo "5. Dans Xcode :"
echo "   - Sélectionnez votre iPad Pro dans la liste des devices"
echo "   - Allez dans Signing & Capabilities"
echo "   - Cochez 'Automatically manage signing'"
echo "   - Sélectionnez votre Team (siwekathalia@gmail.com)"
echo "6. Cliquez sur ▶️ Play (ou Cmd+R)"
echo ""

