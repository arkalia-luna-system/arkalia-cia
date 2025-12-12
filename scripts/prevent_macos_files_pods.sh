#!/bin/bash
# Script pour empêcher la création de fichiers macOS cachés dans Pods
# À exécuter après chaque pod install

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🍎 Nettoyage des fichiers macOS cachés dans Pods...${NC}"

cd /Volumes/T7/arkalia-cia/arkalia_cia

# Supprimer tous les fichiers macOS cachés dans Pods (iOS et macOS)
find ios/Pods -name "._*" -type f -delete 2>/dev/null || true
find ios/Pods -name ".DS_Store" -type f -delete 2>/dev/null || true
find macos/Pods -name "._*" -type f -delete 2>/dev/null || true
find macos/Pods -name ".DS_Store" -type f -delete 2>/dev/null || true

COUNT_IOS=$(find ios/Pods -name "._*" -type f 2>/dev/null | wc -l | tr -d ' ')
COUNT_MACOS=$(find macos/Pods -name "._*" -type f 2>/dev/null | wc -l | tr -d ' ')
COUNT=$((COUNT_IOS + COUNT_MACOS))
if [ "$COUNT" -eq 0 ]; then
    echo -e "${GREEN}✅ Aucun fichier macOS caché trouvé dans Pods (iOS et macOS)${NC}"
else
    echo -e "${YELLOW}⚠️  $COUNT fichiers macOS cachés restants (iOS: $COUNT_IOS, macOS: $COUNT_MACOS)${NC}"
fi

echo -e "${GREEN}✅ Nettoyage terminé${NC}"

