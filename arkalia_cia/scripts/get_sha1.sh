#!/bin/bash
# Script simple pour obtenir le SHA-1 Debug

cd /Volumes/T7/arkalia-cia/arkalia_cia/android

echo "🔍 Récupération du SHA-1 Debug..."
echo ""

./gradlew signingReport 2>&1 | grep -A 5 "Variant: debug" | grep "SHA1:" | head -1 | sed 's/.*SHA1: //'

echo ""
echo "✅ SHA-1 Debug récupéré"
echo ""
echo "📋 Vérifier dans Google Cloud Console :"
echo "   https://console.cloud.google.com/apis/credentials?project=arkalia-cia"
echo "   → Client Android 1 → Vérifier que ce SHA-1 est présent"

