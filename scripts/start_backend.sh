#!/bin/bash
# Script pour démarrer le backend Arkalia CIA
# Utilise toujours le bon environnement virtuel
# Vérifie les processus en double avant de démarrer

set -e

# Couleurs pour les messages
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Chemin du projet
PROJECT_ROOT="/Volumes/T7/arkalia-cia"
VENV_PATH="/Volumes/T7/arkalia-luna-venv"
BACKEND_DIR="${PROJECT_ROOT}/arkalia_cia_python_backend"
LOCK_FILE="/tmp/arkalia_backend.lock"
PORT=8000

# Fonction de nettoyage
cleanup() {
    echo ""
    echo -e "${YELLOW}🛑 Arrêt du serveur...${NC}"
    rm -f "$LOCK_FILE"
    exit 0
}

# Gérer les signaux pour nettoyer proprement
trap cleanup SIGINT SIGTERM

# Vérifier si le serveur tourne déjà
if [ -f "$LOCK_FILE" ]; then
    PID=$(cat "$LOCK_FILE" 2>/dev/null || echo "")
    if [ -n "$PID" ] && ps -p "$PID" > /dev/null 2>&1; then
        echo -e "${RED}⚠️  Le serveur backend tourne déjà (PID: $PID)${NC}"
        echo -e "${YELLOW}   Utilisez './scripts/cleanup_all.sh' pour l'arrêter${NC}"
        exit 1
    else
        rm -f "$LOCK_FILE"
    fi
fi

# Vérifier si le port est déjà utilisé
if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null 2>&1 ; then
    echo -e "${RED}⚠️  Le port $PORT est déjà utilisé${NC}"
    echo -e "${YELLOW}   Utilisez './scripts/cleanup_all.sh' pour nettoyer les processus${NC}"
    exit 1
fi

# Vérifier s'il y a déjà un processus uvicorn/api.py qui tourne
if ps aux | grep -E "uvicorn.*api:app|python.*api\.py" | grep -v grep > /dev/null 2>&1; then
    echo -e "${RED}⚠️  Un processus backend est déjà en cours d'exécution${NC}"
    echo -e "${YELLOW}   Utilisez './scripts/cleanup_all.sh' pour l'arrêter${NC}"
    ps aux | grep -E "uvicorn.*api:app|python.*api\.py" | grep -v grep | head -2
    exit 1
fi

echo -e "${BLUE}🚀 Démarrage du backend Arkalia CIA${NC}"
echo ""

# Vérifier que le venv existe
if [ ! -d "$VENV_PATH" ]; then
    echo -e "${YELLOW}⚠️  Le venv n'existe pas à $VENV_PATH${NC}"
    exit 1
fi

# Activer le venv
echo -e "${GREEN}✅ Activation du venv: $VENV_PATH${NC}"
source "${VENV_PATH}/bin/activate"

# Vérifier que Python est bien celui du venv
PYTHON_PATH=$(which python)
if [[ ! "$PYTHON_PATH" == *"arkalia-luna-venv"* ]]; then
    echo -e "${YELLOW}⚠️  Attention: Python n'est pas dans le bon venv${NC}"
    echo "Python actuel: $PYTHON_PATH"
    exit 1
fi

echo -e "${GREEN}✅ Python: $PYTHON_PATH${NC}"
echo -e "${GREEN}✅ Version: $(python --version)${NC}"
echo ""

# Aller dans le répertoire backend
cd "$BACKEND_DIR"

# Vérifier que le package est installé
echo -e "${BLUE}📦 Vérification des dépendances...${NC}"
python -c "from arkalia_cia_python_backend.app_types import DocumentMetadataDict" 2>/dev/null || {
    echo -e "${YELLOW}⚠️  Installation du package en mode développement...${NC}"
    cd "$PROJECT_ROOT"
    pip install -e . > /dev/null 2>&1
    cd "$BACKEND_DIR"
}

# Créer le lock file
echo $$ > "$LOCK_FILE"

# Démarrer le serveur
echo ""
echo -e "${GREEN}🌟 Démarrage du serveur sur http://0.0.0.0:8000${NC}"
echo -e "${BLUE}📱 Accessible depuis iPad à: http://192.168.129.35:8000${NC}"
echo -e "${YELLOW}💡 Appuyez sur Ctrl+C pour arrêter${NC}"
echo ""

python -m uvicorn api:app --host 0.0.0.0 --port 8000
