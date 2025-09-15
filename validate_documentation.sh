#!/bin/bash
# Script de validation de la cohérence documentation vs code

echo "🔍 Validation de la cohérence documentation vs code"
echo "=================================================="

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Compteurs
ISSUES=0
WARNINGS=0

echo ""
echo "📊 1. Vérification des services Flutter..."

# Vérifier les services mentionnés dans la doc
EXPECTED_SERVICES=("api_service.dart" "calendar_service.dart" "contacts_service.dart" "local_storage_service.dart")
for service in "${EXPECTED_SERVICES[@]}"; do
    if [ -f "arkalia_cia/lib/services/$service" ]; then
        echo -e "  ✅ $service - Présent"
    else
        echo -e "  ${RED}❌ $service - Manquant${NC}"
        ((ISSUES++))
    fi
done

echo ""
echo "📊 2. Vérification des widgets Flutter..."

# Vérifier les widgets mentionnés dans la doc
EXPECTED_WIDGETS=("emergency_contact_card.dart" "emergency_contact_dialog.dart" "emergency_info_card.dart")
for widget in "${EXPECTED_WIDGETS[@]}"; do
    if [ -f "arkalia_cia/lib/widgets/$widget" ]; then
        echo -e "  ✅ $widget - Présent"
    else
        echo -e "  ${RED}❌ $widget - Manquant${NC}"
        ((ISSUES++))
    fi
done

echo ""
echo "📊 3. Vérification des écrans Flutter..."

# Vérifier les écrans mentionnés dans la doc
EXPECTED_SCREENS=("home_page.dart" "documents_screen.dart" "health_screen.dart" "reminders_screen.dart" "emergency_screen.dart")
for screen in "${EXPECTED_SCREENS[@]}"; do
    if [ -f "arkalia_cia/lib/screens/$screen" ]; then
        echo -e "  ✅ $screen - Présent"
    else
        echo -e "  ${RED}❌ $screen - Manquant${NC}"
        ((ISSUES++))
    fi
done

echo ""
echo "📊 4. Vérification des services Python..."

# Vérifier les services Python mentionnés dans la doc
EXPECTED_PYTHON_SERVICES=("api.py" "database.py" "pdf_processor.py" "security_dashboard.py" "storage.py" "auto_documenter.py")
for service in "${EXPECTED_PYTHON_SERVICES[@]}"; do
    if [ -f "arkalia_cia_python_backend/$service" ]; then
        echo -e "  ✅ $service - Présent"
    else
        echo -e "  ${RED}❌ $service - Manquant${NC}"
        ((ISSUES++))
    fi
done

echo ""
echo "📊 5. Vérification des versions..."

# Vérifier la version Flutter dans pubspec.yaml
FLUTTER_VERSION=$(grep -o 'sdk: ">=3.0.0 <4.0.0"' arkalia_cia/pubspec.yaml)
if [ -n "$FLUTTER_VERSION" ]; then
    echo -e "  ✅ Version Dart: $FLUTTER_VERSION"
else
    echo -e "  ${YELLOW}⚠️ Version Dart non trouvée${NC}"
    ((WARNINGS++))
fi

# Vérifier la version Python dans requirements.txt
if [ -f "requirements.txt" ]; then
    PYTHON_VERSION=$(grep -o 'python_requires.*3.10' pyproject.toml 2>/dev/null || echo "Non spécifié")
    echo -e "  ✅ Version Python: $PYTHON_VERSION"
else
    echo -e "  ${YELLOW}⚠️ requirements.txt non trouvé${NC}"
    ((WARNINGS++))
fi

echo ""
echo "📊 6. Vérification des tests..."

# Compter les tests Python
PYTHON_TESTS=$(find tests -name "*.py" -type f | wc -l)
echo -e "  ✅ Tests Python: $PYTHON_TESTS fichiers"

# Vérifier les tests Flutter
if [ -d "arkalia_cia/test" ]; then
    FLUTTER_TESTS=$(find arkalia_cia/test -name "*.dart" -type f | wc -l)
    echo -e "  ✅ Tests Flutter: $FLUTTER_TESTS fichiers"
else
    echo -e "  ${YELLOW}⚠️ Dossier de tests Flutter non trouvé${NC}"
    ((WARNINGS++))
fi

echo ""
echo "📊 7. Vérification de la structure des dossiers..."

# Vérifier la structure des dossiers
EXPECTED_DIRS=("arkalia_cia/lib/screens" "arkalia_cia/lib/services" "arkalia_cia/lib/widgets" "arkalia_cia/lib/utils" "arkalia_cia_python_backend" "tests" "docs")
for dir in "${EXPECTED_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo -e "  ✅ $dir - Présent"
    else
        echo -e "  ${RED}❌ $dir - Manquant${NC}"
        ((ISSUES++))
    fi
done

echo ""
echo "📊 8. Vérification des fichiers de documentation..."

# Vérifier les fichiers de documentation
EXPECTED_DOCS=("README.md" "SECURITY.md" "docs/ARCHITECTURE.md" "docs/API.md" "docs/CONTRIBUTING.md" "docs/DEPLOYMENT.md" "docs/CHANGELOG.md")
for doc in "${EXPECTED_DOCS[@]}"; do
    if [ -f "$doc" ]; then
        echo -e "  ✅ $doc - Présent"
    else
        echo -e "  ${RED}❌ $doc - Manquant${NC}"
        ((ISSUES++))
    fi
done

echo ""
echo "📊 9. Vérification des fichiers de configuration..."

# Vérifier les fichiers de configuration
EXPECTED_CONFIGS=("arkalia_cia/pubspec.yaml" "pyproject.toml" ".pre-commit-config.yaml" "Makefile")
for config in "${EXPECTED_CONFIGS[@]}"; do
    if [ -f "$config" ]; then
        echo -e "  ✅ $config - Présent"
    else
        echo -e "  ${RED}❌ $config - Manquant${NC}"
        ((ISSUES++))
    fi
done

echo ""
echo "=================================================="
echo "📋 RÉSUMÉ DE LA VALIDATION"
echo "=================================================="

if [ $ISSUES -eq 0 ]; then
    echo -e "${GREEN}✅ Aucun problème critique détecté${NC}"
else
    echo -e "${RED}❌ $ISSUES problème(s) critique(s) détecté(s)${NC}"
fi

if [ $WARNINGS -gt 0 ]; then
    echo -e "${YELLOW}⚠️ $WARNINGS avertissement(s)${NC}"
fi

echo ""
echo "🎯 Actions recommandées:"
if [ $ISSUES -gt 0 ]; then
    echo "  - Corriger les fichiers manquants"
    echo "  - Mettre à jour la documentation"
fi
if [ $WARNINGS -gt 0 ]; then
    echo "  - Vérifier les configurations"
    echo "  - Améliorer la couverture de tests"
fi

echo ""
echo "🔍 Validation terminée !"
