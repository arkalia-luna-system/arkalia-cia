# 📱 Guide Complet : Déploiement iOS sur iPad/iPhone (GRATUIT)

**Date** : Décembre 2025  
**Version** : 1.0

---

## 🎯 **RÉSUMÉ EXÉCUTIF**

**Question** : Est-il possible de tester l'app sur iPad Pro sans payer les 100€ d'Apple Developer Program ?

**Réponse** : **OUI, 100% GRATUIT !** Apple permet de tester vos apps sur vos propres appareils iOS avec un compte Apple ID gratuit.

---

## ✅ **CE QUI EST POSSIBLE GRATUITEMENT**

### **Avec un compte Apple ID gratuit :**
- ✅ Tester l'app sur votre iPad Pro / iPhone
- ✅ Installer l'app directement depuis Xcode
- ✅ Déboguer l'app en temps réel
- ✅ Utiliser toutes les fonctionnalités de développement

### **Limitations du compte gratuit :**
- ⏰ **L'app expire après 7 jours** → Réinstallation nécessaire toutes les semaines
- 📱 **Maximum 3 apps signées** simultanément sur l'appareil
- 🚫 **Pas de distribution sur App Store** (mais suffisant pour tester)
- 🚫 **Pas de TestFlight**

### **Avec le programme payant (100€/an) :**
- ✅ L'app ne expire jamais
- ✅ Distribution sur App Store
- ✅ TestFlight pour bêta-testeurs
- ✅ Certificats de distribution

**Conclusion** : Pour tester sur votre iPad Pro, le compte gratuit suffit largement !

---

## 📋 **PRÉREQUIS**

### **Matériel :**
- ✅ Mac (macOS requis)
- ✅ iPad Pro / iPhone
- ✅ Câble USB pour connecter l'appareil au Mac

### **Logiciel :**
- ✅ Flutter installé
- ✅ Xcode (gratuit, App Store)
- ✅ CocoaPods (gratuit)
- ✅ Compte Apple ID (gratuit)

---

## 🚀 **INSTALLATION COMPLÈTE**

### **ÉTAPE 1 : Installer Xcode**

Xcode est **gratuit** et disponible sur l'App Store Mac.

1. **Ouvrir App Store** sur Mac
2. **Chercher "Xcode"**
3. **Installer** (⚠️ ~15GB, téléchargement long : 30 min - 2h)
4. **Sélectionner les composants** :
   - ✅ **macOS 26.1** (Built-in)
   - ✅ **iOS 26.1** (10,34 GB) - **OBLIGATOIRE**
   - ⚪ watchOS, tvOS, visionOS (optionnel)

**Configuration après installation :**
```bash
# Configurer Xcode
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -license accept
sudo xcodebuild -runFirstLaunch

# Vérifier
xcodebuild -version
```

---

### **ÉTAPE 2 : Installer Ruby (si nécessaire)**

Si Ruby est trop ancien (< 3.1.0), installer une version récente :

```bash
# Installer Ruby via Homebrew
brew install ruby

# Ajouter au PATH (ajouter à ~/.zshrc pour permanence)
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export PATH="/opt/homebrew/lib/ruby/gems/3.4.0/bin:$PATH"

# Vérifier
ruby --version  # Doit être >= 3.1.0
```

---

### **ÉTAPE 3 : Installer CocoaPods**

CocoaPods est le gestionnaire de dépendances pour iOS.

```bash
# Option 1 : Installation système (nécessite sudo)
sudo gem install cocoapods

# Option 2 : Installation utilisateur (recommandé)
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
gem install cocoapods --user-install
export PATH="/Users/$USER/.local/share/gem/ruby/3.4.0/bin:$PATH"

# Vérifier
pod --version  # Doit afficher une version (ex: 1.16.2)
```

**Note** : Si `pod` n'est pas trouvé après installation, ajoutez le chemin au PATH dans `~/.zshrc`.

---

### **ÉTAPE 4 : Préparer le projet Flutter**

```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia

# Récupérer les dépendances Flutter
flutter pub get

# Générer le projet iOS
flutter build ios --no-codesign

# Installer les dépendances iOS (CocoaPods)
cd ios
pod install
cd ..
```

**Temps estimé** : 5-10 minutes (première fois)

---

### **ÉTAPE 5 : Configurer Apple ID dans Xcode**

**IMPORTANT** : Utilisez votre Apple ID personnel (celui de votre iPad/iPhone), pas besoin de compte développeur payant !

