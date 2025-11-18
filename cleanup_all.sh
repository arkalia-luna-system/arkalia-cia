#!/bin/bash
# Script de nettoyage complet pour tous les processus problématiques
# Version optimisée et unifiée

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Charger les fonctions communes
LIB_DIR="$SCRIPT_DIR/lib"
if [ -f "$LIB_DIR/common_functions.sh" ]; then
    source "$LIB_DIR/common_functions.sh"
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

# 2. bandit
cleanup_processes "bandit" "bandit" 3 false && echo "   ✅ bandit nettoyé" || echo "   ⚠️  bandit partiellement nettoyé"
echo ""

# 3. watch-macos-files.sh
cleanup_processes "watch-macos-files" "watch-macos-files" 3 false && echo "   ✅ watch-macos-files nettoyé" || echo "   ⚠️  watch-macos-files partiellement nettoyé"
echo ""

# 4. FastAPI/uvicorn
cleanup_processes "uvicorn|fastapi|api\.py" "FastAPI/uvicorn" 3 false && echo "   ✅ FastAPI/uvicorn nettoyé" || echo "   ⚠️  FastAPI/uvicorn partiellement nettoyé"
echo ""

# 5. Flutter
cleanup_processes "flutter.*run|dart.*flutter" "Flutter" 3 false && echo "   ✅ Flutter nettoyé" || echo "   ⚠️  Flutter partiellement nettoyé"
echo ""

# 6. Gradle daemons (optionnel)
if [ "$1" == "--include-gradle" ] || [ "$1" == "--all" ]; then
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

if [ -f ".coverage" ] && [ "$1" != "--keep-coverage" ]; then
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
echo "✅ Nettoyage complet terminé"
echo ""
echo "💡 Astuce: Utilisez './cleanup_all.sh --include-gradle' pour nettoyer aussi les daemons Gradle"
echo "💡 Astuce: Utilisez './cleanup_all.sh --keep-coverage' pour garder le fichier .coverage"

