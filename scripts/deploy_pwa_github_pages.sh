#!/bin/bash

# Script de déploiement PWA sur GitHub Pages
# Date: 10 décembre 2025

set -e

echo "🚀 Déploiement PWA sur GitHub Pages"
echo "===================================="
echo ""

# Aller dans le dossier Flutter
cd "$(dirname "$0")/../arkalia_cia"

# Vérifier que Flutter est installé
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter n'est pas installé ou n'est pas dans le PATH"
    exit 1
fi

echo "📦 Build web en cours..."
flutter clean
flutter pub get
flutter build web --release --no-wasm-dry-run

echo ""
echo "✅ Build web réussi"
echo ""

# Aller dans le dossier build/web
cd build/web

# Créer .nojekyll si nécessaire
if [ ! -f ".nojekyll" ]; then
    echo "📝 Création fichier .nojekyll..."
    touch .nojekyll
fi

# Initialiser git si nécessaire
if [ ! -d ".git" ]; then
    echo "🔧 Initialisation git..."
    git init
    git branch -M gh-pages
    git remote add origin https://github.com/arkalia-luna-system/arkalia-cia.git 2>/dev/null || \
        git remote set-url origin https://github.com/arkalia-luna-system/arkalia-cia.git
fi

# Ajouter tous les fichiers
echo "📤 Ajout des fichiers..."
git add .

# Commit
echo "💾 Commit..."
git commit -m "Deploy PWA v1.3.1 - $(date +'%d %B %Y')" || echo "Aucun changement à commiter"

# Push
echo "🚀 Push sur GitHub Pages..."
git push -u origin gh-pages --force

echo ""
echo "✅ Déploiement terminé !"
echo ""
echo "📋 Prochaines étapes :"
echo "1. Aller sur : https://github.com/arkalia-luna-system/arkalia-cia"
echo "2. Settings → Pages"
echo "3. Source : gh-pages branch"
echo "4. Save"
echo "5. Attendre 2-3 minutes"
echo ""
echo "🌐 URL de l'app :"
echo "https://arkalia-luna-system.github.io/arkalia-cia"
echo ""