1. **Ouvrir Xcode**
2. **Xcode** > **Settings** (ou **Preferences**) > **Accounts**
3. Cliquer sur **+** (en bas à gauche)
4. Sélectionner **Apple ID**
5. Entrer votre **email Apple ID** et **mot de passe**
6. Cliquer sur **Sign In**

**C'est tout !** Pas besoin de payer quoi que ce soit.

---

### **ÉTAPE 6 : Connecter votre appareil**

1. **Brancher l'iPad/iPhone** au Mac via USB
2. **Déverrouiller l'appareil**
3. Sur l'appareil, quand la popup apparaît :
   - **"Faire confiance à cet ordinateur ?"** → **Appuyer sur "Faire confiance"**
   - Entrer le **code** si demandé

**Vérifier la connexion :**
```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia
flutter devices
```

**Résultat attendu :**
```
iPad de Nathalie (2) (mobile) • [UUID] • ios • iOS 26.1
```

---

### **ÉTAPE 7 : Ouvrir le projet dans Xcode**

```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia/ios
open Runner.xcworkspace
```

**⚠️ IMPORTANT** : Ouvrez `Runner.xcworkspace` (pas `.xcodeproj`) !

---

### **ÉTAPE 8 : Configurer le Signing**

Dans Xcode, avec le projet ouvert :

1. **Sélectionner le projet "Runner"** dans le navigateur de gauche (icône bleue)
2. **Sélectionner le target "Runner"** (sous TARGETS)
3. Aller dans l'onglet **"Signing & Capabilities"**
4. Cocher **"Automatically manage signing"**
5. Dans **Team**, sélectionner votre **Apple ID** (ex: siwekathalia@gmail.com)
6. Xcode va automatiquement créer un **Bundle Identifier** unique

**Note** : Si vous voyez une erreur "No profiles found", attendez quelques secondes. Xcode crée automatiquement les certificats de développement gratuits.

---

### **ÉTAPE 9 : Lancer l'app**

#### **Option A : Via Xcode (Recommandé)**

1. **En haut de Xcode**, sélectionner votre appareil dans la liste déroulante
2. **Cliquer sur le bouton ▶️ Play** (ou **Cmd+R**)
3. **Attendre la compilation** (première fois : 5-10 minutes)
4. L'app va s'installer et se lancer automatiquement ! 🎉

#### **Option B : Via Flutter CLI**

```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia
flutter run
```

Flutter va automatiquement détecter l'appareil, compiler et installer l'app.

---

## ⚠️ **IMPORTANT : Expiration après 7 jours**

Avec un compte gratuit, l'app expire après **7 jours**. Pour continuer à l'utiliser :

1. **Réinstaller l'app** avec `flutter run` ou depuis Xcode
2. Ou **renouveler la signature** dans Xcode (Signing & Capabilities)

**Astuce** : Si vous testez régulièrement, l'app sera automatiquement renouvelée à chaque lancement depuis Xcode/Flutter.

---

## 🔧 **PROBLÈMES COURANTS**

### **"Command not found: pod"**
**Solution** : CocoaPods n'est pas dans le PATH. Ajoutez au `~/.zshrc` :
```bash
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export PATH="/Users/$USER/.local/share/gem/ruby/3.4.0/bin:$PATH"
```

### **"No iOS devices found"**
**Solution** :
- Vérifier que l'appareil est déverrouillé
- Autoriser le Mac sur l'appareil ("Faire confiance")
- Vérifier le câble USB
- Relancer `flutter devices`

### **"Signing for Runner requires a development team"**
**Solution** :
- Vérifier que votre Apple ID est dans Xcode > Settings > Accounts
- Dans Signing & Capabilities, sélectionner votre Team
- Attendre quelques secondes que Xcode crée les certificats

### **"Pod install" échoue**
**Solution** :
```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia/ios
rm -rf Pods Podfile.lock
pod install --repo-update
```

### **"Xcode installation is incomplete"**
**Solution** :
```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -license accept
```

### **"iOS 26.1 is downloading" dans Xcode**
**Normal !** Xcode télécharge le SDK iOS nécessaire. Attendez la fin du téléchargement avant de compiler.

---

## 📊 **COMPARAISON : Gratuit vs Payant**

