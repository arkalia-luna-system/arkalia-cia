#!/bin/bash
# Script pour tester Google Sign-In et voir les logs détaillés

set -e

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔍 Test Google Sign-In avec logs détaillés${NC}"
echo ""

# Nettoyer les logs
echo -e "${YELLOW}🧹 Nettoyage des logs Android...${NC}"
adb logcat -c > /dev/null 2>&1
echo -e "${GREEN}✅ Logs nettoyés${NC}"
echo ""

# Arrêter l'app si elle tourne déjà
echo -e "${YELLOW}🛑 Arrêt de l'app si elle tourne...${NC}"
adb shell am force-stop com.arkalia.cia 2>/dev/null || true
adb shell pm clear com.arkalia.cia 2>/dev/null || true
echo -e "${GREEN}✅ App arrêtée${NC}"
echo ""

echo -e "${BLUE}📱 Instructions:${NC}"
echo "   1. L'app va se lancer dans 3 secondes"
echo "   2. Attends que l'app soit complètement chargée"
echo "   3. Clique sur 'Continuer avec Gmail' ou 'Continuer avec Google'"
echo "   4. Les logs vont s'afficher ici en temps réel"
echo "   5. Appuie sur Ctrl+C pour arrêter"
echo ""
echo -e "${YELLOW}⏳ Lancement de l'app dans 3 secondes...${NC}"
sleep 3

# Lancer l'app en arrière-plan
cd /Volumes/T7/arkalia-cia/arkalia_cia
echo -e "${BLUE}🚀 Lancement de l'app...${NC}"
bash scripts/run-android.sh > /tmp/arkalia_test_build.log 2>&1 &
APP_PID=$!

# Attendre que l'app se lance
echo -e "${YELLOW}⏳ Attente du lancement de l'app (15 secondes)...${NC}"
sleep 15

echo ""
echo -e "${GREEN}✅ App lancée (PID: $APP_PID)${NC}"
echo ""
echo -e "${BLUE}📋 Logs Google Sign-In en temps réel:${NC}"
echo -e "${YELLOW}   (Filtre: google|signin|auth|oauth|GetTokenResponseHandler|DEVELOPER_ERROR|PlatformException)${NC}"
echo ""
echo -e "${GREEN}👉 MAINTENANT: Clique sur 'Continuer avec Gmail' dans l'app${NC}"
echo ""

# Capturer les logs avec un filtre plus large
adb logcat | grep -iE "google|signin|auth|oauth|GetTokenResponseHandler|DEVELOPER_ERROR|PlatformException|arkalia.*cia|com\.arkalia\.cia" --color=always | while IFS= read -r line; do
    # Colorer les erreurs en rouge
    if echo "$line" | grep -qiE "error|exception|failed|❌"; then
        echo -e "${RED}$line${NC}"
    # Colorer les succès en vert
    elif echo "$line" | grep -qiE "success|✅|ok"; then
        echo -e "${GREEN}$line${NC}"
    # Colorer les warnings en jaune
    elif echo "$line" | grep -qiE "warning|⚠️|warn"; then
        echo -e "${YELLOW}$line${NC}"
    else
        echo "$line"
    fi
done

