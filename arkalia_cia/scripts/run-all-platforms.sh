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

# Mettre à jour la branche UNIQUE (develop pour TOUT)
echo -e "${YELLOW}📥 Mise à jour de la branche UNIQUE (develop pour tout)...${NC}"
REPO_ROOT="$(cd "$PROJECT_DIR/.." && pwd)"
cd "$REPO_ROOT"
CURRENT_BRANCH=$(git branch --show-current)
echo "   Branche actuelle: $CURRENT_BRANCH"
echo "   ✅ TOUT utilise: develop (unifié)"
# Mettre à jour develop
echo "   Fetch et pull develop..."
git fetch origin develop
git checkout develop 2>/dev/null || true
git pull origin develop || echo "   ⚠️  Impossible de mettre à jour develop"
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

# Lancer sur WEB (utilise la branche develop - UNIFIÉE)
if echo "$DEVICES" | grep -q "Chrome\|chrome\|web"; then
    echo -e "${GREEN}🌐 Lancement sur WEB (branche develop - unifiée)...${NC}"
    if echo "$DEVICES" | grep -q "Chrome\|chrome"; then
        WEB_DEVICE="chrome"
    else
        WEB_DEVICE="web-server"
    fi
    (
        cd "$REPO_ROOT"
        echo "   Vérification develop pour web (unifié)..."
        git checkout develop 2>/dev/null || true
        cd "$PROJECT_DIR"
        echo "   Nettoyage et pub get pour web..."
        flutter clean > /dev/null 2>&1 || true
        flutter pub get
        echo "   Lancement web..."
        flutter run -d "$WEB_DEVICE" --web-port=8080 > /tmp/arkalia_web.log 2>&1
    ) &
    WEB_PID=$!
    echo "   Web PID: $WEB_PID"
    echo "   URL: http://localhost:8080"
    sleep 3
else
    echo -e "${YELLOW}⚠️  Web non disponible, web ignoré${NC}"
    WEB_PID=""
fi

# Lancer sur ANDROID (utilise develop)
if echo "$DEVICES" | grep -q "android\|Android\|mobile"; then
    echo -e "${GREEN}📱 Lancement sur ANDROID (branche develop)...${NC}"
    (
        cd "$REPO_ROOT"
        echo "   Vérification develop pour Android..."
        git checkout develop 2>/dev/null || true
        cd "$PROJECT_DIR"
        bash scripts/run-android.sh > /tmp/arkalia_android.log 2>&1
    ) &
    ANDROID_PID=$!
    echo "   Android PID: $ANDROID_PID"
    sleep 3
else
    echo -e "${YELLOW}⚠️  Android non disponible, Android ignoré${NC}"
    ANDROID_PID=""
fi

# Lancer sur macOS (utilise develop)
if echo "$DEVICES" | grep -q "macos"; then
    echo -e "${GREEN}🍎 Lancement sur macOS (branche develop)...${NC}"
    (
        cd "$REPO_ROOT"
        echo "   Vérification develop pour macOS..."
        git checkout develop 2>/dev/null || true
        cd "$PROJECT_DIR"
        echo "   Nettoyage et pub get pour macOS..."
        flutter clean > /dev/null 2>&1 || true
        flutter pub get
        echo "   Lancement macOS..."
        flutter run -d macos > /tmp/arkalia_macos.log 2>&1
    ) &
    MACOS_PID=$!
    echo "   macOS PID: $MACOS_PID"
    sleep 3
else
    echo -e "${YELLOW}⚠️  macOS non disponible, macOS ignoré${NC}"
    MACOS_PID=""
fi

echo ""
echo -e "${GREEN}✅ Toutes les plateformes lancées en parallèle${NC}"
echo ""
echo "   Logs:"
[ -n "$WEB_PID" ] && echo "   - Web (PID $WEB_PID): /tmp/arkalia_web.log"
[ -n "$ANDROID_PID" ] && echo "   - Android (PID $ANDROID_PID): /tmp/arkalia_android.log"
[ -n "$MACOS_PID" ] && echo "   - macOS (PID $MACOS_PID): /tmp/arkalia_macos.log"
echo ""
echo "   Pour arrêter: Ctrl+C"
echo ""

# Attendre que tous les processus se terminent
if [ -n "$WEB_PID" ]; then wait $WEB_PID; fi
if [ -n "$ANDROID_PID" ]; then wait $ANDROID_PID; fi
if [ -n "$MACOS_PID" ]; then wait $MACOS_PID; fi

