#!/bin/bash

# Script de nettoyage du cache Flutter
# Utilisé pour éviter les erreurs de cache dans les workflows CI/CD

set -e

echo "🧹 Nettoyage du cache Flutter..."
echo "================================"

# Aller dans le dossier Flutter
cd arkalia_cia

# Nettoyer le cache Flutter
echo "🗑️  Nettoyage du cache Flutter..."
flutter clean

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
