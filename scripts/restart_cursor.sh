#!/bin/bash
# Script pour redémarrer Cursor en préservant l'état (fichiers ouverts, etc.)
# Cursor restaure automatiquement la session précédente

set -e

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔄 Redémarrage de Cursor...${NC}"
echo ""

# Vérifier si Cursor est ouvert
if pgrep -f "Cursor.app" > /dev/null; then
    echo -e "${YELLOW}📝 Fermeture de Cursor (sauvegarde de l'état en cours)...${NC}"
    
    # Fermer Cursor proprement avec AppleScript (sauvegarde automatique de l'état)
    osascript -e 'tell application "Cursor" to quit' 2>/dev/null || {
        echo -e "${YELLOW}⚠️  Fermeture via AppleScript échouée, tentative avec kill...${NC}"
        pkill -SIGTERM -f "Cursor.app" || true
    }
    
    # Attendre que Cursor se ferme complètement
    echo -e "${BLUE}⏳ Attente de la fermeture complète...${NC}"
    for i in {1..10}; do
        if ! pgrep -f "Cursor.app" > /dev/null; then
            break
        fi
        sleep 0.5
    done
    
    # Si Cursor est toujours ouvert, forcer la fermeture
    if pgrep -f "Cursor.app" > /dev/null; then
        echo -e "${YELLOW}⚠️  Fermeture forcée...${NC}"
        pkill -9 -f "Cursor.app" || true
        sleep 1
    fi
    
    echo -e "${GREEN}✅ Cursor fermé${NC}"
    echo ""
    
    # Attendre un peu pour que tout soit bien sauvegardé
    sleep 2
    
    echo -e "${BLUE}🚀 Réouverture de Cursor...${NC}"
    
    # Rouvrir Cursor (il restaurera automatiquement la session précédente)
    open -a "Cursor" 2>/dev/null || {
        echo -e "${YELLOW}⚠️  Impossible de rouvrir Cursor automatiquement${NC}"
        echo -e "${BLUE}💡 Ouvre Cursor manuellement depuis le Dock ou Applications${NC}"
        exit 1
    }
    
    echo -e "${GREEN}✅ Cursor en cours de réouverture...${NC}"
    echo ""
    echo -e "${BLUE}⏳ Attente du chargement complet (5 secondes)...${NC}"
    sleep 5
    
    # Vérifier que Cursor est bien ouvert
    if pgrep -f "Cursor.app" > /dev/null; then
        echo -e "${GREEN}✅ Cursor est maintenant ouvert !${NC}"
        echo ""
        echo -e "${BLUE}📋 Vérifications à faire :${NC}"
        echo "   1. Vérifier que tous les fichiers sont toujours ouverts"
        echo "   2. Vérifier que mypy ne se relance plus automatiquement"
        echo "   3. Vérifier la charge CPU (devrait être plus basse)"
    else
        echo -e "${YELLOW}⚠️  Cursor ne semble pas s'être ouvert correctement${NC}"
        echo -e "${BLUE}💡 Essaie de l'ouvrir manuellement${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}⚠️  Cursor n'est pas ouvert${NC}"
    echo -e "${BLUE}🚀 Ouverture de Cursor...${NC}"
    open -a "Cursor" 2>/dev/null || {
        echo -e "${YELLOW}⚠️  Impossible d'ouvrir Cursor${NC}"
        exit 1
    }
    echo -e "${GREEN}✅ Cursor ouvert !${NC}"
fi

echo ""
echo -e "${GREEN}✅ Redémarrage terminé !${NC}"


