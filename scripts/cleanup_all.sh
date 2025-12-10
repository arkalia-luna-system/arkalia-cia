#!/bin/bash
# Script de nettoyage complet pour tous les processus problématiques
# Version optimisée et unifiée - Fusionne cleanup_memory.sh et cleanup_all.sh
# Nettoie aussi les fichiers macOS cachés avec numéros (.!*!._*)

# Ne pas utiliser set -e car certaines commandes peuvent échouer normalement (find sans résultats)
set +e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Charger les fonctions communes
if [ -f "$SCRIPT_DIR/common_functions.sh" ]; then
    source "$SCRIPT_DIR/common_functions.sh"
else
    echo "⚠️  Fichier common_functions.sh non trouvé, utilisation des fonctions intégrées"
    # Fonction de fallback
    cleanup_processes() {
        local pattern="$1"
        local name="${2:-processus}"
        local pids=$(ps aux | grep -E "$pattern" | grep -v grep | awk '{print $2}' | tr '\n' ' ')
        if [ -z "$pids" ]; then
            echo "   ✅ Aucun processus $name trouvé"
            return 0
        fi
        echo "   ⚠️  Arrêt de $name (PIDs: $pids)..."
        echo "$pids" | xargs kill -9 2>/dev/null || true
        sleep 1
    }
fi

echo "🧹 Nettoyage complet de tous les processus problématiques..."
echo ""

# Nettoyer tous les processus (optimisé - un seul appel ps aux par type)
echo "📋 Nettoyage des processus..."

# 1. pytest et coverage
cleanup_processes "pytest|coverage.*pytest" "pytest/coverage" 3 false && echo "   ✅ pytest/coverage nettoyé" || echo "   ⚠️  pytest/coverage partiellement nettoyé"
echo ""

# 2. bandit (scans de sécurité - très lourd en CPU)
cleanup_processes "bandit" "bandit" 3 false && echo "   ✅ bandit nettoyé" || echo "   ⚠️  bandit partiellement nettoyé"
echo ""

# 2b. mypy (vérification de types - lourd en CPU, lancé par Cursor IDE)
# Note: Ne pas tuer le serveur LSP de Cursor (mypy-type-checker), seulement les scans manuels
cleanup_processes "python.*-m mypy.*arkalia|python.*mypy.*\.py" "mypy (scans)" 3 false && echo "   ✅ mypy nettoyé" || echo "   ⚠️  mypy partiellement nettoyé"
echo ""

# 3. watch-macos-files.sh
cleanup_processes "watch-macos-files" "watch-macos-files" 3 false && echo "   ✅ watch-macos-files nettoyé" || echo "   ⚠️  watch-macos-files partiellement nettoyé"
echo ""

# 4. FastAPI/uvicorn
cleanup_processes "uvicorn|fastapi|api\.py" "FastAPI/uvicorn" 3 false && echo "   ✅ FastAPI/uvicorn nettoyé" || echo "   ⚠️  FastAPI/uvicorn partiellement nettoyé"
# Nettoyer aussi les lock files
rm -f /tmp/arkalia_backend.lock
echo ""

# 5. Flutter et boucles infinies de nettoyage
cleanup_processes "flutter.*run|dart.*flutter|while true.*find build" "Flutter" 3 false && echo "   ✅ Flutter nettoyé" || echo "   ⚠️  Flutter partiellement nettoyé"
# Nettoyer aussi les lock files
rm -f /tmp/arkalia_flutter.lock /tmp/arkalia_flutter_web.lock
echo ""

# 5b. Boucles infinies de nettoyage macOS (très lourd)
cleanup_processes "while true.*find.*build.*delete|CLEANUP_PID" "boucle nettoyage macOS" 3 false && echo "   ✅ Boucles de nettoyage nettoyées" || echo "   ⚠️  Boucles partiellement nettoyées"
echo ""

# 6. Gradle daemons (optionnel)
INCLUDE_GRADLE=false
PURGE_MEMORY=false
for arg in "$@"; do
    if [ "$arg" == "--include-gradle" ] || [ "$arg" == "--all" ]; then
        INCLUDE_GRADLE=true
    fi
    if [ "$arg" == "--purge-memory" ] || [ "$arg" == "--all" ]; then
        PURGE_MEMORY=true
    fi
done

if [ "$INCLUDE_GRADLE" = true ]; then
    echo "📋 Nettoyage Gradle daemons..."
    cleanup_processes "GradleDaemon|gradle.*daemon" "Gradle daemon" 3 false && echo "   ✅ Gradle daemon nettoyé" || echo "   ⚠️  Gradle daemon partiellement nettoyé"
    echo ""
fi

