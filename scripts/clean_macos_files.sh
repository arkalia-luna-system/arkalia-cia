#!/bin/bash
# Script pour nettoyer les fichiers macOS

echo "🧹 Nettoyage des fichiers macOS..."

# Compter les fichiers avant nettoyage
COUNT_BEFORE=$(find . -name "._*" -type f 2>/dev/null | wc -l | tr -d ' ')

# Supprimer tous les fichiers ._* (y compris dans .git)
find . -name "._*" -type f -delete 2>/dev/null || true

# Supprimer les fichiers macOS dans .git/objects/pack et .git/refs (si .git existe)
if [ -d ".git" ]; then
  if [ -d ".git/objects/pack" ]; then
    find .git/objects/pack -name "._*" -type f -delete 2>/dev/null || true
  fi
  if [ -d ".git/refs" ]; then
    find .git/refs -name "._*" -type f -delete 2>/dev/null || true
  fi
fi

# Supprimer les dossiers de build (sans erreur si n'existent pas)
rm -rf build/ dist/ *.egg-info/ 2>/dev/null || true

# Supprimer les fichiers .DS_Store
find . -name ".DS_Store" -type f -delete 2>/dev/null || true

# Supprimer les fichiers .AppleDouble
find . -name ".AppleDouble" -type d -exec rm -rf {} + 2>/dev/null || true

# Compter les fichiers après nettoyage
COUNT_AFTER=$(find . -name "._*" -type f 2>/dev/null | wc -l | tr -d ' ')

if [ "$COUNT_BEFORE" -gt 0 ]; then
  echo "⚠️  Attention: $COUNT_BEFORE fichiers macOS détectés, suppression..."
fi

echo "✅ Nettoyage terminé"
