#!/bin/bash

# Script pour finaliser la configuration iOS
# Utilise le bon PATH pour CocoaPods

set -e

cd /Volumes/T7/arkalia-cia/arkalia_cia

# Configurer le PATH pour Ruby et CocoaPods
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export PATH="/Users/athalia/.local/share/gem/ruby/3.4.0/bin:$PATH"

echo "🚀 Finalisation de la configuration iOS"
echo "========================================"
echo ""

# Vérifier CocoaPods
echo "📦 Vérification de CocoaPods..."
if ! command -v pod &> /dev/null; then
    echo "❌ CocoaPods non trouvé dans le PATH"
    echo "   Utilisation du chemin complet..."
    POD_CMD="/Users/athalia/.local/share/gem/ruby/3.4.0/bin/pod"
else
    POD_CMD="pod"
fi

echo "✅ CocoaPods trouvé : $($POD_CMD --version)"
echo ""

# Vérifier si pod install a déjà été fait
if [ -f "ios/Podfile.lock" ] && [ -d "ios/Pods" ]; then
    echo "✅ Dépendances iOS déjà installées"
else
    echo "📦 Installation des dépendances iOS..."
    cd ios
    $POD_CMD install
    cd ..
    echo "✅ Dépendances iOS installées"
fi

echo ""
echo "🔍 Vérification finale..."
echo ""
flutter doctor -v | grep -A 5 "Xcode" || true
echo ""
flutter devices
echo ""

echo "✅ Configuration terminée !"
echo ""
echo "📱 Pour tester sur l'iPad :"
echo "1. Ouvrir dans Xcode :"
echo "   cd ios && open Runner.xcworkspace"
echo ""
echo "2. Dans Xcode :"
echo "   - Sélectionner votre iPad dans la liste"
echo "   - Signing & Capabilities > Automatically manage signing"
echo "   - Sélectionner votre Team (siwekathalia@gmail.com)"
echo "   - Cliquer sur ▶️ Play"
echo ""

