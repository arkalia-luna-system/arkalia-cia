#!/bin/bash
# Script pour générer le keystore Android pour Arkalia CIA

set -e

echo "🔐 Génération du keystore Android pour Arkalia CIA"
echo "=================================================="
echo ""

cd "$(dirname "$0")"

# Vérifier si le keystore existe déjà
if [ -f "arkalia-cia-release.jks" ]; then
    echo "⚠️  Le keystore existe déjà !"
    read -p "Voulez-vous le regénérer ? (o/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Oo]$ ]]; then
        echo "❌ Annulé"
        exit 1
    fi
    rm -f arkalia-cia-release.jks
fi

echo "📝 Vous allez devoir répondre à quelques questions :"
echo ""
echo "1. Mot de passe keystore (à retenir !) - sera demandé 2 fois"
echo "2. Prénom/Nom : Arkalia Luna System"
echo "3. Organisation : Arkalia Luna System"
echo "4. Ville : (ta ville)"
echo "5. Pays : BE (Belgique)"
echo ""
echo "⚠️  IMPORTANT : Notez bien le mot de passe keystore, vous en aurez besoin !"
echo ""
read -p "Appuyez sur Entrée pour commencer..."

echo ""
echo "🔨 Génération du keystore..."
echo ""

keytool -genkey -v \
  -keystore arkalia-cia-release.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias arkalia-cia

echo ""
echo "✅ Keystore généré avec succès !"
echo "📁 Fichier : $(pwd)/arkalia-cia-release.jks"
echo ""
echo "🔐 Maintenant, notez le mot de passe que vous avez utilisé :"
echo "   Store Password = [le mot de passe que vous avez entré]"
echo "   Key Password = [le même mot de passe]"
echo ""

