#!/bin/bash
# Script pour nettoyer les processus Python qui consomment trop de mémoire
# ⚠️  OBSOLÈTE: Ce script redirige maintenant vers cleanup_all.sh
# Utilisez directement: ./cleanup_all.sh --purge-memory

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "⚠️  Note: cleanup_memory.sh est maintenant intégré dans cleanup_all.sh"
echo "💡 Utilisez directement: ./cleanup_all.sh --purge-memory"
echo ""

# Rediriger vers cleanup_all.sh avec purge-memory
exec "$SCRIPT_DIR/cleanup_all.sh" --purge-memory "$@"

