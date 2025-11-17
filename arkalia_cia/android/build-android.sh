#!/bin/bash
# Script wrapper pour forcer Gradle à utiliser ~/.gradle
# Utilisez ce script au lieu de flutter build directement

set -e

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🔧 Configuration Gradle pour build Android${NC}"

# Forcer les variables d'environnement Gradle
export GRADLE_USER_HOME="$HOME/.gradle"
export GRADLE_OPTS="-Dorg.gradle.user.home=$HOME/.gradle -Duser.home=$HOME"

# Arrêter tous les daemons Gradle existants
echo -e "${YELLOW}🛑 Arrêt des daemons Gradle existants...${NC}"
cd "$(dirname "$0")"
./gradlew --stop 2>/dev/null || true

# Attendre un peu pour que les daemons se terminent
sleep 2

# Vérifier que le répertoire .gradle existe
if [ ! -d "$HOME/.gradle" ]; then
    echo -e "${YELLOW}📁 Création du répertoire $HOME/.gradle${NC}"
    mkdir -p "$HOME/.gradle"
fi

# Afficher les variables d'environnement
echo -e "${GREEN}✅ Variables d'environnement:${NC}"
echo "   GRADLE_USER_HOME=$GRADLE_USER_HOME"
echo "   GRADLE_OPTS=$GRADLE_OPTS"
echo "   HOME=$HOME"

# Obtenir le répertoire du script (android/)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Retourner au répertoire du projet Flutter (arkalia_cia/)
# Le script est dans arkalia_cia/android/, donc on remonte d'un niveau
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Vérifier que nous sommes dans le bon répertoire (doit contenir pubspec.yaml)
if [ ! -f "$PROJECT_DIR/pubspec.yaml" ]; then
    echo -e "${RED}❌ Erreur: Impossible de trouver le répertoire du projet Flutter${NC}"
    echo "   SCRIPT_DIR: $SCRIPT_DIR"
    echo "   PROJECT_DIR: $PROJECT_DIR"
    exit 1
fi

# Aller dans le répertoire du projet Flutter
cd "$PROJECT_DIR"

# Nettoyer les fichiers macOS cachés juste avant le build
echo -e "${YELLOW}🧹 Nettoyage des fichiers macOS avant build...${NC}"

# Utiliser le script de prévention si disponible
PREVENT_SCRIPT="$SCRIPT_DIR/prevent-macos-files.sh"
if [ -f "$PREVENT_SCRIPT" ]; then
    chmod +x "$PREVENT_SCRIPT"
    "$PREVENT_SCRIPT" || true
else
    # Fallback : nettoyage manuel
    find . -name "._*" -type f ! -path "./.git/*" -delete 2>/dev/null || true
    find . -name ".DS_Store" -type f ! -path "./.git/*" -delete 2>/dev/null || true
    find . -name ".AppleDouble" -type d ! -path "./.git/*" -exec rm -rf {} + 2>/dev/null || true
fi

# Lancer un script de surveillance en arrière-plan pour supprimer les fichiers pendant le build
WATCH_SCRIPT="$SCRIPT_DIR/watch-macos-files.sh"
if [ -f "$WATCH_SCRIPT" ]; then
    chmod +x "$WATCH_SCRIPT"
    "$WATCH_SCRIPT" &
    WATCH_PID=$!
    echo -e "${GREEN}✅ Surveillance des fichiers macOS activée (PID: $WATCH_PID)${NC}"
    # Tuer le processus de surveillance à la fin
    trap "kill $WATCH_PID 2>/dev/null" EXIT
fi

# Exécuter la commande Flutter passée en argument
echo -e "${GREEN}🚀 Lancement du build Flutter...${NC}"
echo ""

# Exécuter la commande Flutter avec les variables d'environnement forcées
# S'assurer que nous sommes dans le bon répertoire
cd "$PROJECT_DIR"

# Exécuter la commande passée en argument (ex: "flutter build apk --debug")
# avec les variables d'environnement forcées
env GRADLE_USER_HOME="$HOME/.gradle" \
    GRADLE_OPTS="-Dorg.gradle.user.home=$HOME/.gradle -Duser.home=$HOME" \
    "$@"

