#!/bin/bash
# Script pour nettoyer les fichiers macOS

echo "🧹 Nettoyage des fichiers macOS..."

# Supprimer tous les fichiers ._*
find . -name "._*" -type f -delete 2>/dev/null

# Supprimer les dossiers de build
rm -rf build/ dist/ *.egg-info/

# Supprimer les fichiers .DS_Store
find . -name ".DS_Store" -type f -delete 2>/dev/null

# Supprimer les fichiers .AppleDouble
find . -name ".AppleDouble" -type d -exec rm -rf {} + 2>/dev/null

echo "✅ Nettoyage terminé"
