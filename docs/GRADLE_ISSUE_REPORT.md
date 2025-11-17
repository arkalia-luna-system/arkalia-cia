# 🔴 Rapport Problème Build Android - Gradle

**Date**: November 17, 2025
**Statut**: 🔄 **SOLUTIONS IMPLÉMENTÉES** - À tester

---

## 📋 **PROBLÈME**

**Erreur récurrente** :
```
Failed to create directory /Volumes/T7/gradle/caches/8.12/kotlin-dsl/scripts/...
> Failed to create class directory /Volumes/T7/gradle/.tmp/classes*.tmp.
```

**Impact** : Impossible de compiler l'app Android pour installer sur Samsung S25 Ultra.

---

## 🔍 **CAUSES IDENTIFIÉES**

### **1. Gradle utilise `/Volumes/T7/gradle` au lieu de `~/.gradle`**

**Problème** : Gradle ignore toutes les configurations et utilise systématiquement `/Volumes/T7/gradle` comme cache.

**Tentatives de correction** :
- ✅ Ajout de `org.gradle.user.home=/Users/athalia/.gradle` dans `gradle.properties`
- ✅ Configuration dans `gradle-wrapper.properties`
- ✅ Création de `init.gradle` pour forcer le cache local
- ✅ Variables d'environnement `GRADLE_USER_HOME` et `GRADLE_OPTS`
- ✅ Modification du script `gradlew`
- ✅ Suppression du dossier `/Volumes/T7/gradle` (réapparaît)
- ✅ Création de lien symbolique (erreur "Too many levels")
- ✅ Dossier vide créé (Gradle le recrée)

**Résultat** : ❌ Aucune solution n'a fonctionné. Gradle continue d'utiliser `/Volumes/T7/gradle`.

---

## 🛠️ **SOLUTIONS TENTÉES**

### **Solution 1 : Configuration gradle.properties**
```properties
org.gradle.user.home=/Users/athalia/.gradle
```
**Résultat** : ❌ Ignoré par Gradle

### **Solution 2 : Variables d'environnement**
```bash
export GRADLE_USER_HOME=$HOME/.gradle
export GRADLE_OPTS="-Dorg.gradle.user.home=$HOME/.gradle"
```
**Résultat** : ❌ Ignoré par Gradle

### **Solution 3 : init.gradle**
```groovy
settingsEvaluated { settings ->
    settings.gradle.userHome = new File(System.getProperty("user.home"), ".gradle")
}
```
**Résultat** : ❌ Ignoré par Gradle

### **Solution 4 : Modification gradlew**
Ajout des exports dans le script shell.
**Résultat** : ❌ Ignoré par Gradle

### **Solution 5 : Suppression du dossier**
```bash
rm -rf /Volumes/T7/gradle
```
**Résultat** : ❌ Gradle le recrée automatiquement

### **Solution 6 : Lien symbolique**
```bash
ln -s $HOME/.gradle /Volumes/T7/gradle
```
**Résultat** : ❌ Erreur "Too many levels of symbolic links"

---

## 🔬 **ANALYSE TECHNIQUE**

### **Configuration actuelle**

**Fichiers modifiés** :
- `android/gradle.properties` : Configuration propre (sans org.gradle.user.home)
- `android/gradle/wrapper/gradle-wrapper.properties` : Configuration standard
- `android/app/build.gradle.kts` : Nettoyé (pas de tâches custom)

**Variables d'environnement** :
- `GRADLE_USER_HOME=/Users/athalia/.gradle` ✅ Configuré
- `GRADLE_OPTS="-Dorg.gradle.user.home=$HOME/.gradle"` ✅ Configuré

**Dossier problématique** :
- `/Volumes/T7/gradle` : Existe et est utilisé par Gradle malgré toutes les configurations

### **Hypothèses**

