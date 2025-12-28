#!/bin/bash
# Script de développement rapide avec preview en temps réel
# Lance Flutter avec Chrome en mode device emulation + hot reload
# Optimisé pour développement rapide (skip clean, skip build release)

# Ne pas utiliser set -e car on veut que Flutter reste actif même en cas d'erreur mineure
# set -e

# Couleurs (pas de jaune ni vert pour éviter la fatigue oculaire)
BLUE='\033[0;34m'
BRIGHT_BLUE='\033[1;34m'
CYAN='\033[0;36m'
BRIGHT_CYAN='\033[1;36m'
BRIGHT_MAGENTA='\033[1;35m'
RED='\033[0;31m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m'

echo -e "${BLUE}🚀 Arkalia CIA - Développement Rapide (Hot Reload)${NC}"
echo ""

# Obtenir le répertoire du script
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Vérifier qu'on est dans le bon répertoire
if [ ! -f "$PROJECT_DIR/pubspec.yaml" ]; then
    echo -e "${RED}❌ Erreur: Ce script doit être exécuté depuis arkalia_cia/scripts/${NC}"
    echo -e "${CYAN}   Utilisez: cd arkalia_cia && bash scripts/dev-web-fast.sh${NC}"
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
    echo -e "${CYAN}📦 Mise à jour des dépendances...${NC}"
    flutter pub get > /dev/null 2>&1 || exit 1
    echo -e "${BRIGHT_CYAN}✅ Dépendances à jour${NC}"
    echo ""
else
    echo -e "${CYAN}⏭️  Dépendances déjà à jour${NC}"
    echo ""
fi

# Vérification rapide du lint (APRÈS pub get pour éviter erreurs de packages manquants)
echo -e "${CYAN}🔍 Vérification rapide du code...${NC}"
LINT_OUTPUT=$(timeout 15 flutter analyze --no-pub 2>&1 || echo "")
ERROR_COUNT=$(echo "$LINT_OUTPUT" | grep -c "error •" || echo "0")

# Convertir en nombre (éviter les erreurs de comparaison)
ERROR_COUNT=${ERROR_COUNT:-0}

if [ "$ERROR_COUNT" -gt 0 ] 2>/dev/null; then
    echo -e "${RED}⚠️  ${ERROR_COUNT} erreur(s) trouvée(s)${NC}"
    echo "$LINT_OUTPUT" | grep "error •" | head -3
    echo ""
    echo -e "${CYAN}💡 Le lancement continuera, mais corrigez ces erreurs${NC}"
    echo ""
else
    echo -e "${BRIGHT_CYAN}✅ Aucune erreur critique${NC}"
    echo ""
fi

# Vérifier et créer le répertoire web si nécessaire
if [ ! -d "web" ]; then
    echo -e "${CYAN}📁 Création du répertoire web...${NC}"
    flutter create --platforms=web . 2>/dev/null || {
        mkdir -p web
        echo -e "${BRIGHT_CYAN}✅ Répertoire web créé${NC}"
    }
    echo ""
fi

# Nettoyer le build web pour éviter les erreurs de compilation
echo -e "${CYAN}🧹 Nettoyage complet du build web...${NC}"
rm -rf build/web 2>/dev/null || true
rm -rf .dart_tool/build 2>/dev/null || true
rm -rf .dart_tool/flutter_build 2>/dev/null || true
flutter clean > /dev/null 2>&1 || true
echo -e "${BRIGHT_CYAN}✅ Nettoyage terminé${NC}"
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
    echo -e "${BRIGHT_CYAN}✅ Chrome détecté par Flutter${NC}"
elif [ "$COMET_INSTALLED" = true ]; then
    DEVICE="web-server"
    BROWSER_NAME="Comet"
    USE_COMET=true
    echo -e "${BRIGHT_CYAN}✅ Comet détecté (sera ouvert automatiquement)${NC}"
elif [ "$CHROME_INSTALLED" = true ]; then
    DEVICE="web-server"
    BROWSER_NAME="Chrome"
    USE_CHROME=true
    echo -e "${BRIGHT_CYAN}✅ Chrome détecté (sera ouvert automatiquement)${NC}"
