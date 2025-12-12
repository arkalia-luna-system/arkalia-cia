#!/bin/bash
# Script UNIQUE pour mettre à jour TOUTES les plateformes depuis develop
# Une seule branche (develop) pour tout : web, Android, macOS

set -e

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  🚀 Mise à jour UNIFIÉE - TOUTES les plateformes${NC}"
echo -e "${BLUE}  📦 Branche UNIQUE : develop${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

# Obtenir le répertoire du projet
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_ROOT="$(cd "$PROJECT_DIR/.." && pwd)"
cd "$REPO_ROOT"

# Vérifier Flutter
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter n'est pas installé${NC}"
    exit 1
fi

# Mettre à jour develop (BRANCHE UNIQUE)
echo -e "${YELLOW}📥 Mise à jour de la branche UNIQUE (develop)...${NC}"
git fetch origin develop
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "develop" ]; then
    echo "   Checkout develop..."
    git checkout develop 2>/dev/null || true
fi
git pull origin develop || echo "   ⚠️  Impossible de mettre à jour develop"
echo -e "${GREEN}✅ Branche develop à jour${NC}"
echo ""

# Aller dans le projet Flutter
cd "$PROJECT_DIR"

# Nettoyer et mettre à jour
echo -e "${YELLOW}🧹 Nettoyage et mise à jour des dépendances...${NC}"
flutter clean > /dev/null 2>&1 || true
flutter pub get
echo -e "${GREEN}✅ Dépendances à jour${NC}"
echo ""

# Afficher la version actuelle
echo -e "${BLUE}📋 Version actuelle :${NC}"
VERSION=$(grep "^version:" pubspec.yaml | sed 's/version: //' | tr -d ' ')
echo "   Version: $VERSION"
echo ""

# Vérifier les devices disponibles
echo -e "${YELLOW}📱 Vérification des devices disponibles...${NC}"
DEVICES=$(flutter devices)
echo "$DEVICES"
echo ""

echo -e "${GREEN}✅ Mise à jour terminée !${NC}"
echo ""
echo "📋 Pour lancer l'app :"
echo "   - Web : bash scripts/run-web.sh"
echo "   - Android : bash scripts/run-android.sh"
echo "   - macOS : bash scripts/run-macos.sh"
echo "   - Tout : bash scripts/run-all-platforms.sh"
echo ""
echo "🌐 Toutes les plateformes utilisent maintenant la branche UNIQUE : develop"
echo ""

