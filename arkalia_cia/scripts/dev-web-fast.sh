#!/bin/bash
# Script de développement rapide avec preview en temps réel
# Lance Flutter avec Chrome en mode device emulation + hot reload
# Optimisé pour développement rapide (skip clean, skip build release)

set -e

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}🚀 Arkalia CIA - Développement Rapide (Hot Reload)${NC}"
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

# Vérification rapide du lint (non bloquant mais informatif)
echo -e "${YELLOW}🔍 Vérification rapide du code...${NC}"
LINT_OUTPUT=$(timeout 15 flutter analyze --no-pub 2>&1 || echo "")
ERROR_COUNT=$(echo "$LINT_OUTPUT" | grep -c "error •" || echo "0")

if [ "$ERROR_COUNT" -gt 0 ]; then
    echo -e "${RED}⚠️  ${ERROR_COUNT} erreur(s) trouvée(s)${NC}"
    echo "$LINT_OUTPUT" | grep "error •" | head -3
    echo ""
    echo -e "${YELLOW}💡 Le lancement continuera, mais corrigez ces erreurs${NC}"
    echo ""
else
    echo -e "${GREEN}✅ Aucune erreur critique${NC}"
    echo ""
fi

# Vérifier si pubspec.yaml a changé (skip pub get si non)
NEEDS_PUB_GET=true
if [ -f "pubspec.yaml" ] && [ -f ".dart_tool/package_config.json" ]; then
    # Comparer les dates de modification
    PUBSPEC_TIME=$(stat -f %m pubspec.yaml 2>/dev/null || stat -c %Y pubspec.yaml 2>/dev/null || echo "0")
    PACKAGE_CONFIG_TIME=$(stat -f %m .dart_tool/package_config.json 2>/dev/null || stat -c %Y .dart_tool/package_config.json 2>/dev/null || echo "0")
    
    if [ "$PUBSPEC_TIME" -le "$PACKAGE_CONFIG_TIME" ]; then
        NEEDS_PUB_GET=false
    fi
fi

# Pub get seulement si nécessaire
if [ "$NEEDS_PUB_GET" = true ]; then
    echo -e "${YELLOW}📦 Mise à jour des dépendances...${NC}"
    flutter pub get > /dev/null 2>&1 || exit 1
    echo -e "${GREEN}✅ Dépendances à jour${NC}"
    echo ""
else
    echo -e "${CYAN}⏭️  Dépendances déjà à jour${NC}"
    echo ""
fi

# Vérifier les devices disponibles
DEVICES_OUTPUT=$(flutter devices 2>&1)

# Priorité : Chrome > Comet > web-server
if echo "$DEVICES_OUTPUT" | grep -qi "chrome"; then
    DEVICE="chrome"
    BROWSER_NAME="Chrome"
    echo -e "${GREEN}✅ Chrome détecté${NC}"
elif echo "$DEVICES_OUTPUT" | grep -qi "comet"; then
    DEVICE="comet"
    BROWSER_NAME="Comet"
    echo -e "${GREEN}✅ Comet détecté${NC}"
else
    DEVICE="web-server"
    BROWSER_NAME="Navigateur par défaut"
    echo -e "${YELLOW}⚠️  Chrome/Comet non trouvé, utilisation de web-server${NC}"
    echo -e "${YELLOW}   Le navigateur par défaut s'ouvrira automatiquement${NC}"
fi

