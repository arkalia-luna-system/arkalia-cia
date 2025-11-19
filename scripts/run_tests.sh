#!/bin/bash
# Script wrapper pour lancer pytest proprement sans doublons
# Version optimisée - utilise cleanup_all.sh pour le nettoyage

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "🧹 Nettoyage des processus pytest existants..."

# Utiliser cleanup_all.sh pour nettoyer pytest (plus efficace et unifié)
# Mais seulement pytest/coverage, pas tout le reste
if [ -f "$SCRIPT_DIR/lib/common_functions.sh" ]; then
    source "$SCRIPT_DIR/lib/common_functions.sh"
    cleanup_processes "pytest|coverage.*pytest" "pytest/coverage" 5 false
else
    # Fallback rapide
    pkill -f "pytest" 2>/dev/null || true
    pkill -f "coverage.*pytest" 2>/dev/null || true
    sleep 1
fi

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

