# 📱 Créer un Émulateur Android - Guide Simple

**Date** : 12 décembre 2025  
**Pourquoi c'est important** : Tester Google Sign-In nécessite un appareil Android

---

## 🎯 POURQUOI C'EST IMPORTANT

### Pour tester Google Sign-In :
- ✅ **Google Sign-In ne fonctionne que sur Android/iOS** (pas sur macOS desktop)
- ✅ **Besoin de tester** que la connexion fonctionne vraiment
- ✅ **Vérifier** que le SHA-1 est correct
- ✅ **Valider** l'expérience utilisateur

### Sans émulateur/appareil Android :
- ❌ Impossible de tester Google Sign-In
- ❌ Impossible de vérifier que tout fonctionne
- ❌ Risque de bugs en production

---

## 🚀 MÉTHODE SIMPLE : Android Studio (Recommandé)

### Étape 1 : Ouvrir Android Studio

1. Ouvrir **Android Studio**
2. Si pas installé : https://developer.android.com/studio

### Étape 2 : Device Manager

1. Dans Android Studio, cliquer sur **Device Manager** (icône téléphone en haut à droite)
2. Ou : **Tools** > **Device Manager**

### Étape 3 : Créer un appareil virtuel

1. Cliquer sur **Create Device** (ou **+ Create Virtual Device**)
2. Choisir un appareil :
   - **Pixel 5** (recommandé)
   - Ou **Pixel 6**
   - Ou n'importe quel appareil récent
3. Cliquer sur **Next**

### Étape 4 : Choisir une image système

1. Choisir une **System Image** :
   - **API 33 (Android 13)** - Recommandé
   - Ou **API 34 (Android 14)**
   - Cliquer sur **Download** si nécessaire (première fois)
2. Cliquer sur **Next**

### Étape 5 : Finaliser

1. Vérifier les paramètres (nom, orientation, etc.)
2. Cliquer sur **Finish**

### Étape 6 : Lancer l'émulateur

1. Dans Device Manager, cliquer sur **▶️ Play** à côté de l'émulateur créé
2. Attendre que l'émulateur démarre (peut prendre 1-2 minutes la première fois)

---

## 🧪 TESTER APRÈS CRÉATION

### 1. Vérifier que l'émulateur est détecté
```bash
flutter devices
```
Tu devrais voir ton émulateur listé.

### 2. Lancer l'app
```bash
cd arkalia_cia
flutter run -d android
```

### 3. Tester Google Sign-In
- Cliquer sur "Continuer avec Gmail"
- Vérifier que le sélecteur Google s'ouvre
- Sélectionner un compte
- Vérifier la redirection

---

## 🔧 MÉTHODE ALTERNATIVE : Ligne de commande

Si tu préfères la ligne de commande :

```bash
# Lister les images système disponibles
sdkmanager --list | grep "system-images"

# Créer un émulateur (exemple)
avdmanager create avd -n Pixel5_API33 -k "system-images;android-33;google_apis;x86_64"

# Lancer l'émulateur
emulator -avd Pixel5_API33
```

**Note** : Cette méthode est plus complexe. Android Studio est plus simple.

---

## ✅ VÉRIFICATION

Après avoir créé et lancé l'émulateur :

1. **Vérifier Flutter** :
```bash
flutter devices
```
→ L'émulateur doit apparaître

2. **Lancer l'app** :
```bash
cd arkalia_cia
flutter run -d android
```

3. **Tester Google Sign-In** :
   - Bouton "Continuer avec Gmail" visible
   - Sélecteur Google s'ouvre
   - Connexion fonctionne

---

## 🐛 PROBLÈMES COURANTS

### "No devices found"
- Vérifier que l'émulateur est bien lancé
- Attendre 1-2 minutes après le lancement
- Relancer `flutter devices`

### L'émulateur est lent
- Normal la première fois (téléchargement des images)
- Fermer d'autres applications
- Augmenter la RAM allouée dans les paramètres de l'émulateur

### Erreur de création
- Vérifier que Android SDK est installé
- Vérifier que les images système sont téléchargées
- Redémarrer Android Studio

---

## 📋 RÉSUMÉ

1. ✅ **Ouvrir Android Studio**
2. ✅ **Device Manager** > **Create Device**
3. ✅ **Choisir Pixel 5** > **API 33**
4. ✅ **Lancer l'émulateur** (▶️)
5. ✅ **Tester** : `flutter run -d android`

**Temps estimé** : 5-10 minutes (première fois, avec téléchargements)

---

**C'est important car sans émulateur/appareil Android, tu ne peux pas tester Google Sign-In !** 🎯

