# 🔧 Résolution : Erreur APK vers App Bundle

**Date** : 7 décembre 2025  
**Note** : Le version code est maintenant auto-incrémenté avec format YYMMDDHH (date/heure du push)  
**Problème** : "Vous ne pouvez pas déployer cette version car elle ne permet pas aux utilisateurs existants de passer aux nouveaux packs d'applications ajoutés."

---

## 🚨 Le Problème

Tu as une version **APK** déjà publiée sur Play Console, et tu essaies maintenant d'uploader un **App Bundle (.aab)**. Google Play ne permet **PAS** de passer d'APK à AAB pour les utilisateurs existants.

**Erreur exacte** :
- "Vous ne pouvez pas déployer cette version car elle ne permet pas aux utilisateurs existants de passer aux nouveaux packs d'applications ajoutés."
- "Aucun utilisateur de cette version APK ne pourra la mettre à jour vers les nouvelles versions APK ajoutées dans cette mise à jour."

---

## ✅ SOLUTION : Supprimer l'ancienne version APK

### Option 1 : Supprimer la version APK dans Play Console (Recommandé)

**⚠️ IMPORTANT** : Cette solution supprime la version APK existante. Si tu as des utilisateurs, ils devront réinstaller l'app.

**Étapes** :

1. **Va sur Play Console** :
   ```
   https://play.google.com/console
   ```

2. **Sélectionne ton app** :
   - Clique sur **"Arkalia CIA"**

3. **Va dans la section des versions** :
   - Menu de gauche : **Production** → **Versions**
   - OU **Tests** → **Tests internes** → **Versions**

4. **Trouve la version APK** :
   - Cherche la version qui a été uploadée en **APK** (pas AAB)
   - Elle devrait avoir un statut "Publiée" ou "En attente"

5. **Supprime la version APK** :
   - Clique sur la version APK
   - Clique sur **"Supprimer"** ou **"Retirer"**
   - Confirme la suppression

6. **Upload la nouvelle version en AAB** :
   - Clique sur **"Créer une nouvelle version"**
   - Upload ton fichier `.aab` (pas APK)
   - Complète les informations
   - Publie

---

### Option 2 : Créer une nouvelle application (Si tu n'as pas d'utilisateurs)

Si tu n'as pas encore d'utilisateurs réels, tu peux créer une nouvelle application :

1. **Va sur Play Console** :
   ```
   https://play.google.com/console
   ```

2. **Crée une nouvelle application** :
   - Clique sur **"Créer une application"**
   - Utilise un nouveau **Package Name** (ex: `com.arkalia.cia.v2`)
   - Configure tout depuis le début avec AAB

**⚠️ Inconvénient** : Tu perds l'historique de l'ancienne app.

---

### Option 3 : Continuer avec APK (Non recommandé)

Si tu veux garder l'APK, tu dois build un APK au lieu d'un AAB :

```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia
./android/build-android.sh flutter build apk --release
```

**Fichier** : `build/app/outputs/flutter-apk/app-release.apk`

**⚠️ Inconvénient** : Les APK sont plus gros et moins optimisés que les AAB.

---

## 📋 Checklist Après Résolution

- [ ] Ancienne version APK supprimée de Play Console
- [ ] Nouvelle version AAB uploadée
- [ ] Version AAB publiée avec succès
- [ ] Pas d'erreurs dans Play Console
- [ ] Testeurs peuvent installer la nouvelle version

---

## 💡 Pourquoi App Bundle (AAB) est mieux que APK ?

1. **Taille réduite** : Google Play génère des APK optimisés par appareil
2. **Requis par Google** : Depuis août 2021, Google exige les AAB pour les nouvelles apps
3. **Meilleure optimisation** : Google Play peut créer des APK spécifiques par architecture

---

## 🆘 Si le problème persiste

1. **Vérifier qu'il n'y a plus d'APK** :
   - Play Console → Production → Versions
   - Vérifier qu'aucune version APK n'est active

2. **Vérifier le format du fichier** :
   - Le fichier doit être `.aab` (pas `.apk`)
   - Vérifier avec : `file app-release.aab`
   - Doit afficher : "Android App Bundle"

3. **Contacter Google Support** :
   - Si le problème persiste après avoir supprimé l'APK
   - Play Console → Aide → Contacter le support

---

**Dernière mise à jour** : 7 décembre 2025

