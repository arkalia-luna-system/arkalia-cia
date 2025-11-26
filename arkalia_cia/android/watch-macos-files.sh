#!/bin/bash
# Script qui surveille et supprime les fichiers macOS cachés en continu pendant le build
# Version améliorée avec lock file et signal d'arrêt propre

# Obtenir le répertoire du projet dynamiquement
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$(cd "$PROJECT_DIR/.." && pwd)"
LOCK_FILE="/tmp/watch-macos-files.lock"

# Fonction de nettoyage
cleanup() {
    echo ""
    echo "🛑 Arrêt de watch-macos-files..."
    rm -f "$LOCK_FILE"
    exit 0
}

# Gérer les signaux pour nettoyer proprement
trap cleanup SIGINT SIGTERM

# Vérifier si le script tourne déjà
if [ -f "$LOCK_FILE" ]; then
    PID=$(cat "$LOCK_FILE" 2>/dev/null || echo "")
    if [ -n "$PID" ] && ps -p "$PID" > /dev/null 2>&1; then
        echo "⚠️  watch-macos-files tourne déjà (PID: $PID)"
        echo "   Utilisez './cleanup_all.sh' pour l'arrêter"
        exit 1
    else
        # Lock file orphelin, le supprimer
        rm -f "$LOCK_FILE"
    fi
fi

# Créer le lock file avec le PID
echo $$ > "$LOCK_FILE"

# Fonction pour supprimer les fichiers macOS cachés
clean_macos_files() {
    # Nettoyer dans build/ (récursif et agressif)
    if [ -d "$PROJECT_DIR/build" ]; then
        find "$PROJECT_DIR/build" -type f \( -name "._*" -o -name ".!*!._*" -o -name ".DS_Store" \) -delete 2>/dev/null || true
        # Nettoyer spécifiquement dans intermediates (où le problème se produit)
        if [ -d "$PROJECT_DIR/build/app/intermediates" ]; then
            find "$PROJECT_DIR/build/app/intermediates" -type f \( -name "._*" -o -name ".!*!._*" \) -delete 2>/dev/null || true
        fi
    fi
    
    # Nettoyer aussi dans android/.gradle
    if [ -d "$SCRIPT_DIR/.gradle" ]; then
        find "$SCRIPT_DIR/.gradle" -type f \( -name "._*" -o -name ".DS_Store" \) -delete 2>/dev/null || true
    fi
}

echo "👀 Surveillance des fichiers macOS (PID: $$)"
echo "   Pour arrêter: Ctrl+C ou './cleanup_all.sh'"
echo ""

# Surveiller en continu (toutes les 0.5 secondes pendant le build pour être plus réactif)
# Plus rapide pendant le build pour éviter les erreurs AAPT
while [ -f "$LOCK_FILE" ]; do
    clean_macos_files
    sleep 0.5
done

# Nettoyage à la fin
cleanup