1. **Configuration système** : Peut-être une configuration macOS qui force Gradle à utiliser le volume externe
2. **Gradle Daemon** : Les daemons existants utilisent peut-être l'ancien chemin
3. **Flutter** : Flutter peut forcer un chemin spécifique pour Gradle
4. **Permissions** : Problème de permissions sur le volume externe

---

## 📊 **ÉTAT ACTUEL**

### **✅ Ce qui fonctionne**
- Flutter détecte le téléphone Samsung S25 Ultra
- Tous les outils de qualité de code (Black, Ruff, MyPy, Bandit) passent
- Tests Python : 61/61 passants
- Configuration Android : SDK 35, NDK 27 configurés

### **❌ Ce qui ne fonctionne pas**
- Build Android : Échec systématique à cause du cache Gradle
- Installation sur téléphone : Impossible sans build réussi

---

## 🎯 **RECOMMANDATIONS POUR AUDIT**

### **Points à vérifier**

1. **Configuration système macOS** :
   - Vérifier les variables d'environnement globales
   - Vérifier les fichiers de configuration shell (`~/.zshrc`, `~/.bash_profile`)
   - Vérifier les préférences système

2. **Gradle Daemon** :
   - Arrêter tous les daemons : `./gradlew --stop`
   - Vérifier les processus Gradle en cours
   - Nettoyer complètement le cache

3. **Flutter configuration** :
   - Vérifier si Flutter force un chemin Gradle
   - Vérifier `flutter doctor -v` pour les chemins
   - Vérifier les fichiers de configuration Flutter

4. **Volume externe** :
   - Vérifier les permissions sur `/Volumes/T7`
   - Vérifier si le volume est monté avec des options spéciales
   - Tester avec le projet sur le disque local

5. **Alternative** :
   - Tester le build sur un autre Mac
   - Tester avec le projet copié sur le disque local
   - Utiliser Android Studio directement au lieu de Flutter CLI

---

## 📝 **FICHIERS À FOURNIR POUR AUDIT**

1. `android/gradle.properties`
2. `android/gradle/wrapper/gradle-wrapper.properties`
3. `android/app/build.gradle.kts`
4. `android/local.properties`
5. Sortie complète de `flutter doctor -v`
6. Sortie de `env | grep -i gradle`
7. Sortie de `./gradlew --version`
8. Logs complets du build avec `--stacktrace`

---

## 🚨 **URGENCE**

**Blocant pour** :
- Tests manuels sur Android
- Prise de screenshots Android
- Release v1.0

**Priorité** : 🔴 **HAUTE** - Nécessite résolution avant release

---

**Dernière mise à jour**: November 17, 2025
**Prochaine étape**: Tester les nouvelles solutions implémentées

---

## ✅ **NOUVELLES SOLUTIONS IMPLÉMENTÉES** (2025-11-17)

### **Solution 7 : Configuration renforcée dans gradle.properties**
✅ Ajout de `org.gradle.user.home=/Users/athalia/.gradle` avec chemin absolu

### **Solution 8 : Script init.gradle dans le projet**
✅ Création de `android/init.gradle` qui force le user.home avant chaque build

### **Solution 9 : Amélioration du script gradlew**
✅ Modification pour :
- Exporter les variables AVANT l'exécution de Java
- Ajouter les propriétés système Java `-Duser.home` et `-Dorg.gradle.user.home`
- Forcer ces propriétés directement dans la JVM

### **Solution 10 : Script wrapper build-android.sh**
✅ Script à utiliser pour tous les builds Android qui :
- Force les variables d'environnement
- Arrête les daemons Gradle
- Lance Flutter avec les bonnes configurations

### **Solution 11 : Script de nettoyage clean-gradle.sh**
✅ Script pour nettoyer complètement :
- Arrête tous les daemons
- Supprime `/Volumes/T7/gradle`
- Nettoie le build local

**📖 Voir le guide complet**: `docs/GRADLE_FIX_GUIDE.md`
