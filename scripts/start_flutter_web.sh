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
echo -e "${BLUE}📱 Ouvrez Comet et allez à: http://localhost:8080 (ou 8081 si 8080 est occupé)${NC}"
echo -e "${YELLOW}💡 Appuyez sur Ctrl+C pour arrêter${NC}"
echo ""

# Vérifier s'il y a déjà un processus Flutter qui tourne
LOCK_FILE="/tmp/arkalia_flutter_web.lock"
if [ -f "$LOCK_FILE" ]; then
    PID=$(cat "$LOCK_FILE" 2>/dev/null || echo "")
    if [ -n "$PID" ] && ps -p "$PID" > /dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  Flutter web tourne déjà (PID: $PID)${NC}"
        echo -e "${YELLOW}   Utilisez './scripts/cleanup_all.sh' pour l'arrêter${NC}"
        exit 1
    else
        rm -f "$LOCK_FILE"
    fi
fi

if ps aux | grep -E "flutter.*run.*web|dart.*flutter.*web" | grep -v grep > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Un processus Flutter web est déjà en cours d'exécution${NC}"
    echo -e "${YELLOW}   Utilisez './scripts/cleanup_all.sh' pour l'arrêter${NC}"
    exit 1
fi

# Fonction de nettoyage
cleanup() {
    echo ""
    echo -e "${YELLOW}🛑 Arrêt de Flutter web...${NC}"
    rm -f "$LOCK_FILE"
    exit 0
}

# Gérer les signaux pour nettoyer proprement
trap cleanup SIGINT SIGTERM

# Vérifier si le port est libre, sinon utiliser un autre
PORT=8080
if lsof -ti:$PORT > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Port $PORT déjà utilisé, utilisation du port 8081${NC}"
    PORT=8081
    if lsof -ti:$PORT > /dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  Port $PORT aussi utilisé, utilisation du port 8082${NC}"
        PORT=8082
    fi
fi

# Créer le lock file
echo $$ > "$LOCK_FILE"

# Démarrer Flutter en mode web
echo -e "${GREEN}🌟 App accessible sur: http://localhost:$PORT${NC}"
flutter run -d web-server --web-port=$PORT --web-hostname=localhost