# 7. Kotlin compiler daemon
cleanup_processes "KotlinCompileDaemon|kotlin.*daemon" "Kotlin daemon" 3 false && echo "   ✅ Kotlin daemon nettoyé" || echo "   ⚠️  Kotlin daemon partiellement nettoyé"
echo ""

# Nettoyer les fichiers de lock
echo "📋 Nettoyage des fichiers de lock..."
if [ -d ".pytest_cache" ]; then
    rm -rf .pytest_cache
    echo "   ✅ Cache pytest nettoyé"
fi

# Vérifier si --keep-coverage est dans les arguments
KEEP_COVERAGE=false
for arg in "$@"; do
    if [ "$arg" == "--keep-coverage" ]; then
        KEEP_COVERAGE=true
        break
    fi
done

if [ -f ".coverage" ] && [ "$KEEP_COVERAGE" = false ]; then
    rm -f .coverage
    echo "   ✅ Fichier .coverage nettoyé"
fi

# Nettoyer les fichiers de lock watch-macos-files
if [ -f "/tmp/watch-macos-files.lock" ]; then
    rm -f /tmp/watch-macos-files.lock
    echo "   ✅ Lock watch-macos-files nettoyé"
fi

echo ""

# Afficher les processus restants
echo "📊 Processus restants:"
remaining=$(ps aux | grep -E "python.*arkalia|python.*security|python.*test|flutter|gradle.*daemon" | grep -v grep | wc -l | tr -d ' ')
if [ "$remaining" -gt 0 ]; then
    ps aux | grep -E "python.*arkalia|python.*security|python.*test|flutter|gradle.*daemon" | grep -v grep | head -5
    echo "⚠️  Il reste $remaining processus"
else
    echo "✅ Aucun processus problématique détecté"
fi

echo ""

# Libérer la mémoire Python si possible
if command -v python3 &> /dev/null; then
    python3 -c "import gc; gc.collect(); print('✅ Mémoire Python libérée')" 2>/dev/null || true
fi

echo ""

# Nettoyer les fichiers macOS cachés (y compris ceux avec numéros)
echo "📋 Nettoyage des fichiers macOS cachés..."
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

# Compter avant suppression (méthode améliorée avec find + grep)
# 1. Fichiers standards ._* (exclure .git, venv, build, etc.)
STANDARD_COUNT=$(find . -type f -name "._*" ! -path "./.git/*" ! -path "./arkalia_cia_venv/*" ! -path "./.dart_tool/*" ! -path "./build/*" ! -path "./node_modules/*" ! -path "./.idea/*" 2>/dev/null | wc -l | tr -d ' ')

# 2. Fichiers avec numéros .!nombre!._* (méthode robuste: find puis grep)
NUMBERED_COUNT=$(find . -type f ! -path "./.git/*" ! -path "./arkalia_cia_venv/*" ! -path "./.dart_tool/*" ! -path "./build/*" ! -path "./node_modules/*" ! -path "./.idea/*" 2>/dev/null | grep -E "\.![0-9]+!\._" | wc -l | tr -d ' ')

# 3. Fichiers .DS_Store
DSSTORE_COUNT=$(find . -type f -name ".DS_Store" ! -path "./.git/*" ! -path "./arkalia_cia_venv/*" ! -path "./.dart_tool/*" ! -path "./build/*" ! -path "./node_modules/*" ! -path "./.idea/*" 2>/dev/null | wc -l | tr -d ' ')

BEFORE_COUNT=$((STANDARD_COUNT + NUMBERED_COUNT + DSSTORE_COUNT))

