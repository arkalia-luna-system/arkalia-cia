#!/bin/bash
# Phase 2 : Nettoyage des fichiers macOS
# Supprime tous les fichiers macOS cachés avant le build

set -e

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}  Phase 2 : Nettoyage des fichiers macOS${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}"

echo "🧹 Nettoyage des fichiers macOS cachés..."

# Nettoyer dans build/ si il existe
if [ -d "build" ]; then
    find build -name "._*" -type f -delete 2>/dev/null || true
    find build -name ".DS_Store" -type f -delete 2>/dev/null || true
fi

# Nettoyer dans tout le projet (sauf .git et .dart_tool)
find . -type f \( -name "._*" -o -name ".DS_Store" \) ! -path "./.git/*" ! -path "./.dart_tool/*" -delete 2>/dev/null || true

echo -e "${GREEN}✅ Phase 2 terminée avec succès${NC}"
echo ""

