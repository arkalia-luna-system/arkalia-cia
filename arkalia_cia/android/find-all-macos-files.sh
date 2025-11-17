#!/bin/bash
# Script ULTRA-COMPLET pour trouver TOUS les fichiers macOS cachés
# Cherche dans TOUS les répertoires, y compris les répertoires cachés et .gradle

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$(cd "$PROJECT_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

echo -e "${BLUE}🔍 Recherche ULTRA-COMPLÈTE des fichiers macOS cachés...${NC}"
echo ""

# Compter tous les fichiers (y compris dans .gradle mais pas dans .git)
FILES_COUNT=$(find . -name "._*" -type f ! -path "./.git/*" ! -path "./.git" 2>/dev/null | wc -l | tr -d ' ')
DS_COUNT=$(find . -name ".DS_Store" -type f ! -path "./.git/*" ! -path "./.git" 2>/dev/null | wc -l | tr -d ' ')
APPLE_DOUBLE_COUNT=$(find . -name ".AppleDouble" -type d ! -path "./.git/*" ! -path "./.git" 2>/dev/null | wc -l | tr -d ' ')
SPOTLIGHT_COUNT=$(find . -name ".Spotlight-V100" -type d ! -path "./.git/*" ! -path "./.git" 2>/dev/null | wc -l | tr -d ' ')
TRASHES_COUNT=$(find . -name ".Trashes" -type d ! -path "./.git/*" ! -path "./.git" 2>/dev/null | wc -l | tr -d ' ')

# Compter par répertoire pour identifier les zones problématiques
GRADLE_COUNT=$(find . -path "*/.gradle/*" -name "._*" -type f 2>/dev/null | wc -l | tr -d ' ')
BUILD_COUNT=$(find . -path "*/build/*" -name "._*" -type f 2>/dev/null | wc -l | tr -d ' ')
DART_TOOL_COUNT=$(find . -path "*/.dart_tool/*" -name "._*" -type f 2>/dev/null | wc -l | tr -d ' ')

echo -e "${YELLOW}📊 Résultats de la recherche :${NC}"
echo "   Fichiers ._* : $FILES_COUNT"
echo "   Fichiers .DS_Store : $DS_COUNT"
echo "   Répertoires .AppleDouble : $APPLE_DOUBLE_COUNT"
echo "   Répertoires .Spotlight-V100 : $SPOTLIGHT_COUNT"
echo "   Répertoires .Trashes : $TRASHES_COUNT"
echo ""
echo -e "${YELLOW}📁 Répartition par répertoire :${NC}"
echo "   Dans .gradle : $GRADLE_COUNT"
echo "   Dans build : $BUILD_COUNT"
echo "   Dans .dart_tool : $DART_TOOL_COUNT"
echo ""

if [ "$FILES_COUNT" -gt 0 ] || [ "$DS_COUNT" -gt 0 ] || [ "$APPLE_DOUBLE_COUNT" -gt 0 ]; then
    echo -e "${RED}⚠️  Fichiers macOS cachés détectés !${NC}"
    echo ""
    echo -e "${YELLOW}📋 Liste des fichiers trouvés :${NC}"
    echo ""
    
    if [ "$FILES_COUNT" -gt 0 ]; then
        echo -e "${RED}Fichiers ._* (premiers 50) :${NC}"
        find . -name "._*" -type f ! -path "./.git/*" ! -path "./.git" 2>/dev/null | head -50 | sed 's/^/   /'
        if [ "$FILES_COUNT" -gt 50 ]; then
            echo -e "${YELLOW}   ... et $((FILES_COUNT - 50)) autres fichiers ._*${NC}"
        fi
        echo ""
    fi
    
    if [ "$DS_COUNT" -gt 0 ]; then
        echo -e "${RED}Fichiers .DS_Store :${NC}"
        find . -name ".DS_Store" -type f ! -path "./.git/*" ! -path "./.git" 2>/dev/null | sed 's/^/   /'
        echo ""
    fi
    
    if [ "$APPLE_DOUBLE_COUNT" -gt 0 ]; then
        echo -e "${RED}Répertoires .AppleDouble :${NC}"
        find . -name ".AppleDouble" -type d ! -path "./.git/*" ! -path "./.git" 2>/dev/null | sed 's/^/   /'
        echo ""
    fi
    
    if [ "$SPOTLIGHT_COUNT" -gt 0 ]; then
        echo -e "${RED}Répertoires .Spotlight-V100 :${NC}"
        find . -name ".Spotlight-V100" -type d ! -path "./.git/*" ! -path "./.git" 2>/dev/null | sed 's/^/   /'
        echo ""
    fi
    
    if [ "$TRASHES_COUNT" -gt 0 ]; then
        echo -e "${RED}Répertoires .Trashes :${NC}"
        find . -name ".Trashes" -type d ! -path "./.git/*" ! -path "./.git" 2>/dev/null | sed 's/^/   /'
        echo ""
    fi
    
    echo -e "${YELLOW}💡 Pour supprimer tous ces fichiers, exécutez :${NC}"
    echo "   ./android/prevent-macos-files.sh"
    echo "   ou"
    echo "   ./android/clean-gradle.sh"
    echo ""
    echo -e "${YELLOW}   Ou manuellement :${NC}"
    echo "   find . -name \"._*\" -type f ! -path \"./.git/*\" -delete"
    echo "   find . -name \".DS_Store\" -type f ! -path \"./.git/*\" -delete"
    echo "   find . -name \".AppleDouble\" -type d ! -path \"./.git/*\" -exec rm -rf {} +"
    echo "   find . -name \".Spotlight-V100\" -type d ! -path \"./.git/*\" -exec rm -rf {} +"
    echo "   find . -name \".Trashes\" -type d ! -path \"./.git/*\" -exec rm -rf {} +"
else
    echo -e "${GREEN}✅ Aucun fichier macOS caché trouvé !${NC}"
fi

echo ""

