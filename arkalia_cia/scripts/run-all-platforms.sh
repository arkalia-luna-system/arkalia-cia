#!/bin/bash
# Script pour lancer l'app sur TOUTES les plateformes en parallèle
# Web, Android, macOS

set -e

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🚀 Lancement Arkalia CIA - TOUTES LES PLATEFORMES${NC}"
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

# Mettre à jour la branche
echo -e "${YELLOW}📥 Mise à jour de la branche...${NC}"
cd "$(cd "$PROJECT_DIR/.." && pwd)"
CURRENT_BRANCH=$(git branch --show-current)
echo "   Branche actuelle: $CURRENT_BRANCH"
git pull origin "$CURRENT_BRANCH" || echo "   ⚠️  Impossible de mettre à jour (peut-être pas un repo git)"
cd "$PROJECT_DIR"

# Nettoyer
echo -e "${YELLOW}🧹 Nettoyage...${NC}"
flutter clean > /dev/null 2>&1 || true
flutter pub get

# Vérifier les devices disponibles
echo -e "${YELLOW}📱 Vérification des devices disponibles...${NC}"
DEVICES=$(flutter devices)
echo "$DEVICES"
echo ""

# Fonction pour nettoyer les processus à la sortie
cleanup() {
    echo ""
    echo -e "${YELLOW}🛑 Arrêt de tous les processus...${NC}"
    pkill -f "flutter.*run.*web" 2>/dev/null || true
    pkill -f "flutter.*run.*android" 2>/dev/null || true
    pkill -f "flutter.*run.*macos" 2>/dev/null || true
    exit 0
}

trap cleanup SIGINT SIGTERM

# Lancer sur WEB
if echo "$DEVICES" | grep -q "Chrome\|chrome"; then
    echo -e "${GREEN}🌐 Lancement sur WEB (Chrome)...${NC}"
    (
        cd "$PROJECT_DIR"
        flutter run -d chrome --web-port=8080 > /tmp/arkalia_web.log 2>&1 &
        WEB_PID=$!
        echo "   Web PID: $WEB_PID"
        echo "   URL: http://localhost:8080"
        wait $WEB_PID
    ) &
    WEB_PID=$!
else
    echo -e "${YELLOW}⚠️  Chrome non disponible, web ignoré${NC}"
    WEB_PID=""
fi

# Lancer sur ANDROID
if echo "$DEVICES" | grep -q "android\|Android\|mobile"; then
    echo -e "${GREEN}📱 Lancement sur ANDROID...${NC}"
    (
        cd "$PROJECT_DIR"
        bash scripts/run-android.sh > /tmp/arkalia_android.log 2>&1 &
        ANDROID_PID=$!
        wait $ANDROID_PID
    ) &
    ANDROID_PID=$!
else
    echo -e "${YELLOW}⚠️  Android non disponible, Android ignoré${NC}"
    ANDROID_PID=""
fi

# Lancer sur macOS
if echo "$DEVICES" | grep -q "macos"; then
    echo -e "${GREEN}🍎 Lancement sur macOS...${NC}"
    (
        cd "$PROJECT_DIR"
        flutter run -d macos > /tmp/arkalia_macos.log 2>&1 &
        MACOS_PID=$!
        wait $MACOS_PID
    ) &
    MACOS_PID=$!
else
    echo -e "${YELLOW}⚠️  macOS non disponible, macOS ignoré${NC}"
    MACOS_PID=""
fi

echo ""
echo -e "${GREEN}✅ Toutes les plateformes lancées en parallèle${NC}"
echo ""
echo "   Logs:"
echo "   - Web: /tmp/arkalia_web.log"
echo "   - Android: /tmp/arkalia_android.log"
echo "   - macOS: /tmp/arkalia_macos.log"
echo ""
echo "   Pour arrêter: Ctrl+C"
echo ""

# Attendre que tous les processus se terminent
wait

