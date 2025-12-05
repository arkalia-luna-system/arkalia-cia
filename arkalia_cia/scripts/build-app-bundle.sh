#!/bin/bash
# Script pour build l'App Bundle et afficher le chemin complet

set -e

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Obtenir le répertoire du script
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# Remonter d'un niveau pour aller dans arkalia_cia/
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo -e "${GREEN}🔨 Build de l'App Bundle pour Play Store${NC}"
echo ""

# Aller dans le répertoire du projet
cd "$PROJECT_DIR"

# Nettoyer avant de build
echo -e "${YELLOW}🧹 Nettoyage...${NC}"
flutter clean

# Build l'App Bundle
echo -e "${GREEN}🚀 Build de l'App Bundle...${NC}"
if [ -f "android/build-android.sh" ]; then
    ./android/build-android.sh flutter build appbundle --release
else
    flutter build appbundle --release
fi

# Chemin de l'App Bundle
BUNDLE_PATH="$PROJECT_DIR/build/app/outputs/bundle/release/app-release.aab"

# Vérifier que le fichier existe
if [ -f "$BUNDLE_PATH" ]; then
    echo ""
    echo -e "${GREEN}✅ App Bundle créé avec succès !${NC}"
    echo ""
    echo "📁 Chemin complet du fichier :"
    echo "   $BUNDLE_PATH"
    echo ""
    echo "📋 Pour uploader dans Play Console :"
    echo "   1. Va sur https://play.google.com/console"
    echo "   2. Sélectionne 'Arkalia CIA'"
    echo "   3. Tests internes → Créer une nouvelle version"
    echo "   4. Upload ce fichier : $BUNDLE_PATH"
    echo ""
    # Ouvrir le Finder sur macOS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "🔍 Ouverture du Finder..."
        open -R "$BUNDLE_PATH"
    fi
else
    echo -e "${YELLOW}❌ Erreur : App Bundle non trouvé${NC}"
    echo "   Chemin attendu : $BUNDLE_PATH"
    exit 1
fi

