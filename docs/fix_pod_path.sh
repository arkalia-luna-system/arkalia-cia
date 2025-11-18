#!/bin/bash

# Script pour trouver et utiliser CocoaPods

set -e

echo "🔍 Recherche de CocoaPods..."
echo ""

# Utiliser la nouvelle version de Ruby
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export PATH="/opt/homebrew/lib/ruby/gems/3.4.0/bin:$PATH"

# Chercher pod dans plusieurs emplacements
POD_PATHS=(
    "/opt/homebrew/lib/ruby/gems/3.4.0/bin/pod"
    "/usr/local/bin/pod"
    "/usr/bin/pod"
    "$(which pod 2>/dev/null)"
    "$HOME/.gem/ruby/*/bin/pod"
)

POD_CMD=""

for path in "${POD_PATHS[@]}"; do
    if [ -f "$path" ] 2>/dev/null; then
        POD_CMD="$path"
        echo "✅ CocoaPods trouvé : $POD_CMD"
        break
    fi
done

# Si pas trouvé, essayer avec gem
if [ -z "$POD_CMD" ]; then
    echo "⚠️  CocoaPods non trouvé dans le PATH"
    echo "   Tentative avec gem..."
    
    # Chercher dans les gems installés
    GEM_BIN=$(gem environment | grep "EXECUTABLE DIRECTORY" | cut -d: -f2 | tr -d ' ')
    if [ -f "$GEM_BIN/pod" ]; then
        POD_CMD="$GEM_BIN/pod"
        export PATH="$GEM_BIN:$PATH"
        echo "✅ CocoaPods trouvé via gem : $POD_CMD"
    fi
fi

# Si toujours pas trouvé, essayer avec sudo gem
if [ -z "$POD_CMD" ]; then
    echo "⚠️  CocoaPods installé avec sudo, cherchant dans les gems système..."
    SUDO_GEM_BIN=$(sudo gem env 2>/dev/null | grep "EXECUTABLE DIRECTORY" | cut -d: -f2 | tr -d ' ' || echo "")
    if [ -n "$SUDO_GEM_BIN" ] && [ -f "$SUDO_GEM_BIN/pod" ]; then
        POD_CMD="$SUDO_GEM_BIN/pod"
        export PATH="$SUDO_GEM_BIN:$PATH"
        echo "✅ CocoaPods trouvé dans gems système : $POD_CMD"
    fi
fi

if [ -z "$POD_CMD" ]; then
    echo "❌ CocoaPods non trouvé !"
    echo ""
    echo "Essayez de réinstaller avec :"
    echo "  export PATH=\"/opt/homebrew/opt/ruby/bin:\$PATH\""
    echo "  sudo gem install cocoapods"
    echo "  export PATH=\"/opt/homebrew/lib/ruby/gems/3.4.0/bin:\$PATH\""
    exit 1
fi

# Vérifier la version
echo ""
echo "📦 Version de CocoaPods :"
$POD_CMD --version

echo ""
echo "✅ CocoaPods est prêt !"
echo ""
echo "Pour utiliser pod dans ce terminal, exécutez :"
echo "  export PATH=\"$(dirname $POD_CMD):\$PATH\""
echo "  pod --version"

