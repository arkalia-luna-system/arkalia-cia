#!/bin/bash
# Script de diagnostic COMPLET pour Google Sign-In
# Vérifie TOUT ce qui peut causer des problèmes

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  🔍 DIAGNOSTIC COMPLET GOOGLE SIGN-IN${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

cd /Volumes/T7/arkalia-cia/arkalia_cia

# ========================================================================
# 1. VÉRIFICATION CODE FLUTTER
# ========================================================================
echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}1. VÉRIFICATION CODE FLUTTER${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}"

# Package google_sign_in
if grep -q "google_sign_in:" pubspec.yaml; then
    VERSION=$(grep "google_sign_in:" pubspec.yaml | sed 's/.*google_sign_in: //' | tr -d ' ')
    echo -e "${GREEN}✅ Package google_sign_in: $VERSION${NC}"
else
    echo -e "${RED}❌ Package google_sign_in manquant dans pubspec.yaml${NC}"
fi

# Service GoogleAuthService
if [ -f "lib/services/google_auth_service.dart" ]; then
    echo -e "${GREEN}✅ Service GoogleAuthService présent${NC}"
    # Vérifier que GoogleSignIn est bien initialisé
    if grep -q "GoogleSignIn(" lib/services/google_auth_service.dart; then
        echo -e "${GREEN}✅ GoogleSignIn initialisé${NC}"
    else
        echo -e "${RED}❌ GoogleSignIn non initialisé${NC}"
    fi
else
    echo -e "${RED}❌ Service GoogleAuthService manquant${NC}"
fi

# Écran WelcomeAuthScreen
if [ -f "lib/screens/auth/welcome_auth_screen.dart" ]; then
    echo -e "${GREEN}✅ Écran WelcomeAuthScreen présent${NC}"
    if grep -q "_handleGoogleSignIn\|_handleGmailSignIn" lib/screens/auth/welcome_auth_screen.dart; then
        echo -e "${GREEN}✅ Handlers Google/Gmail présents${NC}"
    else
        echo -e "${RED}❌ Handlers Google/Gmail manquants${NC}"
    fi
else
    echo -e "${RED}❌ Écran WelcomeAuthScreen manquant${NC}"
fi

echo ""

# ========================================================================
# 2. VÉRIFICATION CONFIGURATION ANDROID
# ========================================================================
echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}2. VÉRIFICATION CONFIGURATION ANDROID${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}"

# Package name
PACKAGE_NAME=$(grep "applicationId" android/app/build.gradle.kts 2>/dev/null | head -1 | sed 's/.*applicationId = "\(.*\)".*/\1/' || echo "")
if [ -n "$PACKAGE_NAME" ]; then
    echo -e "${GREEN}✅ Package Name: $PACKAGE_NAME${NC}"
    echo "   Doit être: com.arkalia.cia"
    if [ "$PACKAGE_NAME" != "com.arkalia.cia" ]; then
        echo -e "${RED}   ⚠️  Package name incorrect !${NC}"
    fi
else
    echo -e "${RED}❌ Package name introuvable${NC}"
fi

# Namespace
NAMESPACE=$(grep "namespace" android/app/build.gradle.kts 2>/dev/null | head -1 | sed 's/.*namespace = "\(.*\)".*/\1/' || echo "")
if [ -n "$NAMESPACE" ]; then
    echo -e "${GREEN}✅ Namespace: $NAMESPACE${NC}"
    if [ "$NAMESPACE" != "com.arkalia.cia" ]; then
        echo -e "${RED}   ⚠️  Namespace incorrect !${NC}"
    fi
else
    echo -e "${RED}❌ Namespace introuvable${NC}"
fi

# AndroidManifest.xml
if grep -q "com.google.android.gms.version" android/app/src/main/AndroidManifest.xml; then
    echo -e "${GREEN}✅ Google Play Services configuré dans AndroidManifest.xml${NC}"
else
    echo -e "${RED}❌ Google Play Services manquant dans AndroidManifest.xml${NC}"