else
    DEVICE="web-server"
    BROWSER_NAME="Navigateur par défaut"
    echo -e "${CYAN}⚠️  Utilisation de web-server${NC}"
    echo -e "${CYAN}   Le navigateur par défaut s'ouvrira automatiquement${NC}"
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
echo -e "${BRIGHT_BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BRIGHT_BLUE}║     🌟  ARKALIA CIA - SERVEUR DE DÉVELOPPEMENT  🌟      ║${NC}"
echo -e "${BRIGHT_BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}📱 ${BROWSER_NAME} sera ouvert automatiquement${NC}"
echo ""
echo -e "${BRIGHT_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BRIGHT_CYAN}📍  ACCÈS À L'APPLICATION${NC}"
echo -e "${BRIGHT_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${WHITE}💻 Sur votre Mac:${NC}"
echo -e "   ${BLUE}👉 http://localhost:${PORT}${NC}"
echo ""
echo -e "${WHITE}📱 Sur votre mobile (même WiFi):${NC}"
echo -e "   ${BLUE}👉 http://${LOCAL_IP}:${PORT}${NC}"
echo ""
echo -e "${BRIGHT_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BRIGHT_CYAN}⚡  COMMANDES RAPIDES${NC}"
echo -e "${BRIGHT_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BRIGHT_MAGENTA}🎯 Hot Reload:${NC}"
echo -e "   ${WHITE}Appuyez sur 'r' dans le terminal${NC}"
echo -e "   ${WHITE}Appuyez sur 'R' pour hot restart${NC}"
echo ""
echo -e "${CYAN}📱 Mode Device Emulation (Chrome):${NC}"
echo -e "   ${WHITE}1. Ouvrez Chrome DevTools (F12 ou Cmd+Option+I)${NC}"
echo -e "   ${WHITE}2. Cliquez sur l'icône 'Toggle device toolbar' (Cmd+Shift+M)${NC}"
echo -e "   ${WHITE}3. Sélectionnez un appareil (ex: iPhone 14 Pro, Galaxy S21)${NC}"
echo ""
echo -e "${CYAN}💡 Appuyez sur Ctrl+C pour arrêter${NC}"
echo ""

# Fonction de nettoyage
cleanup() {
    echo ""
    echo -e "${CYAN}🛑 Arrêt du serveur...${NC}"
    # Nettoyer le fichier de verrouillage
    rm -f "/tmp/arkalia_browser_opened_${PORT}" 2>/dev/null || true
    exit 0
}

trap cleanup SIGINT SIGTERM

# Fonction pour vérifier que Flutter est vraiment prêt (app chargée, pas juste serveur)
wait_for_flutter() {
    local max_attempts=90  # 90 secondes maximum
    local attempt=0
    local silent=${1:-false}  # Mode silencieux par défaut
    
    if [ "$silent" != "true" ]; then
        echo -e "${CYAN}⏳ Attente du démarrage complet de Flutter...${NC}"
    fi
    
    while [ $attempt -lt $max_attempts ]; do
        # Vérifier que flutter_bootstrap.js est accessible (meilleur indicateur)
        if curl -s "http://localhost:${PORT}/flutter_bootstrap.js" > /dev/null 2>&1; then
            # Vérifier aussi que le fichier n'est pas vide
            BOOTSTRAP_SIZE=$(curl -s "http://localhost:${PORT}/flutter_bootstrap.js" 2>/dev/null | wc -c)
            if [ "$BOOTSTRAP_SIZE" -gt 100 ]; then
                if [ "$silent" != "true" ]; then
                    echo ""
                    echo -e "${BRIGHT_CYAN}✅ Flutter est prêt et l'app est chargée !${NC}"
                fi
                sleep 3  # Délai supplémentaire pour être sûr que tout est prêt
                return 0
            fi
        fi
        
        attempt=$((attempt + 1))
        if [ "$silent" != "true" ] && [ $((attempt % 10)) -eq 0 ]; then
            printf "."
        fi
        sleep 1
    done
    
    if [ "$silent" != "true" ]; then
        echo ""
        echo -e "${CYAN}⚠️  Flutter prend du temps à démarrer, ouverture du navigateur quand même...${NC}"
    fi
    return 1
}

