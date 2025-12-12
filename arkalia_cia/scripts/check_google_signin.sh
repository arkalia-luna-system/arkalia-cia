#!/bin/bash
# Script de diagnostic pour Google Sign-In

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}  🔍 Diagnostic Google Sign-In${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}"
echo ""

cd /Volumes/T7/arkalia-cia/arkalia_cia

# 1. Vérifier le SHA-1 Debug
echo -e "${YELLOW}1. SHA-1 Debug (keystore de développement)${NC}"
SHA1_FOUND=false

# Méthode 1: keytool direct
if [ -f ~/.android/debug.keystore ]; then
    SHA1_OUTPUT=$(keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android 2>&1)
    SHA1_DEBUG=$(echo "$SHA1_OUTPUT" | grep -i "SHA1:" | head -1 | sed 's/.*SHA1: //' | tr -d ' ' | tr '[:lower:]' '[:upper:]')
    if [ -n "$SHA1_DEBUG" ] && [ ${#SHA1_DEBUG} -eq 40 ]; then
        echo -e "${GREEN}✅ SHA-1 Debug (keytool): $SHA1_DEBUG${NC}"
        SHA1_FORMATTED=$(echo "$SHA1_DEBUG" | sed 's/\(..\)/:\1/g' | sed 's/^://')
        echo "   Format avec deux-points: $SHA1_FORMATTED"
        SHA1_FOUND=true
    fi
fi

# Méthode 2: gradlew signingReport
if [ "$SHA1_FOUND" = false ] && [ -f "android/gradlew" ]; then
    echo "   Tentative avec gradlew signingReport..."
    cd android
    SHA1_GRADLE=$(./gradlew signingReport 2>&1 | grep -A 3 "Variant: debug" | grep -i "SHA1:" | head -1 | sed 's/.*SHA1: //' | tr -d ' ' | tr '[:lower:]' '[:upper:]')
    cd ..
    if [ -n "$SHA1_GRADLE" ] && [ ${#SHA1_GRADLE} -eq 40 ]; then
        echo -e "${GREEN}✅ SHA-1 Debug (gradlew): $SHA1_GRADLE${NC}"
        SHA1_FORMATTED=$(echo "$SHA1_GRADLE" | sed 's/\(..\)/:\1/g' | sed 's/^://')
        echo "   Format avec deux-points: $SHA1_FORMATTED"
        SHA1_FOUND=true
    fi
fi

if [ "$SHA1_FOUND" = false ]; then
    echo -e "${RED}❌ Impossible de lire le SHA-1 Debug${NC}"
    echo "   Essayez manuellement :"
    echo "   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android"
fi
echo ""

# 2. Vérifier le package name
echo -e "${YELLOW}2. Package Name${NC}"
PACKAGE_NAME=$(grep "applicationId" android/app/build.gradle.kts | head -1 | sed 's/.*applicationId = "\(.*\)".*/\1/')
if [ -n "$PACKAGE_NAME" ]; then
    echo -e "${GREEN}✅ Package Name: $PACKAGE_NAME${NC}"
    echo "   Doit correspondre à celui dans Google Cloud Console"
else
    echo -e "${RED}❌ Package name introuvable${NC}"
fi
echo ""

# 3. Vérifier la configuration dans le code
echo -e "${YELLOW}3. Configuration Code${NC}"
if grep -q "google_sign_in" pubspec.yaml; then
    echo -e "${GREEN}✅ Package google_sign_in présent dans pubspec.yaml${NC}"
else
    echo -e "${RED}❌ Package google_sign_in manquant${NC}"
fi

if [ -f "lib/services/google_auth_service.dart" ]; then
    echo -e "${GREEN}✅ Service GoogleAuthService présent${NC}"
else
    echo -e "${RED}❌ Service GoogleAuthService manquant${NC}"
fi

if grep -q "com.google.android.gms.version" android/app/src/main/AndroidManifest.xml; then
    echo -e "${GREEN}✅ Google Play Services configuré dans AndroidManifest.xml${NC}"
else
    echo -e "${RED}❌ Google Play Services manquant dans AndroidManifest.xml${NC}"
fi
echo ""

# 4. Instructions
echo -e "${YELLOW}4. Instructions${NC}"
echo "   Pour que Google Sign-In fonctionne :"
echo "   1. Aller sur Google Cloud Console :"
echo "      https://console.cloud.google.com/apis/credentials?project=arkalia-cia"
echo "   2. Vérifier que le Client Android a :"
echo "      - Package name: $PACKAGE_NAME"
echo "      - SHA-1 Debug: (voir ci-dessus)"
echo "   3. Si le SHA-1 ne correspond pas, l'ajouter dans Google Cloud Console"
echo "   4. Attendre 5-10 minutes pour la propagation"
echo "   5. Redémarrer l'app"
echo ""

# 5. Vérifier les logs possibles
echo -e "${YELLOW}5. Pour voir les erreurs détaillées${NC}"
echo "   - Les erreurs sont maintenant affichées dans un dialog"
echo "   - Vérifier les logs avec : adb logcat | grep -i google"
echo ""

echo -e "${GREEN}✅ Diagnostic terminé${NC}"