if [ "$BEFORE_COUNT" -gt 0 ]; then
    echo "   📊 Trouvé $BEFORE_COUNT fichiers macOS cachés:"
    [ "$STANDARD_COUNT" -gt 0 ] && echo "      - $STANDARD_COUNT fichiers ._*"
    [ "$NUMBERED_COUNT" -gt 0 ] && echo "      - $NUMBERED_COUNT fichiers .!nombre!._*"
    [ "$DSSTORE_COUNT" -gt 0 ] && echo "      - $DSSTORE_COUNT fichiers .DS_Store"
    
    # Supprimer les fichiers macOS cachés standards (._*)
    if [ "$STANDARD_COUNT" -gt 0 ]; then
        find . -type f -name "._*" ! -path "./.git/*" ! -path "./arkalia_cia_venv/*" ! -path "./.dart_tool/*" ! -path "./build/*" ! -path "./node_modules/*" ! -path "./.idea/*" -delete 2>/dev/null || true
    fi
    
    # Supprimer les fichiers macOS avec numéros (format: .!28431!._fichier.md)
    # Méthode robuste: find tous les fichiers puis grep pour le pattern
    if [ "$NUMBERED_COUNT" -gt 0 ]; then
        find . -type f ! -path "./.git/*" ! -path "./arkalia_cia_venv/*" ! -path "./.dart_tool/*" ! -path "./build/*" ! -path "./node_modules/*" ! -path "./.idea/*" 2>/dev/null | grep -E "\.![0-9]+!\._" | while read -r file; do
            echo "      🗑️  Suppression: $file"
            rm -f "$file" 2>/dev/null || true
        done
    fi
    
    # Supprimer les fichiers .DS_Store
    if [ "$DSSTORE_COUNT" -gt 0 ]; then
        find . -type f -name ".DS_Store" ! -path "./.git/*" ! -path "./arkalia_cia_venv/*" ! -path "./.dart_tool/*" ! -path "./build/*" ! -path "./node_modules/*" ! -path "./.idea/*" -delete 2>/dev/null || true
    fi
    
    # Supprimer les dossiers macOS cachés
    find . -type d -name ".AppleDouble" ! -path "./.git/*" ! -path "./arkalia_cia_venv/*" ! -path "./.dart_tool/*" ! -path "./build/*" ! -path "./node_modules/*" ! -path "./.idea/*" -exec rm -rf {} + 2>/dev/null || true
    find . -type d -name ".Spotlight-V100" ! -path "./.git/*" ! -path "./arkalia_cia_venv/*" ! -path "./.dart_tool/*" ! -path "./build/*" ! -path "./node_modules/*" ! -path "./.idea/*" -exec rm -rf {} + 2>/dev/null || true
    find . -type d -name ".Trashes" ! -path "./.git/*" ! -path "./arkalia_cia_venv/*" ! -path "./.dart_tool/*" ! -path "./build/*" ! -path "./node_modules/*" ! -path "./.idea/*" -exec rm -rf {} + 2>/dev/null || true
    
    # Vérifier après suppression
    STANDARD_AFTER=$(find . -type f -name "._*" ! -path "./.git/*" ! -path "./arkalia_cia_venv/*" ! -path "./.dart_tool/*" ! -path "./build/*" ! -path "./node_modules/*" ! -path "./.idea/*" 2>/dev/null | wc -l | tr -d ' ')
    NUMBERED_AFTER=$(find . -type f ! -path "./.git/*" ! -path "./arkalia_cia_venv/*" ! -path "./.dart_tool/*" ! -path "./build/*" ! -path "./node_modules/*" ! -path "./.idea/*" 2>/dev/null | grep -E "\.![0-9]+!\._" | wc -l | tr -d ' ')
    DSSTORE_AFTER=$(find . -type f -name ".DS_Store" ! -path "./.git/*" ! -path "./arkalia_cia_venv/*" ! -path "./.dart_tool/*" ! -path "./build/*" ! -path "./node_modules/*" ! -path "./.idea/*" 2>/dev/null | wc -l | tr -d ' ')
    AFTER_COUNT=$((STANDARD_AFTER + NUMBERED_AFTER + DSSTORE_AFTER))
    
    if [ "$AFTER_COUNT" -eq 0 ]; then
        echo "   ✅ Tous les fichiers macOS cachés supprimés ($BEFORE_COUNT fichiers)"
    else
        echo "   ⚠️  Il reste $AFTER_COUNT fichiers (peut-être verrouillés)"
        if [ "$NUMBERED_AFTER" -gt 0 ]; then
            echo "      Fichiers avec numéros restants:"
            find . -type f ! -path "./.git/*" ! -path "./arkalia_cia_venv/*" ! -path "./.dart_tool/*" ! -path "./build/*" ! -path "./node_modules/*" ! -path "./.idea/*" 2>/dev/null | grep -E "\.![0-9]+!\._" | head -5 | sed 's/^/         - /'
        fi
    fi
else
    echo "   ✅ Aucun fichier macOS caché trouvé"
fi

echo ""

# Libérer le cache système si possible (macOS) - seulement si --purge-memory est spécifié
if [ "$PURGE_MEMORY" = true ]; then
    if command -v purge &> /dev/null; then
        echo "💾 Libération du cache système..."
        sudo purge 2>/dev/null || echo "   ⚠️  Nécessite les droits sudo pour purge"
        echo ""
    fi
fi

echo "✅ Nettoyage complet terminé"
echo ""
echo "💡 Astuce: Utilisez './cleanup_all.sh --include-gradle' pour nettoyer aussi les daemons Gradle"
echo "💡 Astuce: Utilisez './cleanup_all.sh --keep-coverage' pour garder le fichier .coverage"
echo "💡 Astuce: Utilisez './cleanup_all.sh --purge-memory' pour libérer aussi le cache système macOS"

