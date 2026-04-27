#!/bin/bash
# Script wrapper pour lancer pytest proprement sans doublons
# Version optimisée - utilise cleanup_all.sh pour le nettoyage
# Nettoie automatiquement après les tests (y compris fichiers macOS cachés)

# Ne pas utiliser set -e car on veut toujours faire le nettoyage même si les tests échouent
set +e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🧹 Nettoyage des processus pytest existants..."

# Utiliser cleanup_all.sh pour nettoyer pytest (plus efficace et unifié)
# Mais seulement pytest/coverage, pas tout le reste
if [ -f "$SCRIPT_DIR/common_functions.sh" ]; then
    source "$SCRIPT_DIR/common_functions.sh"
    cleanup_processes "pytest|coverage.*pytest" "pytest/coverage" 5 false
else
    # Fallback rapide
    pkill -f "pytest" 2>/dev/null || true
    pkill -f "coverage.*pytest" 2>/dev/null || true
    sleep 1
fi

# Nettoyer les fichiers de lock pytest
if [ -d ".pytest_cache" ]; then
    rm -rf .pytest_cache
    echo "✅ Cache pytest nettoyé"
fi

# Nettoyer le fichier .coverage s'il existe (mais le garder si on fait de la couverture)
if [ -f ".coverage" ] && [[ ! "$*" =~ "--cov" ]]; then
    rm -f .coverage
    echo "✅ Fichier .coverage nettoyé"
fi

# Vérification finale
remaining=$(ps aux | grep -E "pytest|coverage.*pytest" | grep -v grep | wc -l | tr -d ' ')
if [ "$remaining" -gt 0 ]; then
    echo "❌ ERREUR: Il reste $remaining processus pytest actifs!"
    ps aux | grep -E "pytest|coverage" | grep -v grep
    exit 1
fi

echo "✅ Environnement nettoyé, lancement des tests..."
echo ""

# Lancer pytest et capturer le code de sortie
if [ $# -eq 0 ]; then
    echo "ℹ️  Aucun argument fourni, utilisation des valeurs par défaut: tests/ -v"
    python3 -m pytest tests/ -v
    TEST_EXIT_CODE=$?
else
    # Lancer pytest avec les arguments passés
    python3 -m pytest "$@"
    TEST_EXIT_CODE=$?
fi

# Nettoyage automatique après les tests (toujours exécuté, même si les tests échouent)
echo ""
echo "🧹 Nettoyage automatique après les tests..."
cd "$PROJECT_ROOT"

# Utiliser cleanup_all.sh pour le nettoyage complet
"$SCRIPT_DIR/cleanup_all.sh" --keep-coverage > /dev/null 2>&1 || {
    # Fallback si cleanup_all.sh échoue
    echo "   ⚠️  Nettoyage partiel..."
    if [ -d ".pytest_cache" ]; then
        rm -rf .pytest_cache 2>/dev/null || true
    fi
    # Nettoyer les fichiers macOS cachés (y compris ceux avec numéros)
    find . -type f \( -name "._*" -o -name ".!*!._*" -o -name ".DS_Store" \) ! -path "./.git/*" ! -path "./arkalia_cia_venv/*" ! -path "./.dart_tool/*" ! -path "./build/*" -delete 2>/dev/null || true
    # Pattern alternatif pour fichiers avec numéros
    find . -type f ! -path "./.git/*" ! -path "./arkalia_cia_venv/*" ! -path "./.dart_tool/*" ! -path "./build/*" | grep -E "\.![0-9]+!\._" | xargs rm -f 2>/dev/null || true
}

# Retourner le code de sortie des tests
exit $TEST_EXIT_CODE

