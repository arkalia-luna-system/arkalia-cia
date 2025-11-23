#!/bin/bash
# Script pour démarrer l'app Flutter en mode web dans Comet
# L'interface complète sera accessible dans le navigateur

set -e

# Couleurs pour les messages
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Chemin du projet
PROJECT_ROOT="/Volumes/T7/arkalia-cia"
FLUTTER_DIR="${PROJECT_ROOT}/arkalia_cia"

echo -e "${BLUE}🌐 Démarrage de l'app Flutter en mode Web${NC}"
echo ""

# Aller dans le répertoire Flutter
cd "$FLUTTER_DIR"

# Vérifier que Flutter est installé
if ! command -v flutter &> /dev/null; then
    echo -e "${YELLOW}❌ Flutter n'est pas installé ou n'est pas dans le PATH${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Flutter: $(flutter --version | head -1)${NC}"
echo ""

# Installer les dépendances
echo -e "${BLUE}📦 Installation des dépendances...${NC}"
flutter pub get > /dev/null 2>&1

# Vérifier si le build web existe
if [ ! -f "build/web/index.html" ]; then
    echo -e "${BLUE}🔨 Génération du build web (première fois, peut prendre quelques minutes)...${NC}"
    flutter build web --release
    echo -e "${GREEN}✅ Build web généré${NC}"
else
    echo -e "${GREEN}✅ Build web existant trouvé${NC}"
fi

# Démarrer le serveur web local
echo ""
echo -e "${GREEN}🌟 Démarrage du serveur web...${NC}"
echo -e "${BLUE}📱 Ouvrez Comet et allez à: http://localhost:8080${NC}"
echo -e "${YELLOW}💡 Appuyez sur Ctrl+C pour arrêter${NC}"
echo ""

# Démarrer Flutter en mode web
flutter run -d web-server --web-port=8080 --web-hostname=localhost

