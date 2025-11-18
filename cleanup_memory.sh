#!/bin/bash
# Script pour nettoyer les processus Python qui consomment trop de mémoire

echo "🧹 Nettoyage des processus Python gourmands..."

# Tuer tous les processus bandit qui tournent
pkill -9 -f "bandit" 2>/dev/null
echo "✅ Processus bandit arrêtés"

# Tuer tous les processus pytest qui tournent
pkill -9 -f "pytest" 2>/dev/null
pkill -9 -f "coverage.*pytest" 2>/dev/null
echo "✅ Processus pytest arrêtés"

# Attendre un peu pour que les processus se terminent
sleep 2

# Afficher les processus Python restants
echo ""
echo "📊 Processus Python restants:"
remaining=$(ps aux | grep -E "python.*arkalia|python.*security|python.*test" | grep -v grep | wc -l | tr -d ' ')
if [ "$remaining" -gt 0 ]; then
    ps aux | grep -E "python.*arkalia|python.*security|python.*test" | grep -v grep | head -5
    echo "⚠️  Il reste $remaining processus Python"
else
    echo "✅ Aucun processus Python problématique détecté"
fi

# Libérer le cache système si possible (macOS)
if command -v purge &> /dev/null; then
    echo ""
    echo "💾 Libération du cache système..."
    sudo purge 2>/dev/null || echo "⚠️  Nécessite les droits sudo pour purge"
fi

# Libérer la mémoire Python si possible
if command -v python3 &> /dev/null; then
    python3 -c "import gc; gc.collect(); print('✅ Mémoire Python libérée')" 2>/dev/null || true
fi

echo ""
echo "✅ Nettoyage terminé"

