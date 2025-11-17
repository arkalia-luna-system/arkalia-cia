# 📱 Étapes pour installer l'app sur iPad Pro

**Date**: November 17, 2025

---

## ✅ **ÉTAPE 1 : Vérifier la connexion iPad**

### Sur l'iPad :
1. **Déverrouiller** l'iPad
2. **Autoriser l'ordinateur** : Quand une popup apparaît "Faire confiance à cet ordinateur ?" → **Appuyer sur "Faire confiance"**
3. **Entrer le code** de l'iPad si demandé

### Sur le Mac :
```bash
# Vérifier que l'iPad est détecté par le système
system_profiler SPUSBDataType | grep -i "iPad\|Apple"
```

---

## ✅ **ÉTAPE 2 : Installer/Configurer Xcode**

### Vérifier si Xcode est installé :
```bash
xcode-select --print-path
```

### Si Xcode n'est pas installé :
1. **Ouvrir App Store** sur Mac
2. **Chercher "Xcode"**
3. **Installer** (c'est gros, ~15GB, prend du temps)

### Si Xcode est installé mais pas configuré :
```bash
# Configurer Xcode
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer

# Accepter la licence
sudo xcodebuild -license accept

# Installer les outils de ligne de commande
xcode-select --install
```

### Vérifier Xcode :
```bash
xcodebuild -version
```

---

## ✅ **ÉTAPE 3 : Installer CocoaPods**

```bash
# Installer CocoaPods
sudo gem install cocoapods

# Vérifier l'installation
pod --version
```

**Note** : Si erreur "permission denied", utiliser :
```bash
sudo gem install -n /usr/local/bin cocoapods
```

---

## ✅ **ÉTAPE 4 : Installer les dépendances iOS**

```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia/ios
pod install
cd ..
```

**Note** : La première fois, ça peut prendre plusieurs minutes.

---

## ✅ **ÉTAPE 5 : Vérifier que l'iPad est détecté**

```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia
flutter devices
```

**Résultat attendu** :
```
iPad Pro de [Votre Nom] (mobile) • [UUID] • ios • iOS [version]
```

**Si l'iPad n'apparaît toujours pas** :
1. **Débrancher/rebrancher** l'iPad
2. **Sur l'iPad** : Aller dans **Réglages** > **Confidentialité et sécurité** > **Développeur** > Autoriser le Mac
3. **Relancer** : `flutter devices`

---

## ✅ **ÉTAPE 6 : Lancer l'app sur iPad**

### Option A : Via Flutter CLI (Recommandé)
```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia
flutter run
```

Flutter va :
1. Détecter automatiquement l'iPad
2. Compiler l'app
3. L'installer sur l'iPad
4. La lancer

### Option B : Via Xcode (Si besoin de configurer le signing)
```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia/ios
open Runner.xcworkspace
```

Puis dans Xcode :
1. Sélectionner **Runner** en haut
2. Choisir votre **iPad Pro** dans la liste des devices
3. Aller dans **Signing & Capabilities**
4. Cocher **"Automatically manage signing"**
5. Sélectionner votre **Team** (Apple ID)
6. Cliquer sur **▶️ Play** (ou Cmd+R)

---

## ⚠️ **PROBLÈMES COURANTS**

### "No iOS devices found"
**Solution** :
1. Vérifier que l'iPad est déverrouillé
2. Autoriser l'ordinateur sur l'iPad
3. Vérifier le câble USB (essayer un autre câble)
4. Redémarrer l'iPad
5. Relancer `flutter devices`

### "Signing for Runner requires a development team"
**Solution** :
1. Ouvrir Xcode
2. **Xcode** > **Preferences** > **Accounts**
3. Cliquer sur **+** et ajouter votre **Apple ID**
4. Dans le projet, sélectionner votre Team dans Signing

### "CocoaPods not installed"
**Solution** :
```bash
sudo gem install cocoapods
# OU
sudo gem install -n /usr/local/bin cocoapods
```

### "Xcode installation is incomplete"
**Solution** :
```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -license accept
```

---

## 📸 **UNE FOIS L'APP INSTALLÉE**

Pour prendre les screenshots :

1. **Lancer l'app** sur l'iPad
2. **Naviguer** vers chaque écran :
   - Home Page
   - Documents
   - Emergency
   - Health
3. **Capturer** : **Volume Up + Power** (ou **Volume Up + Top Button**)
4. **Les screenshots** sont dans **Photos** > **Screenshots**
5. **Transférer** via AirDrop ou câble USB

---

## 🎯 **CHECKLIST RAPIDE**

- [ ] iPad branché et déverrouillé
- [ ] iPad autorisé sur le Mac ("Faire confiance")
- [ ] Xcode installé et configuré
- [ ] CocoaPods installé
- [ ] `pod install` exécuté dans `ios/`
- [ ] `flutter devices` montre l'iPad
- [ ] App lancée avec succès sur iPad

---

**Dernière mise à jour**: November 17, 2025
