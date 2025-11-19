#!/bin/bash
# Script sécurisé pour mettre à jour Arkalia CIA sur tous les appareils
# ⚠️ IMPORTANT : Ce script NE SUPPRIME JAMAIS les données utilisateur
# Date : 19 novembre 2025

set -uo pipefail  # Mode strict mais sans -e pour éviter arrêt sur erreur mineure

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_DIR="/Volumes/T7/arkalia-cia/arkalia_cia"
ADB_PATH="$HOME/Library/Android/sdk/platform-tools/adb"
WIFI_IP_FILE="$PROJECT_DIR/.wifi_adb_ip"
BUILD_CLEANUP_DAYS=7  # Garder les builds de moins de 7 jours

# Chemins des données utilisateur (NE JAMAIS SUPPRIMER)
IOS_DATA_PATTERNS=(
    "Library/Containers/com.example.arkaliaCia"
    "Library/Application Support/com.example.arkaliaCia"
    "Library/Preferences/com.example.arkaliaCia"
)
ANDROID_DATA_PATTERNS=(
    "/data/data/com.example.arkalia_cia"
    "/sdcard/Android/data/com.example.arkalia_cia"
)
MACOS_DATA_PATTERNS=(
    "$HOME/Library/Application Support/arkalia_cia"
    "$HOME/Library/Preferences/com.example.arkaliaCia"
)

# Fonctions utilitaires
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
check_project_dir() {
    if [ ! -f "$PROJECT_DIR/pubspec.yaml" ]; then
        log_error "Répertoire projet introuvable : $PROJECT_DIR"
        exit 1
    fi
    cd "$PROJECT_DIR" || exit 1
}

# Nettoyer les builds anciens (SANS toucher aux données utilisateur)
cleanup_old_builds() {
    log_info "Nettoyage des builds anciens (> $BUILD_CLEANUP_DAYS jours)..."
    
    local cleaned=0
    
    # Nettoyer les builds iOS
    if [ -d "$PROJECT_DIR/build/ios" ]; then
        find "$PROJECT_DIR/build/ios" -type d -name "*.app" -mtime +$BUILD_CLEANUP_DAYS -exec rm -rf {} + 2>/dev/null && cleaned=$((cleaned + 1))
    fi
    
    # Nettoyer les builds Android
    if [ -d "$PROJECT_DIR/build/app" ]; then
        find "$PROJECT_DIR/build/app" -name "*.apk" -mtime +$BUILD_CLEANUP_DAYS -delete 2>/dev/null && cleaned=$((cleaned + 1))
        find "$PROJECT_DIR/build/app" -name "*.aab" -mtime +$BUILD_CLEANUP_DAYS -delete 2>/dev/null && cleaned=$((cleaned + 1))
    fi
    
    # Nettoyer les builds macOS
    if [ -d "$PROJECT_DIR/build/macos" ]; then
        find "$PROJECT_DIR/build/macos" -type d -name "*.app" -mtime +$BUILD_CLEANUP_DAYS -exec rm -rf {} + 2>/dev/null && cleaned=$((cleaned + 1))
    fi
    
    # Nettoyer les fichiers temporaires
    find "$PROJECT_DIR/build" -name "._*" -type f -delete 2>/dev/null
    
    if [ $cleaned -gt 0 ]; then
        log_success "Nettoyage terminé : $cleaned ancien(s) build(s) supprimé(s)"
    else
        log_info "Aucun build ancien à nettoyer"
    fi
}

