#!/bin/bash
# Script pour vérifier que l'app iOS fonctionne correctement

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "🔍 Vérification de l'app iOS"
echo "============================"
echo ""

cd /Volumes/T7/arkalia-cia/arkalia_cia

# 1. Vérifier que l'app est compilée
echo -e "${YELLOW}1. Vérification de la compilation...${NC}"
if [ -f "build/ios/iphoneos/Runner.app/Runner" ]; then
    SIZE=$(ls -lh build/ios/iphoneos/Runner.app/Runner | awk '{print $5}')
    echo -e "${GREEN}✅ App compilée avec succès (Taille: $SIZE)${NC}"
else
    echo -e "${RED}❌ App non compilée${NC}"
    exit 1
fi

# 2. Vérifier que l'iPad est connecté
echo -e "${YELLOW}2. Vérification de l'iPad...${NC}"
if flutter devices 2>&1 | grep -q "iPad"; then
    IPAD=$(flutter devices 2>&1 | grep "iPad" | head -1)
    echo -e "${GREEN}✅ iPad détecté: $IPAD${NC}"
else
    echo -e "${RED}❌ Aucun iPad détecté${NC}"
    echo "   Assurez-vous que l'iPad est branché et déverrouillé"
fi

# 3. Vérifier Xcode
echo -e "${YELLOW}3. Vérification de Xcode...${NC}"
if flutter doctor -v 2>&1 | grep -q "Xcode.*develop for iOS"; then
    XCODE_VERSION=$(flutter doctor -v 2>&1 | grep "Xcode" | head -1 | sed 's/.*Xcode //' | sed 's/).*//')
    echo -e "${GREEN}✅ Xcode configuré ($XCODE_VERSION)${NC}"
else
    echo -e "${RED}❌ Xcode non configuré${NC}"
fi

# 4. Vérifier CocoaPods
echo -e "${YELLOW}4. Vérification de CocoaPods...${NC}"
if flutter doctor -v 2>&1 | grep -q "CocoaPods version"; then
    POD_VERSION=$(flutter doctor -v 2>&1 | grep "CocoaPods version" | sed 's/.*version //')
    echo -e "${GREEN}✅ CocoaPods installé (version $POD_VERSION)${NC}"
else
    echo -e "${RED}❌ CocoaPods non détecté${NC}"
fi

# 5. Vérifier les Pods
echo -e "${YELLOW}5. Vérification des dépendances...${NC}"
if [ -d "ios/Pods" ] && [ -f "ios/Podfile.lock" ]; then
    POD_COUNT=$(find ios/Pods -maxdepth 1 -type d | wc -l | tr -d ' ')
    echo -e "${GREEN}✅ Dépendances installées ($POD_COUNT pods)${NC}"
else
    echo -e "${RED}❌ Dépendances non installées${NC}"
fi

# 6. Vérifier les fichiers macOS cachés (avertissement seulement)
echo -e "${YELLOW}6. Vérification des fichiers macOS cachés...${NC}"
MACOS_FILES=$(find build/ios -name "._*" -type f 2>/dev/null | wc -l | tr -d ' ')
if [ "$MACOS_FILES" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  $MACOS_FILES fichiers macOS cachés trouvés (non bloquant)${NC}"
    echo "   Exécutez: ./prevent_macos_files_pods.sh pour nettoyer"
else
    echo -e "${GREEN}✅ Aucun fichier macOS caché${NC}"
fi

echo ""
echo -e "${GREEN}========================================"
echo "📱 COMMENT VÉRIFIER SUR L'IPAD"
echo "========================================"
echo ""
echo "1. Sur votre iPad, cherchez l'icône de l'app 'arkaliaCia'"
echo "   (elle devrait être sur l'écran d'accueil)"
echo ""
echo "2. Si l'app est installée :"
echo "   ✅ Ouvrez-la et testez les fonctionnalités"
echo "   ✅ Vérifiez que tout fonctionne normalement"
echo ""
echo "3. Si l'app n'est pas visible :"
echo "   → Retournez dans Xcode"
echo "   → Cliquez sur ▶️ Play (ou Cmd+R)"
echo "   → Attendez la fin de la compilation"
echo ""
echo "4. Pour vérifier depuis le terminal :"
echo "   flutter run"
echo ""
echo -e "${GREEN}✅ Vérification terminée !${NC}"

