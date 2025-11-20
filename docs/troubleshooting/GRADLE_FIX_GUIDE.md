# Guide de correction Gradle

**Version** : 3.0  
**Date** : 19 novembre 2025  
**Statut** : ✅ Résolu - Solution ultra-robuste v3.0  
**Objectif** : Forcer Gradle à utiliser `~/.gradle` au lieu de `/Volumes/T7/gradle`

---

## Vue d'ensemble

Ce guide décrit la solution ultra-robuste pour forcer Gradle à utiliser le répertoire local `~/.gradle` au lieu du disque externe `/Volumes/T7/gradle`.

---

## 🎯 **SOLUTION ULTRA-ROBUSTE IMPLÉMENTÉE**

### **1. Fichier `android/init.gradle` v3.0** ✅

Script d'initialisation Gradle qui force le bon chemin à **4 niveaux** :
- `beforeSettings` : Avant le chargement des settings (priorité maximale)
- `settingsEvaluated` : Après l'évaluation des settings (double vérification)
- `projectsLoaded` : Au chargement des projets (vérification finale)
- `beforeProject` : Avant chaque projet (prévention proactive)

**Fonctionnalités avancées** :
- ✅ Détection multi-niveaux du user.home (5 priorités : HOME, USER_HOME, user.home, USER, fallback)
- ✅ Validation de l'existence des répertoires avant utilisation
- ✅ Vérification des permissions d'écriture
- ✅ Création automatique de `~/.gradle` si nécessaire
- ✅ Gestion d'erreurs complète avec try/catch
- ✅ Fallbacks multiples en cas d'échec
- ✅ Prévention proactive de création sur `/Volumes/`
- ✅ Messages de log détaillés pour diagnostic

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

### **Méthode 1 : Build sur disque local (RECOMMANDÉ)**

> ⚠️ **IMPORTANT** : Pour éviter les problèmes de fichiers macOS cachés, utilisez le disque local pour le build.

```bash
# Copier sur disque local (une seule fois)
cd /Volumes/T7/arkalia-cia
rsync -av --exclude='build' --exclude='.dart_tool' --exclude='.git' --exclude='*.log' arkalia_cia/ ~/arkalia-cia-build/arkalia_cia/

# Builder depuis disque local
cd ~/arkalia-cia-build/arkalia_cia
flutter run --release -d 192.168.129.46:5555
```

### **Méthode 2 : Script wrapper (si build sur disque externe)**

```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia/android
./build-android.sh flutter run -d 192.168.129.46:5555
```

### **Méthode 3 : Variables d'environnement**

```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia
export GRADLE_USER_HOME=$HOME/.gradle
export GRADLE_OPTS="-Dorg.gradle.user.home=$HOME/.gradle -Duser.home=$HOME"
find build -name "._*" -type f -delete 2>/dev/null
flutter run --release -d 192.168.129.46:5555
```

### **Méthode 4 : Directement avec gradlew**

```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia/android
find ../build -name "._*" -type f -delete 2>/dev/null
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

1. ✅ **init.gradle v3.0** : 4 hooks (beforeSettings, settingsEvaluated, projectsLoaded, beforeProject) + gestion d'erreurs complète
2. ✅ **gradlew** : Variables d'environnement + propriétés système Java
3. ✅ **gradle.properties** : Configuration explicite
4. ✅ **build-android.sh** : Wrapper qui force tout
5. ✅ **clean-gradle.sh** : Nettoyage complet

---

## ✅ **GARANTIES**

La solution v3.0 garantit :
- ✅ **Aucun risque** de création sur `/Volumes/` grâce à 4 niveaux de protection
- ✅ **Gestion d'erreurs** complète avec fallbacks multiples
- ✅ **Validation** de tous les chemins avant utilisation
- ✅ **Création automatique** de `~/.gradle` si nécessaire
- ✅ **Messages de diagnostic** détaillés pour troubleshooting

---

## 📋 **HISTORIQUE DU PROBLÈME**

### **Problème initial**
Gradle utilisait systématiquement `/Volumes/T7/gradle` au lieu de `~/.gradle`, causant des erreurs :
```
Failed to create directory /Volumes/T7/gradle/caches/8.12/kotlin-dsl/scripts/...
> Failed to create class directory /Volumes/T7/gradle/.tmp/classes*.tmp.
```

### **Tentatives de correction (toutes échouées)**
- ❌ Configuration `gradle.properties` : Ignoré par Gradle
- ❌ Variables d'environnement : Ignoré par Gradle
- ❌ Script `init.gradle` basique : Ignoré par Gradle
- ❌ Modification `gradlew` : Ignoré par Gradle
- ❌ Suppression du dossier : Gradle le recréait automatiquement
- ❌ Lien symbolique : Erreur "Too many levels"

### **Solution finale**
Script `init.gradle` v3.0 avec **4 niveaux de protection** :
- `beforeSettings` : Avant le chargement des settings (priorité maximale)
- `settingsEvaluated` : Après l'évaluation des settings (double vérification)
- `projectsLoaded` : Au chargement des projets (vérification finale)
- `beforeProject` : Avant chaque projet (prévention proactive)

**Résultat** : ✅ Problème définitivement résolu

---

---

## Voir aussi

- [deployment/BUILD_RELEASE_ANDROID.md](../deployment/BUILD_RELEASE_ANDROID.md) - Guide de build Android
- [troubleshooting/TESTS_PROBLEMATIQUES.md](troubleshooting/TESTS_PROBLEMATIQUES.md) - Tests problématiques
- [INDEX_DOCUMENTATION.md](../INDEX_DOCUMENTATION.md) - Index de la documentation

---

**Dernière mise à jour** : 19 novembre 2025  
**Version** : 3.0 - Ultra-robuste
