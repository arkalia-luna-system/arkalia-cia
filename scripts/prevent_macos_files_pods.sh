#!/bin/bash
# Script pour empêcher la création de fichiers macOS cachés dans Pods
# À exécuter après chaque pod install

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🍎 Nettoyage des fichiers macOS cachés dans Pods...${NC}"

cd /Volumes/T7/arkalia-cia/arkalia_cia

# Supprimer tous les fichiers macOS cachés dans Pods
find ios/Pods -name "._*" -type f -delete 2>/dev/null || true
find ios/Pods -name ".DS_Store" -type f -delete 2>/dev/null || true

COUNT=$(find ios/Pods -name "._*" -type f 2>/dev/null | wc -l | tr -d ' ')
if [ "$COUNT" -eq 0 ]; then
    echo -e "${GREEN}✅ Aucun fichier macOS caché trouvé dans Pods${NC}"
else
    echo -e "${YELLOW}⚠️  $COUNT fichiers macOS cachés restants${NC}"
fi

echo -e "${GREEN}✅ Nettoyage terminé${NC}"

