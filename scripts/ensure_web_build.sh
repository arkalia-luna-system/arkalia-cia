#!/bin/bash

# Script pour s'assurer que le build web Flutter est disponible
# Utilisé dans les workflows CI/CD pour éviter l'erreur "Missing index.html"

set -e

echo "🔧 Vérification et génération du build web Flutter..."
echo "=================================================="

# Aller dans le dossier Flutter
if [ ! -d "arkalia_cia" ]; then
    echo "❌ Erreur: Le dossier arkalia_cia n'existe pas"
    exit 1
fi
cd arkalia_cia

# Vérifier si Flutter est installé
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter n'est pas installé ou n'est pas dans le PATH"
    exit 1
fi

# Vérifier si le build web existe déjà
if [ -f "build/web/index.html" ]; then
    echo "✅ Build web existant trouvé"
    echo "📁 Fichiers web disponibles:"
    ls -la build/web/ | head -10
else
    echo "🔨 Génération du build web..."

    # Installer les dépendances
    echo "📦 Installation des dépendances Flutter..."
    flutter pub get

    # Générer le build web
    echo "🏗️  Build web en cours..."
    flutter build web --release

    echo "✅ Build web généré avec succès"
fi

# Vérification finale
if [ -f "build/web/index.html" ]; then
    echo "✅ Vérification finale: index.html présent"
    echo "📊 Taille du build web: $(du -sh build/web/ | cut -f1)"
else
    echo "❌ Erreur: index.html manquant après le build"
    exit 1
fi

echo "🎉 Build web prêt pour le déploiement !"
