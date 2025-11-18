#!/bin/bash
# Script de nettoyage complet pour tous les processus problématiques

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "🧹 Nettoyage complet de tous les processus problématiques..."
echo ""

# Fonction pour arrêter proprement les processus
cleanup_processes() {
    local pattern="$1"
    local name="$2"
    local max_attempts=3
    local attempt=1
    
    echo "📋 Nettoyage: $name"
    
    while [ $attempt -le $max_attempts ]; do
        local pids=$(ps aux | grep -E "$pattern" | grep -v grep | awk '{print $2}' | tr '\n' ' ')
        
        if [ -z "$pids" ]; then
            echo "   ✅ Aucun processus $name trouvé"
            return 0
        fi
        
        if [ $attempt -eq 1 ]; then
            echo "   ⚠️  Arrêt propre de $name (PIDs: $pids)..."
            echo "$pids" | xargs kill 2>/dev/null || true
        else
            echo "   ⚠️  Arrêt forcé de $name..."
            echo "$pids" | xargs kill -9 2>/dev/null || true
        fi
        
        sleep 1
        attempt=$((attempt + 1))
    done
    
    # Vérification finale
    local remaining=$(ps aux | grep -E "$pattern" | grep -v grep | wc -l | tr -d ' ')
    if [ "$remaining" -gt 0 ]; then
        echo "   ❌ Il reste $remaining processus $name"
        return 1
    else
        echo "   ✅ Tous les processus $name arrêtés"
        return 0
    fi
}

# 1. Nettoyer pytest et coverage
cleanup_processes "pytest|coverage.*pytest" "pytest/coverage"
echo ""

# 2. Nettoyer bandit
cleanup_processes "bandit" "bandit"
echo ""

# 3. Nettoyer watch-macos-files.sh (boucle infinie)
cleanup_processes "watch-macos-files" "watch-macos-files"
echo ""

# 4. Nettoyer les serveurs FastAPI/uvicorn
cleanup_processes "uvicorn|fastapi|api\.py" "FastAPI/uvicorn"
echo ""

# 5. Nettoyer les processus Flutter
cleanup_processes "flutter.*run|dart.*flutter" "Flutter"
echo ""

# 6. Nettoyer les daemons Gradle (optionnel - peut être gardé pour performance)
if [ "$1" == "--include-gradle" ]; then
    echo "📋 Nettoyage Gradle daemons (peut ralentir les prochains builds)..."
    cleanup_processes "GradleDaemon|gradle.*daemon" "Gradle daemon"
    echo ""
fi

# 7. Nettoyer les processus Kotlin compiler daemon
cleanup_processes "KotlinCompileDaemon|kotlin.*daemon" "Kotlin daemon"
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