fi

# SHA-1 Debug
echo ""
echo -e "${YELLOW}   SHA-1 Debug:${NC}"
SHA1_FOUND=false

# Méthode 1: keytool
if [ -f ~/.android/debug.keystore ]; then
    SHA1_OUTPUT=$(keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android 2>&1 || echo "")
    SHA1_DEBUG=$(echo "$SHA1_OUTPUT" | grep -i "SHA1:" | head -1 | sed 's/.*SHA1: //' | tr -d ' ' | tr '[:lower:]' '[:upper:]' || echo "")
    if [ -n "$SHA1_DEBUG" ] && [ ${#SHA1_DEBUG} -eq 40 ]; then
        SHA1_FORMATTED=$(echo "$SHA1_DEBUG" | sed 's/\(..\)/:\1/g' | sed 's/^://')
        echo -e "${GREEN}   ✅ SHA-1 Debug: $SHA1_FORMATTED${NC}"
        SHA1_FOUND=true
    fi
fi

# Méthode 2: Depuis l'appareil connecté
if [ "$SHA1_FOUND" = false ]; then
    if command -v adb &> /dev/null; then
        echo "   Tentative depuis l'appareil connecté..."
        # Obtenir le SHA-1 depuis l'app installée
        SHA1_DEVICE=$(adb shell dumpsys package com.arkalia.cia 2>/dev/null | grep -i "signatures" | head -1 || echo "")
        if [ -n "$SHA1_DEVICE" ]; then
            echo -e "${GREEN}   ✅ SHA-1 depuis appareil: (voir ci-dessous)${NC}"
            echo "$SHA1_DEVICE"
            SHA1_FOUND=true
        fi
    fi
fi

if [ "$SHA1_FOUND" = false ]; then
    echo -e "${RED}   ❌ Impossible de lire le SHA-1${NC}"
    echo "   Commandes à essayer manuellement :"
    echo "   1. keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android"
    echo "   2. cd android && ./gradlew signingReport"
fi

echo ""

# ========================================================================
# 3. VÉRIFICATION CONFIGURATION iOS
# ========================================================================
echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}3. VÉRIFICATION CONFIGURATION iOS${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}"

if [ -f "ios/Runner/Info.plist" ]; then
    if grep -q "com.googleusercontent.apps" ios/Runner/Info.plist; then
        CLIENT_ID_IOS=$(grep "com.googleusercontent.apps" ios/Runner/Info.plist | sed 's/.*<string>\(.*\)<\/string>.*/\1/')
        echo -e "${GREEN}✅ REVERSED_CLIENT_ID iOS: $CLIENT_ID_IOS${NC}"
        if [[ "$CLIENT_ID_IOS" == *"1062485264410"* ]]; then
            echo -e "${GREEN}   ✅ Client ID iOS semble correct${NC}"
        else
            echo -e "${RED}   ⚠️  Client ID iOS peut être incorrect${NC}"
        fi
    else
        echo -e "${RED}❌ REVERSED_CLIENT_ID iOS manquant dans Info.plist${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Info.plist introuvable (normal si pas sur iOS)${NC}"
fi

echo ""

# ========================================================================
# 4. VÉRIFICATION GOOGLE CLOUD CONSOLE
# ========================================================================
echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}4. VÉRIFICATION GOOGLE CLOUD CONSOLE${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}"

echo "   📋 Informations attendues dans Google Cloud Console :"
echo ""
echo "   Projet: arkalia-cia"
echo "   URL: https://console.cloud.google.com/apis/credentials?project=arkalia-cia"
echo ""
echo "   Client Android 1 :"
echo "   - Package name: com.arkalia.cia"
if [ "$SHA1_FOUND" = true ] && [ -n "$SHA1_FORMATTED" ]; then
    echo "   - SHA-1 Debug: $SHA1_FORMATTED"
    echo "   - ⚠️  VÉRIFIER que ce SHA-1 est dans Google Cloud Console !"
