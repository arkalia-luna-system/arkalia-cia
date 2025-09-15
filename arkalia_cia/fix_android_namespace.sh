#!/bin/bash
# Script pour corriger le namespace Android du plugin contacts_service

echo "🔧 Correction du namespace Android pour contacts_service..."

# Trouver le fichier build.gradle du plugin contacts_service
CONTACTS_GRADLE_FILE=$(find ~/.pub-cache -name "build.gradle" -path "*/contacts_service-*/android/*" 2>/dev/null | head -1)

if [ -z "$CONTACTS_GRADLE_FILE" ]; then
    echo "❌ Fichier build.gradle de contacts_service non trouvé"
    echo "🔍 Recherche dans le cache Flutter..."
    CONTACTS_GRADLE_FILE=$(find .dart_tool -name "build.gradle" -path "*/contacts_service-*/android/*" 2>/dev/null | head -1)
fi

if [ -z "$CONTACTS_GRADLE_FILE" ]; then
    echo "❌ Plugin contacts_service non trouvé dans le cache"
    exit 1
fi

echo "📁 Fichier trouvé: $CONTACTS_GRADLE_FILE"

# Créer une sauvegarde
cp "$CONTACTS_GRADLE_FILE" "$CONTACTS_GRADLE_FILE.backup"

# Ajouter le namespace si pas déjà présent
if ! grep -q "namespace" "$CONTACTS_GRADLE_FILE"; then
    echo "➕ Ajout du namespace au fichier build.gradle..."

    # Ajouter le namespace après la ligne android {
    sed -i.bak '/android {/a\
    namespace = "com.contacts_service"
' "$CONTACTS_GRADLE_FILE"

    echo "✅ Namespace ajouté avec succès"
else
    echo "✅ Namespace déjà présent"
fi

echo "🎉 Correction terminée!"