# Vérifier que les données utilisateur sont préservées (sécurité)
verify_user_data_safe() {
    log_info "Vérification de la sécurité des données utilisateur..."
    
    local data_found=0
    
    # Vérifier iOS
    for pattern in "${IOS_DATA_PATTERNS[@]}"; do
        if [ -d "$HOME/$pattern" ] 2>/dev/null; then
            data_found=$((data_found + 1))
            log_success "Données iOS trouvées : $pattern"
        fi
    done
    
    # Vérifier Android (via ADB si disponible)
    if command -v "$ADB_PATH" &> /dev/null; then
        local android_devices=$("$ADB_PATH" devices 2>/dev/null | grep -v "List" | grep "device" | wc -l | tr -d ' ')
        if [ "$android_devices" -gt 0 ]; then
            log_info "Appareil(s) Android détecté(s) - données préservées"
            data_found=$((data_found + 1))
        fi
    fi
    
    # Vérifier macOS
    for pattern in "${MACOS_DATA_PATTERNS[@]}"; do
        if [ -d "$pattern" ] 2>/dev/null; then
            data_found=$((data_found + 1))
            log_success "Données macOS trouvées : $pattern"
        fi
    done
    
    if [ $data_found -eq 0 ]; then
        log_warning "Aucune donnée utilisateur trouvée (normal si première installation)"
    fi
    
    log_success "Vérification sécurité terminée - données utilisateur préservées"
}

