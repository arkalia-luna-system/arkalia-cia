#!/bin/bash
# Script qui surveille et supprime les fichiers macOS cachés en continu pendant le build

# Obtenir le répertoire du projet dynamiquement
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$(cd "$PROJECT_DIR/.." && pwd)"

# Fonction pour supprimer les fichiers macOS cachés
clean_macos_files() {
    # Nettoyer dans build/
    if [ -d "$PROJECT_DIR/build" ]; then
        find "$PROJECT_DIR/build" -name "._*" -type f -delete 2>/dev/null || true
        find "$PROJECT_DIR/build" -name ".DS_Store" -type f -delete 2>/dev/null || true
    fi
    
    # Nettoyer aussi dans android/.gradle
    if [ -d "$SCRIPT_DIR/.gradle" ]; then
        find "$SCRIPT_DIR/.gradle" -name "._*" -type f -delete 2>/dev/null || true
        find "$SCRIPT_DIR/.gradle" -name ".DS_Store" -type f -delete 2>/dev/null || true
    fi
}

# Surveiller en continu (toutes les 0.5 secondes)
while true; do
    clean_macos_files
    sleep 0.5
done

