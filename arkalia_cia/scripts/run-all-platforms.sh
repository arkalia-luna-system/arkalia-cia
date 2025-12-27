#!/bin/bash
# Script optimisé pour lancer l'app sur TOUTES les plateformes en parallèle
# Web, Android, macOS
# Version ultra-optimisée : rapide, léger en RAM, meilleure UX

# Utilisation: 
#   bash scripts/run-all-platforms.sh                    # Toutes les plateformes
#   PLATFORMS=web,macos bash scripts/run-all-platforms.sh  # Seulement web et macOS
#   SKIP_CLEAN=true bash scripts/run-all-platforms.sh    # Sans nettoyage

set -e  # Exit on error, mais on gère les erreurs avec || true où nécessaire

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

# Options configurables
SKIP_CLEAN="${SKIP_CLEAN:-false}"
SKIP_PUB_GET="${SKIP_PUB_GET:-false}"
LOG_DIR="${LOG_DIR:-$HOME/.arkalia_cia_logs}"
PLATFORMS="${PLATFORMS:-web,android,macos}"
MAX_LOG_SIZE_MB=10  # Limiter la taille des logs pour économiser la RAM

echo -e "${BLUE}🚀 Arkalia CIA - Lancement Multi-Plateformes${NC}"
echo ""

# Obtenir le répertoire du script (une seule fois)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_ROOT="$(cd "$PROJECT_DIR/.." && pwd)"
cd "$PROJECT_DIR"

# Vérifier Flutter
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter n'est pas installé${NC}"
    exit 1
fi

# Créer le répertoire de logs
mkdir -p "$LOG_DIR"

# Fonction spinner simple (légère en RAM)
show_spinner() {
    local pid=$1
    local msg=$2
    local spin='-\|/'
    local i=0
    while kill -0 "$pid" 2>/dev/null; do
        i=$(( (i+1) %4 ))
        printf "\r${CYAN}   %s ${spin:$i:1}${NC}" "$msg"
        sleep 0.2
    done
    printf "\r${GREEN}   ✅ ${msg}${NC}\n"
}

# Fonction pour vérifier si pubspec.yaml a changé (optimisée)
needs_pub_get() {
    [ "$SKIP_PUB_GET" = "true" ] && return 1
    
    local hash_file="$LOG_DIR/pubspec.hash"
    [ ! -f "pubspec.yaml" ] && return 0
    
    # Utiliser stat pour comparer (plus rapide que hash sur macOS)
    if command -v stat &> /dev/null; then
        local current_mtime=$(stat -f %m pubspec.yaml 2>/dev/null || stat -c %Y pubspec.yaml 2>/dev/null || echo "0")
        local stored_mtime=$(cat "$hash_file" 2>/dev/null || echo "0")
        if [ "$current_mtime" = "$stored_mtime" ] && [ "$current_mtime" != "0" ]; then
            return 1  # Pas besoin
        fi
        echo "$current_mtime" > "$hash_file" 2>/dev/null || true
    fi
    return 0
}

# Fonction pour vérifier si une plateforme est demandée
should_run_platform() {
    echo "$PLATFORMS" | grep -qi "$1"
}

# Fonction cleanup optimisée
cleanup() {
    echo -e "\n${YELLOW}🛑 Arrêt...${NC}"
    # Ne pas tuer WEB_PID si c'est juste "web-opened" (navigateur ouvert)
    [ -n "${WEB_PID:-}" ] && [ "$WEB_PID" != "web-opened" ] && kill "$WEB_PID" 2>/dev/null || true
    [ -n "${ANDROID_PID:-}" ] && kill "$ANDROID_PID" 2>/dev/null || true
    [ -n "${MACOS_PID:-}" ] && kill "$MACOS_PID" 2>/dev/null || true
    pkill -f "flutter.*run" 2>/dev/null || true
    exit 0
}

trap cleanup SIGINT SIGTERM

# Mise à jour Git (rapide, non bloquant)
echo -e "${YELLOW}📥 Mise à jour Git...${NC}"
cd "$REPO_ROOT"
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
[ "$CURRENT_BRANCH" != "develop" ] && git checkout develop 2>/dev/null || true
git fetch origin develop 2>/dev/null &  # En arrière-plan
git pull origin develop 2>/dev/null || true
cd "$PROJECT_DIR"

# Nettoyage (seulement si nécessaire)
if [ "$SKIP_CLEAN" != "true" ]; then
    echo -e "${YELLOW}🧹 Nettoyage...${NC}"
    flutter clean > /dev/null 2>&1 || true
