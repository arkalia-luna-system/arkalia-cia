#!/bin/bash
# Script pour DÉSACTIVER la création de fichiers macOS cachés sur ce volume
# Ce script doit être exécuté UNE FOIS pour configurer le système

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🛡️  Désactivation de la création de fichiers macOS cachés${NC}"
echo ""

# Obtenir le répertoire du projet
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$(cd "$PROJECT_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

# 1. Désactiver la création de fichiers ._* via les attributs étendus
echo -e "${YELLOW}📋 Configuration des attributs étendus...${NC}"

if command -v xattr &> /dev/null; then
    # Marquer les répertoires principaux pour empêcher la création de fichiers AppleDouble
    DIRS_TO_MARK=(
        "arkalia_cia"
        "arkalia_cia/android"
        "arkalia_cia/android/.gradle"
        "arkalia_cia/build"
        "arkalia_cia/.dart_tool"
    )
    
    for dir in "${DIRS_TO_MARK[@]}"; do
        if [ -d "$dir" ]; then
            # Essayer de désactiver la création de fichiers AppleDouble
            # Note: Cela ne fonctionne pas toujours sur tous les volumes
            xattr -w com.apple.FinderInfo "0000000000000000040000000000000000000000000000000000000000000000" "$dir" 2>/dev/null || true
            echo -e "${GREEN}   ✅ $dir configuré${NC}"
        fi
    done
else
    echo -e "${YELLOW}   ⚠️  xattr non disponible, cette étape est ignorée${NC}"
fi

# 2. Créer un fichier .gitattributes pour empêcher Git de traiter ces fichiers
echo -e "${YELLOW}📝 Configuration de .gitattributes...${NC}"
GITATTRIBUTES="$PROJECT_ROOT/.gitattributes"

if [ ! -f "$GITATTRIBUTES" ]; then
    cat > "$GITATTRIBUTES" << 'EOF'
# Empêcher Git de traiter les fichiers macOS cachés
._* filter=gitignore
._* -text
._* -diff
.DS_Store filter=gitignore
.DS_Store -text
.DS_Store -diff
.AppleDouble filter=gitignore
.Spotlight-V100 filter=gitignore
.Trashes filter=gitignore
EOF
    echo -e "${GREEN}   ✅ .gitattributes créé${NC}"
else
    # Vérifier si les règles sont déjà présentes
    if ! grep -q "._\*" "$GITATTRIBUTES"; then
        cat >> "$GITATTRIBUTES" << 'EOF'

# Empêcher Git de traiter les fichiers macOS cachés
._* filter=gitignore
._* -text
._* -diff
.DS_Store filter=gitignore
.DS_Store -text
.DS_Store -diff
.AppleDouble filter=gitignore
.Spotlight-V100 filter=gitignore
.Trashes filter=gitignore
EOF
        echo -e "${GREEN}   ✅ .gitattributes mis à jour${NC}"
    else
        echo -e "${YELLOW}   ℹ️  .gitattributes déjà configuré${NC}"
    fi
fi

# 3. Configurer Git pour utiliser ce fichier
echo -e "${YELLOW}🔧 Configuration de Git...${NC}"
git config --local core.attributesFile "$GITATTRIBUTES" 2>/dev/null || true
echo -e "${GREEN}   ✅ Git configuré${NC}"

# 4. Créer un script de nettoyage automatique qui s'exécute via Git hooks
echo -e "${YELLOW}🪝 Configuration des Git hooks...${NC}"
GIT_HOOKS_DIR="$PROJECT_ROOT/.git/hooks"
PRE_COMMIT_HOOK="$GIT_HOOKS_DIR/pre-commit"

if [ -d "$GIT_HOOKS_DIR" ]; then
    cat > "$PRE_COMMIT_HOOK" << 'HOOK_EOF'
#!/bin/bash
# Git hook pour supprimer les fichiers macOS avant chaque commit

# Supprimer les fichiers macOS cachés
find . -name "._*" -type f ! -path "./.git/*" -delete 2>/dev/null || true
find . -name ".DS_Store" -type f ! -path "./.git/*" -delete 2>/dev/null || true

# Vérifier s'il reste des fichiers
REMAINING=$(find . -name "._*" -o -name ".DS_Store" ! -path "./.git/*" 2>/dev/null | wc -l | tr -d ' ')

if [ "$REMAINING" -gt 0 ]; then
    echo "⚠️  Attention: $REMAINING fichiers macOS détectés, suppression..."
    find . -name "._*" -type f ! -path "./.git/*" -delete 2>/dev/null || true
    find . -name ".DS_Store" -type f ! -path "./.git/*" -delete 2>/dev/null || true
fi

exit 0
HOOK_EOF
    chmod +x "$PRE_COMMIT_HOOK"
    echo -e "${GREEN}   ✅ Git hook pre-commit créé${NC}"
else
    echo -e "${YELLOW}   ⚠️  .git/hooks n'existe pas (pas un dépôt Git?)${NC}"
fi

# 5. Instructions pour désactiver au niveau système (optionnel)
echo ""
echo -e "${BLUE}📋 Instructions pour désactiver au niveau système macOS :${NC}"
echo ""
echo "Pour empêcher macOS de créer ces fichiers sur TOUS les volumes externes :"
echo ""
echo "1. Ouvrir Terminal"
echo "2. Exécuter :"
echo "   defaults write com.apple.desktopservices DSDontWriteNetworkStores true"
echo "   defaults write com.apple.desktopservices DSDontWriteUSBStores true"
echo ""
echo "3. Redémarrer macOS ou se déconnecter/reconnecter"
echo ""
echo -e "${YELLOW}⚠️  Note: Ces paramètres s'appliquent à TOUS les volumes externes${NC}"
echo ""

# 6. Nettoyer les fichiers existants
echo -e "${YELLOW}🧹 Nettoyage des fichiers existants...${NC}"
./arkalia_cia/android/prevent-macos-files.sh || true

echo ""
echo -e "${GREEN}✅ Configuration terminée !${NC}"
echo ""
echo -e "${YELLOW}💡 Prochaines étapes :${NC}"
echo "   1. Exécutez ce script une fois : ./arkalia_cia/android/disable-macos-files.sh"
echo "   2. Utilisez ./arkalia_cia/android/prevent-macos-files.sh avant chaque build"
echo "   3. Utilisez ./arkalia_cia/android/build-android.sh pour vos builds"
echo ""

