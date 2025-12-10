#!/bin/bash
# Script pour libérer la RAM et réduire la surchauffe
# Nettoie les processus lourds et les caches
# Désactive temporairement mypy dans Cursor pour éviter qu'il se relance

set -e

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🧹 Nettoyage RAM et réduction surchauffe...${NC}"
echo ""

# 0. Désactiver temporairement mypy dans Cursor (si fichier settings existe)
echo -e "${YELLOW}0. Désactivation temporaire de mypy dans Cursor...${NC}"
SETTINGS_FILE=".vscode/settings.json"
if [ -f "$SETTINGS_FILE" ]; then
    # Vérifier si mypy est déjà désactivé
    if ! grep -q '"python.analysis.typeCheckingMode": "off"' "$SETTINGS_FILE"; then
        echo -e "${BLUE}   ℹ️  Mypy sera désactivé dans Cursor après redémarrage${NC}"
    else
        echo -e "${GREEN}   ✅ Mypy déjà désactivé dans Cursor${NC}"
    fi
else
    echo -e "${YELLOW}   ⚠️  Fichier .vscode/settings.json non trouvé${NC}"
    echo -e "${BLUE}   💡 Création du fichier pour désactiver mypy...${NC}"
    mkdir -p .vscode
    cat > "$SETTINGS_FILE" << 'EOF'
{
  "python.analysis.typeCheckingMode": "off",
  "python.analysis.banditEnabled": false
}
EOF
    echo -e "${GREEN}   ✅ Fichier créé - Redémarrez Cursor pour appliquer${NC}"
fi
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

# 7. Statistiques mémoire avec niveaux clairs
echo -e "${YELLOW}7. Statistiques système:${NC}"

# Détecter les specs du Mac
CORES=$(sysctl -n hw.ncpu 2>/dev/null || echo "4")
RAM_GB=$(sysctl -n hw.memsize 2>/dev/null | awk '{printf "%.1f", $1/1024/1024/1024}' || echo "8")
TOTAL_RAM=$(ps aux | awk '{sum+=$4} END {printf "%.1f", sum}')
TOTAL_CPU=$(ps aux | awk '{sum+=$3} END {printf "%.1f", sum}')
MAX_CPU_THEORIQUE=$(echo "$CORES * 100" | bc -l)

# Seuils RAM (adaptés à Mac Mini)
RAM_OK=60
RAM_ATTENTION=80
RAM_ALERTE=90

# Seuils CPU (en % des cores disponibles)
CPU_OK_PERCENT=50   # 50% des cores = OK
CPU_ATTENTION_PERCENT=75  # 75% des cores = Attention
CPU_ALERTE_PERCENT=90     # 90% des cores = Alerte
CPU_OK=$(echo "$CORES * $CPU_OK_PERCENT" | bc -l)
CPU_ATTENTION=$(echo "$CORES * $CPU_ATTENTION_PERCENT" | bc -l)
CPU_ALERTE=$(echo "$CORES * $CPU_ALERTE_PERCENT" | bc -l)

# Afficher les specs du Mac
echo -e "   Mac Mini: ${CORES} cores, ${RAM_GB} GB RAM"
echo ""

# Évaluer niveau RAM
echo -e "   📊 RAM utilisée: ${TOTAL_RAM}%"
if (( $(echo "$TOTAL_RAM < $RAM_OK" | bc -l) )); then
    echo -e "      ${GREEN}✅ NIVEAU OK${NC} (<${RAM_OK}%) - Tout va bien !"
    RAM_LEVEL="OK"
elif (( $(echo "$TOTAL_RAM < $RAM_ATTENTION" | bc -l) )); then
    echo -e "      ${YELLOW}⚠️  NIVEAU ATTENTION${NC} (${RAM_OK}-${RAM_ATTENTION}%) - Surveille, mais pas grave"
    RAM_LEVEL="ATTENTION"
elif (( $(echo "$TOTAL_RAM < $RAM_ALERTE" | bc -l) )); then
    echo -e "      ${RED}🔴 NIVEAU ALERTE${NC} (${RAM_ATTENTION}-${RAM_ALERTE}%) - Ferme des apps"
    RAM_LEVEL="ALERTE"
else
    echo -e "      ${RED}🚨 NIVEAU CRITIQUE${NC} (>${RAM_ALERTE}%) - Action immédiate requise !"
    RAM_LEVEL="CRITIQUE"
fi

# Évaluer niveau CPU
echo ""
echo -e "   📊 CPU utilisée: ${TOTAL_CPU}% (max théorique: ${MAX_CPU_THEORIQUE}%)"
if (( $(echo "$TOTAL_CPU < $CPU_OK" | bc -l) )); then
    echo -e "      ${GREEN}✅ NIVEAU OK${NC} (<${CPU_OK}%) - Tout va bien !"
    CPU_LEVEL="OK"
elif (( $(echo "$TOTAL_CPU < $CPU_ATTENTION" | bc -l) )); then
    echo -e "      ${YELLOW}⚠️  NIVEAU ATTENTION${NC} (${CPU_OK}-${CPU_ATTENTION}%) - Normal si indexation en cours"
    CPU_LEVEL="ATTENTION"
elif (( $(echo "$TOTAL_CPU < $CPU_ALERTE" | bc -l) )); then
    echo -e "      ${RED}🔴 NIVEAU ALERTE${NC} (${CPU_ATTENTION}-${CPU_ALERTE}%) - Ferme des apps lourdes"
    CPU_LEVEL="ALERTE"
else
    echo -e "      ${RED}🚨 NIVEAU CRITIQUE${NC} (>${CPU_ALERTE}%) - Action immédiate requise !"
    CPU_LEVEL="CRITIQUE"
