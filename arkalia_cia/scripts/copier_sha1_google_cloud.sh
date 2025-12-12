#!/bin/bash
# Script pour afficher le SHA-1 exact à copier dans Google Cloud Console

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  📋 SHA-1 à copier dans Google Cloud Console${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

cd /Volumes/T7/arkalia-cia/arkalia_cia/android

SHA1=$(./gradlew signingReport 2>&1 | grep -A 5 "Variant: debug" | grep "SHA1:" | head -1 | sed 's/.*SHA1: //' | tr -d ' ')

echo -e "${GREEN}✅ SHA-1 Debug (format exact) :${NC}"
echo ""
echo -e "${YELLOW}$SHA1${NC}"
echo ""
echo -e "${BLUE}📋 Instructions pour Google Cloud Console :${NC}"
echo ""
echo "1. Ouvre : https://console.cloud.google.com/apis/credentials?project=arkalia-cia"
echo "2. Clique sur 'Client Android 1'"
echo "3. Clique sur 'EDIT'"
echo "4. Dans 'SHA-1 certificate fingerprints', colle EXACTEMENT :"
echo ""
echo -e "${YELLOW}   $SHA1${NC}"
echo ""
echo "5. ⚠️  IMPORTANT :"
echo "   - Copie TOUT le SHA-1 (avec les deux-points)"
echo "   - Pas d'espaces avant ou après"
echo "   - Majuscules/minuscules exactes"
echo "   - Format : XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX"
echo ""
echo "6. Clique sur 'SAVE'"
echo "7. Attends 5-10 minutes pour la propagation"
echo ""
echo -e "${GREEN}✅ Après modification, redémarre l'app :${NC}"
echo "   adb shell am force-stop com.arkalia.cia"
echo "   adb shell pm clear com.arkalia.cia"
echo ""

