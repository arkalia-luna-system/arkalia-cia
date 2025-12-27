#!/bin/bash
# Script de vérification accessibilité - Tailles de boutons
# Vérifie que tous les boutons ont minimumSize ≥48px

echo "🔍 Vérification accessibilité - Tailles de boutons..."
echo ""

PROBLEMS=0

echo "📝 Recherche des boutons sans minimumSize..."
grep -rn "ElevatedButton\|TextButton\|IconButton" arkalia_cia/lib/screens/ | \
  grep -v "minimumSize" | \
  while IFS= read -r line; do
    # Ignorer les lignes avec minimumSize dans les 5 lignes suivantes
    FILE=$(echo "$line" | cut -d: -f1)
    LINE_NUM=$(echo "$line" | cut -d: -f2)
    
    # Vérifier si minimumSize existe dans les 10 lignes suivantes
    if ! sed -n "${LINE_NUM},$((LINE_NUM + 10))p" "$FILE" | grep -q "minimumSize"; then
      echo "❌ PROBLÈME: $line"
      echo "   → Bouton sans minimumSize (minimum requis: Size(120, 48))"
      PROBLEMS=$((PROBLEMS + 1))
    fi
  done

if [ $PROBLEMS -eq 0 ]; then
  echo "✅ Aucun problème trouvé - Tous les boutons ont minimumSize"
  exit 0
else
  echo ""
  echo "⚠️  $PROBLEMS problème(s) trouvé(s)"
  echo "💡 Action: Ajouter minimumSize: Size(120, 48) à tous les boutons"
  exit 1
fi

