# 📋 Résumé Configuration Actuelle - Arkalia CIA

**Date** : 7 décembre 2025  
**Version** : 1.3.1  
**Statut** : ✅ Configuration complète et à jour

---

## ✅ Configuration Play Store

### Catégorie
- **Catégorie principale** : **Productivité** ✅
- **Raison** : Changée depuis "Santé et forme physique" pour éviter les exigences strictes PlayStation/Android XR
- **Date du changement** : 7 décembre 2025

### Version Code
- **Format** : `YYMMDDHH` (ex: `25120701` = 7 décembre 2025, 01h)
- **Auto-incrémentation** : ✅ Activée
- **Source** : Date/heure du push GitHub
- **Limite** : Reste sous `Int.MAX_VALUE` (2,147,483,647)

### Workflow CI/CD
- **Fichier** : `.github/workflows/deploy-play-store.yml`
- **Déclenchement** : Push sur `main` ou tag `v*`
- **Actions** :
  1. Auto-incrémente version code (format YYMMDDHH)
  2. Met à jour `pubspec.yaml`
  3. Build App Bundle
  4. Upload Play Store (si secret configuré)

### Build Configuration
- **Fichier** : `arkalia_cia/android/app/build.gradle.kts`
- **Méthode** : Utilise directement `flutter.versionCode`
- **Source** : Le plugin Flutter lit depuis `pubspec.yaml`
- **Fichiers de support** : `init.gradle` et `build.gradle.kts` lisent aussi depuis `pubspec.yaml`

---

## 📝 Format Version

### pubspec.yaml
```yaml
version: 1.3.1+25120701
```
- `1.3.1` = versionName (affichée aux utilisateurs)
- `25120701` = versionCode (format YYMMDDHH)

### Exemple
- `25120701` = 7 décembre 2025, 01h
- `25120715` = 7 décembre 2025, 15h

---

## 🔄 Processus de Déploiement

### Automatique (Recommandé)
```bash
# 1. Développer sur develop
git checkout develop
# ... modifications ...

# 2. Commit et push
git add -A
git commit -m "feat: Nouvelle fonctionnalité"
git push origin develop

# 3. Merge sur main
git checkout main
git merge develop
git push origin main

# 4. ✅ Le workflow CI fait tout automatiquement :
#    - Auto-incrémente version code
#    - Build App Bundle
#    - Upload Play Store (si secret configuré)
```

### Manuel (Si nécessaire)
```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia
./scripts/build-release-clean.sh
# Le script auto-incrémente le version code
# Puis uploader manuellement sur Play Console
```

---

## ✅ Checklist Configuration

- [x] Catégorie : Productivité ✅
- [x] Version code : Auto-incrémentation activée ✅
- [x] Workflow CI : Configuré et fonctionnel ✅
- [x] Build configuration : Utilise flutter.versionCode ✅
- [x] Documentation : À jour ✅

---

**Dernière mise à jour** : 7 décembre 2025

