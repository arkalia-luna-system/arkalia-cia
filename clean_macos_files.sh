#!/bin/bash

# Script de nettoyage des fichiers cachés macOS
# Supprime tous les fichiers ._* qui causent des problèmes avec Flutter

echo "🧹 Nettoyage des fichiers cachés macOS..."

# Compter les fichiers avant suppression
count_before=$(find . -name "._*" -type f | wc -l)

if [ $count_before -eq 0 ]; then
    echo "✅ Aucun fichier caché trouvé - tout est propre !"
    exit 0
fi

echo "📁 Fichiers cachés trouvés : $count_before"

# Supprimer les fichiers cachés
find . -name "._*" -type f -delete

# Compter après suppression
count_after=$(find . -name "._*" -type f | wc -l)

if [ $count_after -eq 0 ]; then
    echo "✅ Nettoyage terminé - $count_before fichiers supprimés"
else
    echo "⚠️  Attention : $count_after fichiers cachés restants"
fi

echo "🚀 Prêt pour Flutter !"
