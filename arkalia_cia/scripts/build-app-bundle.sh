#!/bin/bash
# Script wrapper pour build-release-clean.sh qui affiche le chemin absolu

set -e

# Obtenir le répertoire du script
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# Remonter d'un niveau pour aller dans arkalia_cia/
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Utiliser le script existant build-release-clean.sh
BUILD_SCRIPT="$SCRIPT_DIR/build-release-clean.sh"

if [ ! -f "$BUILD_SCRIPT" ]; then
    echo "❌ Erreur: Script build-release-clean.sh non trouvé"
    exit 1
fi

# Exécuter le script existant
chmod +x "$BUILD_SCRIPT"
"$BUILD_SCRIPT"

# Afficher le chemin absolu après le build
BUNDLE_PATH="$PROJECT_DIR/build/app/outputs/bundle/release/app-release.aab"

if [ -f "$BUNDLE_PATH" ]; then
    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo "📁 CHEMIN ABSOLU DU FICHIER :"
    echo "   $BUNDLE_PATH"
    echo "═══════════════════════════════════════════════════════════"
    echo ""
    # Ouvrir le Finder sur macOS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "🔍 Ouverture du Finder..."
        open -R "$BUNDLE_PATH"
    fi
fi

