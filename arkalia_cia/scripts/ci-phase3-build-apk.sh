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

# Configuration GRADLE_OPTS pour passer flutter.source au niveau JVM
export GRADLE_OPTS="-Dorg.gradle.project.flutter.source=$FLUTTER_SOURCE_DIR"

# Build avec -P pour garantir la priorité maximale
flutter build apk --release -Pflutter.source="$FLUTTER_SOURCE_DIR"

echo ""
echo -e "${GREEN}✅ Phase 3 terminée avec succès${NC}"
echo ""

