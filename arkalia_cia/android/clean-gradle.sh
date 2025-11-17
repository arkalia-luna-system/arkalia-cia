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

# Nettoyer les fichiers macOS cachés qui causent des problèmes de build
echo -e "${YELLOW}🧹 Nettoyage des fichiers macOS cachés...${NC}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
# Aller à la racine du projet (depuis arkalia_cia/android -> arkalia_cia -> racine)
PROJECT_ROOT="$(cd "$PROJECT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

# Compter tous les fichiers macOS cachés dans TOUT le projet (y compris répertoires cachés)
echo -e "${YELLOW}🔍 Recherche approfondie des fichiers macOS cachés...${NC}"
FILES_COUNT=$(find . -name "._*" -type f 2>/dev/null | wc -l | tr -d ' ')
DS_COUNT=$(find . -name ".DS_Store" -type f 2>/dev/null | wc -l | tr -d ' ')

if [ "$FILES_COUNT" -gt 0 ] || [ "$DS_COUNT" -gt 0 ]; then
    echo -e "${YELLOW}📊 Trouvé $FILES_COUNT fichiers ._* et $DS_COUNT fichiers .DS_Store${NC}"
    
    # Supprimer dans tous les répertoires, y compris cachés
    # Ne pas supprimer dans .git pour éviter les problèmes
    find . -name "._*" -type f ! -path "./.git/*" -delete 2>/dev/null
    find . -name ".DS_Store" -type f ! -path "./.git/*" -delete 2>/dev/null
    
    # Nettoyer spécifiquement les répertoires problématiques
    echo -e "${YELLOW}🧹 Nettoyage des répertoires de build...${NC}"
    find . -type d \( -name "build" -o -name ".gradle" -o -name ".dart_tool" -o -name ".mypy_cache" -o -name ".pytest_cache" -o -name ".ruff_cache" \) -exec find {} -name "._*" -type f -delete \; 2>/dev/null
    
    # Vérifier le résultat
    REMAINING_FILES=$(find . -name "._*" -type f ! -path "./.git/*" 2>/dev/null | wc -l | tr -d ' ')
    REMAINING_DS=$(find . -name ".DS_Store" -type f ! -path "./.git/*" 2>/dev/null | wc -l | tr -d ' ')
    
    echo -e "${GREEN}✅ Supprimé $FILES_COUNT fichiers ._* et $DS_COUNT fichiers .DS_Store${NC}"
    if [ "$REMAINING_FILES" -gt 0 ] || [ "$REMAINING_DS" -gt 0 ]; then
        echo -e "${YELLOW}⚠️  Il reste $REMAINING_FILES fichiers ._* et $REMAINING_DS fichiers .DS_Store (peut-être dans .git)${NC}"
    fi
else
    echo -e "${GREEN}✅ Aucun fichier macOS caché trouvé${NC}"
fi

# Retourner dans le répertoire android
cd "$SCRIPT_DIR"

# Nettoyer le build local
echo -e "${YELLOW}🧹 Nettoyage du build local...${NC}"
./gradlew clean 2>/dev/null || true

# Nettoyer à nouveau les fichiers macOS qui peuvent être recréés pendant le build
echo -e "${YELLOW}🧹 Nettoyage final des fichiers macOS dans build...${NC}"
cd "$PROJECT_ROOT"
if [ -d "arkalia_cia/build" ]; then
    find arkalia_cia/build -name "._*" -type f -delete 2>/dev/null
    find arkalia_cia/build -name ".DS_Store" -type f -delete 2>/dev/null
    echo -e "${GREEN}✅ Nettoyage build terminé${NC}"
fi
cd "$SCRIPT_DIR"

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

