# 🧪 Guide de Test Simple - Google Sign-In

**Date** : 12 décembre 2025  
**Statut** : ✅ Configuration complète | ⏳ Tests à effectuer

---

## 🎯 TEST RAPIDE (5 minutes)

### Étape 1 : Lancer l'app

```bash
cd arkalia_cia
flutter clean
flutter pub get
flutter run -d android
```

**Temps** : 2-3 minutes

---

### Étape 2 : Tester la connexion Google

**Dans l'app** :

1. ✅ Tu arrives sur `WelcomeAuthScreen`
2. ✅ Tu vois les boutons :
   - "Continuer avec Gmail"
   - "Continuer avec Google"
3. ✅ Clique sur un des boutons
4. ✅ Un dialog "Connexion en cours..." s'affiche
5. ✅ Le sélecteur de compte Google s'ouvre
6. ✅ Sélectionne ton compte Google
7. ✅ Tu es redirigé vers `LockScreen`

**✅ Si tout ça fonctionne : CONNEXION RÉUSSIE !** 🎉

---

### Étape 3 : Vérifier la déconnexion

**Dans l'app** :

1. Va dans **Paramètres** (⚙️)
2. Section **Sécurité**
3. Clique sur **Déconnexion**
4. Confirme la déconnexion
5. ✅ Tu reviens sur `WelcomeAuthScreen`
6. ✅ En te reconnectant, ça remarcher

**✅ Si tout ça fonctionne : DÉCONNEXION RÉUSSIE !** 🎉

---

## ⚠️ SI ERREUR "DEVELOPER_ERROR"

**C'est normal si tu viens juste de modifier la config !**

**Solution** :
1. ⏰ **Attendre 5-10 minutes** (propagation Google)
2. 🔄 **Redémarrer l'app**
3. 🔄 **Réessayer**

**Si ça persiste après 10 min** :

```bash
# Vérifier le SHA-1 actuel
cd arkalia_cia/android
./gradlew signingReport

# Comparer avec celui dans Google Cloud Console
# https://console.cloud.google.com/apis/credentials?project=arkalia-cia
```

---

## 📱 TEST iOS (si tu as un Mac)

```bash
cd arkalia_cia
flutter run -d ios
```

**Même test que sur Android.**

---

## 🔍 VÉRIFIER LES LOGS (optionnel)

Si tu veux voir ce qui se passe en détail :

```bash
# Sur Android
adb logcat | grep -i "google\|signin\|auth"

# Filtrer les erreurs
adb logcat | grep -i "error\|exception"
```

**Logs attendus** :
```
GoogleAuthService: Sign in successful
GoogleAuthService: User email: ton.email@gmail.com
```

---

## ✅ CHECKLIST DE TEST

### Connexion
- [ ] L'app démarre sans erreur
- [ ] `WelcomeAuthScreen` s'affiche
- [ ] Boutons Google/Gmail visibles
- [ ] Sélecteur de compte s'ouvre
- [ ] Connexion réussie
- [ ] Redirection vers `LockScreen`

### Déconnexion
- [ ] Accès aux paramètres
- [ ] Bouton déconnexion fonctionne
- [ ] Redirection vers `WelcomeAuthScreen`
- [ ] Reconnexion fonctionne

---

## 🎉 RÉSULTAT ATTENDU

### ✅ Tout fonctionne

1. **Connexion Google** : ✅ Fonctionne
2. **Déconnexion** : ✅ Fonctionne
3. **Stockage local** : ✅ Données sauvegardées
4. **Redirection** : ✅ Correcte

**→ Configuration Google Sign-In 100% opérationnelle !** 🚀

---

## 🆘 EN CAS DE PROBLÈME

### Erreur "DEVELOPER_ERROR"
- ⏰ Attendre 5-10 minutes
- 🔄 Redémarrer l'app
- ✅ Réessayer

### L'app ne compile pas
```bash
flutter clean
flutter pub get
flutter run -d android
```

### Autre erreur
**Envoie-moi** :
1. Le message d'erreur exact
2. Les logs : `adb logcat | grep -i error`
3. Quelle plateforme (Android/iOS)

---

## 📊 RÉCAPITULATIF

| Action | Temps | Statut |
|--------|-------|--------|
| Lancer l'app | 2-3 min | ⏳ À faire |
| Tester connexion | 1 min | ⏳ À faire |
| Tester déconnexion | 1 min | ⏳ À faire |

**Total** : ~5 minutes

---

## 🚀 ACTION IMMÉDIATE

**Lance juste ça** :
```bash
cd arkalia_cia
flutter run -d android
```

Puis teste la connexion Google dans l'app.

**Dis-moi si ça marche ou s'il y a une erreur !** 🎉

---

**Dernière mise à jour** : 12 décembre 2025  
**Statut** : ✅ Prêt pour tests

