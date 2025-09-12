#!/bin/bash

# Script de démarrage pour Arkalia CIA Flutter
echo "📱 Démarrage d'Arkalia CIA Flutter..."

# Aller dans le dossier Flutter
cd /Volumes/T7/arkalia-cia/arkalia_cia

# Installer les dépendances
echo "📦 Installation des dépendances..."
flutter pub get

# Démarrer l'application
echo "🚀 Démarrage de l'application Flutter..."
flutter run -d chrome --web-port=8080
