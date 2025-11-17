#!/bin/bash
# Script ULTRA-AGGRESSIF pour empêcher macOS de créer des fichiers cachés
# Ce script doit être exécuté AVANT chaque build

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🛡️  Prévention des fichiers macOS cachés${NC}"

# Obtenir le répertoire du script
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# 1. Désactiver la création de fichiers ._* sur ce volume (si possible)
echo -e "${YELLOW}📋 Configuration du système...${NC}"

# Créer un attribut étendu pour empêcher la création de fichiers AppleDouble
# Note: Cela fonctionne seulement si le volume le supporte
if command -v xattr &> /dev/null; then
    # Marquer le répertoire pour ne pas créer de fichiers AppleDouble
    cd "$PROJECT_ROOT"
    find . -type d -maxdepth 3 -exec xattr -w com.apple.FinderInfo "0000000000000000040000000000000000000000000000000000000000000000" {} \; 2>/dev/null || true
fi

# 2. Supprimer TOUS les fichiers macOS cachés de manière agressive
echo -e "${YELLOW}🧹 Suppression agressive des fichiers macOS cachés...${NC}"

cd "$PROJECT_ROOT"

# Compter avant suppression (inclure .gradle dans le nettoyage)
BEFORE_COUNT=$(find . -type f \( -name "._*" -o -name ".DS_Store" \) ! -path "./.git/*" 2>/dev/null | wc -l | tr -d ' ')

if [ "$BEFORE_COUNT" -gt 0 ]; then
    echo -e "${YELLOW}📊 Trouvé $BEFORE_COUNT fichiers macOS cachés${NC}"
    
    # Supprimer de manière récursive et agressive
    find . -type f -name "._*" ! -path "./.git/*" -delete 2>/dev/null || true
    find . -type f -name ".DS_Store" ! -path "./.git/*" -delete 2>/dev/null || true
    find . -type d -name ".AppleDouble" ! -path "./.git/*" -exec rm -rf {} + 2>/dev/null || true
    find . -type d -name ".Spotlight-V100" ! -path "./.git/*" -exec rm -rf {} + 2>/dev/null || true
    find . -type d -name ".Trashes" ! -path "./.git/*" -exec rm -rf {} + 2>/dev/null || true
    
    # Nettoyer spécifiquement dans les répertoires de build et Gradle
    for dir in build .gradle .dart_tool android/.gradle; do
        if [ -d "$dir" ]; then
            find "$dir" -type f \( -name "._*" -o -name ".DS_Store" \) -delete 2>/dev/null || true
        fi
    done
    
    # Nettoyer aussi dans arkalia_cia/android/.gradle si on est à la racine
    if [ -d "arkalia_cia/android/.gradle" ]; then
        find "arkalia_cia/android/.gradle" -type f \( -name "._*" -o -name ".DS_Store" \) -delete 2>/dev/null || true
    fi
    
    # Vérifier après suppression
    AFTER_COUNT=$(find . -type f \( -name "._*" -o -name ".DS_Store" \) ! -path "./.git/*" 2>/dev/null | wc -l | tr -d ' ')
    
    if [ "$AFTER_COUNT" -eq 0 ]; then
        echo -e "${GREEN}✅ Tous les fichiers macOS cachés ont été supprimés ($BEFORE_COUNT fichiers)${NC}"
    else
        echo -e "${YELLOW}⚠️  Il reste $AFTER_COUNT fichiers (peut-être verrouillés)${NC}"
    fi
else
    echo -e "${GREEN}✅ Aucun fichier macOS caché trouvé${NC}"
fi

# 3. Créer un fichier .gitattributes pour empêcher Git de créer ces fichiers
GITATTRIBUTES="$PROJECT_ROOT/.gitattributes"
if [ ! -f "$GITATTRIBUTES" ] || ! grep -q "._*" "$GITATTRIBUTES"; then
    echo -e "${YELLOW}📝 Création/mise à jour de .gitattributes...${NC}"
    cat >> "$GITATTRIBUTES" << 'EOF'
# Empêcher Git de traiter les fichiers macOS cachés
._* filter=gitignore
._* -text
.DS_Store filter=gitignore
.DS_Store -text
EOF
    echo -e "${GREEN}✅ .gitattributes mis à jour${NC}"
fi

# 4. Configurer Git pour ignorer ces fichiers
git config --local core.attributesFile "$GITATTRIBUTES" 2>/dev/null || true

echo -e "${GREEN}✅ Prévention terminée${NC}"

