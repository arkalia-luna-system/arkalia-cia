#!/bin/bash
# Script pour réinitialiser l'onboarding (pour tests)

echo "🔄 Réinitialisation de l'onboarding..."

# Supprimer les préférences d'onboarding
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    defaults delete com.arkalia.cia onboarding_completed 2>/dev/null
    echo "✅ Préférences macOS supprimées"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    rm -f ~/.local/share/com.arkalia.cia/preferences.json 2>/dev/null
    echo "✅ Préférences Linux supprimées"
fi

# Supprimer les données SharedPreferences de l'app
echo "📱 Pour réinitialiser complètement :"
echo "   1. Désinstaller l'app de votre device/simulateur"
echo "   2. Relancer l'app"
echo ""
echo "   Ou dans l'app Flutter :"
echo "   - Utiliser la fonction OnboardingService.resetOnboarding()"
echo ""
echo "✅ Script terminé !"

