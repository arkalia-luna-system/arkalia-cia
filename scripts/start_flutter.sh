#!/bin/bash
# Script pour démarrer l'app Flutter
# Vérifie les processus en double avant de démarrer

set -e

# Couleurs pour les messages
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

LOCK_FILE="/tmp/arkalia_flutter.lock"
WEB_PORT=8080

# Fonction de nettoyage
cleanup() {
    echo ""
    echo -e "${YELLOW}🛑 Arrêt de Flutter...${NC}"
    rm -f "$LOCK_FILE"
    exit 0
}

# Gérer les signaux pour nettoyer proprement
trap cleanup SIGINT SIGTERM

# Vérifier si Flutter tourne déjà
if [ -f "$LOCK_FILE" ]; then
    PID=$(cat "$LOCK_FILE" 2>/dev/null || echo "")
    if [ -n "$PID" ] && ps -p "$PID" > /dev/null 2>&1; then
        echo -e "${RED}⚠️  Flutter tourne déjà (PID: $PID)${NC}"
        echo -e "${YELLOW}   Utilisez './scripts/cleanup_all.sh' pour l'arrêter${NC}"
        exit 1
    else
        rm -f "$LOCK_FILE"
    fi
fi

# Vérifier si le port est déjà utilisé
if lsof -Pi :$WEB_PORT -sTCP:LISTEN -t >/dev/null 2>&1 ; then
    echo -e "${RED}⚠️  Le port $WEB_PORT est déjà utilisé${NC}"
    echo -e "${YELLOW}   Utilisez './scripts/cleanup_all.sh' pour nettoyer les processus${NC}"
    exit 1
fi

# Vérifier s'il y a déjà un processus Flutter qui tourne
if ps aux | grep -E "flutter.*run|dart.*flutter" | grep -v grep > /dev/null 2>&1; then
    echo -e "${RED}⚠️  Un processus Flutter est déjà en cours d'exécution${NC}"
    echo -e "${YELLOW}   Utilisez './scripts/cleanup_all.sh' pour l'arrêter${NC}"
    ps aux | grep -E "flutter.*run|dart.*flutter" | grep -v grep | head -2
    exit 1
fi

# Script de démarrage pour Arkalia CIA Flutter
echo -e "${GREEN}📱 Démarrage d'Arkalia CIA Flutter...${NC}"

# Aller dans le dossier Flutter
cd /Volumes/T7/arkalia-cia/arkalia_cia

# Créer le lock file
echo $$ > "$LOCK_FILE"

# Installer les dépendances
echo -e "${GREEN}📦 Installation des dépendances...${NC}"
flutter pub get

# Démarrer l'application
echo -e "${GREEN}🚀 Démarrage de l'application Flutter...${NC}"
flutter run -d chrome --web-port=8080