| Fonctionnalité | Compte Gratuit | Programme Payant (100€/an) |
|----------------|----------------|----------------------------|
| Tester sur son propre appareil | ✅ Oui | ✅ Oui |
| Déboguer l'app | ✅ Oui | ✅ Oui |
| Durée de validité | ⏰ 7 jours | ✅ Illimitée |
| Distribution App Store | ❌ Non | ✅ Oui |
| TestFlight | ❌ Non | ✅ Oui |
| Nombre d'apps simultanées | 📱 3 max | ✅ Illimité |

**Conclusion** : Pour tester sur votre iPad Pro, le compte gratuit est **parfaitement suffisant**.

---

## 📸 **CAPTURE D'ÉCRANS POUR APP STORE**

### **Sur iPad Pro (Recommandé)**

**iPad Pro est une excellente option** car :
- ✅ **App Store requiert** des screenshots iPad Pro 12.9" (2048 x 2732 px)
- ✅ **Meilleure qualité** : Plus d'espace pour voir les détails
- ✅ **Design adaptatif** : L'app Flutter s'adapte automatiquement

**Comment capturer :**
1. **Lancer l'app** sur l'iPad
2. **Naviguer** vers chaque écran :
   - Home Page
   - Documents
   - Emergency
   - Health
3. **Capturer** : **Volume Up + Power** (ou **Volume Up + Top Button**)
4. **Les screenshots** sont dans **Photos** > **Screenshots**
5. **Transférer** via AirDrop ou câble USB

**Tailles requises :**
- **iPad Pro 12.9"** : 2048 x 2732 pixels (requis pour App Store)
- Minimum 3 screenshots par taille

---

## ✅ **CHECKLIST COMPLÈTE**

- [ ] Xcode installé et configuré
- [ ] Ruby >= 3.1.0 installé
- [ ] CocoaPods installé (`pod --version` fonctionne)
- [ ] Projet iOS généré (`flutter build ios --no-codesign`)
- [ ] Dépendances iOS installées (`pod install`)
- [ ] Apple ID ajouté dans Xcode
- [ ] Appareil branché et détecté (`flutter devices`)
- [ ] Projet ouvert dans Xcode (`Runner.xcworkspace`)
- [ ] Signing configuré (Team sélectionné)
- [ ] App lancée sur iPad/iPhone ! 🎉

---

## 🎯 **COMMANDES UTILES**

```bash
# Vérifier les devices connectés
flutter devices

# Lancer directement depuis Flutter
flutter run -d [UUID_DE_L_APPAREIL]

# Ouvrir dans Xcode
cd ios && open Runner.xcworkspace

# Vérifier la configuration complète
flutter doctor -v
```

---

## ❓ **QUESTIONS FRÉQUENTES**

### **Q : Est-ce que je dois payer les 100€ pour tester ?**
**R : NON !** Le compte Apple ID gratuit suffit pour tester sur votre propre iPad/iPhone.

### **Q : L'app va-t-elle fonctionner normalement ?**
**R : OUI !** Toutes les fonctionnalités fonctionnent exactement pareil. La seule différence est l'expiration après 7 jours.

### **Q : Puis-je publier sur l'App Store avec le compte gratuit ?**
**R : NON.** Pour publier sur l'App Store, il faut le programme payant (100€/an).

### **Q : Que se passe-t-il après 7 jours ?**
**R :** L'app ne se lance plus. Il suffit de la réinstaller avec `flutter run` ou depuis Xcode (2 minutes).

### **Q : Combien d'apps puis-je tester en même temps ?**
**R :** Maximum 3 apps signées simultanément avec le compte gratuit.

### **Q : Pourquoi Xcode télécharge iOS 26.1 ?**
**R :** C'est normal ! Xcode télécharge le SDK iOS nécessaire pour compiler. Attendez la fin du téléchargement.

---

## 🎉 **CONCLUSION**

**OUI, c'est 100% faisable gratuitement !**

Vous pouvez tester votre app Flutter sur votre iPad Pro / iPhone avec :
- ✅ Xcode (gratuit)
- ✅ CocoaPods (gratuit)
- ✅ Votre compte Apple ID personnel (gratuit)

**Pas besoin de payer les 100€** pour tester. Le programme payant n'est nécessaire que si vous voulez :
- Publier sur l'App Store
- Utiliser TestFlight
- Que l'app ne expire jamais

Pour votre cas d'usage (tester sur votre iPad Pro), le compte gratuit est parfait !

---

**Dernière mise à jour** : Décembre 2025