fi

# Pub get (seulement si nécessaire)
if needs_pub_get; then
    echo -e "${YELLOW}📦 Dépendances...${NC}"
    flutter pub get > /dev/null 2>&1 || exit 1
else
    echo -e "${CYAN}⏭️  Dépendances à jour${NC}"
fi

# Vérifier les devices (une seule fois, mis en cache)
echo -e "${YELLOW}📱 Devices...${NC}"
DEVICES=$(flutter devices 2>&1 || echo "")
WEB_DEVICE="web-server"
echo "$DEVICES" | grep -qi "chrome" && WEB_DEVICE="chrome"

# Variables PIDs
WEB_PID=""
WEB_URL=""
ANDROID_PID=""
MACOS_PID=""

# Lancer les plateformes en parallèle (sans attendre)
if should_run_platform "web"; then
    echo -e "${GREEN}🌐 Web${NC}"
    WEB_URL="https://arkalia-luna-system.github.io/arkalia-cia/"
    
    # Vérifier si la version web est à jour
    CURRENT_VERSION=$(grep "^version:" "$PROJECT_DIR/pubspec.yaml" | sed 's/version: //' | cut -d'+' -f1 | tr -d ' ')
    echo -e "${CYAN}   Version actuelle: $CURRENT_VERSION${NC}"
    
    # Vérifier la dernière version déployée (optionnel, non bloquant)
    LAST_DEPLOY=$(cd "$REPO_ROOT" && git log --oneline --all --grep="Deploy PWA" -1 2>/dev/null | head -1 || echo "")
    if [ -n "$LAST_DEPLOY" ]; then
        DEPLOY_DATE=$(echo "$LAST_DEPLOY" | grep -oE "[0-9]+ [A-Za-z]+ [0-9]+" || echo "inconnue")
        echo -e "${YELLOW}   ⚠️  Dernier déploiement: $DEPLOY_DATE${NC}"
        echo -e "${YELLOW}   💡 La version web peut ne pas être à jour${NC}"
        echo -e "${CYAN}   Pour mettre à jour: bash scripts/deploy_pwa_github_pages.sh${NC}"
    fi
    
    # Ouvrir l'URL de production dans le navigateur
    if command -v open &> /dev/null; then
        # macOS
        open "$WEB_URL" > /dev/null 2>&1
        WEB_PID="web-opened"  # Marqueur pour indiquer que l'URL est ouverte
    elif command -v xdg-open &> /dev/null; then
        # Linux
        xdg-open "$WEB_URL" > /dev/null 2>&1
        WEB_PID="web-opened"
    else
        # Fallback : essayer de lancer un serveur local si l'URL ne fonctionne pas
        echo -e "${YELLOW}   ⚠️  Ouvrez manuellement: $WEB_URL${NC}"
        (
            cd "$PROJECT_DIR"
            flutter run -d "$WEB_DEVICE" --web-port=8080 > "$LOG_DIR/arkalia_web.log" 2>&1
        ) &
        WEB_PID=$!
        WEB_URL="http://localhost:8080"
    fi
    echo -e "   ${CYAN}→ $WEB_URL${NC}"
fi

if should_run_platform "android" && echo "$DEVICES" | grep -qi "android\|mobile"; then
    echo -e "${GREEN}📱 Android${NC}"
    (
        cd "$PROJECT_DIR"
        bash scripts/run-android.sh > "$LOG_DIR/arkalia_android.log" 2>&1
    ) &
    ANDROID_PID=$!
    echo -e "   ${CYAN}→ En cours...${NC} (PID: $ANDROID_PID)"
elif should_run_platform "android"; then
    echo -e "${YELLOW}⚠️  Android non disponible${NC}"
fi

