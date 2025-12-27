#!/bin/bash
# Script de vérification accessibilité - Tailles de texte
# Vérifie que tous les textes sont ≥14px

echo "🔍 Vérification accessibilité - Tailles de texte..."
echo ""

# Chercher tous les fontSize avec des valeurs <14
PROBLEMS=0

echo "📝 Recherche des textes <14px..."
grep -rn "fontSize.*[0-9]" arkalia_cia/lib/screens/ | \
  grep -E "fontSize.*[0-9]{1,2}[^0-9]" | \
  while IFS= read -r line; do
    # Extraire la valeur fontSize
    FONT_SIZE=$(echo "$line" | grep -oE "fontSize.*[0-9]{1,2}" | grep -oE "[0-9]{1,2}")
    
    if [ -n "$FONT_SIZE" ] && [ "$FONT_SIZE" -lt 14 ]; then
      echo "❌ PROBLÈME: $line"
      echo "   → Taille: ${FONT_SIZE}px (minimum requis: 14px)"
      PROBLEMS=$((PROBLEMS + 1))
    fi
  done

if [ $PROBLEMS -eq 0 ]; then
  echo "✅ Aucun problème trouvé - Tous les textes sont ≥14px"
  exit 0
else
  echo ""
  echo "⚠️  $PROBLEMS problème(s) trouvé(s)"
  echo "💡 Action: Remplacer tous les fontSize <14 par 14 minimum"
  exit 1
fi