# Fonction pour ouvrir le navigateur automatiquement (une seule fois)
open_browser() {
    # Vérifier qu'on n'a pas déjà ouvert le navigateur
    if [ -f "/tmp/arkalia_browser_opened_${PORT}" ]; then
        return 0
    fi
    
    # Marquer qu'on a ouvert le navigateur
    touch "/tmp/arkalia_browser_opened_${PORT}"
    
    # Attendre que Flutter soit prêt (mode silencieux pour éviter les messages)
    wait_for_flutter true
    
    sleep 2  # Petit délai supplémentaire pour être sûr
    
    if command -v open &> /dev/null; then
        if [ "${USE_COMET:-false}" = true ]; then
            # Vérifier si Comet est déjà ouvert avec cette URL
            if pgrep -f "Comet.*localhost:${PORT}" > /dev/null; then
                echo -e "${CYAN}ℹ️  Comet est déjà ouvert${NC}"
                return 0
            fi
            
            # Ouvrir Comet avec l'URL (une seule fois)
            COMET_URL="http://localhost:${PORT}"
            if [ -d "/Applications/Comet.app" ]; then
                open -a "/Applications/Comet.app" "$COMET_URL" 2>/dev/null || true
            elif [ -d "$HOME/Applications/Comet.app" ]; then
                open -a "$HOME/Applications/Comet.app" "$COMET_URL" 2>/dev/null || true
            else
                open -a "Comet" "$COMET_URL" 2>/dev/null || true
            fi
            
            # Attendre un peu pour que Comet s'ouvre et charge la page
            sleep 5
            
            # Essayer d'activer DevTools et Device Emulation automatiquement avec AppleScript
            SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
            APPLE_SCRIPT="$SCRIPT_DIR/open_comet_devtools.applescript"
            
            echo ""
            echo -e "${BRIGHT_CYAN}✅ Comet ouvert avec l'application${NC}"
            echo ""
            
            # NE PAS activer automatiquement le device emulation
            # L'utilisateur peut l'activer manuellement s'il le souhaite
            echo ""
            echo -e "${BRIGHT_CYAN}✅ Comet ouvert avec l'application${NC}"
            echo ""
            echo -e "${CYAN}💡 Pour activer le mode téléphone (optionnel) :${NC}"
            echo -e "   ${WHITE}1.${NC} Appuyez sur ${BRIGHT_MAGENTA}F12${NC} ou ${BRIGHT_MAGENTA}Cmd+Option+I${NC} (DevTools)"
            echo -e "   ${WHITE}2.${NC} Appuyez sur ${BRIGHT_MAGENTA}Cmd+Shift+M${NC} (Toggle device toolbar)"
            echo ""
            
            # Ne pas ouvrir Chrome automatiquement pour éviter les ouvertures multiples
        elif [ "${USE_CHROME:-false}" = true ]; then
            # Ouvrir Chrome
            if [ -d "/Applications/Google Chrome.app" ]; then
                open -a "/Applications/Google Chrome.app" "http://localhost:${PORT}" 2>/dev/null || true
            else
                open -a "Google Chrome" "http://localhost:${PORT}" 2>/dev/null || true
            fi
            echo ""
            echo -e "${BRIGHT_CYAN}✅ Chrome ouvert automatiquement${NC}"
            echo ""
            echo -e "${BRIGHT_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo -e "${BRIGHT_CYAN}💡  ACTIVATION DU MINI TÉLÉPHONE DANS CHROME${NC}"
            echo -e "${BRIGHT_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo ""
            echo -e "${WHITE}Pour voir la 'mini télé' dans Chrome :${NC}"
            echo ""
            echo -e "   ${WHITE}1.${NC} Appuyez sur ${BRIGHT_MAGENTA}Cmd+Option+I${NC} (DevTools)"
            echo ""
            echo -e "   ${WHITE}2.${NC} Appuyez sur ${BRIGHT_MAGENTA}Cmd+Shift+M${NC} (Toggle device toolbar)"
            echo ""
            echo -e "   ${WHITE}3.${NC} Sélectionnez un appareil (iPhone 14 Pro, etc.)"
            echo ""
        elif [ "$DEVICE" = "chrome" ]; then
            # Chrome détecté par Flutter (s'ouvre automatiquement)
            echo ""
            echo -e "${BRIGHT_CYAN}✅ Chrome devrait s'ouvrir automatiquement${NC}"
            echo ""
        else
            # web-server : ouvrir avec le navigateur par défaut
            open "http://localhost:${PORT}" 2>/dev/null || true
            echo ""
            echo -e "${BRIGHT_CYAN}✅ Navigateur ouvert automatiquement${NC}"
            echo ""
        fi
    fi
}

