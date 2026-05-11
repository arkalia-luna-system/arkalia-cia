#!/bin/bash
# Script pour nettoyer les fichiers macOS (sans parcourir venv / node_modules : trop lourd)

echo "🧹 Nettoyage des fichiers macOS..."

find_prune_heavy() {
    find . \( \
        -path './arkalia_cia_venv/*' -o \
        -path './arkalia_cia/.dart_tool/*' -o \
        -path './arkalia_cia/build/*' -o \
        -path './node_modules/*' -o \
        -path './.idea/*' -o \
        -path './htmlcov/*' \
    \) -prune -o "$@"
}

# Compter les fichiers avant nettoyage
COUNT_BEFORE=$(find_prune_heavy -type f -name '._*' -print 2>/dev/null | wc -l | tr -d ' ')

# Supprimer les fichiers ._* (hors grosses arborescences jetables)
find_prune_heavy -type f -name '._*' -delete 2>/dev/null || true

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
find_prune_heavy -type f -name '.DS_Store' -delete 2>/dev/null || true

# Supprimer les fichiers .AppleDouble
find_prune_heavy -type d -name '.AppleDouble' -exec rm -rf {} + 2>/dev/null || true

# Compter les fichiers après nettoyage
COUNT_AFTER=$(find_prune_heavy -type f -name '._*' -print 2>/dev/null | wc -l | tr -d ' ')

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
