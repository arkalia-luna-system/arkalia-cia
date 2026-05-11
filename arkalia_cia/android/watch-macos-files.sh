#!/bin/bash
# Script qui surveille et supprime les fichiers macOS cachés en continu pendant le build
# Version améliorée avec lock file et signal d'arrêt propre

# Obtenir le répertoire du projet dynamiquement
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$(cd "$PROJECT_DIR/.." && pwd)"
LOCK_FILE="/tmp/watch-macos-files.lock"

# Fonction de nettoyage
cleanup() {
    echo ""
    echo "🛑 Arrêt de watch-macos-files..."
    rm -f "$LOCK_FILE"
    exit 0
}

# Gérer les signaux pour nettoyer proprement
trap cleanup SIGINT SIGTERM

# Vérifier si le script tourne déjà
if [ -f "$LOCK_FILE" ]; then
    PID=$(cat "$LOCK_FILE" 2>/dev/null || echo "")
    if [ -n "$PID" ] && ps -p "$PID" > /dev/null 2>&1; then
        echo "⚠️  watch-macos-files tourne déjà (PID: $PID)"
        echo "   Utilisez './cleanup_all.sh' pour l'arrêter"
        exit 1
    else
        # Lock file orphelin, le supprimer
        rm -f "$LOCK_FILE"
    fi
fi

# Créer le lock file avec le PID
echo $$ > "$LOCK_FILE"

