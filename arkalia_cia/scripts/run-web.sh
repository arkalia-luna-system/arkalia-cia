#!/bin/bash
# Script pour lancer l'app Flutter sur web
# Met à jour la branche et lance l'app

set -e

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🌐 Lancement Arkalia CIA - Web${NC}"
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

# Mettre à jour la branche (develop pour TOUT)
echo -e "${YELLOW}📥 Mise à jour de la branche (develop pour tout)...${NC}"
cd "$(cd "$PROJECT_DIR/.." && pwd)"
echo "   Branche pour web: develop (unifiée)"
git fetch origin develop
git checkout develop 2>/dev/null || echo "   ⚠️  Branche develop non disponible"
git pull origin develop || echo "   ⚠️  Impossible de mettre à jour (peut-être pas un repo git)"
cd "$PROJECT_DIR"

# Nettoyer
echo -e "${YELLOW}🧹 Nettoyage...${NC}"
flutter clean > /dev/null 2>&1 || true
flutter pub get

# Lancer sur web
echo -e "${GREEN}🚀 Lancement sur web...${NC}"

# Vérifier si Chrome est disponible
if flutter devices | grep -q "Chrome\|chrome"; then
    DEVICE="chrome"
    echo "   Device: Chrome"
else
    DEVICE="web-server"
    echo "   Device: Web Server (Chrome non trouvé)"
fi

echo "   URL: http://localhost:8080"
echo ""

flutter run -d "$DEVICE" --web-port=8080

