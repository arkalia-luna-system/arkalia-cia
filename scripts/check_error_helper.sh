#!/bin/bash
# Script de vérification gestion d'erreurs
# Vérifie que ErrorHelper est utilisé partout

echo "🔍 Vérification gestion d'erreurs - ErrorHelper..."
echo ""

PROBLEMS=0

echo "📝 Recherche des messages d'erreur sans ErrorHelper..."
grep -rn "_showError\|showSnackBar.*error\|Text.*error" arkalia_cia/lib/screens/ | \
  grep -v "ErrorHelper" | \
  while IFS= read -r line; do
    # Ignorer les lignes qui importent ErrorHelper
    if ! echo "$line" | grep -q "import.*error_helper"; then
      echo "❌ PROBLÈME: $line"
      echo "   → Message d'erreur sans ErrorHelper.getUserFriendlyMessage()"
      PROBLEMS=$((PROBLEMS + 1))
    fi
  done

if [ $PROBLEMS -eq 0 ]; then
  echo "✅ Aucun problème trouvé - ErrorHelper utilisé partout"
  exit 0
else
  echo ""
  echo "⚠️  $PROBLEMS problème(s) trouvé(s)"
  echo "💡 Action: Utiliser ErrorHelper.getUserFriendlyMessage() pour tous les messages d'erreur"
  exit 1
fi

