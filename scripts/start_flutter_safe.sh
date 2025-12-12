#!/bin/bash
# Script de démarrage sécurisé pour Arkalia CIA Flutter (évite les doublons)
# Version optimisée - utilise les fonctions communes

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Charger les fonctions communes si disponibles
if [ -f "$SCRIPT_DIR/common_functions.sh" ]; then
    source "$SCRIPT_DIR/common_functions.sh"
fi

LOCK_FILE="/tmp/arkalia_flutter.lock"
WEB_PORT=8080

# Fonction de nettoyage
cleanup() {
    echo ""
    echo "🛑 Arrêt de Flutter..."
    cleanup_lock "$LOCK_FILE"
    exit 0
}

# Gérer les signaux pour nettoyer proprement
trap cleanup SIGINT SIGTERM

# Vérifier si Flutter tourne déjà (utilise fonction commune si disponible)
if command -v check_process_running >/dev/null 2>&1; then
    check_process_running "$LOCK_FILE" "Flutter" || exit 1
else
    # Fallback
    if [ -f "$LOCK_FILE" ]; then
        PID=$(cat "$LOCK_FILE" 2>/dev/null || echo "")
        if [ -n "$PID" ] && ps -p "$PID" > /dev/null 2>&1; then
            echo "⚠️  Flutter tourne déjà (PID: $PID)"
            echo "   Utilisez './cleanup_all.sh' pour l'arrêter"
            exit 1
        else
            rm -f "$LOCK_FILE"
        fi
    fi
fi

# Vérifier si le port est déjà utilisé (utilise fonction commune si disponible)
if command -v check_port >/dev/null 2>&1; then
    if ! check_port "$WEB_PORT"; then
        echo "⚠️  Le port $WEB_PORT est déjà utilisé"
        echo "   Utilisez './cleanup_all.sh' pour nettoyer les processus"
        exit 1
    fi
else
    # Fallback
    if lsof -Pi :$WEB_PORT -sTCP:LISTEN -t >/dev/null 2>&1 ; then
        echo "⚠️  Le port $WEB_PORT est déjà utilisé"
        echo "   Utilisez './cleanup_all.sh' pour nettoyer les processus"
        exit 1
    fi
fi

echo "📱 Démarrage d'Arkalia CIA Flutter..."
echo ""

# Aller dans le dossier Flutter
if [ ! -d "$SCRIPT_DIR/arkalia_cia" ]; then
    echo "❌ Erreur: Le dossier arkalia_cia n'existe pas"
    exit 1
fi
cd "$SCRIPT_DIR/arkalia_cia"

# Vérifier que Flutter est installé
if ! command -v flutter >/dev/null 2>&1; then
    echo "❌ Flutter n'est pas installé"
    exit 1
fi

# Installer les dépendances
echo "📦 Installation des dépendances..."
flutter pub get

# Créer le lock file avec le PID (utilise fonction commune si disponible)
if command -v create_lock_file >/dev/null 2>&1; then
    create_lock_file "$LOCK_FILE"
else
    echo $$ > "$LOCK_FILE"
fi

# Démarrer l'application
echo "🚀 Démarrage de l'application Flutter..."
echo "   PID: $$"
echo "   Lock file: $LOCK_FILE"
echo ""
echo "   Pour arrêter: Ctrl+C ou './cleanup_all.sh'"
echo ""

flutter run -d chrome --web-port=$WEB_PORT

# Nettoyage à la fin
cleanup

