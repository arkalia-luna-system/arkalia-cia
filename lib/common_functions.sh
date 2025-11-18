#!/bin/bash
# Fonctions communes pour tous les scripts
# Source ce fichier avec: source "$(dirname "$0")/lib/common_functions.sh"

# Fonction optimisée pour arrêter proprement les processus
# Utilise un cache pour éviter les appels répétés à ps aux
cleanup_processes() {
    local pattern="$1"
    local name="${2:-processus}"
    local max_attempts="${3:-3}"
    local force_kill="${4:-false}"
    local attempt=1
    local pids=""
    
    # Trouver les PIDs une seule fois
    pids=$(ps aux | grep -E "$pattern" | grep -v grep | awk '{print $2}' | tr '\n' ' ')
    
    if [ -z "$pids" ]; then
        return 0
    fi
    
    # Arrêt propre puis forcé si nécessaire
    while [ $attempt -le $max_attempts ]; do
        if [ $attempt -eq 1 ] && [ "$force_kill" != "true" ]; then
            # Essayer d'abord un arrêt propre
            echo "$pids" | xargs kill 2>/dev/null || true
        else
            # Puis forcer l'arrêt
            echo "$pids" | xargs kill -9 2>/dev/null || true
        fi
        
        sleep 1
        
        # Vérifier si les processus sont toujours là
        local remaining_pids=$(ps aux | grep -E "$pattern" | grep -v grep | awk '{print $2}' | tr '\n' ' ')
        if [ -z "$remaining_pids" ]; then
            return 0
        fi
        
        pids="$remaining_pids"
        attempt=$((attempt + 1))
    done
    
    # Dernière tentative forcée
    if [ -n "$pids" ]; then
        echo "$pids" | xargs kill -9 2>/dev/null || true
        sleep 1
    fi
    
    # Vérification finale
    local remaining=$(ps aux | grep -E "$pattern" | grep -v grep | wc -l | tr -d ' ')
    if [ "$remaining" -eq 0 ]; then
        return 0
    else
        return 1
    fi
}

# Fonction pour vérifier si un processus tourne déjà (via lock file)
check_process_running() {
    local lock_file="$1"
    local process_name="${2:-processus}"
    
    if [ -f "$lock_file" ]; then
        local pid=$(cat "$lock_file" 2>/dev/null || echo "")
        if [ -n "$pid" ] && ps -p "$pid" > /dev/null 2>&1; then
            echo "⚠️  $process_name tourne déjà (PID: $pid)"
            echo "   Utilisez './cleanup_all.sh' pour l'arrêter"
            return 1
        else
            # Lock file orphelin, le supprimer
            rm -f "$lock_file"
        fi
    fi
    return 0
}

# Fonction pour créer un lock file
create_lock_file() {
    local lock_file="$1"
    echo $$ > "$lock_file"
}

# Fonction de nettoyage standard (pour trap)
cleanup_lock() {
    local lock_file="$1"
    rm -f "$lock_file"
}

# Fonction pour vérifier si un port est utilisé
check_port() {
    local port="$1"
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 ; then
        return 1
    fi
    return 0
}

