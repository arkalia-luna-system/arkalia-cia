#!/bin/bash
# Script de vérification lint complet
# Vérifie Flutter analyze, Python ruff, et markdown

echo "🔍 Vérification lint complète..."
echo ""

ERRORS=0

# Flutter analyze
echo "📱 Vérification Flutter analyze..."
cd arkalia_cia || exit 1
if flutter analyze > /tmp/flutter_analyze.log 2>&1; then
  echo "✅ Flutter analyze: Aucune erreur"
else
  echo "❌ Flutter analyze: Erreurs trouvées"
  cat /tmp/flutter_analyze.log
  ERRORS=$((ERRORS + 1))
fi
cd ..

# Python ruff
echo ""
echo "🐍 Vérification Python ruff..."
cd arkalia_cia_python_backend || exit 1
if ruff check . > /tmp/ruff_check.log 2>&1; then
  echo "✅ Ruff check: Aucune erreur"
else
  echo "❌ Ruff check: Erreurs trouvées"
  cat /tmp/ruff_check.log | head -20
  ERRORS=$((ERRORS + 1))
fi
cd ..

# Résumé
echo ""
if [ $ERRORS -eq 0 ]; then
  echo "✅ Tous les lints passent - Aucune erreur"
  exit 0
else
  echo "⚠️  $ERRORS type(s) d'erreur(s) trouvé(s)"
  echo "💡 Action: Corriger les erreurs avant de continuer"
  exit 1
fi

