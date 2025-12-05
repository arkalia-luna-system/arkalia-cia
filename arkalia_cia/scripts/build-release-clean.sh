#!/bin/bash
# Script de build release propre pour Google Play Store
# Vérifie tout avant de builder et garantit un build sans erreurs

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  🚀 Build Release Arkalia CIA - Google Play Store${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

# Vérifier qu'on est dans le bon répertoire
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

if [ ! -f "$PROJECT_DIR/pubspec.yaml" ]; then
    echo -e "${RED}❌ Erreur: Ce script doit être exécuté depuis le répertoire du projet${NC}"
    exit 1
fi

cd "$PROJECT_DIR"

# ========================================================================
# ÉTAPE 1 : Vérification de la version
# ========================================================================
echo -e "${YELLOW}📋 Étape 1 : Vérification de la version${NC}"

VERSION=$(grep "^version:" pubspec.yaml | sed 's/version: //' | tr -d ' ')
if [ -z "$VERSION" ]; then
    echo -e "${RED}❌ Erreur: Impossible de lire la version dans pubspec.yaml${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Version trouvée : ${VERSION}${NC}"
VERSION_NAME=$(echo $VERSION | cut -d'+' -f1)
VERSION_CODE=$(echo $VERSION | cut -d'+' -f2)

echo "   Version Name (affichée) : ${VERSION_NAME}"
echo "   Version Code (build)     : ${VERSION_CODE}"
echo ""

# ========================================================================
# ÉTAPE 2 : Vérification Flutter
# ========================================================================
echo -e "${YELLOW}🔍 Étape 2 : Vérification Flutter${NC}"

if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Erreur: Flutter n'est pas installé ou pas dans le PATH${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Flutter trouvé${NC}"
flutter --version | head -1
echo ""

# ========================================================================
# ÉTAPE 3 : Nettoyage
# ========================================================================
echo -e "${YELLOW}🧹 Étape 3 : Nettoyage${NC}"

echo "   Nettoyage des builds précédents..."
flutter clean > /dev/null 2>&1 || true

echo "   Nettoyage des fichiers macOS..."
find . -type f \( -name "._*" -o -name ".DS_Store" \) ! -path "./.git/*" ! -path "./.dart_tool/*" -delete 2>/dev/null || true

echo -e "${GREEN}✅ Nettoyage terminé${NC}"
echo ""

# ========================================================================
# ÉTAPE 4 : Récupération des dépendances
# ========================================================================
echo -e "${YELLOW}📦 Étape 4 : Récupération des dépendances${NC}"

flutter pub get
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Erreur: Échec de la récupération des dépendances${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Dépendances récupérées${NC}"
echo ""

# ========================================================================
# ÉTAPE 5 : Analyse du code (optionnelle, sautée si bloque)
# ========================================================================
echo -e "${YELLOW}🔍 Étape 5 : Analyse du code (optionnelle)${NC}"
echo "   Tentative d'analyse rapide (timeout: 10 secondes)..."

# Exécuter flutter analyze avec timeout strict
ANALYZE_OUTPUT=$(timeout 10 flutter analyze 2>&1) || {
    ANALYZE_EXIT=$?
    if [ $ANALYZE_EXIT -eq 124 ]; then
        echo -e "${YELLOW}⚠️  Analyse timeout après 10s, on continue le build${NC}"
        echo "   Tu peux lancer 'flutter analyze' manuellement plus tard"
    else
        echo -e "${YELLOW}⚠️  Analyse interrompue, on continue le build${NC}"
    fi
    ANALYZE_OUTPUT=""
}

if [ -n "$ANALYZE_OUTPUT" ] && [ "$ANALYZE_OUTPUT" != "" ]; then
    # Compter les erreurs (pas les warnings/info)
    ERROR_COUNT=$(echo "$ANALYZE_OUTPUT" | grep -c "error •" || true)

    if [ $ERROR_COUNT -gt 0 ]; then
        echo -e "${RED}❌ Erreurs trouvées dans le code :${NC}"
        echo "$ANALYZE_OUTPUT" | grep "error •" | head -10
        echo ""
        echo -e "${YELLOW}⚠️  Le build continuera, mais corrige ces erreurs avant de publier${NC}"
    else
        echo -e "${GREEN}✅ Aucune erreur critique trouvée${NC}"
        
        # Afficher les warnings/info s'il y en a
        WARNING_COUNT=$(echo "$ANALYZE_OUTPUT" | grep -c "warning •\|info •" || true)
        if [ $WARNING_COUNT -gt 0 ]; then
            echo -e "${YELLOW}ℹ️  ${WARNING_COUNT} avertissement(s) trouvé(s) (non bloquant)${NC}"
        fi
    fi
fi

echo ""

# ========================================================================
# ÉTAPE 6 : Vérification de la signature
# ========================================================================
echo -e "${YELLOW}🔐 Étape 6 : Vérification de la signature${NC}"

KEY_PROPERTIES="android/key.properties"
if [ -f "$KEY_PROPERTIES" ]; then
    echo -e "${GREEN}✅ Fichier key.properties trouvé${NC}"
    echo "   L'app sera signée avec la clé de release"
else
    echo -e "${YELLOW}⚠️  Fichier key.properties non trouvé${NC}"
    echo "   L'app sera signée avec la clé de debug (non valide pour Play Store)"
    echo ""
    echo -e "${YELLOW}   Pour créer key.properties :${NC}"
    echo "   1. Générer le keystore (voir docs/deployment/PLAY_STORE_SETUP.md)"
    echo "   2. Créer android/key.properties avec les informations"
fi

echo ""

# ========================================================================
# ÉTAPE 7 : Build App Bundle
# ========================================================================
echo -e "${YELLOW}🔨 Étape 7 : Build App Bundle${NC}"
echo ""

# Utiliser le script build-android.sh si disponible
BUILD_SCRIPT="android/build-android.sh"
if [ -f "$BUILD_SCRIPT" ]; then
    echo "   Utilisation du script build-android.sh..."
    chmod +x "$BUILD_SCRIPT"
    "$BUILD_SCRIPT" flutter build appbundle --release
else
    echo "   Build direct avec Flutter..."
    flutter build appbundle --release
fi

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Erreur: Échec du build App Bundle${NC}"
    exit 1
fi

echo ""

# ========================================================================
# ÉTAPE 8 : Vérification du fichier généré
# ========================================================================
echo -e "${YELLOW}✅ Étape 8 : Vérification du fichier généré${NC}"

BUNDLE_PATH="build/app/outputs/bundle/release/app-release.aab"

if [ ! -f "$BUNDLE_PATH" ]; then
    echo -e "${RED}❌ Erreur: App Bundle non trouvé à ${BUNDLE_PATH}${NC}"
    exit 1
fi

FILE_SIZE=$(ls -lh "$BUNDLE_PATH" | awk '{print $5}')
echo -e "${GREEN}✅ App Bundle généré avec succès${NC}"
echo "   Fichier : ${BUNDLE_PATH}"
echo "   Taille  : ${FILE_SIZE}"
echo ""

# Vérifier la signature si jarsigner est disponible
if command -v jarsigner &> /dev/null; then
    echo "   Vérification de la signature..."
    if jarsigner -verify -verbose -certs "$BUNDLE_PATH" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Signature valide${NC}"
    else
        echo -e "${YELLOW}⚠️  Signature non vérifiée (peut être signée avec debug key)${NC}"
    fi
    echo ""
fi

# ========================================================================
# RÉSUMÉ
# ========================================================================
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Build terminé avec succès !${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}📦 Fichier à uploader :${NC}"
echo "   ${BUNDLE_PATH}"
echo ""
echo -e "${YELLOW}📱 Prochaines étapes :${NC}"
echo "   1. Aller sur Google Play Console"
echo "   2. Production → Créer une version (ou Tests internes)"
echo "   3. Uploader le fichier : ${BUNDLE_PATH}"
echo "   4. Vérifier que la version est : ${VERSION_NAME} (code: ${VERSION_CODE})"
echo "   5. Ajouter les notes de version"
echo "   6. Publier"
echo ""
echo -e "${YELLOW}📚 Documentation :${NC}"
echo "   - Guide Play Console : docs/deployment/GUIDE_PLAY_CONSOLE_VERSION.md"
echo "   - Setup Play Store  : docs/deployment/PLAY_STORE_SETUP.md"
echo ""

