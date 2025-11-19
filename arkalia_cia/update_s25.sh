#!/bin/bash
# Script simplifié pour mettre à jour Arkalia CIA sur le S25 via WiFi
# Date : 19 novembre 2025

set -e

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Configuration
PROJECT_DIR="/Volumes/T7/arkalia-cia/arkalia_cia"
S25_IP="192.168.129.46:5555"
ADB_PATH="$HOME/Library/Android/sdk/platform-tools/adb"

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Vérifier que nous sommes dans le bon répertoire
cd "$PROJECT_DIR" || exit 1

# Ajouter ADB au PATH
export PATH="$HOME/Library/Android/sdk/platform-tools:$PATH"

echo "═══════════════════════════════════════════════════════════════"
echo "🚀 Mise à jour Arkalia CIA sur S25"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Étape 1 : Vérifier la connexion WiFi
log_info "Vérification connexion WiFi..."
if ! adb devices | grep -q "$S25_IP.*device"; then
    log_warning "S25 non connecté via WiFi. Tentative de reconnexion..."
    adb connect "$S25_IP" 2>&1
    sleep 2
    
    if ! adb devices | grep -q "$S25_IP.*device"; then
        log_error "Impossible de se connecter au S25 via WiFi"
        log_info "Vérifiez que :"
        echo "  - Le S25 est allumé et déverrouillé"
        echo "  - Le S25 et le Mac sont sur le même réseau WiFi"
        echo "  - Le débogage USB WiFi est activé"
        exit 1
    fi
fi

log_success "S25 connecté via WiFi ($S25_IP)"

# Étape 2 : Vérifier Flutter
if ! command -v flutter &> /dev/null; then
    log_error "Flutter n'est pas installé ou pas dans le PATH"
    exit 1
fi

# Étape 3 : Compiler l'APK
log_info "Compilation de l'APK release..."
if flutter build apk --release; then
    log_success "APK compilé avec succès"
else
    log_error "Échec de la compilation APK"
    exit 1
fi

# Étape 4 : Vérifier que l'APK existe
APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
if [ ! -f "$APK_PATH" ]; then
    log_error "APK non trouvé : $APK_PATH"
    exit 1
fi

log_info "APK trouvé : $(ls -lh "$APK_PATH" | awk '{print $5}')"

# Étape 5 : Installer sur le S25
log_info "Installation sur le S25..."
log_info "Cela peut prendre quelques secondes..."

if adb -s "$S25_IP" install -r "$APK_PATH"; then
    log_success "Installation réussie !"
    
    # Vérifier la version installée
    log_info "Vérification de la version installée..."
    sleep 2
    local installed_version=$(adb -s "$S25_IP" shell "dumpsys package com.example.arkalia_cia | grep versionName" 2>/dev/null | awk '{print $1}' | cut -d= -f2 || echo "")
    
    if [ -n "$installed_version" ]; then
        log_success "Version installée : $installed_version"
    fi
    
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    log_success "✅ Mise à jour terminée avec succès !"
    echo "═══════════════════════════════════════════════════════════════"
else
    log_error "Échec de l'installation"
    log_info "Vérifiez les logs ci-dessus pour plus de détails"
    exit 1
fi

