#!/bin/bash
# Script pour préparer les secrets GitHub à partir du keystore existant
# Génère les commandes pour encoder le keystore et configurer les secrets

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Préparation des secrets GitHub pour déploiement automatique${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

cd "$(dirname "$0")"

# Vérifier que le keystore existe (fichier réel ou lien symbolique)
KEYSTORE_FILE="arkalia-cia-release.jks"
if [ -L "$KEYSTORE_FILE" ]; then
    KEYSTORE_REAL=$(readlink -f "$KEYSTORE_FILE")
    echo -e "${YELLOW}ℹ️  Keystore est un lien symbolique vers: $KEYSTORE_REAL${NC}"
elif [ ! -f "$KEYSTORE_FILE" ]; then
    echo -e "${RED}❌ Erreur : Le keystore n'existe pas !${NC}"
    echo "   Exécutez d'abord : ./generate_keystore.sh"
    exit 1
fi

# Vérifier que key.properties existe (fichier réel ou lien symbolique)
if [ -L "key.properties" ]; then
    KEY_PROP_REAL=$(readlink -f "key.properties")
    echo -e "${YELLOW}ℹ️  key.properties est un lien symbolique vers: $KEY_PROP_REAL${NC}"
elif [ ! -f "key.properties" ]; then
    echo -e "${RED}❌ Erreur : key.properties n'existe pas !${NC}"
    echo "   Exécutez d'abord : ./setup_key_properties.sh"
    exit 1
fi

echo -e "${GREEN}✅ Keystore trouvé : arkalia-cia-release.jks${NC}"
echo -e "${GREEN}✅ key.properties trouvé${NC}"
echo ""

# Lire les mots de passe depuis key.properties
STORE_PASSWORD=$(grep "^storePassword=" key.properties | cut -d'=' -f2)
KEY_PASSWORD=$(grep "^keyPassword=" key.properties | cut -d'=' -f2)
KEY_ALIAS=$(grep "^keyAlias=" key.properties | cut -d'=' -f2)

if [ -z "$STORE_PASSWORD" ] || [ -z "$KEY_PASSWORD" ]; then
    echo -e "${RED}❌ Erreur : Impossible de lire les mots de passe depuis key.properties${NC}"
    exit 1
fi

echo -e "${YELLOW}📝 Informations détectées :${NC}"
echo "   Key Alias: $KEY_ALIAS"
echo "   Store Password: ${STORE_PASSWORD:0:3}*** (masqué)"
echo "   Key Password: ${KEY_PASSWORD:0:3}*** (masqué)"
echo ""

# Encoder le keystore en base64 (suivre le lien symbolique si nécessaire)
echo -e "${YELLOW}🔐 Encodage du keystore en base64...${NC}"
if [ -L "$KEYSTORE_FILE" ]; then
    KEYSTORE_REAL=$(readlink -f "$KEYSTORE_FILE")
    KEYSTORE_BASE64=$(base64 -i "$KEYSTORE_REAL")
else
    KEYSTORE_BASE64=$(base64 -i "$KEYSTORE_FILE")
fi

if [ -z "$KEYSTORE_BASE64" ]; then
    echo -e "${RED}❌ Erreur : Impossible d'encoder le keystore${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Keystore encodé avec succès${NC}"
echo ""

# Afficher les instructions
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  INSTRUCTIONS POUR CONFIGURER LES SECRETS GITHUB${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}1. Aller sur GitHub :${NC}"
echo "   https://github.com/arkalia-luna-system/arkalia-cia/settings/secrets/actions"
echo ""
echo -e "${YELLOW}2. Cliquer sur 'New repository secret' pour chaque secret :${NC}"
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Secret 1 : KEYSTORE_BASE64${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "   Name: KEYSTORE_BASE64"
echo "   Secret: (voir ci-dessous - copier TOUT le texte)"
echo ""
echo "$KEYSTORE_BASE64" | head -c 100
echo "..."
echo ""
echo -e "${YELLOW}💡 Le secret complet est très long. Copie-le depuis le fichier :${NC}"
echo "   /tmp/arkalia_keystore_base64.txt"
echo ""
echo "$KEYSTORE_BASE64" > /tmp/arkalia_keystore_base64.txt
echo -e "${GREEN}✅ Secret sauvegardé dans /tmp/arkalia_keystore_base64.txt${NC}"
echo ""

echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Secret 2 : KEYSTORE_PASSWORD${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "   Name: KEYSTORE_PASSWORD"
echo "   Secret: $STORE_PASSWORD"
echo ""

echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Secret 3 : KEY_PASSWORD${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "   Name: KEY_PASSWORD"
echo "   Secret: $KEY_PASSWORD"
echo ""

echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Secret 4 : KEY_ALIAS (optionnel)${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "   Name: KEY_ALIAS"
echo "   Secret: $KEY_ALIAS"
echo -e "${YELLOW}   (Optionnel - le workflow utilise 'arkalia-cia' par défaut)${NC}"
echo ""

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  RÉSUMÉ${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}✅ Fichiers préparés :${NC}"
echo "   - /tmp/arkalia_keystore_base64.txt (KEYSTORE_BASE64 complet)"
echo ""
echo -e "${YELLOW}📋 Secrets à créer dans GitHub :${NC}"
echo "   1. KEYSTORE_BASE64 (copier depuis /tmp/arkalia_keystore_base64.txt)"
echo "   2. KEYSTORE_PASSWORD (voir ci-dessus)"
echo "   3. KEY_PASSWORD (voir ci-dessus)"
echo "   4. KEY_ALIAS (optionnel, voir ci-dessus)"
echo ""
echo -e "${YELLOW}🔗 Lien direct :${NC}"
echo "   https://github.com/arkalia-luna-system/arkalia-cia/settings/secrets/actions"
echo ""
echo -e "${GREEN}✅ Une fois les secrets configurés, le workflow pourra :${NC}"
echo "   - Signer l'app avec la clé de release (pas debug)"
echo "   - Uploader automatiquement sur Play Store"
echo "   - Publier en tests internes automatiquement"
echo ""

