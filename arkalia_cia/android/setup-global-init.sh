#!/bin/bash
# Script pour créer un init.gradle global qui force user.home pour TOUS les projets Gradle
# Ce script crée un fichier dans ~/.gradle/init.d/ qui sera chargé automatiquement

set -e

# Couleurs pour les messages
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🔧 Configuration de l'init.gradle global${NC}"

# Créer le répertoire init.d s'il n'existe pas
INIT_DIR="$HOME/.gradle/init.d"
mkdir -p "$INIT_DIR"

# Créer le fichier init.gradle global
INIT_FILE="$INIT_DIR/force-user-home.gradle"

cat > "$INIT_FILE" << 'EOF'
// Init script global pour forcer Gradle à utiliser ~/.gradle
// Ce script s'exécute pour TOUS les projets Gradle sur cette machine

import org.gradle.api.initialization.Settings

// Forcer user.home au niveau système
def userHome = System.getenv("HOME")
if (userHome == null || userHome.isEmpty()) {
    userHome = System.getProperty("user.home")
}

if (userHome != null && !userHome.isEmpty()) {
    System.setProperty("user.home", userHome)
    println "✅ Init.gradle global: user.home forcé à: $userHome"
} else {
    println "⚠️  Init.gradle global: Impossible de déterminer user.home"
}

// Forcer le gradleUserHomeDir dans les settings
settingsEvaluated { Settings settings ->
    def home = System.getenv("HOME") ?: System.getProperty("user.home")
    if (home != null && !home.isEmpty()) {
        def gradleUserHome = new File(home, ".gradle")
        settings.gradle.gradleUserHomeDir = gradleUserHome
        println "✅ Init.gradle global: Gradle user home forcé à: ${gradleUserHome.absolutePath}"
    }
}
EOF

echo -e "${GREEN}✅ Fichier créé: $INIT_FILE${NC}"
echo ""
echo -e "${YELLOW}📋 Ce fichier sera automatiquement chargé par Gradle pour tous vos projets.${NC}"
echo ""
echo -e "${GREEN}✅ Configuration terminée!${NC}"

