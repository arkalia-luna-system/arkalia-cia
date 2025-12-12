# 📱 Lancer l'App Android - Guide Rapide

**Date** : 12 décembre 2025  
**Version** : 1.3.1

---

## 🚀 OPTIONS POUR LANCER L'APP

### Option 1 : Émulateur Android (Recommandé pour tester)

1. **Lister les émulateurs disponibles** :
```bash
flutter emulators
```

2. **Lancer un émulateur** :
```bash
flutter emulators --launch <nom_emulateur>
```

3. **Ou lancer depuis Android Studio** :
   - Ouvrir Android Studio
   - Tools > Device Manager
   - Cliquer sur ▶️ pour lancer un émulateur

4. **Lancer l'app** :
```bash
cd arkalia_cia
flutter run -d android
```

---

### Option 2 : Appareil Physique

1. **Activer le mode développeur** sur ton téléphone :
   - Paramètres > À propos du téléphone
   - Taper 7 fois sur "Numéro de build"
   - Activer "Options de développement"
   - Activer "Débogage USB"

2. **Connecter le téléphone** :
   - Brancher le câble USB
   - Autoriser le débogage USB sur le téléphone

3. **Vérifier la connexion** :
```bash
flutter devices
```

4. **Lancer l'app** :
```bash
cd arkalia_cia
flutter run -d android
```

---

### Option 3 : Build APK et Installer Manuellement

1. **Créer l'APK** :
```bash
cd arkalia_cia
flutter build apk --debug
```

2. **Installer sur l'appareil** :
   - L'APK sera dans `build/app/outputs/flutter-apk/app-debug.apk`
   - Transférer sur le téléphone
   - Installer l'APK

---

## ✅ VÉRIFICATIONS AVANT DE LANCER

### 1. Vérifier Flutter
```bash
flutter doctor
```
Tous les éléments Android doivent être ✅

### 2. Vérifier les appareils
```bash
flutter devices
```
Au moins un appareil Android doit être listé

### 3. Nettoyer et reconstruire (si problème)
```bash
cd arkalia_cia
flutter clean
flutter pub get
```

---

## 🧪 TESTER GOOGLE SIGN-IN

Une fois l'app lancée :

1. **Vérifier l'écran d'accueil** :
   - L'écran `WelcomeAuthScreen` doit s'afficher
   - Les boutons "Continuer avec Gmail" et "Continuer avec Google" doivent être visibles

2. **Tester la connexion** :
   - Cliquer sur "Continuer avec Gmail"
   - Le sélecteur de compte Google doit s'ouvrir
   - Sélectionner un compte
   - Vérifier la redirection vers `LockScreen`

3. **Vérifier les logs** (si erreur) :
```bash
# Dans un autre terminal
adb logcat | grep -i "google\|signin\|auth"
```

---

## 🐛 PROBLÈMES COURANTS

### "No devices found"

**Solution** :
1. Vérifier qu'un émulateur est lancé OU qu'un appareil est connecté
2. Vérifier avec `flutter devices`
3. Relancer l'émulateur si nécessaire

### "Waiting for another flutter command to release the startup lock"

**Solution** :
```bash
# Tuer tous les processus Flutter
killall -9 dart
killall -9 flutter
```

### Erreur de compilation

**Solution** :
```bash
cd arkalia_cia
flutter clean
flutter pub get
flutter run -d android
```

---

## 📋 CHECKLIST RAPIDE

- [ ] Flutter installé et configuré (`flutter doctor`)
- [ ] Émulateur lancé OU appareil connecté (`flutter devices`)
- [ ] Dépendances installées (`flutter pub get`)
- [ ] App lancée (`flutter run -d android`)
- [ ] Écran d'accueil visible
- [ ] Boutons Google/Gmail visibles
- [ ] Test de connexion Google effectué

---

**Note** : Pour tester Google Sign-In, il faut absolument un appareil Android (émulateur ou physique). Le test sur macOS ne fonctionnera pas pour Google Sign-In.