# Fonction pour supprimer les fichiers macOS cachés
clean_macos_files() {
    # Nettoyer dans build/ (récursif et agressif)
    if [ -d "$PROJECT_DIR/build" ]; then
        find "$PROJECT_DIR/build" -type f \( -name "._*" -o -name ".!*!._*" -o -name ".DS_Store" \) -delete 2>/dev/null || true
        # Nettoyer spécifiquement dans intermediates (où le problème se produit)
        if [ -d "$PROJECT_DIR/build/app/intermediates" ]; then
            find "$PROJECT_DIR/build/app/intermediates" -type f \( -name "._*" -o -name ".!*!._*" \) -delete 2>/dev/null || true
        fi
        # Nettoyer spécifiquement javac qui cause les erreurs D8
        if [ -d "$PROJECT_DIR/build/app/intermediates/javac" ]; then
            find "$PROJECT_DIR/build/app/intermediates/javac" -type f \( -name "._*" -o -name ".!*!._*" \) -delete 2>/dev/null || true
            # Supprimer aussi les répertoires vides créés par macOS
            find "$PROJECT_DIR/build/app/intermediates/javac" -type d -empty -delete 2>/dev/null || true
        fi
        # Nettoyer aussi dans compileDebugJavaWithJavac/classes spécifiquement (où l'erreur se produit)
        if [ -d "$PROJECT_DIR/build/app/intermediates/javac/debug/compileDebugJavaWithJavac/classes" ]; then
            find "$PROJECT_DIR/build/app/intermediates/javac/debug/compileDebugJavaWithJavac/classes" -type f \( -name "._*" -o -name ".!*!._*" \) -delete 2>/dev/null || true
            # Nettoyer aussi dans com/arkalia/cia/ spécifiquement (où MainActivity.class est créé)
            if [ -d "$PROJECT_DIR/build/app/intermediates/javac/debug/compileDebugJavaWithJavac/classes/com/arkalia/cia" ]; then
                find "$PROJECT_DIR/build/app/intermediates/javac/debug/compileDebugJavaWithJavac/classes/com/arkalia/cia" -type f \( -name "._*" -o -name ".!*!._*" \) -delete 2>/dev/null || true
            fi
        fi
        # Nettoyer aussi dans tous les sous-répertoires de javac (récursif)
        if [ -d "$PROJECT_DIR/build/app/intermediates/javac" ]; then
            find "$PROJECT_DIR/build/app/intermediates/javac" -type f -name "._*" -delete 2>/dev/null || true
            find "$PROJECT_DIR/build/app/intermediates/javac" -type f -name ".!*!._*" -delete 2>/dev/null || true
        fi
        # Nettoyer aussi dans kotlin-classes (où les fichiers sont créés)
        if [ -d "$PROJECT_DIR/build/app/tmp/kotlin-classes" ]; then
            find "$PROJECT_DIR/build/app/tmp/kotlin-classes" -type f \( -name "._*" -o -name ".!*!._*" \) -delete 2>/dev/null || true
        fi
        # Nettoyer spécifiquement compile_and_runtime_not_namespaced_r_class_jar (où l'erreur se produit)
        if [ -d "$PROJECT_DIR/build/app/intermediates/compile_and_runtime_not_namespaced_r_class_jar" ]; then
            find "$PROJECT_DIR/build/app/intermediates/compile_and_runtime_not_namespaced_r_class_jar" -type f \( -name "._*" -o -name ".!*!._*" \) -delete 2>/dev/null || true
        fi
        # Nettoyer aussi dans processDebugResources/R.jar spécifiquement
        if [ -d "$PROJECT_DIR/build/app/intermediates/compile_and_runtime_not_namespaced_r_class_jar/debug/processDebugResources" ]; then
            find "$PROJECT_DIR/build/app/intermediates/compile_and_runtime_not_namespaced_r_class_jar/debug/processDebugResources" -type f \( -name "._*" -o -name ".!*!._*" \) -delete 2>/dev/null || true
        fi
        # Nettoyer aussi dans tous les répertoires où BuildConfig.class peut être créé
        if [ -d "$PROJECT_DIR/build/app/intermediates/javac" ]; then
            find "$PROJECT_DIR/build/app/intermediates/javac" -type f -name "._BuildConfig.class" -delete 2>/dev/null || true
            find "$PROJECT_DIR/build/app/intermediates/javac" -type f -name "._*" -delete 2>/dev/null || true
        fi
        if [ -d "$PROJECT_DIR/build/app/tmp/kotlin-classes" ]; then
            find "$PROJECT_DIR/build/app/tmp/kotlin-classes" -type f -name "._BuildConfig.class" -delete 2>/dev/null || true
            find "$PROJECT_DIR/build/app/tmp/kotlin-classes" -type f -name "._*" -delete 2>/dev/null || true
        fi
        # Nettoyer aussi dans compile_and_runtime_not_namespaced_r_class_jar (où l'erreur se produit)
        if [ -d "$PROJECT_DIR/build/app/intermediates/compile_and_runtime_not_namespaced_r_class_jar" ]; then
            find "$PROJECT_DIR/build/app/intermediates/compile_and_runtime_not_namespaced_r_class_jar" -type f -name "._BuildConfig.class" -delete 2>/dev/null || true
            find "$PROJECT_DIR/build/app/intermediates/compile_and_runtime_not_namespaced_r_class_jar" -type f -name "._*" -delete 2>/dev/null || true
        fi
    fi
    
    # Nettoyer spécifiquement dans packaged_res (où l'erreur parseReleaseLocalResources se produit)
    if [ -d "$PROJECT_DIR/build" ]; then
        find "$PROJECT_DIR/build" -path "*/packaged_res/*" -type f \( -name "._*" -o -name ".!*!._*" -o -name ".DS_Store" \) -delete 2>/dev/null || true
        # Nettoyer aussi dans tous les répertoires packageReleaseResources
        find "$PROJECT_DIR/build" -path "*/packageReleaseResources/*" -type f \( -name "._*" -o -name ".!*!._*" \) -delete 2>/dev/null || true
    fi
    
    # Nettoyer aussi dans android/.gradle
    if [ -d "$SCRIPT_DIR/.gradle" ]; then
        find "$SCRIPT_DIR/.gradle" -type f \( -name "._*" -o -name ".DS_Store" \) -delete 2>/dev/null || true
    fi
}

echo "👀 Surveillance des fichiers macOS (PID: $$)"
echo "   Pour arrêter: Ctrl+C ou './cleanup_all.sh'"
echo ""

# Intervalle volontairement modéré : un balayage toutes les 0,5 s saturait
# CPU/disque (surtout sur volume externe). 4 s reste largement suffisant
# pour supprimer les AppleDouble avant les étapes Gradle lentes.
while [ -f "$LOCK_FILE" ]; do
    clean_macos_files
    sleep 4
done

# Nettoyage à la fin
cleanup

