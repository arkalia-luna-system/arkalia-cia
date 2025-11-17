# Solution Complète pour les Fichiers macOS Cachés

## Problème

macOS crée automatiquement des fichiers cachés (._*, .DS_Store, etc.) sur les volumes externes, ce qui cause des problèmes avec Gradle et Flutter.

## Solution Multi-Niveaux

### 1. Scripts de Nettoyage et Prévention

#### `find-all-macos-files.sh`
**Usage :** Trouve tous les fichiers macOS cachés dans le projet
```bash
./arkalia_cia/android/find-all-macos-files.sh
```

#### `prevent-macos-files.sh`
**Usage :** Supprime agressivement tous les fichiers macOS avant un build
```bash
./arkalia_cia/android/prevent-macos-files.sh
```
- Supprime tous les fichiers ._*, .DS_Store, .AppleDouble, etc.
- Configure .gitattributes
- S'exécute automatiquement avant chaque build via `build-android.sh`

#### `disable-macos-files.sh`
**Usage :** Configuration initiale pour désactiver la création de fichiers macOS
```bash
./arkalia_cia/android/disable-macos-files.sh
```
**À exécuter UNE FOIS** pour :
- Configurer les attributs étendus
- Créer/mettre à jour .gitattributes
- Configurer Git hooks
- Donner les instructions pour désactiver au niveau système

#### `clean-gradle.sh`
**Usage :** Nettoyage complet de Gradle et des fichiers macOS
```bash
./arkalia_cia/android/clean-gradle.sh
```

### 2. Configuration Gradle

#### `build.gradle.kts`
- Exclusion des fichiers macOS dans toutes les tâches PatternFilterable
- Nettoyage automatique avant et après chaque build
- Exclusion dans les tâches Copy, Sync, Zip, Tar, Jar

#### `init.gradle`
- Nettoyage ultra-agressif avant et après chaque tâche
- Nettoyage spécial pour les tâches Android critiques
- Configuration globale pour exclure les fichiers macOS

#### `app/build.gradle.kts`
- Exclusion dans le packaging Android
- Exclusion dans les sourceSets

### 3. Configuration Git

#### `.gitignore`
Les fichiers macOS sont déjà ignorés :
```
._*
.DS_Store
.DS_Store?
.Spotlight-V100
.Trashes
```

#### `.gitattributes` (créé automatiquement)
Empêche Git de traiter les fichiers macOS cachés

#### Git Hooks
Un hook `pre-commit` supprime automatiquement les fichiers macOS avant chaque commit

### 4. Désactivation au Niveau Système (Optionnel)

Pour empêcher macOS de créer ces fichiers sur **TOUS** les volumes externes :

```bash
defaults write com.apple.desktopservices DSDontWriteNetworkStores true
defaults write com.apple.desktopservices DSDontWriteUSBStores true
```

**⚠️ Attention :** Ces paramètres s'appliquent à TOUS les volumes externes. Redémarrer macOS ou se déconnecter/reconnecter pour que les changements prennent effet.

## Workflow Recommandé

### Configuration Initiale (Une fois)
```bash
cd /Volumes/T7/arkalia-cia
./arkalia_cia/android/disable-macos-files.sh
```

### Avant Chaque Build
Utilisez le script `build-android.sh` qui nettoie automatiquement :
```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia
./android/build-android.sh flutter build apk --debug
```

### Si Problèmes Persistent
```bash
# 1. Trouver les fichiers
./arkalia_cia/android/find-all-macos-files.sh

# 2. Nettoyer manuellement
./arkalia_cia/android/prevent-macos-files.sh

# 3. Nettoyer Gradle
./arkalia_cia/android/clean-gradle.sh

# 4. Rebuild
./arkalia_cia/android/build-android.sh flutter build apk --debug
```

## Vérification

Pour vérifier qu'il n'y a plus de fichiers macOS :
```bash
./arkalia_cia/android/find-all-macos-files.sh
```

## Notes Importantes

1. **Les fichiers macOS sont recréés automatiquement** par macOS sur les volumes externes
2. **La solution nettoie avant chaque build** pour éviter les problèmes
3. **Les exclusions Gradle** empêchent ces fichiers d'être traités même s'ils existent
4. **Le nettoyage multi-niveaux** garantit qu'aucun fichier n'est oublié

## Fichiers Créés/Modifiés

- ✅ `android/find-all-macos-files.sh` - Script de recherche
- ✅ `android/prevent-macos-files.sh` - Script de prévention
- ✅ `android/disable-macos-files.sh` - Script de configuration
- ✅ `android/build-android.sh` - Intègre le nettoyage automatique
- ✅ `android/build.gradle.kts` - Exclusion et nettoyage Gradle
- ✅ `android/init.gradle` - Nettoyage ultra-agressif
- ✅ `android/app/build.gradle.kts` - Exclusion dans le packaging
- ✅ `.gitattributes` - Configuration Git (créé automatiquement)

