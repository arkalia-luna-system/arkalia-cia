#!/bin/bash
# Phase 1 : Configuration flutter.source
# Valide que flutter.source est correctement configuré avant de continuer

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}  Phase 1 : Configuration flutter.source${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}"

# Obtenir le répertoire source Flutter
FLUTTER_SOURCE_DIR=$(pwd)
echo "📁 Flutter source directory: $FLUTTER_SOURCE_DIR"

# Vérifier que le répertoire existe et contient pubspec.yaml
if [ ! -d "$FLUTTER_SOURCE_DIR" ]; then
    echo -e "${RED}❌ Flutter source directory does not exist: $FLUTTER_SOURCE_DIR${NC}"
    exit 1
fi

if [ ! -f "$FLUTTER_SOURCE_DIR/pubspec.yaml" ]; then
    echo -e "${RED}❌ pubspec.yaml not found in Flutter source directory: $FLUTTER_SOURCE_DIR${NC}"
    exit 1
fi

# Configurer flutter.source dans gradle.properties (chemin absolu pour fallback)
# Le plugin Flutter Gradle lit depuis gradle.properties si pas dans local.properties
if grep -q "^flutter.source=" android/gradle.properties; then
    sed -i "s|^flutter.source=.*|flutter.source=$FLUTTER_SOURCE_DIR|" android/gradle.properties
else
    echo "flutter.source=$FLUTTER_SOURCE_DIR" >> android/gradle.properties
fi

          # Configurer flutter.source dans local.properties
          # IMPORTANT: Le plugin Flutter Gradle lit depuis local.properties
          # Il faut utiliser un chemin relatif depuis android/ vers arkalia_cia/
          # Chemin relatif: depuis android/ vers .. (arkalia_cia/)
          if [ -f "android/local.properties" ]; then
            # Supprimer la ligne flutter.source existante
            sed -i '/flutter\.source=/d' android/local.properties
            # Ajouter flutter.source avec chemin relatif (depuis android/ vers ..)
            echo "" >> android/local.properties
            echo "flutter.source=.." >> android/local.properties
          else
            echo "flutter.source=.." >> android/local.properties
          fi
          
          # Aussi dans gradle.properties avec chemin absolu (pour fallback)
          # Mais local.properties utilise chemin relatif (priorité)

# Vérification finale
echo ""
echo -e "${YELLOW}✅ Vérification de la configuration:${NC}"

if ! grep -q "flutter\.source=" android/gradle.properties; then
    echo -e "${RED}❌ ERREUR: flutter.source manquant dans gradle.properties${NC}"
    cat android/gradle.properties
    exit 1
fi

if ! grep -q "flutter\.source=" android/local.properties; then
    echo -e "${RED}❌ ERREUR: flutter.source manquant dans local.properties${NC}"
    cat android/local.properties
    exit 1
fi

echo "   gradle.properties: $(grep 'flutter\.source=' android/gradle.properties)"
echo "   local.properties: $(grep 'flutter\.source=' android/local.properties)"

echo ""
echo -e "${GREEN}✅ Phase 1 terminée avec succès${NC}"
echo ""