if should_run_platform "macos" && echo "$DEVICES" | grep -qi "macos"; then
    echo -e "${GREEN}🍎 macOS${NC}"
    (
        cd "$PROJECT_DIR"
        # Attendre un peu avant de lancer pour éviter les conflits
        sleep 2
        # Lancer avec gestion d'erreurs améliorée
        flutter run -d macos > "$LOG_DIR/arkalia_macos.log" 2>&1 || {
            echo "Erreur lors du lancement macOS" >> "$LOG_DIR/arkalia_macos.log"
            exit 1
        }
    ) &
    MACOS_PID=$!
    echo -e "   ${CYAN}→ En cours...${NC} (PID: $MACOS_PID)"
    # Vérifier rapidement si le processus démarre correctement
    sleep 3
    if ! kill -0 "$MACOS_PID" 2>/dev/null; then
        echo -e "${YELLOW}   ⚠️  macOS semble avoir des problèmes au démarrage${NC}"
        echo -e "${CYAN}   Vérifiez les logs: $LOG_DIR/arkalia_macos.log${NC}"
        # Afficher les dernières lignes du log pour debug
        if [ -f "$LOG_DIR/arkalia_macos.log" ]; then
            echo -e "${YELLOW}   Dernières lignes:${NC}"
            tail -10 "$LOG_DIR/arkalia_macos.log" 2>/dev/null | sed 's/^/   /' || true
        fi
    fi
elif should_run_platform "macos"; then
    echo -e "${YELLOW}⚠️  macOS non disponible${NC}"
fi

# Vérifier qu'au moins une plateforme a été lancée
[ -z "$WEB_PID" ] && [ -z "$ANDROID_PID" ] && [ -z "$MACOS_PID" ] && {
    echo -e "${RED}❌ Aucune plateforme lancée${NC}"
    exit 1
}

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Plateformes lancées en parallèle${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}📋 Logs: $LOG_DIR/arkalia_*.log${NC}"
echo -e "${CYAN}🛑 Arrêt: Ctrl+C${NC}"
echo ""

# Fonction de monitoring ultra-légère (vérifie seulement l'état, pas les logs)
monitor_lightweight() {
    local check_count=0
    while true; do
        local any_running=false
        check_count=$((check_count + 1))
        
        # Vérifier Web
        if [ -n "$WEB_PID" ]; then
            # Si WEB_PID est "web-opened", c'est que l'URL est ouverte dans le navigateur
            # On considère qu'elle reste accessible
            if [ "$WEB_PID" = "web-opened" ]; then
                any_running=true
                [ $((check_count % 10)) -eq 0 ] && printf "."
            elif kill -0 "$WEB_PID" 2>/dev/null; then
                # Processus Flutter run local encore actif
                any_running=true
                [ $((check_count % 10)) -eq 0 ] && printf "."
            else
                echo -e "\n${RED}❌ Web arrêté${NC}"
                WEB_PID=""
            fi
        fi
        
        # Vérifier Android
        if [ -n "$ANDROID_PID" ]; then
            if kill -0 "$ANDROID_PID" 2>/dev/null; then
                any_running=true
            else
                echo -e "\n${RED}❌ Android arrêté${NC}"
                ANDROID_PID=""
            fi
        fi
        
        # Vérifier macOS
        if [ -n "$MACOS_PID" ]; then
            if kill -0 "$MACOS_PID" 2>/dev/null; then
                any_running=true
            else
                echo -e "\n${RED}❌ macOS arrêté${NC}"
                MACOS_PID=""
            fi
        fi
        
        [ "$any_running" = "false" ] && break
        sleep 5  # Vérification toutes les 5s (économie RAM/CPU)
    done
    echo ""  # Nouvelle ligne après les points
}

# Limiter la taille des logs en arrière-plan (pour économiser la RAM)
limit_logs() {
    while true; do
        sleep 30  # Vérifier toutes les 30s
        for log in "$LOG_DIR"/arkalia_*.log; do
            [ -f "$log" ] && [ -s "$log" ] || continue
            local size_mb=$(du -m "$log" 2>/dev/null | cut -f1 || echo "0")
            [ "$size_mb" -gt "$MAX_LOG_SIZE_MB" ] && {
                # Garder seulement les dernières 1000 lignes
                tail -1000 "$log" > "${log}.tmp" 2>/dev/null && mv "${log}.tmp" "$log" 2>/dev/null || true
            }
        done
    done
}

# Démarrer le limiteur de logs en arrière-plan
limit_logs &
LIMIT_LOGS_PID=$!

# Attendre les processus avec monitoring léger
monitor_lightweight

# Nettoyer le limiteur de logs
kill "$LIMIT_LOGS_PID" 2>/dev/null || true

# Attendre explicitement les PIDs restants
[ -n "$WEB_PID" ] && [ "$WEB_PID" != "web-opened" ] && wait "$WEB_PID" 2>/dev/null || true
[ -n "$ANDROID_PID" ] && wait "$ANDROID_PID" 2>/dev/null || true
[ -n "$MACOS_PID" ] && wait "$MACOS_PID" 2>/dev/null || true

echo -e "${GREEN}✅ Terminé${NC}"
