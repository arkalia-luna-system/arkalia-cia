#!/bin/bash
# Script de démarrage sécurisé pour Arkalia CIA Flutter (évite les doublons)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

LOCK_FILE="/tmp/arkalia_flutter.lock"
WEB_PORT=8080

# Fonction de nettoyage
cleanup() {
    echo ""
    echo "🛑 Arrêt de Flutter..."
    rm -f "$LOCK_FILE"
    exit 0
}

# Gérer les signaux pour nettoyer proprement
trap cleanup SIGINT SIGTERM

# Vérifier si Flutter tourne déjà
if [ -f "$LOCK_FILE" ]; then
    PID=$(cat "$LOCK_FILE" 2>/dev/null || echo "")
    if [ -n "$PID" ] && ps -p "$PID" > /dev/null 2>&1; then
        echo "⚠️  Flutter tourne déjà (PID: $PID)"
        echo "   Utilisez './cleanup_all.sh' pour l'arrêter"
        exit 1
    else
        # Lock file orphelin, le supprimer
        rm -f "$LOCK_FILE"
    fi
fi

# Vérifier si le port est déjà utilisé (si on utilise web)
if lsof -Pi :$WEB_PORT -sTCP:LISTEN -t >/dev/null 2>&1 ; then
    echo "⚠️  Le port $WEB_PORT est déjà utilisé"
    echo "   Utilisez './cleanup_all.sh' pour nettoyer les processus"
    exit 1
fi

echo "📱 Démarrage d'Arkalia CIA Flutter..."
echo ""

# Aller dans le dossier Flutter
cd "$SCRIPT_DIR/arkalia_cia"

# Vérifier que Flutter est installé
if ! command -v flutter >/dev/null 2>&1; then
    echo "❌ Flutter n'est pas installé"
    exit 1
fi

# Installer les dépendances
echo "📦 Installation des dépendances..."
flutter pub get

# Créer le lock file avec le PID
echo $$ > "$LOCK_FILE"

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

