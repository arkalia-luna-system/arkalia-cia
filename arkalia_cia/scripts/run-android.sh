#!/bin/bash
# Script unifié pour lancer l'app Android
# Fusionne les meilleures parties des scripts existants
# Nettoie, vérifie, et lance l'app Android

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  📱 Lancement Arkalia CIA - Android${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

# Obtenir le répertoire du script
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Vérifier qu'on est dans le bon répertoire
if [ ! -f "$PROJECT_DIR/pubspec.yaml" ]; then
    echo -e "${RED}❌ Erreur: Ce script doit être exécuté depuis le répertoire du projet${NC}"
    exit 1
fi

cd "$PROJECT_DIR"

# ========================================================================
# ÉTAPE 1 : Vérification Flutter
# ========================================================================
echo -e "${YELLOW}🔍 Étape 1 : Vérification Flutter${NC}"

if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Erreur: Flutter n'est pas installé ou pas dans le PATH${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Flutter trouvé${NC}"
flutter --version | head -1
echo ""

# ========================================================================
# ÉTAPE 2 : Vérification appareil Android
# ========================================================================
echo -e "${YELLOW}📱 Étape 2 : Vérification appareil Android${NC}"

# Vérifier si un appareil Android est connecté
DEVICES=$(flutter devices | grep -i "android" || true)

if [ -z "$DEVICES" ]; then
    echo -e "${YELLOW}⚠️  Aucun appareil Android détecté${NC}"
    echo "   Options disponibles :"
    echo "   1. Connecter un téléphone Android via USB (avec USB Debugging activé)"
    echo "   2. Lancer un émulateur Android"
    echo ""
    echo -e "${YELLOW}   Voulez-vous continuer quand même ? (y/n)${NC}"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo -e "${RED}❌ Annulé${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✅ Appareil Android détecté${NC}"
    echo "$DEVICES" | head -3
fi
echo ""

# ========================================================================
# ÉTAPE 3 : Configuration Gradle
# ========================================================================
echo -e "${YELLOW}🔧 Étape 3 : Configuration Gradle${NC}"

# Forcer les variables d'environnement Gradle
export GRADLE_USER_HOME="$HOME/.gradle"
export GRADLE_OPTS="-Dorg.gradle.user.home=$HOME/.gradle -Duser.home=$HOME"

# Vérifier que le répertoire .gradle existe
if [ ! -d "$HOME/.gradle" ]; then
    echo -e "${YELLOW}📁 Création du répertoire $HOME/.gradle${NC}"
    mkdir -p "$HOME/.gradle"
fi

echo -e "${GREEN}✅ Configuration Gradle OK${NC}"
echo "   GRADLE_USER_HOME=$GRADLE_USER_HOME"
echo ""

# ========================================================================
# ÉTAPE 4 : Nettoyage léger
# ========================================================================
echo -e "${YELLOW}🧹 Étape 4 : Nettoyage léger${NC}"

# Nettoyer uniquement les fichiers macOS (pas tout le build)
echo "   Nettoyage des fichiers macOS..."
find . -type f \( -name "._*" -o -name ".!*!._*" -o -name ".DS_Store" \) ! -path "./.git/*" ! -path "./.dart_tool/*" -delete 2>/dev/null || true

# Nettoyer spécifiquement dans build/ si existe
if [ -d "build" ]; then
    find build -type f \( -name "._*" -o -name ".!*!._*" -o -name ".DS_Store" \) -delete 2>/dev/null || true
fi

echo -e "${GREEN}✅ Nettoyage terminé${NC}"
echo ""

# ========================================================================
# ÉTAPE 5 : Récupération des dépendances
# ========================================================================
echo -e "${YELLOW}📦 Étape 5 : Récupération des dépendances${NC}"

flutter pub get
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Erreur: Échec de la récupération des dépendances${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Dépendances récupérées${NC}"
echo ""

# ========================================================================
# ÉTAPE 6 : Analyse rapide (optionnelle, non bloquante)
# ========================================================================
echo -e "${YELLOW}🔍 Étape 6 : Analyse rapide du code (optionnelle)${NC}"

# Exécuter flutter analyze avec timeout strict (10 secondes)
ANALYZE_OUTPUT=$(timeout 10 flutter analyze 2>&1) || {
    ANALYZE_EXIT=$?
    if [ $ANALYZE_EXIT -eq 124 ]; then
        echo -e "${YELLOW}⚠️  Analyse timeout après 10s, on continue${NC}"
    else
        echo -e "${YELLOW}⚠️  Analyse interrompue, on continue${NC}"
    fi
    ANALYZE_OUTPUT=""
}

if [ -n "$ANALYZE_OUTPUT" ] && [ "$ANALYZE_OUTPUT" != "" ]; then
    # Compter les erreurs (pas les warnings/info)
    ERROR_COUNT=$(echo "$ANALYZE_OUTPUT" | grep -c "error •" || true)

    if [ $ERROR_COUNT -gt 0 ]; then
        echo -e "${RED}❌ ${ERROR_COUNT} erreur(s) trouvée(s) dans le code${NC}"
        echo "$ANALYZE_OUTPUT" | grep "error •" | head -5
        echo ""
        echo -e "${YELLOW}⚠️  Le lancement continuera, mais corrige ces erreurs${NC}"
    else
        echo -e "${GREEN}✅ Aucune erreur critique trouvée${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Analyse non effectuée (timeout ou interrompue)${NC}"
fi
echo ""

# ========================================================================
# ÉTAPE 7 : Lancement de l'app
# ========================================================================
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}🚀 Lancement de l'app Android...${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

# Utiliser le script build-android.sh si disponible pour la configuration Gradle
BUILD_SCRIPT="android/build-android.sh"
if [ -f "$BUILD_SCRIPT" ]; then
    echo "   Utilisation du wrapper Gradle optimisé..."
    chmod +x "$BUILD_SCRIPT"
    # Utiliser le script wrapper pour flutter run
    env GRADLE_USER_HOME="$HOME/.gradle" \
        GRADLE_OPTS="-Dorg.gradle.user.home=$HOME/.gradle -Duser.home=$HOME" \
        flutter run -d android
else
    echo "   Lancement direct avec Flutter..."
    env GRADLE_USER_HOME="$HOME/.gradle" \
        GRADLE_OPTS="-Dorg.gradle.user.home=$HOME/.gradle -Duser.home=$HOME" \
        flutter run -d android
fi

# Le script se termine ici si flutter run réussit
# Si erreur, le set -e fera échouer le script

