#!/bin/bash
# Script pour nettoyer complètement Gradle et forcer l'utilisation de ~/.gradle

set -e

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🧹 Nettoyage complet de Gradle${NC}"

# Aller dans le répertoire android
cd "$(dirname "$0")"

# Arrêter tous les daemons Gradle
echo -e "${YELLOW}🛑 Arrêt de tous les daemons Gradle...${NC}"
./gradlew --stop 2>/dev/null || true

# Attendre que les processus se terminent
sleep 3

# Tuer tous les processus Java/Gradle restants (optionnel, à utiliser avec précaution)
echo -e "${YELLOW}🔍 Recherche de processus Gradle restants...${NC}"
pkill -f "gradle.*daemon" 2>/dev/null || true

# Supprimer le cache Gradle problématique sur le volume externe
if [ -d "/Volumes/T7/gradle" ]; then
    echo -e "${RED}🗑️  Suppression du cache Gradle problématique: /Volumes/T7/gradle${NC}"
    rm -rf "/Volumes/T7/gradle" || {
        echo -e "${RED}⚠️  Impossible de supprimer /Volumes/T7/gradle (peut nécessiter sudo)${NC}"
    }
fi

# Nettoyer le cache local Gradle (optionnel - décommentez si nécessaire)
# echo -e "${YELLOW}🧹 Nettoyage du cache local Gradle...${NC}"
# rm -rf "$HOME/.gradle/caches" || true

# Nettoyer le build local
echo -e "${YELLOW}🧹 Nettoyage du build local...${NC}"
./gradlew clean 2>/dev/null || true

# Créer le répertoire .gradle correct s'il n'existe pas
if [ ! -d "$HOME/.gradle" ]; then
    echo -e "${GREEN}📁 Création du répertoire $HOME/.gradle${NC}"
    mkdir -p "$HOME/.gradle"
fi

echo -e "${GREEN}✅ Nettoyage terminé!${NC}"
echo ""
echo -e "${GREEN}📋 Prochaines étapes:${NC}"
echo "   1. Vérifiez que les variables d'environnement sont correctes:"
echo "      export GRADLE_USER_HOME=\$HOME/.gradle"
echo "      export GRADLE_OPTS=\"-Dorg.gradle.user.home=\$HOME/.gradle -Duser.home=\$HOME\""
echo ""
echo "   2. Utilisez le script build-android.sh pour vos builds:"
echo "      ./build-android.sh flutter build apk"
echo ""
echo "   3. Ou utilisez directement gradlew avec les variables:"
echo "      GRADLE_USER_HOME=\$HOME/.gradle ./gradlew build"

