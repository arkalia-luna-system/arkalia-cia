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

# Retourner au répertoire du projet Flutter
cd "$(dirname "$0")/../.."

# Exécuter la commande Flutter passée en argument
echo -e "${GREEN}🚀 Lancement du build Flutter...${NC}"
echo ""

# Exécuter la commande avec les variables d'environnement forcées
exec env GRADLE_USER_HOME="$HOME/.gradle" \
         GRADLE_OPTS="-Dorg.gradle.user.home=$HOME/.gradle -Duser.home=$HOME" \
         "$@"

