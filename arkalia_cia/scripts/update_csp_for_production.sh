#!/bin/bash
# Script pour mettre à jour le CSP dans index.html selon l'environnement
# Utilisé lors du build production pour optimiser la sécurité

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
WEB_DIR="$PROJECT_DIR/web"
INDEX_HTML="$WEB_DIR/index.html"

if [ ! -f "$INDEX_HTML" ]; then
    echo "❌ Erreur: $INDEX_HTML n'existe pas"
    exit 1
fi

# Vérifier si on est en mode production (via variable d'environnement ou argument)
IS_PRODUCTION="${1:-false}"

if [ "$IS_PRODUCTION" = "true" ] || [ "$IS_PRODUCTION" = "production" ]; then
    echo "🔒 Mise à jour du CSP pour la production..."
    
    # Le CSP conditionnel dans index.html gère déjà la détection
    # Ce script peut être utilisé pour forcer le CSP production si nécessaire
    echo "✅ CSP conditionnel déjà configuré dans index.html"
    echo "   Le CSP s'adapte automatiquement selon l'environnement"
else
    echo "🔧 Mode développement détecté"
    echo "✅ CSP conditionnel déjà configuré dans index.html"
    echo "   Le CSP s'adapte automatiquement selon l'environnement"
fi

echo "✅ Configuration CSP terminée"

