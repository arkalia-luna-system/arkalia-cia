#!/bin/bash

# Script de nettoyage du cache Flutter
# Utilisé pour éviter les erreurs de cache dans les workflows CI/CD

set -e

echo "🧹 Nettoyage du cache Flutter..."
echo "================================"

# Aller dans le dossier Flutter
if [ ! -d "arkalia_cia" ]; then
    echo "❌ Erreur: Le dossier arkalia_cia n'existe pas"
    exit 1
fi
cd arkalia_cia

# Nettoyer le cache Flutter
echo "🗑️  Nettoyage du cache Flutter..."
flutter clean 2>&1 | grep -v "Failed to remove" || true

# Nettoyer les dépendances
echo "🗑️  Suppression des dépendances..."
rm -rf .dart_tool/
rm -rf build/
rm -f pubspec.lock

# Réinstaller les dépendances
echo "📦 Réinstallation des dépendances..."
flutter pub get

# Vérifier l'état
echo "✅ Nettoyage terminé"
flutter doctor --version