# Obtenir l'IP locale pour l'accès mobile
LOCAL_IP=$(ifconfig 2>/dev/null | grep -E "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -1)
if [ -z "$LOCAL_IP" ]; then
    LOCAL_IP="<votre-ip-locale>"
fi

# Port
PORT=8080

# Afficher les informations
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🌟 Démarrage du serveur de développement${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${CYAN}💻 Sur votre Mac:${NC}"
echo -e "   ${BLUE}http://localhost:${PORT}${NC}"
echo ""
echo -e "${CYAN}📱 Sur votre mobile (même WiFi):${NC}"
echo -e "   ${BLUE}http://${LOCAL_IP}:${PORT}${NC}"
echo ""
echo -e "${CYAN}🎯 Hot Reload:${NC}"
echo -e "   ${GREEN}Appuyez sur 'r' dans le terminal pour hot reload${NC}"
echo -e "   ${GREEN}Appuyez sur 'R' pour hot restart${NC}"
echo ""
echo -e "${CYAN}📱 Mode Device Emulation (Chrome):${NC}"
echo -e "   ${YELLOW}1. Ouvrez Chrome DevTools (F12 ou Cmd+Option+I)${NC}"
echo -e "   ${YELLOW}2. Cliquez sur l'icône 'Toggle device toolbar' (Cmd+Shift+M)${NC}"
echo -e "   ${YELLOW}3. Sélectionnez un appareil (ex: iPhone 14 Pro, Galaxy S21)${NC}"
echo ""
echo -e "${YELLOW}💡 Appuyez sur Ctrl+C pour arrêter${NC}"
echo ""

# Fonction de nettoyage
cleanup() {
    echo ""
    echo -e "${YELLOW}🛑 Arrêt du serveur...${NC}"
    exit 0
}

trap cleanup SIGINT SIGTERM

# Fonction pour ouvrir le navigateur automatiquement
open_browser() {
    sleep 4  # Attendre que Flutter démarre
    if command -v open &> /dev/null; then
        if [ "$DEVICE" = "chrome" ]; then
            open -a "Google Chrome" "http://localhost:${PORT}" 2>/dev/null || true
        elif [ "$DEVICE" = "comet" ]; then
            open -a "Comet" "http://localhost:${PORT}" 2>/dev/null || \
            open -a "comet" "http://localhost:${PORT}" 2>/dev/null || true
        else
            # web-server : ouvrir avec le navigateur par défaut
            open "http://localhost:${PORT}" 2>/dev/null || true
        fi
    fi
}

# Afficher les instructions AVANT de lancer (pour que l'utilisateur les voie)
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}📱 POUR VOIR LA 'MINI TÉLÉ' SUR VOTRE ÉCRAN :${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${CYAN}1️⃣  ${BROWSER_NAME} va s'ouvrir automatiquement${NC}"
echo ""
if [ "$DEVICE" = "web-server" ]; then
    echo -e "${CYAN}2️⃣  Dans votre navigateur, appuyez sur :${NC}"
    echo -e "   ${GREEN}   F12${NC} ${YELLOW}ou${NC} ${GREEN}Cmd+Option+I${NC} ${YELLOW}(DevTools)${NC}"
    echo ""
    echo -e "${YELLOW}   ⚠️  Note: Certains navigateurs n'ont pas de mode Device Emulation${NC}"
    echo -e "${YELLOW}   Utilisez Chrome ou Comet pour la meilleure expérience${NC}"
else
    echo -e "${CYAN}2️⃣  Dans ${BROWSER_NAME}, appuyez sur :${NC}"
    echo -e "   ${GREEN}   F12${NC} ${YELLOW}ou${NC} ${GREEN}Cmd+Option+I${NC} ${YELLOW}(DevTools)${NC}"
    echo ""
    echo -e "${CYAN}3️⃣  Dans DevTools, appuyez sur :${NC}"
    echo -e "   ${GREEN}   Cmd+Shift+M${NC} ${YELLOW}(Toggle device toolbar)${NC}"
    echo ""
    echo -e "${CYAN}4️⃣  Sélectionnez un appareil dans le menu :${NC}"
    echo -e "   ${GREEN}   • iPhone 14 Pro${NC}"
    echo -e "   ${GREEN}   • Galaxy S21${NC}"
    echo -e "   ${GREEN}   • Ou un autre appareil${NC}"
fi
echo ""
echo -e "${CYAN}✅ Résultat : L'app s'affiche dans une fenêtre type téléphone !${NC}"
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Ouvrir le navigateur en arrière-plan
open_browser &

# Lancer Flutter en mode développement (hot reload activé)
# --web-hostname=0.0.0.0 permet l'accès depuis le réseau local
# Note: Flutter ouvre Chrome automatiquement si DEVICE=chrome
flutter run -d "$DEVICE" --web-port=$PORT --web-hostname=0.0.0.0

