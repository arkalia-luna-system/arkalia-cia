# 🚀 GUIDE COMPLET : Déploiement PWA Arkalia CIA

**Date** : 10 décembre 2025  
**Objectut** : Déployer l'app en PWA (Progressive Web App) pour éviter les restrictions Google Play Store

---

## ✅ CE QUI EST DÉJÀ PRÊT

- ✅ Dossier `web/` avec `index.html` et `manifest.json`
- ✅ Icônes PWA (192x192, 512x512, maskable)
- ✅ Service Worker (`sw.js`) pour support offline
- ✅ Scripts de build web (`ensure_web_build.sh`)
- ✅ Code compatible web (vérifié dans `main.dart`)
- ✅ Manifest.json mis à jour avec les bonnes infos
- ✅ Tests PWA créés (`tests/web/pwa_test.dart`)

---

## 📋 ÉTAPES DE DÉPLOIEMENT

### Étape 1 : Build Web (5 minutes)

```bash
cd arkalia_cia
flutter clean
flutter pub get
flutter build web --release
```

**Résultat** : Dossier `build/web/` avec tous les fichiers statiques

**Vérification** :
```bash
ls -la build/web/
# Doit contenir : index.html, main.dart.js, assets/, etc.
```

---

### Étape 2 : Choisir l'Hébergement

#### Option A : GitHub Pages (Recommandé) ⭐

**Avantages** :
- ✅ Gratuit
- ✅ Simple
- ✅ Automatique (déploiement à chaque push)
- ✅ HTTPS inclus
- ✅ URL : `https://arkalia-luna-system.github.io/arkalia-cia`

**Étapes** :

1. **Créer branche gh-pages** :
```bash
cd build/web
git init
git add .
git commit -m "Deploy PWA v1.3.1"
git branch -M gh-pages
```

2. **Ajouter remote** (si pas déjà fait) :
```bash
git remote add origin https://github.com/arkalia-luna-system/arkalia-cia.git
```

3. **Push** :
```bash
git push -u origin gh-pages --force
```

4. **Activer GitHub Pages** :
   - Aller sur GitHub : `https://github.com/arkalia-luna-system/arkalia-cia`
   - Settings → Pages
   - Source : `gh-pages` branch
   - Save

5. **Attendre 2-3 minutes** → URL disponible !

---

#### Option B : Netlify (Alternative)

**Avantages** :
- ✅ Gratuit
- ✅ Déploiement automatique depuis GitHub
- ✅ URL personnalisée possible
- ✅ Plus rapide que GitHub Pages

**Étapes** :

1. **Créer compte** : https://app.netlify.com
2. **Connecter repo GitHub**
3. **Configurer build** :
   - Build command : `cd arkalia_cia && flutter build web --release`
   - Publish directory : `arkalia_cia/build/web`
4. **Deploy** → URL automatique !

---

#### Option C : Vercel (Alternative)

**Avantages** :
- ✅ Gratuit
- ✅ Très rapide
- ✅ Déploiement automatique

**Étapes** :

1. **Installer Vercel CLI** :
```bash
npm i -g vercel
```

2. **Déployer** :
```bash
cd arkalia_cia/build/web
vercel
```

3. **Suivre les instructions** → URL automatique !

---

### Étape 3 : Tester la PWA

1. **Ouvrir l'URL** dans Chrome (Android ou Desktop)
2. **Vérifier** :
   - ✅ L'app se charge
   - ✅ Pas d'erreurs dans la console
   - ✅ Les icônes s'affichent
   - ✅ Le manifest.json est chargé

3. **Tester installation** (sur Android) :
   - Menu Chrome (3 points) → "Ajouter à l'écran d'accueil"
   - ✅ Icône apparaît sur l'écran d'accueil
   - ✅ L'app s'ouvre en mode standalone (sans barre navigateur)

---

### Étape 4 : Guide pour Ta Mère ✅

**Guide créé** : `docs/guides/GUIDE_INSTALLATION_PWA_MAMAN.md`

Le guide complet est disponible avec :
- ✅ Instructions détaillées étape par étape
- ✅ Dépannage pour problèmes courants
- ✅ Notes importantes
- ✅ Format simple et clair pour ta mère

**URL du guide** : `docs/guides/GUIDE_INSTALLATION_PWA_MAMAN.md`

---

## 🔄 MISE À JOUR DE L'APP

Quand tu veux mettre à jour l'app :

1. **Modifier le code**
2. **Rebuild** :
```bash
cd arkalia_cia
flutter build web --release
```

3. **Redéployer** :

**GitHub Pages** :
```bash
cd build/web
git add .
git commit -m "Update PWA v1.3.2"
git push origin gh-pages
```

**Netlify/Vercel** : Automatique si connecté à GitHub (push = déploiement auto)

4. **Ta mère recharge la page** → Mise à jour automatique !

---

## ✅ CHECKLIST FINALE

- [ ] Build web réussi (`build/web/` existe)
- [ ] Manifest.json configuré correctement
- [ ] Icônes présentes (192x192, 512x512)
- [ ] Déployé sur hébergement (GitHub Pages/Netlify/Vercel)
- [ ] URL accessible
- [ ] Test installation sur Android réussi
- [ ] Guide pour ta mère créé
- [ ] Testé fonctionnalités principales

---

## 🐛 DÉPANNAGE

### Problème : L'app ne se charge pas

**Solution** :
- Vérifier que tous les fichiers sont dans `build/web/`
- Vérifier la console navigateur (F12) pour erreurs
- Vérifier que l'URL est correcte

### Problème : Installation ne fonctionne pas

**Solution** :
- Vérifier que le manifest.json est accessible
- Vérifier que les icônes existent
- Vérifier que l'app est en HTTPS (requis pour PWA)

### Problème : Erreurs dans la console

**Solution** :
- Vérifier que `flutter build web --release` a réussi
- Vérifier les dépendances (`flutter pub get`)
- Vérifier que le code est compatible web

---

## 📞 PROCHAINES ÉTAPES

Une fois déployé :

1. **Tester toi-même** sur Android
2. **Envoyer l'URL à ta mère**
3. **L'aider à installer** (première fois)
4. **C'est prêt !** 🎉

---

## 💡 NOTES IMPORTANTES

- **Pas de serveur local nécessaire** en production (voir `EXPLICATION_SERVEUR_PWA.md`)
- **L'app fonctionne 100% hors-ligne** après installation
- **Mises à jour automatiques** quand ta mère recharge la page
- **Gratuit** (hébergement gratuit)

---

**Prêt à déployer ? Suis les étapes ci-dessus !** 🚀

