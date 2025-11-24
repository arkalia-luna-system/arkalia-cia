#!/bin/bash
# Script pour démarrer l'app Flutter en mode web dans Comet
# L'interface complète sera accessible dans le navigateur
# Ce script coupe les processus existants, met à jour le code, puis démarre

set -e

# Couleurs pour les messages
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Chemin du projet
PROJECT_ROOT="/Volumes/T7/arkalia-cia"
FLUTTER_DIR="${PROJECT_ROOT}/arkalia_cia"
LOCK_FILE="/tmp/arkalia_flutter_web.lock"

echo -e "${BLUE}🌐 Démarrage de l'app Flutter en mode Web${NC}"
echo ""

# Fonction pour arrêter les processus Flutter existants
cleanup_existing() {
    echo -e "${YELLOW}🧹 Nettoyage des processus existants...${NC}"
    
    # Arrêter les processus Flutter web
    if [ -f "$LOCK_FILE" ]; then
        PID=$(cat "$LOCK_FILE" 2>/dev/null || echo "")
        if [ -n "$PID" ] && ps -p "$PID" > /dev/null 2>&1; then
            echo -e "${YELLOW}   Arrêt du processus Flutter (PID: $PID)${NC}"
            kill -9 "$PID" 2>/dev/null || true
        fi
        rm -f "$LOCK_FILE"
    fi
    
    # Tuer tous les processus Flutter web
    pkill -f "flutter.*run.*web" 2>/dev/null || true
    pkill -f "dart.*flutter.*web" 2>/dev/null || true
    
    # Attendre un peu pour que les processus se terminent
    sleep 2
    
    echo -e "${GREEN}✅ Nettoyage terminé${NC}"
    echo ""
}

# Fonction de nettoyage à la sortie
cleanup() {
    echo ""
    echo -e "${YELLOW}🛑 Arrêt de Flutter web...${NC}"
    rm -f "$LOCK_FILE"
    exit 0
}

# Gérer les signaux pour nettoyer proprement
trap cleanup SIGINT SIGTERM

# Nettoyer les processus existants
cleanup_existing

# Aller dans le répertoire Flutter
cd "$FLUTTER_DIR"

# Vérifier que Flutter est installé
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter n'est pas installé ou n'est pas dans le PATH${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Flutter: $(flutter --version | head -1)${NC}"
echo ""

# Mettre à jour le code (git pull si dans un repo git)
if [ -d ".git" ]; then
    echo -e "${BLUE}🔄 Mise à jour du code...${NC}"
    git pull origin develop 2>/dev/null || echo -e "${YELLOW}⚠️  Impossible de mettre à jour (pas de repo git ou erreur)${NC}"
    echo ""
fi

# Nettoyer le build précédent pour forcer la mise à jour
echo -e "${BLUE}🧹 Nettoyage du build précédent...${NC}"
flutter clean > /dev/null 2>&1 || true
echo -e "${GREEN}✅ Nettoyage terminé${NC}"
echo ""

# Installer les dépendances
echo -e "${BLUE}📦 Installation des dépendances...${NC}"
flutter pub get
echo -e "${GREEN}✅ Dépendances installées${NC}"
echo ""

# Vérifier si le build web existe
if [ ! -f "build/web/index.html" ]; then
    echo -e "${BLUE}🔨 Génération du build web (première fois, peut prendre quelques minutes)...${NC}"
    flutter build web --release --no-wasm-dry-run
    echo -e "${GREEN}✅ Build web généré${NC}"
else
    echo -e "${BLUE}🔨 Régénération du build web pour mettre à jour...${NC}"
    flutter build web --release --no-wasm-dry-run
    echo -e "${GREEN}✅ Build web régénéré${NC}"
fi
echo ""

# Vérifier si le port est libre, sinon utiliser un autre
PORT=8080
if lsof -ti:$PORT > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Port $PORT déjà utilisé, arrêt du processus...${NC}"
    lsof -ti:$PORT | xargs kill -9 2>/dev/null || true
    sleep 1
    if lsof -ti:$PORT > /dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  Port $PORT toujours utilisé, utilisation du port 8081${NC}"
        PORT=8081
        if lsof -ti:$PORT > /dev/null 2>&1; then
            lsof -ti:$PORT | xargs kill -9 2>/dev/null || true
            sleep 1
            if lsof -ti:$PORT > /dev/null 2>&1; then
                echo -e "${YELLOW}⚠️  Port $PORT aussi utilisé, utilisation du port 8082${NC}"
                PORT=8082
            fi
        fi
    fi
fi

# Créer le lock file
echo $$ > "$LOCK_FILE"

# Démarrer le serveur web local
echo ""
echo -e "${GREEN}🌟 Démarrage du serveur web...${NC}"
echo -e "${BLUE}📱 Ouvrez Comet et allez à: http://localhost:$PORT${NC}"
echo -e "${YELLOW}💡 Appuyez sur Ctrl+C pour arrêter${NC}"
echo ""

# Démarrer Flutter en mode web
flutter run -d web-server --web-port=$PORT --web-hostname=localhost

