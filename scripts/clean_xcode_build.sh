#!/bin/bash

# Script pour nettoyer et préparer le build iOS
# Supprime les fichiers macOS cachés qui causent des erreurs

set -e

cd /Volumes/T7/arkalia-cia/arkalia_cia

echo "🧹 Nettoyage du projet iOS..."
echo ""

# Nettoyer Flutter
echo "1. Nettoyage Flutter..."
flutter clean 2>&1 | grep -v "Failed to remove" || true
flutter pub get

# Supprimer les fichiers macOS cachés
echo "2. Suppression des fichiers macOS cachés..."
find ios -name "._*" -type f -delete 2>/dev/null || true
find ios/Pods -name "._*" -type f -delete 2>/dev/null || true
echo "✅ Fichiers macOS cachés supprimés"

# Réinstaller les pods
echo "3. Réinstallation des Pods..."
cd ios
rm -rf Pods Podfile.lock

export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export PATH="/Users/athalia/.local/share/gem/ruby/3.4.0/bin:$PATH"

pod install 2>&1 | tail -5

# Supprimer à nouveau les fichiers macOS cachés créés par pod install
find Pods -name "._*" -type f -delete 2>/dev/null || true

cd ..

echo ""
echo "✅ Nettoyage terminé !"
echo ""
echo "Vous pouvez maintenant :"
echo "1. Ouvrir Xcode : cd ios && open Runner.xcworkspace"
echo "2. Configurer le Signing (Signing & Capabilities)"
echo "3. Sélectionner votre iPad"
echo "4. Cliquer sur Play ▶️"