# Afficher les informations de démarrage
echo ""
echo -e "${BRIGHT_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BRIGHT_CYAN}🚀  DÉMARRAGE DE FLUTTER${NC}"
echo -e "${BRIGHT_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${WHITE}📱 ${BROWSER_NAME} s'ouvrira automatiquement quand Flutter sera prêt${NC}"
echo ""
echo -e "${BRIGHT_MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BRIGHT_MAGENTA}⚠️   MESSAGE IMPORTANT - À LIRE${NC}"
echo -e "${BRIGHT_MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${WHITE}📋 Pendant la compilation Flutter :${NC}"
echo -e "${BRIGHT_CYAN}   ✅ Les erreurs WebSocket sont NORMALES${NC}"
echo -e "${BRIGHT_CYAN}   ✅ L'erreur 'Library not defined' est NORMALE${NC}"
echo -e "${BRIGHT_CYAN}   ✅ Ces erreurs disparaîtront automatiquement${NC}"
echo ""
echo -e "${WHITE}⏳ Attendez que Flutter affiche :${NC}"
echo -e "${BRIGHT_CYAN}   'Flutter run key commands.'${NC}"
echo -e "${BRIGHT_CYAN}   'r Hot reload. 🔥🔥🔥'${NC}"
echo ""
echo -e "${BRIGHT_CYAN}✅ Une fois ce message affiché, l'app est prête !${NC}"
echo -e "${WHITE}   Les erreurs dans la console du navigateur disparaîtront.${NC}"
echo ""
echo -e "${BRIGHT_MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Lancer Flutter en mode développement (hot reload activé)
# --web-hostname=0.0.0.0 permet l'accès depuis le réseau local
# Note: Flutter ouvre Chrome automatiquement si DEVICE=chrome
# Note: CanvasKit est utilisé par défaut dans Flutter 3.35.3
echo -e "${CYAN}🚀 Lancement Flutter en mode développement...${NC}"
echo ""

# Lancer Flutter en arrière-plan et ouvrir le navigateur après
# (seulement si DEVICE n'est pas "chrome" car Chrome s'ouvre automatiquement)
if [ "$DEVICE" != "chrome" ]; then
    (
        # Attendre que Flutter démarre avant d'ouvrir le navigateur
        sleep 8
        
        # Vérifier que le serveur Flutter répond et que flutter_bootstrap.js existe
        for i in 1 2 3 4 5 6; do
            if curl -s "http://localhost:${PORT}/flutter_bootstrap.js" > /dev/null 2>&1; then
                # Flutter est vraiment prêt
                sleep 2
                open_browser
                exit 0
            fi
            sleep 3
        done
        
        # Si après 18 secondes Flutter n'est pas prêt, ouvrir quand même
        # (pour éviter que l'utilisateur attende indéfiniment)
        open_browser
    ) &
fi

# Lancer Flutter (compile automatiquement)
# Le WebSocket 8081 est géré automatiquement par Flutter
# Les erreurs WebSocket pendant la compilation sont normales
# IMPORTANT: Ne pas rediriger stdin/stdout pour que les commandes r/R fonctionnent
echo ""
echo -e "${BRIGHT_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BRIGHT_CYAN}💡  COMMANDES DISPONIBLES${NC}"
echo -e "${BRIGHT_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${WHITE}Appuyez sur les touches suivantes dans ce terminal :${NC}"
echo -e "   ${BRIGHT_MAGENTA}r${NC} = Hot reload (recharge rapide) 🔥"
echo -e "   ${BRIGHT_MAGENTA}R${NC} = Hot restart (redémarrage complet)"
echo -e "   ${BRIGHT_MAGENTA}q${NC} = Quitter Flutter"
echo -e "   ${BRIGHT_MAGENTA}h${NC} = Aide (liste toutes les commandes)"
echo ""
echo -e "${CYAN}💡 Astuce: Appuyez sur ${BRIGHT_MAGENTA}r${NC} après chaque modification de code${NC}"
echo ""
echo -e "${BRIGHT_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Lancer Flutter en mode interactif (sans redirection)
# Utiliser exec pour que le processus prenne le contrôle du terminal
exec flutter run -d "$DEVICE" --web-port=$PORT --web-hostname=0.0.0.0

