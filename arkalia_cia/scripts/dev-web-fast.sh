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

# Vérifier les devices disponibles et les navigateurs installés
DEVICES_OUTPUT=$(flutter devices 2>&1)

# Vérifier si Comet est installé
COMET_INSTALLED=false
if [ -d "/Applications/Comet.app" ] || [ -d "$HOME/Applications/Comet.app" ]; then
    COMET_INSTALLED=true
fi

# Vérifier si Chrome est installé
CHROME_INSTALLED=false
if [ -d "/Applications/Google Chrome.app" ] || [ -d "$HOME/Applications/Google Chrome.app" ]; then
    CHROME_INSTALLED=true
fi

# Priorité : Chrome détecté par Flutter > Comet installé > Chrome installé > web-server
if echo "$DEVICES_OUTPUT" | grep -qi "chrome"; then
    DEVICE="chrome"
    BROWSER_NAME="Chrome"
    echo -e "${GREEN}✅ Chrome détecté par Flutter${NC}"
elif [ "$COMET_INSTALLED" = true ]; then
    DEVICE="web-server"
    BROWSER_NAME="Comet"
    USE_COMET=true
    echo -e "${GREEN}✅ Comet détecté (sera ouvert automatiquement)${NC}"
elif [ "$CHROME_INSTALLED" = true ]; then
    DEVICE="web-server"
    BROWSER_NAME="Chrome"
    USE_CHROME=true
    echo -e "${GREEN}✅ Chrome détecté (sera ouvert automatiquement)${NC}"
else
    DEVICE="web-server"
    BROWSER_NAME="Navigateur par défaut"
    echo -e "${YELLOW}⚠️  Utilisation de web-server${NC}"
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

# Fonction pour vérifier que le serveur Flutter répond
wait_for_flutter() {
    local max_attempts=30
    local attempt=0
    echo -e "${YELLOW}⏳ Attente du démarrage de Flutter...${NC}"
    
    while [ $attempt -lt $max_attempts ]; do
        if curl -s "http://localhost:${PORT}" > /dev/null 2>&1; then
            echo -e "${GREEN}✅ Flutter est prêt !${NC}"
            return 0
        fi
        attempt=$((attempt + 1))
        sleep 1
        printf "."
    done
    
    echo -e "${YELLOW}⚠️  Flutter prend du temps à démarrer, ouverture du navigateur quand même...${NC}"
    return 1
}

# Fonction pour ouvrir le navigateur automatiquement
open_browser() {
    # Attendre que Flutter soit prêt (vérifie que le serveur répond)
    wait_for_flutter
    
    sleep 2  # Petit délai supplémentaire pour être sûr
    
    if command -v open &> /dev/null; then
        if [ "${USE_COMET:-false}" = true ]; then
            # Ouvrir Comet
            if [ -d "/Applications/Comet.app" ]; then
                open -a "/Applications/Comet.app" "http://localhost:${PORT}" 2>/dev/null || true
            elif [ -d "$HOME/Applications/Comet.app" ]; then
                open -a "$HOME/Applications/Comet.app" "http://localhost:${PORT}" 2>/dev/null || true
            else
                open -a "Comet" "http://localhost:${PORT}" 2>/dev/null || true
            fi
            echo ""
            echo -e "${GREEN}✅ Comet ouvert avec l'app${NC}"
            echo -e "${CYAN}💡 Pour voir la 'mini télé' :${NC}"
            echo -e "   ${YELLOW}1. Appuyez sur ${GREEN}F12${YELLOW} ou ${GREEN}Cmd+Option+I${YELLOW} (DevTools)${NC}"
            echo -e "   ${YELLOW}2. Appuyez sur ${GREEN}Cmd+Shift+M${YELLOW} (Toggle device toolbar)${NC}"
            echo -e "   ${YELLOW}3. Sélectionnez un appareil dans le menu${NC}"
        elif [ "${USE_CHROME:-false}" = true ]; then
            # Ouvrir Chrome
            if [ -d "/Applications/Google Chrome.app" ]; then
                open -a "/Applications/Google Chrome.app" "http://localhost:${PORT}" 2>/dev/null || true
            else
                open -a "Google Chrome" "http://localhost:${PORT}" 2>/dev/null || true
            fi
            echo -e "${GREEN}✅ Chrome ouvert automatiquement${NC}"
        elif [ "$DEVICE" = "chrome" ]; then
            # Chrome détecté par Flutter (s'ouvre automatiquement)
            echo -e "${GREEN}✅ Chrome devrait s'ouvrir automatiquement${NC}"
        else
            # web-server : ouvrir avec le navigateur par défaut
            open "http://localhost:${PORT}" 2>/dev/null || true
            echo -e "${GREEN}✅ Navigateur ouvert automatiquement${NC}"
        fi
    fi
}

# Afficher les informations de démarrage
echo ""
echo -e "${CYAN}📱 ${BROWSER_NAME} s'ouvrira automatiquement quand Flutter sera prêt${NC}"
echo ""

# Ouvrir le navigateur en arrière-plan
open_browser &

# Lancer Flutter en mode développement (hot reload activé)
# --web-hostname=0.0.0.0 permet l'accès depuis le réseau local
# Note: Flutter ouvre Chrome automatiquement si DEVICE=chrome
flutter run -d "$DEVICE" --web-port=$PORT --web-hostname=0.0.0.0

