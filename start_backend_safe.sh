#!/bin/bash
# Script de démarrage sécurisé pour Arkalia CIA Backend (évite les doublons)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

LOCK_FILE="/tmp/arkalia_backend.lock"
PORT=8000

# Fonction de nettoyage
cleanup() {
    echo ""
    echo "🛑 Arrêt du serveur..."
    rm -f "$LOCK_FILE"
    exit 0
}

# Gérer les signaux pour nettoyer proprement
trap cleanup SIGINT SIGTERM

# Vérifier si le serveur tourne déjà
if [ -f "$LOCK_FILE" ]; then
    PID=$(cat "$LOCK_FILE" 2>/dev/null || echo "")
    if [ -n "$PID" ] && ps -p "$PID" > /dev/null 2>&1; then
        echo "⚠️  Le serveur backend tourne déjà (PID: $PID)"
        echo "   Utilisez './cleanup_all.sh' pour l'arrêter"
        exit 1
    else
        # Lock file orphelin, le supprimer
        rm -f "$LOCK_FILE"
    fi
fi

# Vérifier si le port est déjà utilisé
if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null 2>&1 ; then
    echo "⚠️  Le port $PORT est déjà utilisé"
    echo "   Utilisez './cleanup_all.sh' pour nettoyer les processus"
    exit 1
fi

echo "🚀 Démarrage d'Arkalia CIA Backend..."
echo ""

# Aller dans le dossier backend
cd "$SCRIPT_DIR/arkalia_cia_python_backend"

# Activer l'environnement virtuel
if [ -f "../arkalia_cia_venv/bin/activate" ]; then
    source ../arkalia_cia_venv/bin/activate
else
    echo "⚠️  Environnement virtuel non trouvé, utilisation de python3 système"
fi

# Créer le lock file avec le PID
echo $$ > "$LOCK_FILE"

# Démarrer l'API
echo "📡 Démarrage de l'API FastAPI sur http://localhost:$PORT"
echo "   PID: $$"
echo "   Lock file: $LOCK_FILE"
echo ""
echo "   Pour arrêter: Ctrl+C ou './cleanup_all.sh'"
echo ""

python api.py

# Nettoyage à la fin
cleanup