else
    echo "   - SHA-1 Debug: (à obtenir manuellement)"
fi
echo "   - SHA-1 Production: AC:9E:D1:E9:29:66:5E:95:DD:0E:0B:7F:9F:F9:88:D1:5D:69:71:19"
echo "   - Client ID: 1062485264410-3l6l1kuposfgmn9c609msme3rinlqnap.apps.googleusercontent.com"
echo ""
echo "   Client iOS 1 :"
echo "   - Bundle ID: com.arkalia.cia"
if [ -n "$CLIENT_ID_IOS" ]; then
    echo "   - Client ID: (extrait de $CLIENT_ID_IOS)"
fi
echo ""

# ========================================================================
# 5. PROBLÈMES POTENTIELS
# ========================================================================
echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}5. PROBLÈMES POTENTIELS IDENTIFIÉS${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}"

PROBLEMS=0

# Vérifier si le SHA-1 correspond
if [ "$SHA1_FOUND" = true ] && [ -n "$SHA1_FORMATTED" ]; then
    EXPECTED_SHA1="2C:68:D5:C0:92:A8:7F:59:E7:6A:7C:5B:7C:F9:77:54:9E:68:14:6E"
    if [ "$SHA1_FORMATTED" != "$EXPECTED_SHA1" ]; then
        echo -e "${RED}❌ PROBLÈME: SHA-1 Debug ne correspond pas${NC}"
        echo "   SHA-1 actuel: $SHA1_FORMATTED"
        echo "   SHA-1 attendu: $EXPECTED_SHA1"
        echo "   → Ajouter le SHA-1 actuel dans Google Cloud Console"
        PROBLEMS=$((PROBLEMS + 1))
    else
        echo -e "${GREEN}✅ SHA-1 Debug correspond${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  SHA-1 Debug non vérifiable (à vérifier manuellement)${NC}"
    PROBLEMS=$((PROBLEMS + 1))
fi

# Vérifier package name
if [ "$PACKAGE_NAME" != "com.arkalia.cia" ]; then
    echo -e "${RED}❌ PROBLÈME: Package name incorrect${NC}"
    PROBLEMS=$((PROBLEMS + 1))
fi

# Vérifier namespace
if [ "$NAMESPACE" != "com.arkalia.cia" ]; then
    echo -e "${RED}❌ PROBLÈME: Namespace incorrect${NC}"
    PROBLEMS=$((PROBLEMS + 1))
fi

if [ $PROBLEMS -eq 0 ]; then
    echo -e "${GREEN}✅ Aucun problème évident détecté${NC}"
else
    echo -e "${RED}⚠️  $PROBLEMS problème(s) potentiel(s) détecté(s)${NC}"
fi

echo ""

# ========================================================================
# 6. ACTIONS RECOMMANDÉES
# ========================================================================
echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}6. ACTIONS RECOMMANDÉES${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}"

echo "   1. Vérifier Google Cloud Console :"
echo "      → https://console.cloud.google.com/apis/credentials?project=arkalia-cia"
echo ""
echo "   2. Vérifier que le Client Android a :"
echo "      - Package name: com.arkalia.cia"
if [ "$SHA1_FOUND" = true ] && [ -n "$SHA1_FORMATTED" ]; then
    echo "      - SHA-1 Debug: $SHA1_FORMATTED (AJOUTER si absent)"
fi
echo ""
echo "   3. Si le SHA-1 ne correspond pas :"
echo "      → Ajouter le SHA-1 actuel dans Google Cloud Console"
echo "      → Attendre 5-10 minutes pour la propagation"
echo ""
echo "   4. Tester avec les nouveaux logs :"
echo "      → Relancer l'app"
echo "      → Essayer de se connecter"
echo "      → Un dialog affichera l'erreur exacte"
echo ""
echo "   5. Vérifier les logs Android :"
echo "      → adb logcat | grep -i 'google\\|signin\\|auth'"
echo ""

echo -e "${GREEN}✅ Diagnostic terminé${NC}"

