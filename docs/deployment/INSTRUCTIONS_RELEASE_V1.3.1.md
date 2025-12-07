# 🚀 Instructions Release v1.3.1 - Arkalia CIA

**Date** : 27 novembre 2025  
**Dernière mise à jour** : 7 décembre 2025  
**Version** : 1.3.1  
**Statut** : ✅ **Version publiée en tests internes**  
**Catégorie** : Productivité (changée le 7 décembre 2025)  
**Version Code** : Auto-incrémenté avec format YYMMDDHH

---

## ✅ Ce qui a été fait

### Git et Versioning (27 novembre 2025)

1. ✅ **Versions unifiées** : Toutes les versions sont maintenant à 1.3.1
2. ✅ **Commit et push** : Toutes les modifications ont été commitées et pushées sur `develop`
3. ✅ **Tag créé** : Tag `v1.3.1` créé et pushé sur origin
4. ✅ **Merge sur main** : `develop` a été mergé dans `main` avec message détaillé
5. ✅ **Backup créé** : Branche `backup/v1.3.1` créée et pushée
6. ✅ **Vérification** : `main` et `backup/v1.3.1` pointent vers le même commit

### Publication Google Play Store (27 novembre 2025)

1. ✅ **Keystore généré** : `arkalia-cia-release.jks` créé et configuré
2. ✅ **Signature release** : Configuration complète et fonctionnelle
3. ✅ **App Bundle signé** : Build réussi avec signature release (47.9MB → 10.6MB optimisé)
4. ✅ **Upload Play Console** : Version 1.3.1 uploadée et publiée
5. ✅ **Tests internes** : Version disponible pour 4 testeurs
6. ✅ **Lien de test** : <https://play.google.com/apps/internaltest/4701447837031810861>

---

## 📊 État actuel des branches

| Branche | Commit | Statut |
|---------|-------|--------|
| `develop` | `12c2eb2` | ✅ À jour avec origin |
| `main` | `0a23cfb` | ✅ Merge de develop, pushé |
| `backup/v1.3.1` | `0a23cfb` | ✅ Même commit que main |

**Note** : `main` et `backup/v1.3.1` contiennent le merge commit, ce qui est normal.

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

### 2. Build Release Android ✅ FAIT (27 novembre 2025)

```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia

# Build App Bundle pour Google Play Store
./android/build-android.sh flutter build appbundle --release

# Le fichier sera dans :
# build/app/outputs/bundle/release/app-release.aab
```

**Fichier de sortie** : `build/app/outputs/bundle/release/app-release.aab` ✅

### 3. Configuration Google Play Console ✅ FAIT (27 novembre 2025)

1. ✅ **Application créée** : Arkalia CIA
2. ✅ **Version 1.3.1 uploadée** : App Bundle signé en release
3. ✅ **Notes de version ajoutées** : Description complète
4. ✅ **Tests internes configurés** : Version publiée et active
5. ✅ **Testeurs ajoutés** : 4 utilisateurs dans la liste "Testeurs internes"
6. ✅ **Lien de test créé** : https://play.google.com/apps/internaltest/4701447837031810861

**Note** : Les testeurs peuvent devoir attendre 2-4 heures pour voir l'app dans le Play Store (délai de synchronisation normal).

### 4. Documentation à mettre à jour (Optionnel)

Si vous voulez créer des Release Notes pour cette version :

```bash
# Créer un fichier RELEASE_NOTES_V1.3.1.md
# Voir docs/RELEASE_NOTES_V1.2.0.md comme exemple
```

### 5. Vérifications finales

- [ ] Tous les tests passent
- [ ] Build App Bundle réussi
- [ ] Version dans `pubspec.yaml` : `1.3.1+1` ✅
- [ ] Version dans `setup.py` : `1.3.1` ✅
- [ ] Version dans `pyproject.toml` : `1.3.1` ✅
- [ ] Tag `v1.3.1` créé et pushé ✅
- [ ] `main` contient toutes les modifications ✅
- [ ] `backup/v1.3.1` créé ✅
- [ ] Documentation à jour ✅

---

## 📝 Notes importantes

### Version Flutter vs Python

- **Flutter** : `1.3.1+1` (le `+1` est le build number)
- **Python** : `1.3.1` (version standard)

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

- [x] Versions unifiées à 1.3.1
- [x] Commit et push sur develop
- [x] Tag v1.3.1 créé et pushé
- [x] Merge develop → main
- [x] Push main sur origin
- [x] Branche backup/v1.3.1 créée
       - [x] Tests finaux effectués ✅
       - [x] Build App Bundle réussi ✅ (27 novembre 2025)
       - [x] Upload sur Google Play Console ✅ (27 novembre 2025)
       - [x] Version publiée en tests internes ✅ (27 novembre 2025)
       - [x] Testeurs ajoutés ✅ (27 novembre 2025)
       - [ ] Métadonnées complètes (pour production future)
       - [ ] Soumission pour production publique (optionnel)

---

**Dernière mise à jour** : 27 novembre 2025  
**Statut** : ✅ Version 1.3.1 publiée en tests internes - Disponible pour 4 testeurs

---

## 🎉 Accomplissements du 27 novembre 2025

- ✅ Keystore Android généré et configuré
- ✅ Signature release fonctionnelle
- ✅ App Bundle signé et optimisé (10.6MB)
- ✅ Version 1.3.1 publiée sur Google Play Console
- ✅ Tests internes actifs avec 4 testeurs
- ✅ Lien de test disponible : <https://play.google.com/apps/internaltest/4701447837031810861>

**Vous êtes maintenant sur la branche `develop`** ✅

