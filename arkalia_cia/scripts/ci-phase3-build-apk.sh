#!/bin/bash
# Phase 3 : Build APK
# Build l'APK avec toutes les garanties

set -e

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}  Phase 3 : Build APK${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}"

FLUTTER_SOURCE_DIR=$(pwd)
echo "🔨 Building APK avec flutter.source=$FLUTTER_SOURCE_DIR"

# Vérifier que flutter.source est bien configuré
echo "📋 Vérification finale avant build:"
echo "   gradle.properties: $(grep 'flutter\.source=' android/gradle.properties || echo 'NON TROUVÉ')"
echo "   local.properties: $(grep 'flutter\.source=' android/local.properties || echo 'NON TROUVÉ')"

# Configuration GRADLE_OPTS pour passer flutter.source au niveau JVM
export GRADLE_OPTS="-Dorg.gradle.project.flutter.source=$FLUTTER_SOURCE_DIR"

# Essayer d'abord avec flutter build (méthode standard)
# Si ça échoue, on utilisera directement gradlew
echo "🔨 Tentative 1: flutter build apk --release"
if flutter build apk --release -Pflutter.source="$FLUTTER_SOURCE_DIR" 2>&1 | tee /tmp/flutter_build.log; then
    echo -e "${GREEN}✅ Build réussi avec flutter build${NC}"
else
    BUILD_EXIT_CODE=${PIPESTATUS[0]}
    echo -e "${YELLOW}⚠️ flutter build a échoué (code: $BUILD_EXIT_CODE), essai avec gradlew directement...${NC}"
    
    # Méthode alternative: utiliser gradlew directement
    cd android
    echo "🔨 Tentative 2: ./gradlew assembleRelease avec -Pflutter.source"
    ./gradlew assembleRelease -Pflutter.source="$FLUTTER_SOURCE_DIR" || {
        echo -e "${RED}❌ Les deux méthodes ont échoué${NC}"
        echo "📋 Dernières lignes du log:"
        tail -20 /tmp/flutter_build.log
        exit 1
    }
    cd ..
fi

echo ""
echo -e "${GREEN}✅ Phase 3 terminée avec succès${NC}"
echo ""

