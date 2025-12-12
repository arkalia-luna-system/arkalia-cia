# 📱 Tester sur Téléphone Android - Guide Rapide

**Date** : 12 décembre 2025  
**Appareil** : Samsung S25

---

## ✅ AVANTAGES

- ✅ **Plus rapide** : Pas besoin de créer un émulateur
- ✅ **Plus réaliste** : Test sur vrai appareil
- ✅ **Google Sign-In fonctionne** : Services Google déjà installés
- ✅ **Performance réelle** : Test dans les vraies conditions

---

## 🚀 ÉTAPES RAPIDES

### 1. Activer le Mode Développeur (si pas déjà fait)

Sur ton Samsung S25 :

1. **Paramètres** > **À propos du téléphone**
2. Trouver **"Numéro de build"** (ou "Numéro de version")
3. **Taper 7 fois** dessus
4. Message : "Vous êtes maintenant développeur !"

### 2. Activer le Débogage USB

1. **Paramètres** > **Options de développement** (nouveau menu)
2. Activer **"Débogage USB"**
3. Autoriser si une popup apparaît

### 3. Brancher le Téléphone

1. Brancher le câble USB au Mac
2. Sur le téléphone : Autoriser le débogage USB (popup)
3. Cocher **"Toujours autoriser depuis cet ordinateur"**

### 4. Vérifier la Connexion

```bash
flutter devices
```

Tu devrais voir ton S25 listé, par exemple :
```
samsung_s25 • SM-XXXXX • android-arm64 • Android XX
```

### 5. Lancer l'App

```bash
cd arkalia_cia
flutter run -d android
```

L'app va s'installer et se lancer sur ton S25 !

---

## 🧪 TESTER GOOGLE SIGN-IN

Une fois l'app lancée sur ton S25 :

1. **Vérifier l'écran d'accueil** :
   - L'écran `WelcomeAuthScreen` doit s'afficher
   - Les boutons "Continuer avec Gmail" et "Continuer avec Google" doivent être visibles

2. **Tester la connexion** :
   - Cliquer sur **"Continuer avec Gmail"**
   - Le sélecteur de compte Google doit s'ouvre
   - Sélectionner ton compte Google
   - Vérifier la redirection vers `LockScreen`

3. **Vérifier les données** :
   - Les informations (email, nom) doivent être stockées localement
   - Tu peux vérifier dans les paramètres de l'app

---

## 🐛 PROBLÈMES COURANTS

### "No devices found"

**Solutions** :
1. Vérifier que le câble USB est bien branché
2. Vérifier que le débogage USB est activé
3. Essayer un autre câble USB
4. Redémarrer le téléphone
5. Vérifier avec `adb devices`

### "Unauthorized" dans `adb devices`

**Solutions** :
1. Sur le téléphone : Autoriser le débogage USB (popup)
2. Cocher "Toujours autoriser depuis cet ordinateur"
3. Redémarrer `adb` : `adb kill-server && adb start-server`

### L'app ne se lance pas

**Solutions** :
1. Vérifier que le téléphone est déverrouillé
2. Vérifier que les services Google Play sont à jour
3. Nettoyer et reconstruire :
   ```bash
   flutter clean
   flutter pub get
   flutter run -d android
   ```

---

## 📋 CHECKLIST RAPIDE

- [ ] Mode développeur activé (7 fois sur "Numéro de build")
- [ ] Débogage USB activé
- [ ] Téléphone branché en USB
- [ ] Débogage USB autorisé (popup)
- [ ] `flutter devices` détecte le téléphone
- [ ] App lancée : `flutter run -d android`
- [ ] Test Google Sign-In effectué

---

## ✅ AVANTAGES DU TÉLÉPHONE vs ÉMULATEUR

| Aspect | Téléphone | Émulateur |
|--------|-----------|-----------|
| **Vitesse** | ⚡ Plus rapide | 🐌 Plus lent |
| **Réalisme** | ✅ Vraies conditions | ⚠️ Simulé |
| **Google Services** | ✅ Déjà installés | ⚠️ À configurer |
| **Performance** | ✅ Réelle | ⚠️ Limitée |
| **Facilité** | ✅ Plus simple | ⚠️ Plus complexe |

---

**C'est effectivement beaucoup plus simple de tester directement sur ton S25 !** 🎯

