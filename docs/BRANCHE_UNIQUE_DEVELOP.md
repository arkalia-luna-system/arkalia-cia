# 🌿 Branche UNIQUE : develop pour TOUT

**Date** : 25 janvier 2025  
**Statut** : ✅ Implémenté

---

## 🎯 OBJECTIF

**Une seule branche (`develop`) pour toutes les plateformes** :
- ✅ Web
- ✅ Android
- ✅ macOS

**Avantages** :
- ✅ Pas de confusion entre branches
- ✅ Une seule source de vérité
- ✅ Mise à jour simplifiée
- ✅ Moins d'erreurs

---

## 📋 CONFIGURATION

### Branche utilisée : `develop`

**Avant** :
- Web : `main`
- Android : `develop`
- macOS : `develop`

**Après** :
- **TOUT** : `develop` ✅

---

## 🔧 SCRIPTS MODIFIÉS

### 1. `scripts/run-web.sh`
- ✅ Utilise maintenant `develop` au lieu de `main`
- ✅ Mise à jour automatique depuis `develop`

### 2. `scripts/run-all-platforms.sh`
- ✅ Toutes les plateformes utilisent `develop`
- ✅ Mise à jour unifiée

### 3. `scripts/update-all-from-develop.sh` (NOUVEAU)
- ✅ Script unique pour mettre à jour tout depuis `develop`
- ✅ Affiche la version actuelle
- ✅ Vérifie les devices disponibles

---

## 🚀 UTILISATION

### Mettre à jour tout depuis develop

```bash
bash scripts/update-all-from-develop.sh
```

### Lancer une plateforme

```bash
# Web
bash scripts/run-web.sh

# Android
bash scripts/run-android.sh

# macOS
bash scripts/run-macos.sh

# Tout en parallèle
bash scripts/run-all-platforms.sh
```

**Tous utilisent maintenant `develop` !** ✅

---

## 📝 GITHUB PAGES

**Note** : GitHub Pages utilise toujours `gh-pages` pour le déploiement web.

**Pour déployer la PWA** :
```bash
bash scripts/deploy_pwa_github_pages.sh
```

Ce script :
1. Build le web depuis `develop`
2. Push sur `gh-pages`
3. GitHub Pages déploie automatiquement

---

## ✅ RÉSULTAT

- ✅ **Branche unique** : `develop` pour tout
- ✅ **Scripts unifiés** : Tous utilisent `develop`
- ✅ **Mise à jour simplifiée** : Un seul `git pull origin develop`
- ✅ **Moins de confusion** : Plus besoin de se souvenir quelle branche pour quelle plateforme

---

**Simplification réussie ! 🎉**

