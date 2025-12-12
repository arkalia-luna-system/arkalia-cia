#!/bin/bash
# Script pour vérifier le SHA-1 de l'app installée sur le téléphone

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  📱 Vérification SHA-1 depuis le téléphone${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

cd /Volumes/T7/arkalia-cia/arkalia_cia

# SHA-1 depuis le keystore de debug (Mac)
echo -e "${YELLOW}1. SHA-1 depuis le keystore de debug (Mac) :${NC}"
SHA1_MAC=$(cd android && ./gradlew signingReport 2>&1 | grep -A 5 "Variant: debug" | grep "SHA1:" | head -1 | sed 's/.*SHA1: //' | tr -d ' ')
echo -e "${GREEN}   $SHA1_MAC${NC}"
echo ""

# Vérifier si l'app est installée
echo -e "${YELLOW}2. Vérification de l'app sur le téléphone...${NC}"
if adb shell "pm list packages | grep -q com.arkalia.cia"; then
    echo -e "${GREEN}   ✅ App installée sur le téléphone${NC}"
    echo ""
    
    # Télécharger l'APK
    echo -e "${YELLOW}3. Téléchargement de l'APK depuis le téléphone...${NC}"
    APK_PATH=$(adb shell "pm path com.arkalia.cia" | sed 's/package://' | tr -d '\r')
    adb pull "$APK_PATH" /tmp/arkalia_app_phone.apk > /dev/null 2>&1
    
    if [ -f /tmp/arkalia_app_phone.apk ]; then
        echo -e "${GREEN}   ✅ APK téléchargé${NC}"
        echo ""
        
        # Essayer d'extraire le SHA-1
        echo -e "${YELLOW}4. Extraction du SHA-1 depuis l'APK...${NC}"
        
        # Méthode 1 : apksigner (si disponible)
        if command -v apksigner &> /dev/null; then
            SHA1_PHONE=$(apksigner verify --print-certs /tmp/arkalia_app_phone.apk 2>&1 | grep -i "SHA-1" | head -1 | sed 's/.*SHA-1: //' | tr -d ' ')
            if [ -n "$SHA1_PHONE" ]; then
                echo -e "${GREEN}   ✅ SHA-1 depuis l'APK (apksigner) :${NC}"
                echo -e "${GREEN}   $SHA1_PHONE${NC}"
            fi
        fi
        
        # Méthode 2 : jarsigner
        SHA1_JARSIGNER=$(jarsigner -verify -verbose -certs /tmp/arkalia_app_phone.apk 2>&1 | grep -i "SHA1" | head -1 | sed 's/.*SHA1: //' | tr -d ' ')
        if [ -n "$SHA1_JARSIGNER" ]; then
            echo -e "${GREEN}   ✅ SHA-1 depuis l'APK (jarsigner) :${NC}"
            echo -e "${GREEN}   $SHA1_JARSIGNER${NC}"
        fi
        
        # Comparaison
        echo ""
        if [ -n "$SHA1_PHONE" ] || [ -n "$SHA1_JARSIGNER" ]; then
            SHA1_FINAL="${SHA1_PHONE:-$SHA1_JARSIGNER}"
            if [ "$SHA1_MAC" = "$SHA1_FINAL" ]; then
                echo -e "${GREEN}✅ Les SHA-1 correspondent !${NC}"
                echo ""
                echo -e "${BLUE}📋 SHA-1 à utiliser dans Google Cloud Console :${NC}"
                echo -e "${YELLOW}   $SHA1_MAC${NC}"
            else
                echo -e "${RED}❌ Les SHA-1 ne correspondent PAS !${NC}"
                echo -e "${YELLOW}   Mac  : $SHA1_MAC${NC}"
                echo -e "${YELLOW}   Phone: $SHA1_FINAL${NC}"
                echo ""
                echo -e "${RED}⚠️  Utilise le SHA-1 du téléphone dans Google Cloud Console !${NC}"
            fi
        else
            echo -e "${YELLOW}⚠️  Impossible d'extraire le SHA-1 depuis l'APK${NC}"
            echo -e "${YELLOW}   (APK signé avec v2/v3, extraction complexe)${NC}"
            echo ""
            echo -e "${BLUE}💡 Solution : Utilise le SHA-1 du keystore de debug${NC}"
            echo -e "${BLUE}   (Flutter utilise le même keystore pour signer l'APK)${NC}"
            echo ""
            echo -e "${BLUE}📋 SHA-1 à utiliser dans Google Cloud Console :${NC}"
            echo -e "${YELLOW}   $SHA1_MAC${NC}"
        fi
    else
        echo -e "${RED}   ❌ Impossible de télécharger l'APK${NC}"
    fi
else
    echo -e "${RED}   ❌ App non installée sur le téléphone${NC}"
    echo ""
    echo -e "${BLUE}📋 SHA-1 à utiliser dans Google Cloud Console :${NC}"
    echo -e "${YELLOW}   $SHA1_MAC${NC}"
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  📋 Instructions Google Cloud Console${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo "1. Ouvre : https://console.cloud.google.com/apis/credentials?project=arkalia-cia"
echo "2. Clique sur 'Client Android 1'"
echo "3. Clique sur 'EDIT'"
echo "4. Dans 'SHA-1 certificate fingerprints', colle :"
echo ""
echo -e "${YELLOW}   $SHA1_MAC${NC}"
echo ""
echo "5. Clique sur 'SAVE'"
echo "6. Attends 5-10 minutes"
echo ""

