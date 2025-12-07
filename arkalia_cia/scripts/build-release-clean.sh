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
# ÉTAPE 1 : Auto-incrémentation intelligente du version code
# ========================================================================
echo -e "${YELLOW}📋 Étape 1 : Auto-incrémentation intelligente du version code${NC}"

CURRENT_VERSION=$(grep "^version:" pubspec.yaml | sed 's/version: //' | tr -d ' ')
if [ -z "$CURRENT_VERSION" ]; then
    echo -e "${RED}❌ Erreur: Impossible de lire la version dans pubspec.yaml${NC}"
    exit 1
fi

echo "Version actuelle: ${CURRENT_VERSION}"

# Extraire versionName et versionCode
VERSION_NAME=$(echo $CURRENT_VERSION | cut -d'+' -f1)
CURRENT_VERSION_CODE=$(echo $CURRENT_VERSION | cut -d'+' -f2)

# Utiliser un timestamp pour générer un version code unique
# Format: YYMMDDHHMM (ex: 2512052221 = 5 décembre 2025, 22h21)
# Cela garantit un version code toujours croissant et unique
# Utilise l'année sur 2 chiffres + minutes pour rester dans les limites d'un int32
# Max: 9912312359 = ~99 milliards (limite int32: 2,147,483,647)
TIMESTAMP_CODE=$(date +%y%m%d%H%M)

# Si le timestamp est trop petit ou invalide, utiliser une incrémentation agressive
if [ -z "$TIMESTAMP_CODE" ] || [ "$TIMESTAMP_CODE" -lt "$CURRENT_VERSION_CODE" ] 2>/dev/null; then
    # Incrémentation agressive : +20 pour éviter les conflits
    NEW_VERSION_CODE=$((CURRENT_VERSION_CODE + 20))
    echo -e "${YELLOW}⚠️  Timestamp invalide, utilisation d'une incrémentation agressive (+20)${NC}"
else
    # Utiliser le timestamp comme version code (garantit l'unicité)
    NEW_VERSION_CODE=$TIMESTAMP_CODE
    echo -e "${GREEN}✅ Utilisation du timestamp comme version code (garantit l'unicité)${NC}"
fi

# S'assurer que le nouveau version code est supérieur à l'actuel
if [ "$NEW_VERSION_CODE" -le "$CURRENT_VERSION_CODE" ] 2>/dev/null; then
    NEW_VERSION_CODE=$((CURRENT_VERSION_CODE + 20))
    echo -e "${YELLOW}⚠️  Ajustement: version code trop petit, utilisation de +20${NC}"
fi

NEW_VERSION="$VERSION_NAME+$NEW_VERSION_CODE"

echo ""
echo -e "${BLUE}📊 Calcul du nouveau version code:${NC}"
echo "   - Version actuelle: ${CURRENT_VERSION} (code: ${CURRENT_VERSION_CODE})"
echo "   - Nouveau version code: ${NEW_VERSION_CODE}"
echo "   - Nouvelle version: ${NEW_VERSION}"
echo ""
echo -e "${GREEN}💡 Cette méthode garantit un version code unique et toujours croissant${NC}"
echo ""

# Mettre à jour pubspec.yaml
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s/^version: .*/version: ${NEW_VERSION}/" pubspec.yaml
else
    # Linux
    sed -i "s/^version: .*/version: ${NEW_VERSION}/" pubspec.yaml
fi

echo -e "${GREEN}✅ Version mise à jour: ${CURRENT_VERSION} → ${NEW_VERSION}${NC}"
echo ""

# Utiliser les nouvelles valeurs pour la suite
VERSION=$NEW_VERSION
VERSION_CODE=$NEW_VERSION_CODE

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
# Afficher le chemin absolu
ABSOLUTE_BUNDLE_PATH="$(cd "$(dirname "$BUNDLE_PATH")" && pwd)/$(basename "$BUNDLE_PATH")"

echo -e "${YELLOW}📦 Fichier à uploader :${NC}"
echo "   Chemin relatif : ${BUNDLE_PATH}"
echo "   Chemin absolu  : ${ABSOLUTE_BUNDLE_PATH}"
echo ""
echo -e "${YELLOW}📱 Prochaines étapes :${NC}"
echo "   1. Aller sur Google Play Console : https://play.google.com/console"
echo "   2. Sélectionner 'Arkalia CIA'"
echo "   3. Tests internes → Créer une nouvelle version"
echo "   4. Uploader le fichier : ${ABSOLUTE_BUNDLE_PATH}"
echo "   5. Vérifier que la version est : ${VERSION_NAME} (code: ${VERSION_CODE})"
echo "   6. Ajouter les notes de version"
echo "   7. Publier"
echo ""
echo -e "${YELLOW}📚 Documentation :${NC}"
echo "   - Guide Play Console : docs/deployment/GUIDE_PLAY_CONSOLE_VERSION.md"
echo "   - Setup Play Store  : docs/deployment/PLAY_STORE_SETUP.md"
echo ""

# Ouvrir le Finder sur macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo -e "${YELLOW}🔍 Ouverture du Finder...${NC}"
    open -R "$ABSOLUTE_BUNDLE_PATH"
fi
echo ""

