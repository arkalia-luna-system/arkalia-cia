# Guide build release Android

**Version** : 1.2.0  
**Dernière mise à jour** : 19 novembre 2025  
**Cible** : Google Play Store

Guide complet pour construire des releases Android prêtes pour la production.

---

## Table des matières

1. [Pre-Build Checklist](#pre-build-checklist)
2. [Build Commands](#build-commands)
3. [Post-Build Verification](#post-build-verification)
4. [Testing Checklist](#testing-checklist)
5. [Troubleshooting](#troubleshooting)

---

## ✅ Pre-Build Checklist

### Version Configuration

Verify version information in `pubspec.yaml`:

```yaml
version: 1.2.0+1
# Format: MAJOR.MINOR.PATCH+BUILD_NUMBER
```

| Field | Description | Example |
|-------|-------------|---------|
| **MAJOR** | Major version number | `1` |
| **MINOR** | Minor version number | `2` |
| **PATCH** | Patch version number | `0` |
| **BUILD_NUMBER** | Build increment | `1` |

### Signing Configuration

Verify signing keys are configured in `android/app/build.gradle`:

```gradle
android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
}
```

> **Security**: Never commit keystore files or passwords to version control!

### Pre-Build Verification

- ✅ All tests pass (218/218)
- ✅ Code quality checks pass (Black, Ruff, MyPy, Bandit)
- ✅ Flutter analyze shows no errors
- ✅ Critical bugs fixed
- ✅ UX improvements completed
- ✅ Signing keys configured

---

## 🔨 Build Commands

### Build APK (Universal)

For testing or direct distribution:

```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia
flutter build apk --release
```

**Output Location**: `build/app/outputs/flutter-apk/app-release.apk`

**File Size**: Typically 20-50 MB (varies by dependencies)

### Build APK (Split by ABI)

For smaller file sizes (recommended for distribution):

```bash
flutter build apk --release --split-per-abi
```

**Output Files**:
- `app-armeabi-v7a-release.apk` (32-bit ARM)
- `app-arm64-v8a-release.apk` (64-bit ARM)
- `app-x86_64-release.apk` (x86_64)

### Build App Bundle (Play Store)

**Required for Google Play Store submission**:

```bash
flutter build appbundle --release
```

**Output Location**: `build/app/outputs/bundle/release/app-release.aab`

**File Size**: Typically 15-30 MB (optimized by Google Play)

> **Note**: App Bundles are optimized by Google Play and automatically generate APKs for different device configurations.

---

## ✅ Post-Build Verification

### File Size Check

| Build Type | Expected Size | Maximum Recommended |
|-----------|---------------|---------------------|
| **APK (Universal)** | 20-50 MB | 100 MB |
| **APK (Split)** | 10-25 MB each | 50 MB each |
| **AAB** | 15-30 MB | 100 MB |

### Install on Real Device

```bash
# Install release APK
flutter install --release

# Or manually install
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Verify Installation

- ✅ App installs successfully
- ✅ App launches without crashes
- ✅ No permission errors
- ✅ All features accessible

---

## 🧪 Testing Checklist

### Functional Testing

- [ ] **All screens load correctly**
  - Home page
  - Documents screen
  - Health portals
  - Reminders
  - Emergency contacts
  - ARIA integration
  - Sync screen

- [ ] **Permissions work correctly**
  - Contacts permission (Emergency screen)
  - Calendar permission (Reminders)
  - Storage permission (Documents)

- [ ] **Navigation functions**
  - ARIA navigation works
  - Back button behavior
  - Deep linking (if implemented)

### UI/UX Testing

- [ ] **Text sizes** meet accessibility requirements (16sp minimum)
- [ ] **Color icons** display correctly
- [ ] **FAB (Floating Action Button)** is visible and functional
- [ ] **Large buttons** are easy to tap (senior-friendly)
- [ ] **Dark mode** works (if implemented)

### Performance Testing

- [ ] **No lag** during navigation
- [ ] **Smooth scrolling** in lists
- [ ] **Fast app startup** (<3 seconds)
- [ ] **No memory leaks** (test with extended use)
- [ ] **Battery usage** is reasonable

### Compatibility Testing

Test on multiple devices:
- [ ] **Android 5.0+** (API 21+) - Minimum requirement
- [ ] **Recent Android versions** (API 33+)
- [ ] **Different screen sizes** (phone, tablet)
- [ ] **Different manufacturers** (Samsung, Google, etc.)

---

## 🔧 Troubleshooting

### Build Failures

#### Gradle Issues

If you encounter Gradle cache errors:

```bash
# Clean Gradle cache
cd android
./gradlew clean

# Or use the fix guide
# See: docs/GRADLE_FIX_GUIDE.md
```

#### macOS Hidden Files

If build fails due to macOS hidden files:

```bash
# Remove hidden files
find build -name "._*" -type f -delete

# Or use the solution guide
# See: docs/SOLUTION_FICHIERS_MACOS.md
```

### Signing Issues

#### Keystore Not Found

```bash
# Verify keystore path in android/key.properties
# Ensure keystore file exists
ls -la android/app/your-keystore.jks
```

#### Wrong Password

- Verify `key.properties` has correct passwords
- Check keystore file is not corrupted

### Installation Issues

#### App Won't Install

```bash
# Uninstall existing version first
adb uninstall com.example.arkaliaCia

# Then install release version
adb install build/app/outputs/flutter-apk/app-release.apk
```

#### Permission Denied

- Check AndroidManifest.xml has required permissions
- Verify targetSdkVersion is compatible

---

## 📚 Related Documentation

- **[GRADLE_FIX_GUIDE.md](GRADLE_FIX_GUIDE.md)** - Gradle troubleshooting
- **[RELEASE_CHECKLIST.md](RELEASE_CHECKLIST.md)** - Complete release checklist
- **[DEPLOYMENT.md](DEPLOYMENT.md)** - General deployment guide
- **[INDEX_DOCUMENTATION.md](INDEX_DOCUMENTATION.md)** - Documentation index

---

## 🚀 Next Steps

After successful build and testing:

1. **Upload to Play Store** (if using AAB)
2. **Test on multiple devices** before release
3. **Monitor crash reports** after release
4. **Gather user feedback** for next version

---

**For questions or issues, refer to the troubleshooting section or open an issue on GitHub.**