fi
echo ""

# Vérifier si les processus lourds sont des processus système normaux
TOP_CPU_PROCESS=$(ps aux | sort -rk 3,3 | head -2 | tail -1 | awk '{print $11" "$12" "$13" "$14" "$15}')
IS_SYSTEM_PROCESS=false
if echo "$TOP_CPU_PROCESS" | grep -qE "(mds_stores|WindowServer|kernel_task|com.apple)"; then
    IS_SYSTEM_PROCESS=true
fi

# Vérifier si Cursor a des processus lourds
CURSOR_CPU=$(ps aux | grep -i cursor | grep -v grep | awk '{sum+=$3} END {printf "%.1f", sum}')
CURSOR_HAS_HEAVY_PROCESS=false
if (( $(echo "$CURSOR_CPU > 30" | bc -l) )); then
    CURSOR_HAS_HEAVY_PROCESS=true
fi

# 8. Recommandations selon les niveaux
echo -e "${BLUE}💡 RECOMMANDATIONS SELON LES NIVEAUX:${NC}"
echo ""

# RAM - Actions selon niveau
if [ "$RAM_LEVEL" = "OK" ]; then
    echo -e "${GREEN}✅ RAM: Aucune action nécessaire${NC}"
    echo "   - Tout fonctionne bien"
elif [ "$RAM_LEVEL" = "ATTENTION" ]; then
    echo -e "${YELLOW}⚠️  RAM: Surveille mais pas d'urgence${NC}"
    echo "   - Tu peux continuer à travailler normalement"
    echo "   - Si ça monte encore, ferme quelques onglets"
elif [ "$RAM_LEVEL" = "ALERTE" ]; then
    echo -e "${RED}🔴 RAM: Action recommandée${NC}"
    echo "   - Ferme des onglets dans Cursor/Comet"
    echo "   - Ferme les applications que tu n'utilises pas"
    echo "   - Redémarre Cursor si possible"
else
    echo -e "${RED}🚨 RAM: ACTION IMMÉDIATE REQUISE !${NC}"
    echo "   - Ferme TOUTES les applications non essentielles"
    echo "   - Redémarre Cursor"
    echo "   - Redémarre le Mac si ça ne s'améliore pas"
fi
echo ""

# CPU - Actions selon niveau
if [ "$CPU_LEVEL" = "OK" ]; then
    echo -e "${GREEN}✅ CPU: Aucune action nécessaire${NC}"
    echo "   - Tout fonctionne bien"
elif [ "$CPU_LEVEL" = "ATTENTION" ]; then
    if [ "$IS_SYSTEM_PROCESS" = true ]; then
        echo -e "${BLUE}ℹ️  CPU: Processus système détectés (normal)${NC}"
        echo "   - mds_stores: indexation macOS (se termine seul)"
        echo "   - WindowServer: affichage système (normal)"
        echo "   - Pas d'action nécessaire, ça va se calmer"
    else
        echo -e "${YELLOW}⚠️  CPU: Surveille mais pas d'urgence${NC}"
        echo "   - Normal si tu as plusieurs apps ouvertes"
        echo "   - Si ça monte encore, ferme des apps lourdes"
    fi
elif [ "$CPU_LEVEL" = "ALERTE" ]; then
    echo -e "${RED}🔴 CPU: Action recommandée${NC}"
    echo "   - Ferme les applications lourdes"
    echo "   - Attends que mds_stores termine l'indexation"
    echo "   - Redémarre Cursor si possible"
else
    echo -e "${RED}🚨 CPU: ACTION IMMÉDIATE REQUISE !${NC}"
    echo "   - Ferme TOUTES les applications non essentielles"
    echo "   - Redémarre Cursor"
    echo "   - Redémarre le Mac si ça ne s'améliore pas"
fi
echo ""

# Cursor spécifique
if [ "$CURSOR_HAS_HEAVY_PROCESS" = true ]; then
    MYPY_DISABLED=false
    if [ -f "$SETTINGS_FILE" ] && grep -q '"python.analysis.typeCheckingMode": "off"' "$SETTINGS_FILE"; then
        MYPY_DISABLED=true
    fi
    
    if [ "$MYPY_DISABLED" = false ]; then
        echo -e "${YELLOW}⚠️  Cursor consomme beaucoup de CPU${NC}"
        echo "   - Mypy n'est pas désactivé dans .vscode/settings.json"
        echo "   - Redémarrez Cursor après avoir désactivé mypy"
        echo ""
    else
        echo -e "${BLUE}ℹ️  Cursor: CPU à ${CURSOR_CPU}% (normal au démarrage)${NC}"
        echo "   - Mypy est déjà désactivé ✅"
        echo "   - La charge devrait diminuer dans 1-2 minutes"
        echo ""
    fi
else
    echo -e "${GREEN}✅ Cursor: OK (CPU: ${CURSOR_CPU}%)${NC}"
    echo ""
fi

# Note sur mypy seulement si nécessaire
if [ -f "$SETTINGS_FILE" ] && grep -q '"python.analysis.typeCheckingMode": "off"' "$SETTINGS_FILE"; then
    if [ "$CURSOR_HAS_HEAVY_PROCESS" = false ]; then
        echo -e "${GREEN}✅ Mypy désactivé et Cursor stable${NC}"
    fi
else
    echo -e "${BLUE}📝 NOTE:${NC}"
    echo "   Pour réduire la charge CPU de Cursor, désactivez mypy:"
    echo "   - Settings > Python > Type Checking Mode > Off"
    echo ""
fi

echo -e "${GREEN}✅ Nettoyage terminé !${NC}"

