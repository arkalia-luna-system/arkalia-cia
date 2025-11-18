#!/bin/bash
# Script wrapper pour lancer pytest proprement sans doublons

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "🧹 Nettoyage des processus pytest existants..."

# Fonction pour arrêter proprement les processus
cleanup_processes() {
    local pattern="$1"
    local max_attempts=5
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        # Trouver les PIDs
        local pids=$(ps aux | grep -E "$pattern" | grep -v grep | awk '{print $2}' | tr '\n' ' ')
        
        if [ -z "$pids" ]; then
            return 0
        fi
        
        if [ $attempt -eq 1 ]; then
            # Essayer d'abord un arrêt propre
            echo "$pids" | xargs kill 2>/dev/null || true
        else
            # Puis forcer l'arrêt
            echo "$pids" | xargs kill -9 2>/dev/null || true
        fi
        
        sleep 1
        attempt=$((attempt + 1))
    done
    
    # Dernière vérification
    local remaining=$(ps aux | grep -E "$pattern" | grep -v grep | wc -l | tr -d ' ')
    if [ "$remaining" -gt 0 ]; then
        echo "⚠️  Il reste $remaining processus, arrêt forcé..."
        ps aux | grep -E "$pattern" | grep -v grep | awk '{print $2}' | xargs kill -9 2>/dev/null || true
        sleep 1
    fi
}

# Arrêter tous les processus pytest et coverage
cleanup_processes "pytest"
cleanup_processes "coverage.*pytest"
cleanup_processes "coverage run"

# Nettoyer les fichiers de lock pytest
if [ -d ".pytest_cache" ]; then
    rm -rf .pytest_cache
    echo "✅ Cache pytest nettoyé"
fi

# Nettoyer le fichier .coverage s'il existe (mais le garder si on fait de la couverture)
if [ -f ".coverage" ] && [[ ! "$*" =~ "--cov" ]]; then
    rm -f .coverage
    echo "✅ Fichier .coverage nettoyé"
fi

# Vérification finale
remaining=$(ps aux | grep -E "pytest|coverage.*pytest" | grep -v grep | wc -l | tr -d ' ')
if [ "$remaining" -gt 0 ]; then
    echo "❌ ERREUR: Il reste $remaining processus pytest actifs!"
    ps aux | grep -E "pytest|coverage" | grep -v grep
    exit 1
fi

echo "✅ Environnement nettoyé, lancement des tests..."
echo ""

# Si aucun argument n'est fourni, utiliser les valeurs par défaut
if [ $# -eq 0 ]; then
    echo "ℹ️  Aucun argument fourni, utilisation des valeurs par défaut: tests/ -v"
    exec python3 -m pytest tests/ -v
else
    # Lancer pytest avec les arguments passés
    exec python3 -m pytest "$@"
fi

