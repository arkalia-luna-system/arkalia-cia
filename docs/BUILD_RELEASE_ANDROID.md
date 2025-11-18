# 📱 Guide Build Release Android - Arkalia CIA

**Date** : 18 novembre 2025  
**Version** : v1.1.0+1

---

## ✅ PRÉPARATION BUILD RELEASE

### 1. Vérifier Configuration

#### Version et Build Number
- **Version** : v1.1.0+1 (définie dans `pubspec.yaml`)
- **Build number** : Vérifier dans `pubspec.yaml`

#### Signature APK/AAB
- Vérifier que les clés de signature sont configurées
- Vérifier `android/app/build.gradle` pour la configuration de signature

---

## 🔨 COMMANDES BUILD RELEASE

### Build APK Release
```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia
flutter build apk --release
```

**Fichier généré** : `build/app/outputs/flutter-apk/app-release.apk`

### Build AAB Release (pour Play Store)
```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia
flutter build appbundle --release
```

**Fichier généré** : `build/app/outputs/bundle/release/app-release.aab`

---

## ✅ VÉRIFICATIONS POST-BUILD

### 1. Vérifier Taille du Fichier
- APK : Vérifier taille raisonnable (<50MB recommandé)
- AAB : Vérifier taille raisonnable

### 2. Installer sur Device Réel
```bash
flutter install --release
```

### 3. Tests sur Device Réel
- [ ] Vérifier tous les écrans fonctionnent
- [ ] Tester permissions contacts
- [ ] Tester navigation ARIA
- [ ] Vérifier tailles textes (16sp minimum)
- [ ] Vérifier icônes colorées
- [ ] Tester FAB visibilité
- [ ] Vérifier performance (pas de lag)
- [ ] Vérifier mémoire (pas de fuites)

---

## 📝 NOTES IMPORTANTES

### Avant Build Release
- ✅ Tous les tests passent (191/191)
- ✅ Code propre (0 erreur linting)
- ✅ Bugs critiques corrigés
- ✅ Améliorations UX complétées

### Après Build Release
- ⚠️ Tester sur device réel Android (API 21+)
- ⚠️ Vérifier signature APK/AAB
- ⚠️ Vérifier taille du fichier

---

## 🚀 PROCHAINES ÉTAPES

1. **Build release** : Exécuter les commandes ci-dessus
2. **Tests device réel** : Installer et tester sur Android réel
3. **Screenshots** : Prendre screenshots si nécessaire
4. **Soumission Play Store** : Préparer métadonnées et soumettre

---

**Dernière mise à jour** : 18 novembre 2025

