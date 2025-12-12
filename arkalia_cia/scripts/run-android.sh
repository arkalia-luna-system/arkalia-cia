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

# Obtenir la liste des appareils
DEVICES_OUTPUT=$(flutter devices 2>&1)
ANDROID_DEVICES=$(echo "$DEVICES_OUTPUT" | grep -i "android" || true)

if [ -z "$ANDROID_DEVICES" ]; then
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
    DEVICE_ID="android"
else
    echo -e "${GREEN}✅ Appareil Android détecté${NC}"
    echo "$ANDROID_DEVICES" | head -3
    
    # Extraire l'ID du premier appareil Android
    # Format: "SM S938B (mobile) • R3CY60BJ3ZM • android-arm64 • Android 16 (API 36)"
    # On cherche le deuxième champ séparé par "•"
    FIRST_LINE=$(echo "$ANDROID_DEVICES" | head -1)
    # Extraire l'ID (deuxième champ entre les "•")
    DEVICE_ID=$(echo "$FIRST_LINE" | awk -F'•' '{print $2}' | xargs)
    
    # Si l'extraction échoue, essayer une autre méthode
    if [ -z "$DEVICE_ID" ] || [ "$DEVICE_ID" = "" ]; then
        # Méthode alternative : chercher un ID qui ressemble à un ID d'appareil (alphanumérique, 8+ caractères)
        DEVICE_ID=$(echo "$FIRST_LINE" | grep -oE '[A-Z0-9]{8,}' | head -1)
    fi
    
    if [ -z "$DEVICE_ID" ] || [ "$DEVICE_ID" = "" ]; then
        echo -e "${YELLOW}⚠️  Impossible d'extraire l'ID, utilisation de l'ID complet${NC}"
        # Utiliser le nom complet de l'appareil comme fallback
        DEVICE_ID=$(echo "$FIRST_LINE" | awk '{print $1}')
        if [ -z "$DEVICE_ID" ]; then
            DEVICE_ID="android"
        fi
    else
        echo -e "${GREEN}✅ Utilisation de l'appareil : ${DEVICE_ID}${NC}"
    fi
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
# ÉTAPE 4 : Nettoyage agressif des fichiers macOS
# ========================================================================
echo -e "${YELLOW}🧹 Étape 4 : Nettoyage agressif des fichiers macOS${NC}"

# Utiliser le script de prévention si disponible (comme dans build-android.sh)
PREVENT_SCRIPT="android/prevent-macos-files.sh"
if [ -f "$PREVENT_SCRIPT" ]; then
    echo "   Utilisation du script prevent-macos-files.sh..."
    chmod +x "$PREVENT_SCRIPT"
    "$PREVENT_SCRIPT" || true
else
    # Fallback : nettoyage manuel ultra-agressif
    echo "   Nettoyage manuel agressif..."
    find . -type f \( -name "._*" -o -name ".!*!._*" -o -name ".DS_Store" \) ! -path "./.git/*" ! -path "./.dart_tool/*" -delete 2>/dev/null || true
    find . -type d \( -name ".AppleDouble" -o -name ".Spotlight-V100" -o -name ".Trashes" \) ! -path "./.git/*" -exec rm -rf {} + 2>/dev/null || true
fi

# Nettoyer spécifiquement dans build/ (même s'il n'existe pas encore)
if [ -d "build" ]; then
    find build -type f \( -name "._*" -o -name ".!*!._*" -o -name ".DS_Store" \) -delete 2>/dev/null || true
    # Nettoyer spécifiquement le répertoire javac et intermediates qui causent des problèmes
    if [ -d "build/app/intermediates" ]; then
        find build/app/intermediates -type f \( -name "._*" -o -name ".!*!._*" \) -delete 2>/dev/null || true
    fi
    if [ -d "build/app/intermediates/javac" ]; then
        find build/app/intermediates/javac -type f \( -name "._*" -o -name ".!*!._*" \) -delete 2>/dev/null || true
    fi
    # Nettoyer aussi dans tmp/kotlin-classes
    if [ -d "build/app/tmp/kotlin-classes" ]; then
        find build/app/tmp/kotlin-classes -type f \( -name "._*" -o -name ".!*!._*" \) -delete 2>/dev/null || true
    fi
fi

# Lancer un script de surveillance en arrière-plan pour supprimer les fichiers pendant le build
WATCH_SCRIPT="android/watch-macos-files.sh"
if [ -f "$WATCH_SCRIPT" ]; then
    chmod +x "$WATCH_SCRIPT"
    "$WATCH_SCRIPT" &
    WATCH_PID=$!
    echo -e "${GREEN}✅ Surveillance des fichiers macOS activée (PID: $WATCH_PID)${NC}"
    # Tuer le processus de surveillance à la fin
    trap "kill $WATCH_PID 2>/dev/null || true" EXIT
else
    # Fallback : surveillance simple en arrière-plan
    (
        while true; do
            sleep 0.5
            if [ -d "build" ]; then
                find build -type f \( -name "._*" -o -name ".!*!._*" \) -delete 2>/dev/null || true
            fi
        done
    ) &
    WATCH_PID=$!
    echo -e "${GREEN}✅ Surveillance simple activée (PID: $WATCH_PID)${NC}"
    trap "kill $WATCH_PID 2>/dev/null || true" EXIT
fi

echo -e "${GREEN}✅ Nettoyage terminé${NC}"
echo ""

# ========================================================================
# ÉTAPE 5 : Nettoyage Flutter (si nécessaire)
# ========================================================================
echo -e "${YELLOW}🧹 Étape 5 : Nettoyage Flutter (si nécessaire)${NC}"

# Nettoyer seulement si build/ existe et contient des erreurs
if [ -d "build" ] && [ -d "build/app/intermediates" ]; then
    echo "   Nettoyage du build précédent..."
    flutter clean > /dev/null 2>&1 || true
    echo -e "${GREEN}✅ Build nettoyé${NC}"
else
    echo -e "${GREEN}✅ Pas de nettoyage nécessaire${NC}"
fi
echo ""

# ========================================================================
# ÉTAPE 6 : Récupération des dépendances
# ========================================================================
echo -e "${YELLOW}📦 Étape 6 : Récupération des dépendances${NC}"

flutter pub get
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Erreur: Échec de la récupération des dépendances${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Dépendances récupérées${NC}"
echo ""

# ========================================================================
# ÉTAPE 7 : Analyse rapide (optionnelle, non bloquante)
# ========================================================================
echo -e "${YELLOW}🔍 Étape 7 : Analyse rapide du code (optionnelle)${NC}"

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
# ÉTAPE 8 : Lancement de l'app
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
    # Utiliser le script wrapper pour flutter run avec l'ID de l'appareil
    env GRADLE_USER_HOME="$HOME/.gradle" \
        GRADLE_OPTS="-Dorg.gradle.user.home=$HOME/.gradle -Duser.home=$HOME" \
        flutter run -d "$DEVICE_ID"
else
    echo "   Lancement direct avec Flutter..."
    env GRADLE_USER_HOME="$HOME/.gradle" \
        GRADLE_OPTS="-Dorg.gradle.user.home=$HOME/.gradle -Duser.home=$HOME" \
        flutter run -d "$DEVICE_ID"
fi

# Le script se termine ici si flutter run réussit
# Si erreur, le set -e fera échouer le script

