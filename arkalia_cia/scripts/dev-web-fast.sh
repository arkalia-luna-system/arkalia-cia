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

# Vérifier qu'on est dans le bon répertoire
if [ ! -f "$PROJECT_DIR/pubspec.yaml" ]; then
    echo -e "${RED}❌ Erreur: Ce script doit être exécuté depuis arkalia_cia/scripts/${NC}"
    echo -e "${YELLOW}   Utilisez: cd arkalia_cia && bash scripts/dev-web-fast.sh${NC}"
    exit 1
fi

cd "$PROJECT_DIR"

# Vérifier Flutter
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter n'est pas installé${NC}"
    exit 1
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

# Pub get seulement si nécessaire (AVANT l'analyse pour éviter erreurs)
if [ "$NEEDS_PUB_GET" = true ]; then
    echo -e "${YELLOW}📦 Mise à jour des dépendances...${NC}"
    flutter pub get > /dev/null 2>&1 || exit 1
    echo -e "${GREEN}✅ Dépendances à jour${NC}"
    echo ""
else
    echo -e "${CYAN}⏭️  Dépendances déjà à jour${NC}"
    echo ""
fi

# Vérification rapide du lint (APRÈS pub get pour éviter erreurs de packages manquants)
echo -e "${YELLOW}🔍 Vérification rapide du code...${NC}"
LINT_OUTPUT=$(timeout 15 flutter analyze --no-pub 2>&1 || echo "")
ERROR_COUNT=$(echo "$LINT_OUTPUT" | grep -c "error •" || echo "0")

# Convertir en nombre (éviter les erreurs de comparaison)
ERROR_COUNT=${ERROR_COUNT:-0}

if [ "$ERROR_COUNT" -gt 0 ] 2>/dev/null; then
    echo -e "${RED}⚠️  ${ERROR_COUNT} erreur(s) trouvée(s)${NC}"
    echo "$LINT_OUTPUT" | grep "error •" | head -3
    echo ""
    echo -e "${YELLOW}💡 Le lancement continuera, mais corrigez ces erreurs${NC}"
    echo ""
else
    echo -e "${GREEN}✅ Aucune erreur critique${NC}"
    echo ""
fi

# Vérifier et créer le répertoire web si nécessaire
if [ ! -d "web" ]; then
    echo -e "${YELLOW}📁 Création du répertoire web...${NC}"
    flutter create --platforms=web . 2>/dev/null || {
        mkdir -p web
        echo -e "${GREEN}✅ Répertoire web créé${NC}"
    }
    echo ""
fi

# Nettoyer le build web pour éviter les erreurs de compilation
echo -e "${YELLOW}🧹 Nettoyage complet du build web...${NC}"
rm -rf build/web 2>/dev/null || true
rm -rf .dart_tool/build 2>/dev/null || true
rm -rf .dart_tool/flutter_build 2>/dev/null || true
flutter clean > /dev/null 2>&1 || true
echo -e "${GREEN}✅ Nettoyage terminé${NC}"
echo ""

# Note: On ne fait PAS de build initial car cela compile aussi pour iOS/Android
# flutter build web compile pour toutes les plateformes, ce qui est très lent
# flutter run compile uniquement pour le web, ce qui est plus rapide
# Le build initial causait des compilations iOS inutiles (très long)
echo -e "${CYAN}💡 Flutter compilera automatiquement pour le web au lancement${NC}"
echo ""

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

