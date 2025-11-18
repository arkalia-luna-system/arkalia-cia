#!/bin/bash

# Script pour finaliser la configuration iOS
# À exécuter APRÈS avoir installé CocoaPods

set -e

echo "🚀 Finalisation de la configuration iOS"
echo "========================================"
echo ""

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Utiliser la nouvelle version de Ruby
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export PATH="/opt/homebrew/lib/ruby/gems/3.4.0/bin:$PATH"

# Vérifier CocoaPods
echo -e "${YELLOW}📦 Vérification de CocoaPods...${NC}"
if ! command -v pod &> /dev/null; then
    echo "❌ CocoaPods n'est pas installé !"
    echo "   Exécutez d'abord : sudo gem install cocoapods"
    exit 1
fi
echo -e "${GREEN}✅ CocoaPods installé ($(pod --version))${NC}"
echo ""

# Aller dans le projet
cd /Volumes/T7/arkalia-cia/arkalia_cia

# Générer le projet iOS
echo -e "${YELLOW}🔨 Génération du projet iOS...${NC}"
flutter build ios --no-codesign
echo -e "${GREEN}✅ Projet iOS généré${NC}"
echo ""

# Installer les dépendances iOS
echo -e "${YELLOW}📦 Installation des dépendances iOS (CocoaPods)...${NC}"
cd ios
pod install
cd ..
echo -e "${GREEN}✅ Dépendances iOS installées${NC}"
echo ""

# Vérification finale
echo -e "${YELLOW}🔍 Vérification finale...${NC}"
echo ""
flutter doctor -v | grep -A 5 "Xcode"
echo ""
flutter devices
echo ""

echo -e "${GREEN}========================================"
echo "✅ Configuration terminée !"
echo "========================================"
echo ""
echo "📱 Votre iPad est détecté et prêt !"
echo ""
echo "🚀 Prochaines étapes :"
echo "1. Ouvrir le projet dans Xcode :"
echo "   cd /Volumes/T7/arkalia-cia/arkalia_cia/ios"
echo "   open Runner.xcworkspace"
echo ""
echo "2. Dans Xcode :"
echo "   - Sélectionner votre iPad dans la liste des devices"
echo "   - Aller dans Signing & Capabilities"
echo "   - Cochez 'Automatically manage signing'"
echo "   - Sélectionnez votre Team (siwekathalia@gmail.com)"
echo "   - Cliquez sur ▶️ Play (ou Cmd+R)"
echo ""

