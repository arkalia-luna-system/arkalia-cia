#!/bin/bash
# Script pour nettoyer les processus Python qui consomment trop de mémoire
# Version optimisée - utilise cleanup_all.sh en interne

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "🧹 Nettoyage des processus Python gourmands..."
echo ""

# Utiliser cleanup_all.sh pour pytest et bandit (plus efficace)
"$SCRIPT_DIR/cleanup_all.sh" --keep-coverage 2>/dev/null || {
    # Fallback si cleanup_all.sh n'existe pas
    pkill -9 -f "bandit" 2>/dev/null
    pkill -9 -f "pytest" 2>/dev/null
    pkill -9 -f "coverage.*pytest" 2>/dev/null
}

# Libérer le cache système si possible (macOS)
if command -v purge &> /dev/null; then
    echo ""
    echo "💾 Libération du cache système..."
    sudo purge 2>/dev/null || echo "⚠️  Nécessite les droits sudo pour purge"
fi

# Libérer la mémoire Python si possible
if command -v python3 &> /dev/null; then
    python3 -c "import gc; gc.collect(); print('✅ Mémoire Python libérée')" 2>/dev/null || true
fi

echo ""
echo "✅ Nettoyage terminé"
echo ""
echo "💡 Pour un nettoyage complet, utilisez: ./cleanup_all.sh"