# Afficher les informations de manière claire et organisée
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     🌟  ARKALIA CIA - SERVEUR DE DÉVELOPPEMENT  🌟      ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}📱 ${BROWSER_NAME} sera ouvert automatiquement${NC}"
echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}📍  ACCÈS À L'APPLICATION${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}💻 Sur votre Mac:${NC}"
echo -e "   ${BLUE}👉 http://localhost:${PORT}${NC}"
echo ""
echo -e "${CYAN}📱 Sur votre mobile (même WiFi):${NC}"
echo -e "   ${BLUE}👉 http://${LOCAL_IP}:${PORT}${NC}"
echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}⚡  COMMANDES RAPIDES${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🎯 Hot Reload:${NC}"
echo -e "   ${GREEN}Appuyez sur 'r' dans le terminal${NC}"
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

# Fonction pour vérifier que Flutter est vraiment prêt (app chargée, pas juste serveur)
wait_for_flutter() {
    local max_attempts=90  # Augmenté à 90 secondes pour laisser Flutter compiler
    local attempt=0
    echo -e "${YELLOW}⏳ Attente du démarrage complet de Flutter (compilation + chargement)...${NC}"
    echo -e "${CYAN}   (La première compilation peut prendre 30-60 secondes)${NC}"
    
    while [ $attempt -lt $max_attempts ]; do
        # Vérifier que le serveur répond
        if ! curl -s "http://localhost:${PORT}" > /dev/null 2>&1; then
            attempt=$((attempt + 1))
            sleep 1
            printf "."
            continue
        fi
        
        # Vérifier que la page contient du contenu Flutter (pas juste une page blanche)
        PAGE_CONTENT=$(curl -s "http://localhost:${PORT}" 2>/dev/null || echo "")
        
        # Vérifier la présence de fichiers Flutter compilés
        # Flutter web génère flutter_bootstrap.js, main.dart.js, etc.
        if echo "$PAGE_CONTENT" | grep -qiE "(flutter_bootstrap|main\.dart|canvaskit)" || [ ${#PAGE_CONTENT} -gt 2000 ]; then
            # Vérifier aussi que les fichiers JS sont accessibles
            if curl -s "http://localhost:${PORT}/flutter_bootstrap.js" > /dev/null 2>&1; then
                echo ""
                echo -e "${GREEN}✅ Flutter est prêt et l'app est chargée !${NC}"
                sleep 3  # Délai supplémentaire pour être sûr que tout est prêt
                return 0
            fi
        fi
        
        attempt=$((attempt + 1))
        sleep 1
        printf "."
    done
    
    echo ""
    echo -e "${YELLOW}⚠️  Flutter prend du temps à démarrer, ouverture du navigateur quand même...${NC}"
    echo -e "${YELLOW}   (L'app peut prendre quelques secondes supplémentaires à charger)${NC}"
    sleep 5  # Attendre un peu plus quand même
    return 1
}

# Fonction pour ouvrir le navigateur automatiquement
open_browser() {
    # Attendre que Flutter soit prêt (vérifie que le serveur répond)
    wait_for_flutter
    
    sleep 2  # Petit délai supplémentaire pour être sûr
    
    if command -v open &> /dev/null; then
        if [ "${USE_COMET:-false}" = true ]; then
            # Ouvrir Comet avec l'URL
            COMET_URL="http://localhost:${PORT}"
            if [ -d "/Applications/Comet.app" ]; then
                open -a "/Applications/Comet.app" "$COMET_URL" 2>/dev/null || true
            elif [ -d "$HOME/Applications/Comet.app" ]; then
                open -a "$HOME/Applications/Comet.app" "$COMET_URL" 2>/dev/null || true
            else
                open -a "Comet" "$COMET_URL" 2>/dev/null || true
            fi
            
            # Attendre un peu pour que Comet s'ouvre et charge la page
            sleep 4
            
            # Essayer d'activer DevTools et Device Emulation automatiquement avec AppleScript
            SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
            APPLE_SCRIPT="$SCRIPT_DIR/open_comet_devtools.applescript"
            
            echo ""
            echo -e "${GREEN}✅ Comet ouvert avec l'application${NC}"
            echo ""
            
            if [ -f "$APPLE_SCRIPT" ]; then
                echo -e "${CYAN}🔧 Activation automatique du mode Device Emulation...${NC}"
                osascript "$APPLE_SCRIPT" 2>/dev/null && {
                    sleep 1
                    echo ""
                    echo -e "${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
                    echo -e "${GREEN}║  ✅  DevTools et Device Emulation activés avec succès !  ║${NC}"
                    echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
                    echo ""
                    echo -e "${GREEN}📱 Le 'mini téléphone' devrait maintenant être visible sur votre écran${NC}"
                    echo ""
                } || {
                    echo -e "${YELLOW}⚠️  Activation automatique échouée${NC}"
                    echo ""
                }
            else
                echo -e "${YELLOW}⚠️  Script AppleScript non trouvé${NC}"
                echo ""
            fi
            
            if [ ! -f "$APPLE_SCRIPT" ] || ! osascript "$APPLE_SCRIPT" 2>/dev/null; then
                echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                echo -e "${YELLOW}💡  ACTIVATION MANUELLE DU MINI TÉLÉPHONE${NC}"
                echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                echo ""
                echo -e "${CYAN}Si le 'mini téléphone' n'apparaît pas, suivez ces étapes :${NC}"
                echo ""
                echo -e "   ${YELLOW}1.${NC} Dans Comet, appuyez sur ${GREEN}F12${NC} ou ${GREEN}Cmd+Option+I${NC}"
                echo -e "      ${CYAN}(Ouvre les DevTools)${NC}"
                echo ""
                echo -e "   ${YELLOW}2.${NC} Dans DevTools, appuyez sur ${GREEN}Cmd+Shift+M${NC}"
                echo -e "      ${CYAN}(Toggle device toolbar)${NC}"
                echo ""
                echo -e "   ${YELLOW}3.${NC} Sélectionnez un appareil dans le menu en haut :"
                echo -e "      ${GREEN}• iPhone 14 Pro${NC}"
                echo -e "      ${GREEN}• Galaxy S21${NC}"
                echo -e "      ${GREEN}• Ou un autre appareil${NC}"
                echo ""
                echo -e "   ${YELLOW}4.${NC} Le téléphone devrait apparaître sur votre écran !"
                echo ""
            fi
            
            # Ne pas ouvrir Chrome, l'utilisateur veut utiliser Comet
            if false; then
                # Ancien code pour Chrome (désactivé)
                sleep 4
                # Envoyer Cmd+Shift+M pour activer device toolbar (nécessite que Chrome soit actif)
                osascript -e 'tell application "Google Chrome" to activate' 2>/dev/null || true
                sleep 1
                # Note: L'activation automatique du device toolbar nécessite une extension ou un script plus complexe
                # Pour l'instant, l'utilisateur devra appuyer manuellement sur Cmd+Shift+M
            fi
            
            echo ""
            echo -e "${GREEN}✅ Comet ouvert avec l'app${NC}"
            if [ -d "/Applications/Google Chrome.app" ]; then
                echo -e "${GREEN}✅ Chrome ouvert aussi (pour la vue mobile)${NC}"
            fi
            echo -e "${CYAN}📱 Pour voir la 'mini télé' dans Chrome :${NC}"
            echo -e "   ${YELLOW}1. Appuyez sur ${GREEN}Cmd+Option+I${YELLOW} (DevTools)${NC}"
            echo -e "   ${YELLOW}2. Appuyez sur ${GREEN}Cmd+Shift+M${YELLOW} (Toggle device toolbar)${NC}"
            echo -e "   ${YELLOW}3. Sélectionnez un appareil (iPhone 14 Pro, etc.)${NC}"
            echo -e "${CYAN}💡 Dans Comet, cherchez l'icône de device/phone pour la vue mobile${NC}"
        elif [ "${USE_CHROME:-false}" = true ]; then
            # Ouvrir Chrome
            if [ -d "/Applications/Google Chrome.app" ]; then
                open -a "/Applications/Google Chrome.app" "http://localhost:${PORT}" 2>/dev/null || true
            else
                open -a "Google Chrome" "http://localhost:${PORT}" 2>/dev/null || true
            fi
            echo ""
            echo -e "${GREEN}✅ Chrome ouvert automatiquement${NC}"
            echo ""
            echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo -e "${YELLOW}💡  ACTIVATION DU MINI TÉLÉPHONE DANS CHROME${NC}"
            echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo ""
            echo -e "${CYAN}Pour voir la 'mini télé' dans Chrome :${NC}"
            echo ""
            echo -e "   ${YELLOW}1.${NC} Appuyez sur ${GREEN}Cmd+Option+I${NC} (DevTools)"
            echo ""
            echo -e "   ${YELLOW}2.${NC} Appuyez sur ${GREEN}Cmd+Shift+M${NC} (Toggle device toolbar)"
            echo ""
            echo -e "   ${YELLOW}3.${NC} Sélectionnez un appareil (iPhone 14 Pro, etc.)"
            echo ""
        elif [ "$DEVICE" = "chrome" ]; then
            # Chrome détecté par Flutter (s'ouvre automatiquement)
            echo ""
            echo -e "${GREEN}✅ Chrome devrait s'ouvrir automatiquement${NC}"
            echo ""
        else
            # web-server : ouvrir avec le navigateur par défaut
            open "http://localhost:${PORT}" 2>/dev/null || true
            echo ""
            echo -e "${GREEN}✅ Navigateur ouvert automatiquement${NC}"
            echo ""
        fi
    fi
}

# Afficher les informations de démarrage
echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}🚀  DÉMARRAGE DE FLUTTER${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${CYAN}📱 ${BROWSER_NAME} s'ouvrira automatiquement quand Flutter sera prêt${NC}"
echo ""
echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${RED}⚠️   MESSAGE IMPORTANT - À LIRE${NC}"
echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}📋 Pendant la compilation Flutter :${NC}"
echo -e "${GREEN}   ✅ Les erreurs WebSocket sont NORMALES${NC}"
echo -e "${GREEN}   ✅ L'erreur 'Library not defined' est NORMALE${NC}"
echo -e "${GREEN}   ✅ Ces erreurs disparaîtront automatiquement${NC}"
echo ""
echo -e "${YELLOW}⏳ Attendez que Flutter affiche :${NC}"
echo -e "${GREEN}   'Flutter run key commands.'${NC}"
echo -e "${GREEN}   'r Hot reload. 🔥🔥🔥'${NC}"
echo ""
echo -e "${GREEN}✅ Une fois ce message affiché, l'app est prête !${NC}"
echo -e "${GREEN}   Les erreurs dans la console du navigateur disparaîtront.${NC}"
echo ""
echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Ouvrir le navigateur en arrière-plan
open_browser &

# Lancer Flutter en mode développement (hot reload activé)
# --web-hostname=0.0.0.0 permet l'accès depuis le réseau local
# Note: Flutter ouvre Chrome automatiquement si DEVICE=chrome
# Note: CanvasKit est utilisé par défaut dans Flutter 3.35.3
echo -e "${CYAN}🚀 Lancement Flutter en mode développement...${NC}"
echo ""

# Lancer Flutter (compile automatiquement)
# Le WebSocket 8081 est géré automatiquement par Flutter
# Les erreurs WebSocket pendant la compilation sont normales
flutter run -d "$DEVICE" --web-port=$PORT --web-hostname=0.0.0.0

