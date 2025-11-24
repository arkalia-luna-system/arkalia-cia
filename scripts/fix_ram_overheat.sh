#!/bin/bash
# Script pour libérer la RAM et réduire la surchauffe
# Nettoie les processus lourds et les caches

set -e

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🧹 Nettoyage RAM et réduction surchauffe...${NC}"
echo ""

# 1. Nettoyer tous les processus du projet
echo -e "${YELLOW}1. Nettoyage des processus du projet...${NC}"
cd "$(dirname "$0")/.."
./scripts/cleanup_all.sh --all 2>&1 | grep -E "✅|⚠️" | head -10
echo ""

# 2. Nettoyer les processus Flutter orphelins
echo -e "${YELLOW}2. Nettoyage processus Flutter orphelins...${NC}"
FLUTTER_PIDS=$(ps aux | grep -E "flutter.*run|dart.*flutter.*run" | grep -v grep | awk '{print $2}' | tr '\n' ' ')
if [ -n "$FLUTTER_PIDS" ]; then
    echo "$FLUTTER_PIDS" | xargs kill -9 2>/dev/null || true
    echo -e "${GREEN}✅ Processus Flutter arrêtés${NC}"
else
    echo -e "${GREEN}✅ Aucun processus Flutter orphelin${NC}"
fi
echo ""

# 3. Nettoyer les processus pytest orphelins
echo -e "${YELLOW}3. Nettoyage processus pytest orphelins...${NC}"
PYTEST_PIDS=$(ps aux | grep -E "pytest|python.*test" | grep -v grep | awk '{print $2}' | tr '\n' ' ')
if [ -n "$PYTEST_PIDS" ]; then
    echo "$PYTEST_PIDS" | xargs kill -9 2>/dev/null || true
    echo -e "${GREEN}✅ Processus pytest arrêtés${NC}"
else
    echo -e "${GREEN}✅ Aucun processus pytest orphelin${NC}"
fi
echo ""

# 4. Purger les caches système (si possible)
echo -e "${YELLOW}4. Purge des caches...${NC}"
# Purger le cache DNS
sudo dscacheutil -flushcache 2>/dev/null || true
sudo killall -HUP mDNSResponder 2>/dev/null || true
echo -e "${GREEN}✅ Cache DNS purgé${NC}"
echo ""

# 5. Afficher les processus les plus lourds
echo -e "${YELLOW}5. Top 5 processus consommant le plus de RAM:${NC}"
ps aux | sort -rk 4,4 | head -6 | tail -5 | awk '{printf "   %s - %s%% RAM (%s MB)\n", $11, $4, $6/1024}'
echo ""

# 6. Afficher les processus les plus lourds en CPU
echo -e "${YELLOW}6. Top 5 processus consommant le plus de CPU:${NC}"
ps aux | sort -rk 3,3 | head -6 | tail -5 | awk '{printf "   %s - %s%% CPU\n", $11, $3}'
echo ""

# 7. Statistiques mémoire
echo -e "${YELLOW}7. Statistiques mémoire:${NC}"
TOTAL_RAM=$(ps aux | awk '{sum+=$4} END {printf "%.1f", sum}')
TOTAL_CPU=$(ps aux | awk '{sum+=$3} END {printf "%.1f", sum}')
echo -e "   RAM totale utilisée: ${RED}${TOTAL_RAM}%${NC}"
echo -e "   CPU totale utilisée: ${RED}${TOTAL_CPU}%${NC}"
echo ""

# 8. Recommandations
echo -e "${BLUE}💡 RECOMMANDATIONS:${NC}"
echo ""
if (( $(echo "$TOTAL_RAM > 80" | bc -l) )); then
    echo -e "${RED}⚠️  RAM très élevée (>80%)${NC}"
    echo "   - Fermez des onglets dans Cursor/Comet"
    echo "   - Redémarrez Cursor si possible"
    echo "   - Fermez les applications inutiles"
fi
if (( $(echo "$TOTAL_CPU > 200" | bc -l) )); then
    echo -e "${RED}⚠️  CPU très élevé (>200%)${NC}"
    echo "   - Attendez que mds_stores termine l'indexation"
    echo "   - Fermez les applications lourdes"
fi
echo ""

echo -e "${GREEN}✅ Nettoyage terminé !${NC}"

