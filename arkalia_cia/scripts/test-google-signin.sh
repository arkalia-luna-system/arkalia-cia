#!/bin/bash
# Script pour tester Google Sign-In et voir les logs détaillés

set -e

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}🔍 Test Google Sign-In avec logs détaillés${NC}"
echo ""

# Nettoyer les logs
echo "🧹 Nettoyage des logs Android..."
adb logcat -c

echo ""
echo "📱 Instructions:"
echo "   1. L'app va se lancer"
echo "   2. Clique sur 'Continuer avec Gmail'"
echo "   3. Appuie sur Ctrl+C ici pour voir les logs"
echo ""
echo "⏳ Lancement de l'app dans 3 secondes..."
sleep 3

# Lancer l'app en arrière-plan
cd /Volumes/T7/arkalia-cia/arkalia_cia
bash scripts/run-android.sh &
APP_PID=$!

# Attendre un peu
sleep 5

echo ""
echo "✅ App lancée (PID: $APP_PID)"
echo ""
echo "📋 Logs Google Sign-In (Ctrl+C pour arrêter):"
echo ""

# Capturer les logs
adb logcat | grep -i "google\|signin\|auth\|oauth\|GetTokenResponseHandler" --color=always

