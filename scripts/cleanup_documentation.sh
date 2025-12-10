#!/bin/bash
# Script pour nettoyer la documentation redondante dans docs/deployment/
# Consolide les fichiers RESUME_FINAL et archive les anciens

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🧹 Nettoyage de la documentation redondante${NC}"
echo ""

# Créer le dossier archive si nécessaire
ARCHIVE_DIR="$PROJECT_ROOT/docs/archive/deployment_resumes"
mkdir -p "$ARCHIVE_DIR"

# Liste des fichiers RESUME_FINAL à archiver (garder seulement GUIDE_DEPLOIEMENT_FINAL.md)
FILES_TO_ARCHIVE=(
    "docs/deployment/RESUME_FINAL_AUTHENTIFICATION_WEB.md"
    "docs/deployment/RESUME_FINAL_COMPLET.md"
    "docs/deployment/RESUME_FINAL_DEPLOIEMENT.md"
    "docs/deployment/RESUME_FINAL_DEPLOIEMENT_COMPLET.md"
    "docs/deployment/RESUME_FINAL_NETTOYAGE.md"
    "docs/deployment/RESUME_FINAL_PWA.md"
)

# Archiver les fichiers
ARCHIVED=0
for file in "${FILES_TO_ARCHIVE[@]}"; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        echo -e "${YELLOW}📦 Archivage de $filename...${NC}"
        mv "$file" "$ARCHIVE_DIR/$filename"
        ARCHIVED=$((ARCHIVED + 1))
    fi
done

if [ $ARCHIVED -gt 0 ]; then
    echo -e "${GREEN}✅ $ARCHIVED fichier(s) archivé(s) dans $ARCHIVE_DIR${NC}"
else
    echo -e "${BLUE}ℹ️  Aucun fichier à archiver${NC}"
fi

echo ""
echo -e "${GREEN}✅ Nettoyage terminé${NC}"
echo ""
echo "📝 Note: Les fichiers ont été déplacés vers docs/archive/deployment_resumes/"
echo "   Le fichier GUIDE_DEPLOIEMENT_FINAL.md reste dans docs/deployment/ comme référence principale"
