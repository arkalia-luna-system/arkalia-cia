# 🚀 Instructions Release v1.3.0 - Arkalia CIA

**Date** : 24 novembre 2025  
**Version** : 1.3.0  
**Statut** : ✅ **Prêt pour release**

---

## ✅ Ce qui a été fait

1. ✅ **Versions unifiées** : Toutes les versions sont maintenant à 1.3.0
2. ✅ **Commit et push** : Toutes les modifications ont été commitées et pushées sur `develop`
3. ✅ **Tag créé** : Tag `v1.3.0` créé et pushé sur origin
4. ✅ **Merge sur main** : `develop` a été mergé dans `main` avec message détaillé
5. ✅ **Backup créé** : Branche `backup/v1.3.0` créée et pushée
6. ✅ **Vérification** : `main` et `backup/v1.3.0` pointent vers le même commit

---

## 📊 État actuel des branches

| Branche | Commit | Statut |
|---------|-------|--------|
| `develop` | `12c2eb2` | ✅ À jour avec origin |
| `main` | `0a23cfb` | ✅ Merge de develop, pushé |
| `backup/v1.3.0` | `0a23cfb` | ✅ Même commit que main |

**Note** : `main` et `backup/v1.3.0` contiennent le merge commit, ce qui est normal.

---

## 🎯 Prochaines étapes pour la release

### 1. Tests finaux (Recommandé)

Avant de publier, effectuer des tests finaux :

```bash
# Tests Python
cd /Volumes/T7/arkalia-cia
python -m pytest tests/ -v

# Tests Flutter
cd arkalia_cia
flutter analyze
flutter test

# Vérification lint
make lint
```

### 2. Build Release Android

```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia

# Build App Bundle pour Google Play Store
flutter build appbundle --release

# Le fichier sera dans :
# build/app/outputs/bundle/release/app-release.aab
```

**Fichier de sortie** : `build/app/outputs/bundle/release/app-release.aab`

### 3. Configuration Google Play Console

1. **Se connecter** à [Google Play Console](https://play.google.com/console)
2. **Créer une nouvelle app** (si pas déjà fait)
   - Nom : Arkalia CIA
   - Langue par défaut : Français
   - Type : Application
   - Gratuit/Payant : Gratuit
3. **Remplir les métadonnées** depuis `docs/deployment/PLAY_STORE_METADATA.md`
4. **Uploader l'App Bundle** (`app-release.aab`)
5. **Ajouter les screenshots** (si disponibles)
6. **Soumettre pour révision**

### 4. Documentation à mettre à jour (Optionnel)

Si vous voulez créer des Release Notes pour cette version :

```bash
# Créer un fichier RELEASE_NOTES_V1.3.0.md
# Voir docs/RELEASE_NOTES_V1.2.0.md comme exemple
```

### 5. Vérifications finales

- [ ] Tous les tests passent
- [ ] Build App Bundle réussi
- [ ] Version dans `pubspec.yaml` : `1.3.0+1` ✅
- [ ] Version dans `setup.py` : `1.3.0` ✅
- [ ] Version dans `pyproject.toml` : `1.3.0` ✅
- [ ] Tag `v1.3.0` créé et pushé ✅
- [ ] `main` contient toutes les modifications ✅
- [ ] `backup/v1.3.0` créé ✅
- [ ] Documentation à jour ✅

---

## 📝 Notes importantes

### Version Flutter vs Python

- **Flutter** : `1.3.0+1` (le `+1` est le build number)
- **Python** : `1.3.0` (version standard)

### Prochaine version

Pour la prochaine version (1.3.1 ou 1.4.0) :

1. Créer une nouvelle branche depuis `develop`
2. Faire les modifications
3. Mettre à jour les versions dans tous les fichiers
4. Tester
5. Merge sur `develop`
6. Tag et merge sur `main`

### En cas de problème

Si vous devez faire un hotfix :

```bash
# Créer une branche hotfix depuis main
git checkout main
git checkout -b hotfix/v1.3.1

# Faire les corrections
# ...

# Commit et merge
git commit -m "fix: Description du problème"
git checkout main
git merge hotfix/v1.3.1 --no-ff
git tag -a v1.3.1 -m "Hotfix v1.3.1"
git push origin main
git push origin v1.3.1
```

---

## 🔗 Liens utiles

- **Google Play Console** : https://play.google.com/console
- **Métadonnées Play Store** : `docs/deployment/PLAY_STORE_METADATA.md`
- **Guide déploiement** : `docs/deployment/GUIDE_DEPLOIEMENT_FINAL.md`
- **Versions unifiées** : `docs/VERSIONS_UNIFIEES.md`
- **Changelog** : `docs/CHANGELOG.md`

---

## ✅ Checklist Release

- [x] Versions unifiées à 1.3.0
- [x] Commit et push sur develop
- [x] Tag v1.3.0 créé et pushé
- [x] Merge develop → main
- [x] Push main sur origin
- [x] Branche backup/v1.3.0 créée
- [ ] Tests finaux effectués
- [ ] Build App Bundle réussi
- [ ] Upload sur Google Play Console
- [ ] Métadonnées complétées
- [ ] Soumission pour révision

---

**Dernière mise à jour** : 24 novembre 2025  
**Vous êtes maintenant sur la branche `develop`** ✅

