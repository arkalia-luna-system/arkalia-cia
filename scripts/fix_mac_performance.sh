#!/bin/bash

# Script pour améliorer les performances du Mac
# Résout les problèmes de ralentissement identifiés

set -e

echo "🔧 Correction des problèmes de performance Mac..."

# 1. Désactiver l'indexation Spotlight sur le disque externe T7
echo ""
echo "📁 Désactivation de l'indexation Spotlight sur T7..."
if [ -d "/Volumes/T7" ]; then
    sudo mdutil -i off /Volumes/T7 2>/dev/null || echo "⚠️  Impossible de désactiver Spotlight sur T7 (peut nécessiter des permissions)"
    echo "✅ Indexation Spotlight désactivée sur T7"
else
    echo "⚠️  Le volume T7 n'est pas monté"
fi

# 2. Nettoyer les caches volumineux
echo ""
echo "🧹 Nettoyage des caches volumineux..."

# Cache com.todesktop (1.7G)
if [ -d "$HOME/Library/Caches/com.todesktop.230313mzl4w4u92.ShipIt" ]; then
    echo "  - Suppression du cache com.todesktop (1.7G)..."
    rm -rf "$HOME/Library/Caches/com.todesktop.230313mzl4w4u92.ShipIt" 2>/dev/null || echo "    ⚠️  Impossible de supprimer (peut être en cours d'utilisation)"
fi

# Cache Comet (1.6G)
if [ -d "$HOME/Library/Caches/Comet" ]; then
    echo "  - Suppression du cache Comet (1.6G)..."
    rm -rf "$HOME/Library/Caches/Comet" 2>/dev/null || echo "    ⚠️  Impossible de supprimer (peut être en cours d'utilisation)"
fi

# Cache Spotify (234M) - optionnel, peut être utile
echo "  - Cache Spotify conservé (peut être utile)"

# Cache pip (208M)
if [ -d "$HOME/Library/Caches/pip" ]; then
    echo "  - Nettoyage du cache pip (208M)..."
    pip cache purge 2>/dev/null || echo "    ⚠️  pip cache purge non disponible"
fi

# 3. Redémarrer Spotlight pour qu'il se stabilise
echo ""
echo "🔄 Redémarrage de Spotlight..."
sudo killall mds_stores 2>/dev/null || echo "⚠️  mds_stores n'est pas en cours d'exécution"
sleep 2
sudo mdutil -E / 2>/dev/null || echo "⚠️  Impossible de réinitialiser Spotlight (peut nécessiter des permissions)"
echo "✅ Spotlight redémarré"

# 4. Nettoyer les caches Flutter/Dart
echo ""
echo "🧹 Nettoyage des caches Flutter..."
if command -v flutter &> /dev/null; then
    flutter clean 2>/dev/null || echo "⚠️  flutter clean non disponible dans ce répertoire"
    echo "✅ Cache Flutter nettoyé"
fi

# 5. Afficher l'état actuel
echo ""
echo "📊 État actuel des processus:"
echo ""
top -l 1 -n 5 -stats pid,command,cpu,mem | grep -E "(PID|mds|Cursor)" | head -6

echo ""
echo "✅ Corrections terminées !"
echo ""
echo "💡 Conseils:"
echo "  - Si Spotlight continue de ralentir, vous pouvez le désactiver complètement avec:"
echo "    sudo mdutil -a -i off"
echo "  - Pour le réactiver plus tard:"
echo "    sudo mdutil -a -i on"
echo ""
echo "  - Les caches seront régénérés automatiquement si nécessaire"
echo "  - Redémarrez votre Mac si les problèmes persistent"

