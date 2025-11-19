#!/bin/bash
# Script pour corriger toutes les erreurs iOS et configurer l'environnement

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}🔧 Correction des erreurs iOS${NC}"
echo ""

# Aller dans le répertoire du projet
cd /Volumes/T7/arkalia-cia/arkalia_cia

# 1. Configurer le PATH pour CocoaPods
echo -e "${YELLOW}📦 Configuration du PATH pour CocoaPods...${NC}"
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export PATH="/opt/homebrew/lib/ruby/gems/3.4.0/bin:$PATH"
export PATH="$HOME/.local/share/gem/ruby/3.4.0/bin:$PATH"

# Vérifier CocoaPods
if command -v pod &> /dev/null; then
    POD_VERSION=$(pod --version)
    echo -e "${GREEN}✅ CocoaPods trouvé (version $POD_VERSION)${NC}"
else
    echo -e "${RED}❌ CocoaPods non trouvé dans PATH${NC}"
    echo -e "${YELLOW}   Tentative de localisation...${NC}"
    POD_PATH=$(find ~/.local ~/.gem /opt/homebrew -name "pod" -type f 2>/dev/null | head -1)
    if [ -n "$POD_PATH" ]; then
        POD_DIR=$(dirname "$POD_PATH")
        export PATH="$POD_DIR:$PATH"
        echo -e "${GREEN}✅ CocoaPods trouvé à $POD_PATH${NC}"
    else
        echo -e "${RED}❌ CocoaPods non trouvé. Installation nécessaire.${NC}"
        exit 1
    fi
fi

# 2. Nettoyer le cache DerivedData corrompu
echo -e "${YELLOW}🧹 Nettoyage du cache DerivedData...${NC}"
rm -rf ~/Library/Developer/Xcode/DerivedData/Runner-* 2>/dev/null || true
echo -e "${GREEN}✅ Cache DerivedData nettoyé${NC}"

# 3. Nettoyer Flutter
echo -e "${YELLOW}🔄 Nettoyage Flutter...${NC}"
flutter clean 2>&1 | grep -v "Failed to remove" || true
echo -e "${GREEN}✅ Flutter nettoyé${NC}"

# 4. Nettoyer CocoaPods
echo -e "${YELLOW}📦 Nettoyage CocoaPods...${NC}"
cd ios
rm -rf Pods Podfile.lock .symlinks
echo -e "${GREEN}✅ CocoaPods nettoyé${NC}"

# 5. Supprimer build/ios
echo -e "${YELLOW}🗑️  Suppression du répertoire build/ios...${NC}"
cd ..
rm -rf build/ios
echo -e "${GREEN}✅ build/ios supprimé${NC}"

# 6. Nettoyer les fichiers macOS cachés
echo -e "${YELLOW}🍎 Nettoyage des fichiers macOS cachés...${NC}"
find build -name "._*" -type f -delete 2>/dev/null || true
find build -name ".DS_Store" -type f -delete 2>/dev/null || true
echo -e "${GREEN}✅ Fichiers macOS cachés supprimés${NC}"

# 7. Régénérer le projet Flutter
echo -e "${YELLOW}🔨 Régénération du projet iOS...${NC}"
flutter build ios --no-codesign 2>&1 | grep -v "Failed to remove" || true
echo -e "${GREEN}✅ Projet iOS régénéré${NC}"

# 8. Installer les dépendances CocoaPods
echo -e "${YELLOW}📦 Installation des dépendances CocoaPods...${NC}"
cd ios
pod install
cd ..
echo -e "${GREEN}✅ Dépendances CocoaPods installées${NC}"

# 9. Supprimer les fichiers macOS cachés dans Pods (critique pour éviter les crashes)
echo -e "${YELLOW}🍎 Suppression des fichiers macOS cachés dans Pods...${NC}"
find ios/Pods -name "._*" -type f -delete 2>/dev/null || true
find ios/Pods -name ".DS_Store" -type f -delete 2>/dev/null || true
echo -e "${GREEN}✅ Fichiers macOS cachés supprimés dans Pods${NC}"

echo ""
echo -e "${GREEN}========================================"
echo "✅ Toutes les corrections terminées !"
echo "========================================"
echo ""
echo "📝 Pour utiliser CocoaPods dans le futur, ajoutez à ~/.zshrc :"
echo "   export PATH=\"/opt/homebrew/opt/ruby/bin:\$PATH\""
echo "   export PATH=\"/opt/homebrew/lib/ruby/gems/3.4.0/bin:\$PATH\""
echo "   export PATH=\"\$HOME/.local/share/gem/ruby/3.4.0/bin:\$PATH\""
echo ""
echo "🚀 Vous pouvez maintenant ouvrir Xcode :"
echo "   cd /Volumes/T7/arkalia-cia/arkalia_cia/ios"
echo "   open Runner.xcworkspace"

