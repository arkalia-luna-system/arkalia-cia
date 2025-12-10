# ⚙️ Configuration GitHub Pages - Arkalia CIA

**Date** : 10 décembre 2025  
**Statut** : ✅ **Configuré et opérationnel**

---

## 📊 CONFIGURATION ACTUELLE

### Branche utilisée : `gh-pages`

**GitHub Pages est configuré pour utiliser la branche `gh-pages`**, pas `main` ni `develop`.

**Pourquoi ?**
- ✅ `develop` = Code en développement (progression, tests)
- ✅ `main` = Code stable (version release)
- ✅ `gh-pages` = Build web déployé (PWA)

**Résultat** : Push sur `develop` ou `main` **ne met PAS à jour automatiquement** GitHub Pages. C'est voulu !

---

## 🔄 PROCESSUS DE DÉPLOIEMENT

### Déploiement manuel (actuel)

**Quand déployer ?**
- Après chaque version stable
- Après corrections importantes
- Quand tu veux mettre à jour la PWA

**Comment déployer ?**

```bash
# Option 1 : Script automatique (recommandé)
./scripts/deploy_pwa_github_pages.sh

# Option 2 : Manuel
cd arkalia_cia
flutter build web --release --base-href "/arkalia-cia/"
cd build/web
git init
git add .
git commit -m "Deploy PWA v1.3.1"
git branch -M gh-pages
git remote add origin https://github.com/arkalia-luna-system/arkalia-cia.git
git push -u origin gh-pages --force
```

**Résultat** : La PWA est mise à jour sur https://arkalia-luna-system.github.io/arkalia-cia/

---

## ⚙️ CONFIGURATION GITHUB PAGES

### Vérifier la configuration

1. Aller sur : https://github.com/arkalia-luna-system/arkalia-cia/settings/pages
2. **Source** : `gh-pages` branch
3. **Folder** : `/ (root)`
4. **Save**

### URL de l'app

**Production** : https://arkalia-luna-system.github.io/arkalia-cia/

---

## 🔒 SÉCURITÉ

### Pourquoi pas automatique depuis main/develop ?

**Avantages de la configuration actuelle** :
- ✅ Contrôle total sur quand déployer
- ✅ Pas de déploiement accidentel
- ✅ Séparation claire : code source vs build déployé
- ✅ Possibilité de tester avant de déployer

**Si tu veux automatiser** (optionnel) :
- Créer un workflow GitHub Actions qui build et push sur `gh-pages` quand tu pushes sur `main`
- Mais ce n'est pas nécessaire pour l'instant

---

## 📋 RÉSUMÉ

| Branche | Usage | Déploiement GitHub Pages |
|---------|-------|--------------------------|
| `develop` | Code en développement | ❌ Non (manuel via script) |
| `main` | Code stable | ❌ Non (manuel via script) |
| `gh-pages` | Build web déployé | ✅ Oui (automatique) |

**Déploiement** : Manuel via script `deploy_pwa_github_pages.sh`  
**URL** : https://arkalia-luna-system.github.io/arkalia-cia/

---

**Date** : 10 décembre 2025

