#!/bin/bash
# Script pour vérifier la configuration Google Cloud Console

echo "🔍 Vérification Configuration Google Cloud Console"
echo "=================================================="
echo ""

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 1. Vérifier package name
echo "📦 1. Vérification Package Name..."
PACKAGE_NAME=$(grep -E "applicationId\s*=|namespace\s*=" /Volumes/T7/arkalia-cia/arkalia_cia/android/app/build.gradle.kts | head -1 | sed 's/.*= *"\(.*\)".*/\1/' | tr -d ' ')
if [ "$PACKAGE_NAME" = "com.arkalia.cia" ]; then
    echo -e "${GREEN}✅ Package name correct : $PACKAGE_NAME${NC}"
else
    echo -e "${RED}❌ Package name incorrect : $PACKAGE_NAME (attendu: com.arkalia.cia)${NC}"
fi
echo ""

# 2. Obtenir SHA-1 Debug
echo "🔐 2. Récupération SHA-1 Debug..."
cd /Volumes/T7/arkalia-cia/arkalia_cia/android
SHA1_DEBUG=$(./gradlew signingReport 2>&1 | grep -A 5 "Variant: debug" | grep "SHA1:" | head -1 | sed 's/.*SHA1: //' | tr -d ' ')
if [ -n "$SHA1_DEBUG" ]; then
    echo -e "${GREEN}✅ SHA-1 Debug : $SHA1_DEBUG${NC}"
else
    echo -e "${RED}❌ Impossible de récupérer le SHA-1 Debug${NC}"
    SHA1_DEBUG="NON_TROUVÉ"
fi
echo ""

# 3. SHA-1 attendu
SHA1_ATTENDU="2C:68:D5:C0:92:A8:7F:59:E7:6A:7C:5B:7C:F9:77:54:9E:68:14:6E"
echo "📋 3. SHA-1 attendu dans Google Cloud Console :"
echo -e "${YELLOW}   $SHA1_ATTENDU${NC}"
echo ""

# 4. Comparaison
if [ "$SHA1_DEBUG" = "$SHA1_ATTENDU" ]; then
    echo -e "${GREEN}✅ SHA-1 correspond !${NC}"
else
    echo -e "${RED}❌ SHA-1 ne correspond PAS !${NC}"
    echo -e "${YELLOW}   Actuel  : $SHA1_DEBUG${NC}"
    echo -e "${YELLOW}   Attendu : $SHA1_ATTENDU${NC}"
    echo ""
    echo "⚠️  ACTION REQUISE :"
    echo "   1. Aller sur : https://console.cloud.google.com/apis/credentials?project=arkalia-cia"
    echo "   2. Ouvrir 'Client Android 1'"
    echo "   3. Vérifier/ajouter le SHA-1 Debug : $SHA1_DEBUG"
    echo "   4. Attendre 5-10 minutes"
    echo "   5. Redémarrer l'app"
fi
echo ""

# 5. Instructions
echo "📋 5. Vérifications à faire dans Google Cloud Console :"
echo ""
echo "   URL : https://console.cloud.google.com/apis/credentials?project=arkalia-cia"
echo ""
echo "   ✅ Client Android 1 doit avoir :"
echo "      - Package name : com.arkalia.cia"
echo "      - SHA-1 Debug  : $SHA1_ATTENDU"
echo "      - SHA-1 Production : AC:9E:D1:E9:29:66:5E:95:DD:0E:0B:7F:9F:F9:88:D1:5D:69:71:19"
echo ""
echo "   ✅ API Google Sign-In doit être activée :"
echo "      URL : https://console.cloud.google.com/apis/library?project=arkalia-cia"
echo "      Chercher 'Google Sign-In API' et vérifier qu'elle est activée"
echo ""

# 6. Erreur trouvée dans les logs
echo "🐛 6. Erreur trouvée dans les logs Android :"
echo ""
echo -e "${RED}   [GetTokenResponseHandler] Server returned error:${NC}"
echo -e "${RED}   This android application is not registered to use OAuth2.0,${NC}"
echo -e "${RED}   please confirm the package name and SHA-1 certificate fingerprint${NC}"
echo -e "${RED}   match what you registered in Google Developer Console.${NC}"
echo ""
echo "   Cette erreur signifie que :"
echo "   - Le package name ne correspond pas, OU"
echo "   - Le SHA-1 ne correspond pas, OU"
echo "   - Le Client Android n'existe pas dans Google Cloud Console"
echo ""

echo "✅ Vérification terminée"
echo ""

