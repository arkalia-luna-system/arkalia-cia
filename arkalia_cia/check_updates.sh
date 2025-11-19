#!/bin/bash
# Script de vérification des mises à jour sur tous les appareils
# Date : 19 novembre 2025

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

PROJECT_DIR="/Volumes/T7/arkalia-cia/arkalia_cia"
EXPECTED_VERSION="1.1.0+1"

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

cd "$PROJECT_DIR" || exit 1
export PATH="$HOME/Library/Android/sdk/platform-tools:$PATH"
source ~/.zshrc 2>/dev/null || true

echo "═══════════════════════════════════════════════════════════════"
echo "🔍 Vérification des mises à jour"
echo "═══════════════════════════════════════════════════════════════"
echo ""
log_info "Version attendue : $EXPECTED_VERSION"
echo ""

# Vérifier S25 (WiFi)
if command -v adb &> /dev/null; then
    log_info "Vérification S25 (WiFi : 192.168.129.46:5555)..."
    if adb devices | grep -q "192.168.129.46:5555.*device"; then
        local s25_version=$(adb -s 192.168.129.46:5555 shell "dumpsys package com.example.arkalia_cia | grep versionName" 2>/dev/null | awk '{print $1}' | cut -d= -f2 || echo "")
        local s25_updated=$(adb -s 192.168.129.46:5555 shell "dumpsys package com.example.arkalia_cia | grep lastUpdateTime" 2>/dev/null | awk '{print $1}' | cut -d= -f2 || echo "")
        
        if [ -n "$s25_version" ]; then
            log_success "S25 WiFi : Version installée = $s25_version"
            if [ -n "$s25_updated" ]; then
                local update_date=$(date -r $(($s25_updated / 1000)) "+%Y-%m-%d %H:%M:%S" 2>/dev/null || echo "Date inconnue")
                log_info "Dernière mise à jour : $update_date"
            fi
        else
            log_warning "S25 WiFi : App non installée ou inaccessible"
        fi
    else
        log_warning "S25 WiFi : Non connecté"
    fi
    
    echo ""
    
    # Vérifier S25 (USB)
    log_info "Vérification S25 (USB : R3CY60BJ3ZM)..."
    if adb devices | grep -q "R3CY60BJ3ZM.*device"; then
        local s25_usb_version=$(adb -s R3CY60BJ3ZM shell "dumpsys package com.example.arkalia_cia | grep versionName" 2>/dev/null | awk '{print $1}' | cut -d= -f2 || echo "")
        local s25_usb_updated=$(adb -s R3CY60BJ3ZM shell "dumpsys package com.example.arkalia_cia | grep lastUpdateTime" 2>/dev/null | awk '{print $1}' | cut -d= -f2 || echo "")
        
        if [ -n "$s25_usb_version" ]; then
            log_success "S25 USB : Version installée = $s25_usb_version"
            if [ -n "$s25_usb_updated" ]; then
                local update_date=$(date -r $(($s25_usb_updated / 1000)) "+%Y-%m-%d %H:%M:%S" 2>/dev/null || echo "Date inconnue")
                log_info "Dernière mise à jour : $update_date"
            fi
        else
            log_warning "S25 USB : App non installée ou inaccessible"
        fi
    else
        log_warning "S25 USB : Non connecté"
    fi
fi

echo ""

# Vérifier iPad
log_info "Vérification iPad (WiFi : 00008112-000631060A8B401E)..."
if flutter devices | grep -q "00008112-000631060A8B401E"; then
    log_success "iPad détecté et connecté via WiFi"
    log_info "Pour vérifier la version iOS, ouvrez l'app sur l'iPad et allez dans Paramètres > À propos"
else
    log_warning "iPad : Non détecté ou non connecté"
fi

echo ""
echo "═══════════════════════════════════════════════════════════════"
log_info "Pour mettre à jour, exécutez : ./update_all_devices.sh"
echo "═══════════════════════════════════════════════════════════════"