# Détecter et lister les appareils disponibles
detect_devices() {
    log_info "Détection des appareils disponibles..."
    
    local devices=()
    
    # Vérifier Flutter
    if ! command -v flutter &> /dev/null; then
        log_error "Flutter n'est pas installé ou pas dans le PATH"
        return 1
    fi
    
    # Source le PATH pour ADB
    export PATH="$HOME/Library/Android/sdk/platform-tools:$PATH"
    # Ne pas utiliser source ~/.zshrc car cela peut bloquer
    
    # Attendre un peu pour que Flutter détecte les appareils
    sleep 2
    
    # Obtenir la liste des appareils Flutter en JSON
    local flutter_json=$(flutter devices --machine 2>/dev/null || echo "[]")
    
    if [ -z "$flutter_json" ] || [ "$flutter_json" = "[]" ]; then
        log_warning "Aucun appareil détecté par Flutter (JSON vide)"
        return 1
    fi
    
    # Extraire les IDs des appareils depuis le JSON
    # Utiliser Python si disponible
    local device_ids=""
    if command -v python3 &> /dev/null; then
        device_ids=$(echo "$flutter_json" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    for d in data:
        if 'id' in d:
            print(d['id'])
except Exception as e:
    sys.stderr.write('Erreur parsing: ' + str(e) + '\n')
    sys.exit(1)
" 2>&1)
        
        # Vérifier si Python a retourné une erreur
        if echo "$device_ids" | grep -q "Erreur"; then
            log_warning "Erreur parsing JSON: $device_ids"
            return 1
        fi
    else
        # Fallback : extraction simple avec grep
        device_ids=$(echo "$flutter_json" | grep -o '"id"[[:space:]]*:[[:space:]]*"[^"]*"' | cut -d'"' -f4)
    fi
    
    if [ -z "$device_ids" ]; then
        log_warning "Aucun ID d'appareil extrait du JSON"
        log_info "JSON reçu: ${flutter_json:0:200}..."
        return 1
    fi
    
    # Filtrer les IDs valides et éviter les doublons
    local seen_devices=()
    for device_id in $device_ids; do
        device_id=$(echo "$device_id" | xargs)  # Trim whitespace
        if [ -n "$device_id" ] && [[ ! " ${seen_devices[@]} " =~ " ${device_id} " ]]; then
            devices+=("$device_id")
            seen_devices+=("$device_id")
            
            # Obtenir le nom de l'appareil
            local device_name=$(echo "$flutter_json" | grep -A 10 "\"$device_id\"" | grep '"name"' | head -1 | cut -d'"' -f4 || echo "$device_id")
            log_info "Appareil détecté : $device_name ($device_id)"
        fi
    done
    
    if [ ${#devices[@]} -eq 0 ]; then
        log_warning "Aucun appareil disponible après filtrage"
        return 1
    fi
    
    # Retourner les IDs séparés par des retours à la ligne
    printf '%s\n' "${devices[@]}"
}

# Variable globale pour éviter de compiler plusieurs fois
_APK_BUILT=false
_IOS_BUILT=false
_MACOS_BUILT=false

# Mettre à jour l'app sur un appareil spécifique
update_device() {
    local device_id=$1
    local device_name=$2
    
    log_info "Mise à jour sur $device_name ($device_id)..."
    
    # Détecter le type d'appareil et construire/installer
    local build_success=false
    
    if [[ "$device_id" == *"192.168"* ]] || [[ "$device_id" == *":5555"* ]]; then
        # Android via WiFi
        log_info "Mode : Android WiFi"
        
        # Compiler APK seulement si pas déjà fait
        if [ "$_APK_BUILT" = false ]; then
            log_info "Compilation APK..."
            if flutter build apk --release 2>&1 | tee /tmp/flutter_build_apk.log; then
                _APK_BUILT=true
                log_success "APK compilé avec succès"
            else
                log_error "Échec compilation APK"
                return 1
            fi
        else
            log_info "Utilisation de l'APK déjà compilé"
        fi
        
        log_info "Installation sur $device_id..."
        export PATH="$HOME/Library/Android/sdk/platform-tools:$PATH"
        
        # Vérifier que l'APK existe avant d'installer
        if [ ! -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
            log_error "APK non trouvé : build/app/outputs/flutter-apk/app-release.apk"
            return 1
        fi
        
        # Forcer l'arrêt de l'app avant installation pour éviter les conflits
        log_info "Arrêt de l'app avant installation..."
        adb -s "$device_id" shell "am force-stop com.example.arkalia_cia" 2>/dev/null || true
        sleep 1
        
        if adb -s "$device_id" install -r build/app/outputs/flutter-apk/app-release.apk 2>&1 | tee /tmp/flutter_install_${device_id}.log; then
            build_success=true
            log_success "Installation réussie sur $device_id"
        else
            log_error "Échec installation - voir /tmp/flutter_install_${device_id}.log"
        fi
        
    elif [[ "$device_id" == *"macos"* ]]; then
        # macOS
        log_info "Mode : macOS"
        
        if [ "$_MACOS_BUILT" = false ]; then
            log_info "Compilation macOS..."
            if flutter build macos --release 2>&1 | tee /tmp/flutter_build_macos.log; then
                _MACOS_BUILT=true
                log_success "Application macOS compilée"
            else
                log_error "Échec compilation macOS"
                return 1
            fi
        else
            log_info "Application macOS déjà compilée"
        fi
        
        log_info "Application disponible : build/macos/Build/Products/Release/arkalia_cia.app"
        build_success=true
        
    elif [[ "$device_id" =~ ^[0-9A-F-]+$ ]] || [[ "$device_id" == *"ios"* ]]; then
        # iOS (iPad/iPhone)
        log_info "Mode : iOS"
        
        if [ "$_IOS_BUILT" = false ]; then
            log_info "Compilation iOS..."
            # Compiler d'abord avec build ios
            if flutter build ios --release --no-codesign 2>&1 | tee /tmp/flutter_build_ios.log; then
                _IOS_BUILT=true
                log_success "App iOS compilée"
            else
                log_error "Échec compilation iOS"
                return 1
            fi
        else
            log_info "App iOS déjà compilée"
        fi
        
        log_info "Installation sur $device_id..."
        # Utiliser flutter run pour installer (plus fiable pour iOS)
        # Avec timeout pour éviter le blocage
        if command -v timeout &> /dev/null; then
            local ios_output=$(timeout 180 flutter run --release -d "$device_id" --no-hot 2>&1 | tee /tmp/flutter_install_${device_id}.log || true)
        else
            # Fallback sans timeout (macOS n'a pas timeout par défaut)
            local ios_output=$(flutter run --release -d "$device_id" --no-hot 2>&1 | tee /tmp/flutter_install_${device_id}.log || true)
        fi
        
        if echo "$ios_output" | grep -qE "(Built|Installing|Launching|Xcode build done|Installed)"; then
            build_success=true
        fi
        
    else
        # Android USB
        log_info "Mode : Android USB"
        
        # Compiler APK seulement si pas déjà fait
        if [ "$_APK_BUILT" = false ]; then
            log_info "Compilation APK..."
            if flutter build apk --release 2>&1 | tee /tmp/flutter_build_apk.log; then
                _APK_BUILT=true
                log_success "APK compilé avec succès"
            else
                log_error "Échec compilation APK"
                return 1
            fi
        else
            log_info "Utilisation de l'APK déjà compilé"
        fi
        
        log_info "Installation sur $device_id..."
        export PATH="$HOME/Library/Android/sdk/platform-tools:$PATH"
        
        # Vérifier que l'APK existe avant d'installer
        if [ ! -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
            log_error "APK non trouvé : build/app/outputs/flutter-apk/app-release.apk"
            return 1
        fi
        
        # Forcer l'arrêt de l'app avant installation pour éviter les conflits
        log_info "Arrêt de l'app avant installation..."
        adb -s "$device_id" shell "am force-stop com.example.arkalia_cia" 2>/dev/null || true
        sleep 1
        
        if adb -s "$device_id" install -r build/app/outputs/flutter-apk/app-release.apk 2>&1 | tee /tmp/flutter_install_${device_id}.log; then
            build_success=true
            log_success "Installation réussie sur $device_id"
        else
            log_error "Échec installation - voir /tmp/flutter_install_${device_id}.log"
        fi
    fi
    
    if [ "$build_success" = true ]; then
        log_success "Mise à jour réussie sur $device_name"
        return 0
    else
        log_error "Échec de la mise à jour sur $device_name"
        log_warning "Voir les logs : /tmp/flutter_install_${device_id}.log"
        return 1
    fi
}

# Reconnecter Android via WiFi si nécessaire
reconnect_android_wifi() {
    if [ ! -f "$WIFI_IP_FILE" ]; then
        return 0  # Ne pas bloquer, continuer
    fi
    
    local wifi_ip=$(cat "$WIFI_IP_FILE" 2>/dev/null | tr -d '\r\n' | xargs)
    
    if [ -z "$wifi_ip" ]; then
        return 0  # Ne pas bloquer
    fi
    
    log_info "Tentative de reconnexion Android via WiFi ($wifi_ip)..."
    
    export PATH="$HOME/Library/Android/sdk/platform-tools:$PATH"
    # Ne pas utiliser source ~/.zshrc car cela peut bloquer
    
    if ! command -v adb &> /dev/null; then
        log_warning "ADB non trouvé - continuons sans WiFi"
        return 0  # Ne pas bloquer
    fi
    
    # Vérifier si déjà connecté (sans timeout pour éviter blocage)
    local devices_check=""
    if command -v timeout &> /dev/null; then
        devices_check=$(timeout 2 bash -c "adb devices 2>/dev/null | grep '$wifi_ip:5555'" 2>/dev/null || echo "")
    else
        # macOS n'a pas timeout par défaut
        devices_check=$(adb devices 2>/dev/null | grep "$wifi_ip:5555" || echo "")
    fi
    
    if echo "$devices_check" | grep -q "device"; then
        log_success "Android déjà connecté via WiFi"
        return 0
    fi
    
    # Tenter la connexion en arrière-plan pour ne pas bloquer
    (adb connect "$wifi_ip:5555" >/dev/null 2>&1 &)
    sleep 1
    
    # Vérifier rapidement si connecté
    if command -v timeout &> /dev/null; then
        devices_check=$(timeout 2 bash -c "adb devices 2>/dev/null | grep '$wifi_ip:5555'" 2>/dev/null || echo "")
    else
        devices_check=$(adb devices 2>/dev/null | grep "$wifi_ip:5555" || echo "")
    fi
    
    if echo "$devices_check" | grep -q "device"; then
        log_success "Android reconnecté via WiFi"
    else
        log_warning "Reconnexion WiFi en cours - continuons"
    fi
    
    return 0  # Toujours continuer, ne jamais bloquer
}

# Fonction principale
main() {
    echo "═══════════════════════════════════════════════════════════════"
    echo "🚀 Mise à jour automatique Arkalia CIA"
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
    
    # Vérifications initiales
    check_project_dir
    verify_user_data_safe
    
    # Nettoyer les builds anciens
    cleanup_old_builds
    
    # Reconnecter Android WiFi si possible (ne bloque jamais)
    reconnect_android_wifi
    
    # Petite pause pour laisser Flutter détecter les appareils
    log_info "Attente de détection des appareils..."
    sleep 2
    
    # Debug : vérifier que le script continue
    log_info "Continuation après reconnexion WiFi..."
    
    # Détecter les appareils
    log_info "Détection des appareils..."
    local devices_output=""
    local detect_exit_code=0
    
    devices_output=$(detect_devices 2>&1)
    detect_exit_code=$?
    
    if [ $detect_exit_code -ne 0 ] || [ -z "$devices_output" ]; then
        log_error "Aucun appareil détecté. Vérifiez que :"
        echo "  - iPad/iPhone est connecté et déverrouillé"
        echo "  - S25 est connecté (USB ou WiFi)"
        echo "  - Mac est disponible pour macOS"
        echo ""
        log_info "Appareils Flutter disponibles :"
        flutter devices 2>&1 | head -30
        exit 1
    fi
    
    log_info "Appareils détectés :"
    echo "$devices_output"
    
    # Convertir la sortie en tableau (une ligne par appareil)
    local device_array=()
    local seen_devices=()
    
    while IFS= read -r line; do
        if [ -n "$line" ]; then
            # Éviter les doublons : si S25 est en WiFi ET USB, préférer WiFi
            local is_duplicate=false
            local is_wifi=false
            
            # Détecter si c'est un appareil WiFi
            if [[ "$line" == *"192.168"* ]] || [[ "$line" == *":5555"* ]]; then
                is_wifi=true
            fi
            
            # Vérifier si c'est le même appareil physique (même nom)
            local device_name=$(flutter devices --machine 2>/dev/null | grep -A 10 "\"$line\"" | grep '"name"' | head -1 | cut -d'"' -f4 || echo "")
            
            for seen_id in "${seen_devices[@]}"; do
                local seen_name=$(flutter devices --machine 2>/dev/null | grep -A 10 "\"$seen_id\"" | grep '"name"' | head -1 | cut -d'"' -f4 || echo "")
                
                # Si même nom d'appareil, c'est un doublon
                if [ "$device_name" = "$seen_name" ] && [ -n "$device_name" ]; then
                    # Si le nouveau est WiFi et l'ancien non, remplacer
                    if [ "$is_wifi" = true ]; then
                        # Retirer l'ancien et ajouter le nouveau
                        local new_array=()
                        for d in "${device_array[@]}"; do
                            if [ "$d" != "$seen_id" ]; then
                                new_array+=("$d")
                            fi
                        done
                        device_array=("${new_array[@]}")
                        seen_devices=("${seen_devices[@]/$seen_id}")
                        is_duplicate=false
                        break
                    else
                        is_duplicate=true
                        break
                    fi
                fi
            done
            
            if [ "$is_duplicate" = false ]; then
                device_array+=("$line")
                seen_devices+=("$line")
            fi
        fi
    done <<< "$devices_output"
    
    if [ ${#device_array[@]} -eq 0 ]; then
        log_error "Aucun appareil trouvé dans la liste"
        exit 1
    fi
    
    log_success "${#device_array[@]} appareil(s) unique(s) détecté(s)"
    
    # Mettre à jour chaque appareil
    local success_count=0
    local fail_count=0
    
    for device_id in "${device_array[@]}"; do
        # Obtenir le nom de l'appareil
        local device_name=$(flutter devices --machine 2>/dev/null | grep -A 3 "\"$device_id\"" | grep '"name"' | cut -d'"' -f4 || echo "$device_id")
        
        echo ""
        echo "───────────────────────────────────────────────────────────"
        log_info "Traitement : $device_name ($device_id)"
        echo "───────────────────────────────────────────────────────────"
        
        if update_device "$device_id" "$device_name"; then
            success_count=$((success_count + 1))
        else
            fail_count=$((fail_count + 1))
        fi
        
        # Petite pause entre les appareils
        sleep 2
    done
    
    # Résumé
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo "📊 RÉSUMÉ"
    echo "═══════════════════════════════════════════════════════════════"
    log_success "Mises à jour réussies : $success_count"
    if [ $fail_count -gt 0 ]; then
        log_error "Échecs : $fail_count"
    fi
    echo ""
    log_success "✅ Données utilisateur préservées (aucune suppression)"
    log_success "✅ Builds anciens nettoyés"
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
}

# Exécuter le script
main "$@"

