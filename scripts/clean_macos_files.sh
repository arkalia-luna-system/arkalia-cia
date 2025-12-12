#!/bin/bash
# Script pour nettoyer les fichiers macOS

echo "🧹 Nettoyage des fichiers macOS..."

# Compter les fichiers avant nettoyage
COUNT_BEFORE=$(find . -name "._*" -type f 2>/dev/null | wc -l | tr -d ' ')

# Supprimer tous les fichiers ._* (y compris dans .git)
find . -name "._*" -type f -delete 2>/dev/null || true

# Supprimer les fichiers macOS dans .git/objects/pack et .git/refs (si .git existe)
if [ -d ".git" ]; then
  if [ -d ".git/objects/pack" ]; then
    find .git/objects/pack -name "._*" -type f -delete 2>/dev/null || true
  fi
  if [ -d ".git/refs" ]; then
    find .git/refs -name "._*" -type f -delete 2>/dev/null || true
  fi
fi

# Supprimer les dossiers de build (sans erreur si n'existent pas)
rm -rf build/ dist/ *.egg-info/ 2>/dev/null || true

# Supprimer les fichiers .DS_Store
find . -name ".DS_Store" -type f -delete 2>/dev/null || true

# Supprimer les fichiers .AppleDouble
find . -name ".AppleDouble" -type d -exec rm -rf {} + 2>/dev/null || true

# Compter les fichiers après nettoyage
COUNT_AFTER=$(find . -name "._*" -type f 2>/dev/null | wc -l | tr -d ' ')

# Afficher le résultat du nettoyage
if [ -z "$COUNT_BEFORE" ] || [ "$COUNT_BEFORE" = "0" ]; then
  COUNT_BEFORE=0
fi
if [ -z "$COUNT_AFTER" ] || [ "$COUNT_AFTER" = "0" ]; then
  COUNT_AFTER=0
fi

if [ "$COUNT_BEFORE" -gt 0 ]; then
  REMOVED=$((COUNT_BEFORE - COUNT_AFTER))
  # Vérifier que REMOVED n'est pas négatif (cas edge où COUNT_AFTER > COUNT_BEFORE)
  if [ "$REMOVED" -lt 0 ]; then
    REMOVED=0
  fi
  if [ "$REMOVED" -gt 0 ]; then
    echo "✅ $REMOVED fichier(s) macOS supprimé(s) ($COUNT_BEFORE → $COUNT_AFTER)"
  elif [ "$COUNT_AFTER" -eq "$COUNT_BEFORE" ]; then
    echo "⚠️  $COUNT_BEFORE fichier(s) macOS détecté(s) mais non supprimé(s)"
  else
    # Cas où COUNT_AFTER > COUNT_BEFORE (ne devrait pas arriver, mais géré)
    echo "⚠️  Situation inattendue: $COUNT_BEFORE fichier(s) avant, $COUNT_AFTER après"
  fi
else
  echo "✅ Aucun fichier macOS détecté"
fi

echo "✅ Nettoyage terminé"
