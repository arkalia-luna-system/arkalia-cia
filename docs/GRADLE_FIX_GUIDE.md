# 🔧 Guide de Correction Gradle - Arkalia CIA

**Date**: November 17, 2025
**Objectif**: Forcer Gradle à utiliser `~/.gradle` au lieu de `/Volumes/T7/gradle`

---

## 🎯 **SOLUTION COMPLÈTE IMPLÉMENTÉE**

### **1. Fichier `android/init.gradle`** ✅

Script d'initialisation Gradle qui force le bon chemin à **3 niveaux** :
- `beforeSettings` : Avant le chargement des settings
- `settingsEvaluated` : Après l'évaluation des settings
- `projectsLoaded` : Au chargement des projets

**Fonctionnalités** :
- Détecte si `user.home` est sur `/Volumes/` et le corrige
- Force `org.gradle.user.home` à chaque étape
- Utilise le chemin explicite `/Users/athalia/.gradle` en dernier recours

---

### **2. Script `android/gradlew` modifié** ✅

**Modifications** :
- Lignes 153-155 : Export des variables AVANT Java
- Lignes 164-165 : Ajout des propriétés système Java directement dans JVM_OPTS

**Forces** :
- `GRADLE_USER_HOME=$HOME/.gradle`
- `-Duser.home=$HOME`
- `-Dorg.gradle.user.home=$HOME/.gradle`

---

### **3. Fichier `android/gradle.properties`** ✅

```properties
org.gradle.user.home=/Users/athalia/.gradle
```

Chemin absolu pour éviter toute ambiguïté.

---

### **4. Script `android/build-android.sh`** ✅

**Utilisation** :
```bash
cd arkalia_cia/android
./build-android.sh flutter build apk
```

**Fonctionnalités** :
- Force les variables d'environnement
- Arrête les daemons Gradle existants
- Lance Flutter avec les bonnes configurations

---

### **5. Script `android/clean-gradle.sh`** ✅

**Utilisation** :
```bash
cd arkalia_cia/android
./clean-gradle.sh
```

**Fonctionnalités** :
- Arrête tous les daemons Gradle
- Supprime `/Volumes/T7/gradle` (si possible)
- Nettoie le build local
- Crée `~/.gradle` s'il n'existe pas

---

## 🚀 **UTILISATION**

### **Méthode 1 : Script wrapper (Recommandé)**

```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia/android
./build-android.sh flutter run -d R3CY60BJ3ZM
```

### **Méthode 2 : Variables d'environnement**

```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia
export GRADLE_USER_HOME=$HOME/.gradle
export GRADLE_OPTS="-Dorg.gradle.user.home=$HOME/.gradle -Duser.home=$HOME"
flutter run -d R3CY60BJ3ZM
```

### **Méthode 3 : Directement avec gradlew**

```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia/android
GRADLE_USER_HOME=$HOME/.gradle ./gradlew assembleDebug
```

---

## 🧹 **NETTOYAGE COMPLET**

Si le problème persiste, exécutez le script de nettoyage :

```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia/android
./clean-gradle.sh
```

Puis relancez le build.

---

## ✅ **VÉRIFICATIONS**

### **Vérifier que Gradle utilise le bon cache** :

```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia/android
./gradlew --version
```

Regardez la ligne "Gradle user home" - elle doit indiquer `/Users/athalia/.gradle`

### **Vérifier les variables** :

```bash
env | grep GRADLE
```

Doit afficher :
```
GRADLE_USER_HOME=/Users/athalia/.gradle
GRADLE_OPTS=-Dorg.gradle.user.home=/Users/athalia/.gradle -Duser.home=/Users/athalia
```

---

## 🔍 **DÉPANNAGE**

### **Si Gradle utilise toujours `/Volumes/T7/gradle`** :

1. **Arrêter tous les daemons** :
   ```bash
   cd /Volumes/T7/arkalia-cia/arkalia_cia/android
   ./gradlew --stop
   pkill -f "gradle.*daemon"
   ```

2. **Supprimer le dossier problématique** (peut nécessiter sudo) :
   ```bash
   sudo rm -rf /Volumes/T7/gradle
   ```

3. **Vérifier que `init.gradle` est bien chargé** :
   ```bash
   cd /Volumes/T7/arkalia-cia/arkalia_cia/android
   ./gradlew --init-script init.gradle tasks --info | grep "Init.gradle"
   ```

4. **Utiliser le script wrapper** :
   ```bash
   ./build-android.sh flutter build apk
   ```

---

## 📋 **CHECKLIST**

Avant de lancer un build :

- [ ] Scripts `build-android.sh` et `clean-gradle.sh` sont exécutables (`chmod +x`)
- [ ] Fichier `init.gradle` existe dans `android/`
- [ ] `gradle.properties` contient `org.gradle.user.home=/Users/athalia/.gradle`
- [ ] Variables d'environnement sont configurées
- [ ] Daemons Gradle sont arrêtés (`./gradlew --stop`)
- [ ] Dossier `/Volumes/T7/gradle` est supprimé (si possible)

---

## 🎯 **OBJECTIF**

**Forcer Gradle à utiliser `~/.gradle`** au lieu de `/Volumes/T7/gradle` à **5 niveaux** :

1. ✅ **init.gradle** : 3 hooks (beforeSettings, settingsEvaluated, projectsLoaded)
2. ✅ **gradlew** : Variables d'environnement + propriétés système Java
3. ✅ **gradle.properties** : Configuration explicite
4. ✅ **build-android.sh** : Wrapper qui force tout
5. ✅ **clean-gradle.sh** : Nettoyage complet

---

**Dernière mise à jour**: November 17, 2025
