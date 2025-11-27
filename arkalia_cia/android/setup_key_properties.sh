#!/bin/bash
# Script pour configurer key.properties après génération du keystore

set -e

cd "$(dirname "$0")"

if [ ! -f "arkalia-cia-release.jks" ]; then
    echo "❌ Erreur : Le keystore n'existe pas !"
    echo "   Exécutez d'abord : ./generate_keystore.sh"
    exit 1
fi

if [ -f "key.properties" ]; then
    echo "⚠️  key.properties existe déjà"
    read -p "Voulez-vous le recréer ? (o/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Oo]$ ]]; then
        echo "❌ Annulé"
        exit 1
    fi
fi

echo "🔐 Configuration de key.properties"
echo "==================================="
echo ""
echo "Vous devez entrer le mot de passe que vous avez utilisé pour le keystore"
echo ""

read -sp "Mot de passe keystore (storePassword) : " STORE_PASSWORD
echo ""
read -sp "Confirmer le mot de passe : " STORE_PASSWORD_CONFIRM
echo ""

if [ "$STORE_PASSWORD" != "$STORE_PASSWORD_CONFIRM" ]; then
    echo "❌ Les mots de passe ne correspondent pas !"
    exit 1
fi

# Créer key.properties
cat > key.properties << EOF
storePassword=$STORE_PASSWORD
keyPassword=$STORE_PASSWORD
keyAlias=arkalia-cia
storeFile=arkalia-cia-release.jks
EOF

echo ""
echo "✅ key.properties créé avec succès !"
echo "📁 Fichier : $(pwd)/key.properties"
echo ""
echo "⚠️  IMPORTANT : Ce fichier contient des mots de passe sensibles"
echo "   Il est déjà dans .gitignore, ne le commitez JAMAIS !"
echo ""

