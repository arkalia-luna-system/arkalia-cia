# 🚀 Workflow de Déploiement Automatique - Arkalia CIA

**Date de création** : 27 novembre 2025  
**Version** : 1.3.0

---

## 📖 Comprendre le Déploiement Play Console

### ❓ Comment ça fonctionne ?

**IMPORTANT** : Les branches GitHub ne sont **PAS** automatiquement déployées sur l'app de test.

**Le processus réel** :

1. **Tu codes localement** (sur ton Mac)
2. **Tu commits et pushes sur GitHub** (branche `develop` ou `main`)
3. **Tu builds l'App Bundle localement** (`flutter build appbundle --release`)
4. **Tu uploades manuellement sur Play Console** (via le site web)
5. **Les testeurs reçoivent la mise à jour** (2-4 heures après)

**Les branches GitHub** :
- `develop` = Code en développement
- `main` = Code stable/version release
- `feature/*` = Nouvelles fonctionnalités

**L'app de test Play Console** :
- Utilise le fichier `.aab` que **TU** uploades manuellement
- **N'est PAS** connecté automatiquement à GitHub
- Se met à jour **seulement** quand tu uploades une nouvelle version

---

## 🔄 Workflow Recommandé (Comme les Pros)

### Option 1 : Déploiement Manuel (Actuel - Simple)

**Quand** : Après chaque version stable ou correction importante

**Étapes** :

```bash
# 1. Coder et tester localement
cd /Volumes/T7/arkalia-cia/arkalia_cia
flutter run  # Tester sur téléphone

# 2. Commit et push sur GitHub
git add -A
git commit -m "fix: Description du correctif"
git push origin develop

# 3. Build App Bundle
./android/build-android.sh flutter build appbundle --release

# 4. Upload sur Play Console
# - Va sur https://play.google.com/console
# - Tests internes → Créer une nouvelle version
# - Upload : build/app/outputs/bundle/release/app-release.aab
# - Notes de version
# - Publier
```

**Avantages** :
- ✅ Contrôle total
- ✅ Pas de configuration complexe
- ✅ Tu décides quand publier

**Inconvénients** :
- ❌ Manuel (prend 5-10 minutes)
- ❌ Pas automatique

---

### Option 2 : Déploiement Automatique avec GitHub Actions (Comme les Pros)

**Quand** : Pour automatiser les mises à jour

**Comment ça marche** :

1. **GitHub Actions détecte un push sur `main`**
2. **Build automatique de l'App Bundle**
3. **Upload automatique sur Play Console**
4. **Publication automatique en tests internes**

**Configuration** :

✅ **Workflow créé** : `.github/workflows/deploy-play-store.yml` (27 novembre 2025)

**Ancien exemple** (maintenant remplacé par le workflow réel) :

```yaml
name: Deploy to Play Store (Internal Testing)

on:
  push:
    branches: [main]
    tags:
      - 'v*'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v6
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.35.3'
      
      - name: Build App Bundle
        run: |
          cd arkalia_cia
          flutter pub get
          flutter build appbundle --release
      
      - name: Upload to Play Store
        uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.GOOGLE_PLAY_SERVICE_ACCOUNT_JSON }}
          packageName: com.arkalia.cia
          releaseFiles: arkalia_cia/build/app/outputs/bundle/release/app-release.aab
          track: internal
          status: completed
```

**Configuration requise** :

1. **Créer un compte de service Google Play** :
   - Play Console → Paramètres → Comptes de service
   - Créer un compte de service
   - Télécharger le JSON

2. **Ajouter le JSON dans GitHub Secrets** :
   - GitHub → Settings → Secrets → Actions
   - Créer secret : `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`
   - Coller le contenu du JSON

**Avantages** :
- ✅ Automatique (push sur `main` → déploiement)
- ✅ Pas d'intervention manuelle
- ✅ Workflow professionnel
- ✅ Workflow créé et prêt (27 novembre 2025)

**Inconvénients** :
- ❌ Configuration initiale complexe (compte de service Google)
- ❌ Nécessite le secret `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` dans GitHub

**Statut actuel** :
- ✅ Workflow créé : `.github/workflows/deploy-play-store.yml`
- ⏳ En attente : Configuration du compte de service Google Play
- ⏳ En attente : Ajout du secret `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` dans GitHub

---

## 📱 Mise à Jour Automatique pour les Testeurs

### Comment les Testeurs Reçoivent les Mises à Jour

**Play Console gère automatiquement** :

1. **Tu uploades une nouvelle version** (manuellement ou automatiquement)
2. **Play Console valide** (quelques minutes)
3. **Les testeurs reçoivent une notification** (email automatique)
4. **Ils peuvent mettre à jour via Play Store** (comme une app normale)

**Les testeurs n'ont rien à faire** :
- ✅ Pas besoin de réinstaller
- ✅ Mise à jour via Play Store (comme WhatsApp, etc.)
- ✅ Notification automatique

---

## 🎯 Workflow Recommandé pour Toi

### Pour les Corrections Rapides (Hotfix)

```bash
# 1. Corriger le bug
# ... code ...

# 2. Commit et push
git add -A
git commit -m "fix: Description du bug"
git push origin develop

# 3. Si c'est urgent, merge sur main
git checkout main
git merge develop
git push origin main

# 4. Build et upload manuel (5 minutes)
cd arkalia_cia
./android/build-android.sh flutter build appbundle --release
# Upload sur Play Console
```

### Pour les Nouvelles Fonctionnalités

```bash
# 1. Créer une branche feature
git checkout -b feature/nouvelle-fonctionnalite

# 2. Développer
# ... code ...

# 3. Tester localement
flutter run

# 4. Commit et push
git add -A
git commit -m "feat: Nouvelle fonctionnalité"
git push origin feature/nouvelle-fonctionnalite

# 5. Créer une Pull Request sur GitHub
# 6. Après review, merge sur develop
# 7. Tester sur develop
# 8. Si stable, merge sur main
# 9. Build et upload pour testeurs
```

---

## 📋 Checklist Déploiement

### Avant de Déployer

- [ ] Code testé localement
- [ ] Tous les tests passent (`flutter test`)
- [ ] Aucune erreur lint (`flutter analyze`)
- [ ] Version mise à jour dans `pubspec.yaml`
- [ ] Notes de version préparées

### Déploiement

- [ ] Build App Bundle réussi
- [ ] App Bundle signé en release
- [ ] Upload sur Play Console
- [ ] Notes de version ajoutées
- [ ] Version publiée en tests internes
- [ ] Testeurs notifiés (automatique)

### Après Déploiement

- [ ] Vérifier que la version est disponible
- [ ] Tester l'installation sur un téléphone
- [ ] Informer les testeurs (email/WhatsApp)
- [ ] Attendre les retours (2-7 jours)

---

## 🔗 Liens Utiles

- **Play Console** : https://play.google.com/console
- **Lien de test** : https://play.google.com/apps/internaltest/4701447837031810861
- **Documentation Play Console** : https://support.google.com/googleplay/android-developer

---

**Dernière mise à jour** : 27 novembre 2025

