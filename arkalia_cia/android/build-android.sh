#!/bin/bash
# Script wrapper pour forcer Gradle à utiliser ~/.gradle
# Utilisez ce script au lieu de flutter build directement

set -e

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🔧 Configuration Gradle pour build Android${NC}"

# Forcer les variables d'environnement Gradle
export GRADLE_USER_HOME="$HOME/.gradle"
export GRADLE_OPTS="-Dorg.gradle.user.home=$HOME/.gradle -Duser.home=$HOME"

# Obtenir le répertoire du script (android/)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Arrêter tous les daemons Gradle existants
echo -e "${YELLOW}🛑 Arrêt des daemons Gradle existants...${NC}"
if [ -f "$SCRIPT_DIR/gradlew" ]; then
    cd "$SCRIPT_DIR"
    ./gradlew --stop 2>/dev/null || true
    cd - > /dev/null
fi

# Attendre un peu pour que les daemons se terminent
sleep 2

# Vérifier que le répertoire .gradle existe
if [ ! -d "$HOME/.gradle" ]; then
    echo -e "${YELLOW}📁 Création du répertoire $HOME/.gradle${NC}"
    mkdir -p "$HOME/.gradle"
fi

# Afficher les variables d'environnement
echo -e "${GREEN}✅ Variables d'environnement:${NC}"
echo "   GRADLE_USER_HOME=$GRADLE_USER_HOME"
echo "   GRADLE_OPTS=$GRADLE_OPTS"
echo "   HOME=$HOME"

# Retourner au répertoire du projet Flutter (arkalia_cia/)
# Le script est dans arkalia_cia/android/, donc on remonte d'un niveau
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Vérifier que nous sommes dans le bon répertoire (doit contenir pubspec.yaml)
if [ ! -f "$PROJECT_DIR/pubspec.yaml" ]; then
    echo -e "${RED}❌ Erreur: Impossible de trouver le répertoire du projet Flutter${NC}"
    echo "   SCRIPT_DIR: $SCRIPT_DIR"
    echo "   PROJECT_DIR: $PROJECT_DIR"
    exit 1
fi

# Aller dans le répertoire du projet Flutter
cd "$PROJECT_DIR" || {
    echo -e "${RED}❌ Erreur: Impossible d'accéder au répertoire $PROJECT_DIR${NC}"
    exit 1
}

# Nettoyer les fichiers macOS cachés juste avant le build
echo -e "${YELLOW}🧹 Nettoyage des fichiers macOS avant build...${NC}"

# Utiliser le script de prévention si disponible
PREVENT_SCRIPT="$SCRIPT_DIR/prevent-macos-files.sh"
if [ -f "$PREVENT_SCRIPT" ]; then
    chmod +x "$PREVENT_SCRIPT"
    "$PREVENT_SCRIPT" || true
else
    # Fallback : nettoyage manuel ultra-agressif
    find . -type f \( -name "._*" -o -name ".!*!._*" -o -name ".DS_Store" \) ! -path "./.git/*" ! -path "./.dart_tool/*" -delete 2>/dev/null || true
    find . -type d \( -name ".AppleDouble" -o -name ".Spotlight-V100" -o -name ".Trashes" \) ! -path "./.git/*" -exec rm -rf {} + 2>/dev/null || true
fi

# Nettoyer spécifiquement dans build/ (même s'il n'existe pas encore)
if [ -d "build" ]; then
    find build -type f \( -name "._*" -o -name ".!*!._*" -o -name ".DS_Store" \) -delete 2>/dev/null || true
    # Nettoyer spécifiquement le répertoire javac qui cause des problèmes avec ArtProfile
    if [ -d "build/app/intermediates/javac" ]; then
        find build/app/intermediates/javac -type f \( -name "._*" -o -name ".!*!._*" \) -delete 2>/dev/null || true
        # Nettoyer aussi dans compileDebugJavaWithJavac/classes/com/arkalia/cia (où MainActivity.class est créé)
        if [ -d "build/app/intermediates/javac/debug/compileDebugJavaWithJavac/classes/com/arkalia/cia" ]; then
            find build/app/intermediates/javac/debug/compileDebugJavaWithJavac/classes/com/arkalia/cia -type f \( -name "._*" -o -name ".!*!._*" \) -delete 2>/dev/null || true
        fi
        echo -e "${GREEN}✅ Répertoire javac nettoyé${NC}"
    fi
    # Nettoyer spécifiquement compile_and_runtime_not_namespaced_r_class_jar (où l'erreur D8 se produit)
    if [ -d "build/app/intermediates/compile_and_runtime_not_namespaced_r_class_jar" ]; then
        find build/app/intermediates/compile_and_runtime_not_namespaced_r_class_jar -type f \( -name "._*" -o -name ".!*!._*" \) -delete 2>/dev/null || true
        echo -e "${GREEN}✅ Répertoire compile_and_runtime_not_namespaced_r_class_jar nettoyé${NC}"
    fi
    # Nettoyer aussi dans kotlin-classes
    if [ -d "build/app/tmp/kotlin-classes" ]; then
        find build/app/tmp/kotlin-classes -type f \( -name "._*" -o -name ".!*!._*" -o -name "._BuildConfig.class" \) -delete 2>/dev/null || true
    fi
    # Nettoyer aussi tous les fichiers ._BuildConfig.class dans build/
    find build -type f -name "._BuildConfig.class" -delete 2>/dev/null || true
    find build -type f -name "._*.class" -delete 2>/dev/null || true
fi

# Lancer un script de surveillance en arrière-plan pour supprimer les fichiers pendant le build
WATCH_SCRIPT="$SCRIPT_DIR/watch-macos-files.sh"
if [ -f "$WATCH_SCRIPT" ]; then
    chmod +x "$WATCH_SCRIPT"
    "$WATCH_SCRIPT" &
    WATCH_PID=$!
    echo -e "${GREEN}✅ Surveillance des fichiers macOS activée (PID: $WATCH_PID)${NC}"
    # Tuer le processus de surveillance à la fin
    trap "kill $WATCH_PID 2>/dev/null || true" EXIT
else
    # Fallback : nettoyage peu fréquent (évite de marteler le disque en boucle)
    (
        while true; do
            sleep 12
            find build -type f \( -name "._*" -o -name ".!*!._*" \) -delete 2>/dev/null || true
        done
    ) &
    WATCH_PID=$!
    echo -e "${GREEN}✅ Surveillance simple activée (PID: $WATCH_PID)${NC}"
    trap "kill $WATCH_PID 2>/dev/null || true" EXIT
fi

# Exécuter la commande Flutter passée en argument
echo -e "${GREEN}🚀 Lancement du build Flutter...${NC}"
echo ""

# Exécuter la commande Flutter avec les variables d'environnement forcées
# S'assurer que nous sommes dans le bon répertoire
cd "$PROJECT_DIR" || {
    echo -e "${RED}❌ Erreur: Impossible d'accéder au répertoire $PROJECT_DIR${NC}"
    exit 1
}

# Exécuter la commande passée en argument (ex: "flutter build apk --debug")
# avec les variables d'environnement forcées
env GRADLE_USER_HOME="$HOME/.gradle" \
    GRADLE_OPTS="-Dorg.gradle.user.home=$HOME/.gradle -Duser.home=$HOME" \
    "$@"

