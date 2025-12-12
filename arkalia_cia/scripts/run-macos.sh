#!/bin/bash
# Script pour lancer l'app Flutter sur macOS
# Met à jour la branche et lance l'app

set -e

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🍎 Lancement Arkalia CIA - macOS${NC}"
echo ""

# Obtenir le répertoire du script
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_DIR"

# Vérifier Flutter
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter n'est pas installé${NC}"
    exit 1
fi

# Vérifier que macOS est disponible
if ! flutter devices | grep -q "macos"; then
    echo -e "${RED}❌ macOS n'est pas disponible comme device Flutter${NC}"
    echo "   Vérifiez que vous êtes sur macOS et que Flutter est configuré"
    exit 1
fi

# Mettre à jour la branche develop AVANT tout
echo -e "${YELLOW}📥 Mise à jour de la branche develop...${NC}"
REPO_ROOT="$(cd "$PROJECT_DIR/.." && pwd)"
cd "$REPO_ROOT"
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "develop" ]; then
    echo "   Checkout vers develop..."
    git checkout develop 2>/dev/null || echo "   ⚠️  Impossible de checkout develop"
fi
echo "   Pull depuis origin/develop..."
git fetch origin develop
git pull origin develop || echo "   ⚠️  Impossible de mettre à jour"
cd "$PROJECT_DIR"

# Nettoyer
echo -e "${YELLOW}🧹 Nettoyage...${NC}"
flutter clean > /dev/null 2>&1 || true
flutter pub get

# Lancer sur macOS
echo -e "${GREEN}🚀 Lancement sur macOS...${NC}"
echo ""

flutter run -d macos

