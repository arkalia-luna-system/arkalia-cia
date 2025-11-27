# 📱 Testing and Updating Guide - Android App

> **Complete guide for testing and updating Arkalia CIA on your Android device**

**Last Updated**: November 24, 2025  
**Version**: 1.3.1  
**Platform**: Android

---

## 📋 Table of Contents

1. [Recent Fixes](#recent-fixes)
2. [Testing Methods](#testing-methods)
3. [Updating Without Reconnecting](#updating-without-reconnecting)
4. [Verification Tests](#verification-tests)
5. [Troubleshooting](#troubleshooting)
6. [Quick Reference](#quick-reference)

---

## ✅ Recent Fixes

### Fix 1: Contact Permissions ✅ FIXED

| Issue | Solution | Status |
|-------|----------|--------|
| **Missing permissions** | Added to `AndroidManifest.xml` | ✅ |
| **Abrupt permission request** | Graceful dialog with explanation | ✅ |
| **Red error on denial** | App works without contacts | ✅ |

**Result**: App handles contact permissions gracefully with clear user communication.

### Fix 2: ARIA Navigation ✅ FIXED

| Issue | Solution | Status |
|-------|----------|--------|
| **Confusing error messages** | Clear, explanatory messages | ✅ |
| **Localhost attempts** | Removed (doesn't work on mobile) | ✅ |
| **Browser access unavailable** | Clear explanation provided | ✅ |

**Result**: Users understand why ARIA browser access isn't available on mobile.

### Fix 3: Sync Message ✅ FIXED

| Change | Before | After | Status |
|--------|--------|-------|--------|
| **Message text** | "en cours de développement" | "disponible prochainement" | ✅ |
| **Color** | Orange (alarming) | Blue (informative) | ✅ |
| **Duration** | Long | 2 seconds | ✅ |

**Result**: Professional, non-alarming sync status message.

### Fix 4: Code Quality ✅ VALIDATED

| Tool | Result | Status |
|------|--------|--------|
| **flutter analyze** | 0 errors | ✅ |
| **black** | All Python files formatted | ✅ |
| **ruff** | All checks passed | ✅ |
| **bandit** | 0 security issues | ✅ |

---

## 🚀 Testing Methods

### Method 1: Via USB

#### Step 1: Connect Phone

1. **Connect Samsung S25 Ultra** to Mac via USB
2. **On phone**: Accept USB connection (allow file transfer)
3. **On Mac**: Verify phone is detected:
   ```bash
   adb devices
   ```

   **Expected output**:
   ```
   List of devices attached
   192.168.129.46:5555    device
   ```

#### Step 2: Enable Developer Mode (if not already done)

1. On phone: **Settings** → **About phone**
2. Tap **7 times** on "Build number"
3. Go back to **Settings** → **Developer options**
4. Enable **USB debugging**

#### Step 3: Build and Install

> ⚠️ **IMPORTANT**: To avoid macOS hidden file issues on external drive, use local disk for build.

**Option A: Build on Local Disk (RECOMMENDED)**

```bash
# Copy project to local disk (one-time setup)
cd /Volumes/T7/arkalia-cia
rsync -av \
  --exclude='build' \
  --exclude='.dart_tool' \
  --exclude='.git' \
  --exclude='*.log' \
  arkalia_cia/ ~/arkalia-cia-build/arkalia_cia/

# Build from local disk
cd ~/arkalia-cia-build/arkalia_cia
flutter clean
flutter run --release -d 192.168.129.46:5555
```

**Option B: Build on External Drive (if necessary)**

```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia

# Clean macOS hidden files before build
find build -name "._*" -type f -delete 2>/dev/null
flutter clean

# Build and install directly on phone
flutter run --release
```

**OR** create APK and install manually:

```bash
# Create APK
flutter build apk --release

# APK location: arkalia_cia/build/app/outputs/flutter-apk/app-release.apk

# Install via ADB
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

---

### Method 2: Via WiFi (Wireless) - RECOMMENDED

> ⚠️ **IMPORTANT**: WiFi ADB is ONLY for deploying YOUR development apps (like Arkalia CIA).
> - ✅ Allows updating Arkalia CIA without USB cable
> - ❌ Does NOT automatically update other apps
> - ❌ Does NOT replace Play Store for normal apps
> - ✅ Play Store apps continue updating normally via Play Store

#### Option A: Use Automated Script (EASY)

A secure script is available to simplify WiFi ADB connection:

**Initial setup (phone connected via USB)**:
```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia
./connect_wifi_adb.sh setup
```

**Features**:
- ✅ Finds IP automatically
- ✅ Saves IP securely (file ignored by git)
- ✅ Connects via WiFi

**Reconnect later (without USB, if same WiFi network)**:
```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia
./connect_wifi_adb.sh reconnect
```

**Check status**:
```bash
./connect_wifi_adb.sh status
```

> 🔒 **Security**: IP is saved in `.wifi_adb_ip` which is ignored by git. Your data stays private.

#### Option B: Manual Configuration

If you prefer manual setup:

1. Connect phone via USB
2. Enable USB debugging (see Method 1)
3. Find phone IP (Settings → Wi‑Fi → connected network)
4. Connect via WiFi:
   ```bash
   adb tcpip 5555
   adb connect YOUR_PHONE_IP:5555
   ```

#### Deploy App via WiFi

Once connected (script or manual), you can disconnect USB cable and use:

**Recommended: Build on local disk**
```bash
cd ~/arkalia-cia-build/arkalia_cia
flutter run --release -d 192.168.129.46:5555
```

**Alternative: Build on external drive**
```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia
find build -name "._*" -type f -delete 2>/dev/null
flutter run --release -d 192.168.129.46:5555
```

> **Result**: You can update Arkalia CIA without reconnecting USB cable, but you must **ALWAYS** run `flutter run` manually. It does **NOT** happen automatically.

---

### Method 3: Install APK Manually

#### Step 1: Create APK

```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia
flutter build apk --release
```

**Output**: `build/app/outputs/flutter-apk/app-release.apk`

#### Step 2: Transfer APK to Phone

| Method | Description |
|--------|-------------|
| **AirDrop** | If Mac and iPhone (not Android) |
| **USB** | Copy APK file to phone storage |
| **Cloud** | Upload to Google Drive / Dropbox, download on phone |

#### Step 3: Install on Phone

1. Open APK file on phone
2. Allow installation from "Unknown sources" if prompted
3. Install the app

---

## 🔄 Updating App (Without Reconnecting Phone)

### Using WiFi with Script (Method 2 - Option A)

**If on same WiFi network**:
```bash
# Reconnect via WiFi
cd /Volumes/T7/arkalia-cia/arkalia_cia
./connect_wifi_adb.sh reconnect  # Reconnects if needed

# Build from local disk (recommended)
cd ~/arkalia-cia-build/arkalia_cia
flutter run --release -d 192.168.129.46:5555
```

**No need to reconnect phone!** ✅

**If WiFi network changed**:
1. Reconnect phone via USB once
2. Run `./connect_wifi_adb.sh setup` to update IP
3. Then disconnect and use `reconnect`

### Using WiFi Manually (Method 2 - Option B)

Once WiFi is configured, simply:
```bash
# Build from local disk (recommended)
cd ~/arkalia-cia-build/arkalia_cia
flutter run --release -d 192.168.129.46:5555
```

**No need to reconnect phone!** ✅ (as long as on same WiFi network)

### Using USB

You must reconnect phone each time to update.

---

## ✅ Verification Tests

### Test 1: Contact Permissions

**Steps**:
1. Open Arkalia CIA app
2. Tap **"Urgence"**

**Expected Results**:

| Action | Result |
|--------|--------|
| **Permission dialog** | ✅ Appears explaining why contacts are needed |
| **If accepted** | ✅ Contacts display correctly |
| **If denied** | ✅ **NO red error**, just empty list with message "Aucun contact d'urgence" |

### Test 2: ARIA Navigation

**Steps**:
1. Open Arkalia CIA app
2. Tap **"ARIA"**
3. Tap **"Accéder à ARIA"** or any button (Saisie Rapide, Historique, etc.)

**Expected Results**:
- ✅ Clear message: "L'accès ARIA via navigateur n'est pas disponible sur mobile..."
- ✅ **NO brutal red error**

### Test 3: Sync Message

**Steps**:
1. Open Arkalia CIA app
2. Tap **"Sync"**

**Expected Results**:
- ✅ Blue message: "Synchronisation disponible prochainement"
- ✅ Message disappears after 2 seconds

---

## 🐛 Troubleshooting

### Problem: "adb devices" Doesn't Find Phone

**Solutions**:

1. **Verify USB debugging is enabled**
   - Settings → Developer options → USB debugging

2. **Try different USB cable**
   - Some cables are charge-only

3. **On Mac: Install Android File Transfer** (if needed)

4. **Restart ADB**:
   ```bash
   adb kill-server
   adb start-server
   adb devices
   ```

### Problem: "Permission denied" During Installation

**Solutions**:

1. **Uninstall old app version** on phone
2. **Reinstall**:
   ```bash
   adb install -r build/app/outputs/flutter-apk/app-release.apk
   ```

### Problem: App Doesn't Update

**Solutions**:

1. **Uninstall completely** old version
2. **Reinstall** new version
3. **OR** use `flutter run --release` which automatically replaces old version

---

## 📝 Summary: Do I Need to Reconnect Phone Each Time?

### Answer: Depends on Your Method

| Method | Reconnect Each Time? | Automatic Updates? |
|--------|---------------------|---------------------|
| **USB** | ✅ **YES** - Must reconnect cable | ❌ **NO** - Must run `flutter run` |
| **WiFi** | ❌ **NO** - Once configured, stay wireless | ❌ **NO** - Must run `flutter run` |
| **Manual APK** | ❌ **NO** - Just transfer file | ❌ **NO** - Install manually |

### ⚠️ Important Clarification

**WiFi ADB**:
- ✅ Allows deploying Arkalia CIA **without USB cable**
- ✅ Once configured, stay wireless
- ❌ **BUT** you must **ALWAYS** run `flutter run` manually to update
- ❌ Does **NOT** update automatically
- ❌ Only affects **YOUR** development apps (Arkalia CIA)
- ❌ Does **NOT** replace Play Store for other apps

**Play Store Apps**:
- ✅ Continue updating normally via Play Store
- ✅ Nothing changes for them

### Recommendation: Use WiFi!

Once configured, you can update Arkalia CIA **without ever reconnecting the phone**, but you must still run `flutter run` each time you want to update.

---

## 🎯 Quick Reference Commands

### WiFi ADB Setup (Recommended)

```bash
# Go to source directory
cd /Volumes/T7/arkalia-cia/arkalia_cia

# Initial setup (with USB)
./connect_wifi_adb.sh setup

# Reconnect via WiFi (without USB)
./connect_wifi_adb.sh reconnect

# Check status
./connect_wifi_adb.sh status
```

### Deployment (Recommended: Local Disk)

```bash
# Copy to local disk (one-time setup)
cd /Volumes/T7/arkalia-cia
rsync -av \
  --exclude='build' \
  --exclude='.dart_tool' \
  --exclude='.git' \
  --exclude='*.log' \
  arkalia_cia/ ~/arkalia-cia-build/arkalia_cia/

# Build from local disk
cd ~/arkalia-cia-build/arkalia_cia
flutter run --release -d 192.168.129.46:5555

# Create APK
flutter build apk --release

# Install APK (if needed)
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

> 💡 **Tip**: Once WiFi ADB is configured with script, you can use `./connect_wifi_adb.sh reconnect` then `flutter run --release` without ever reconnecting USB cable (as long as on same WiFi network).

---

## ✨ Ready to Test!

All critical errors are fixed. You can now test the app on your phone and see:
- ✅ No red errors for contact permissions
- ✅ Clear, explanatory ARIA error messages
- ✅ Professional sync message

**Happy testing! 🚀**

---

## Voir aussi

- **[troubleshooting/EXPLICATION_WIFI_ADB.md](./troubleshooting/EXPLICATION_WIFI_ADB.md)** — Explication WiFi ADB
- **[deployment/BUILD_RELEASE_ANDROID.md](./deployment/BUILD_RELEASE_ANDROID.md)** — Guide build Android
- **[CE_QUE_VOUS_DEVRIEZ_VOIR.md](./CE_QUE_VOUS_DEVRIEZ_VOIR.md)** — Ce que vous devriez voir
- **[deployment/CONNECTER_S25_ANDROID.md](./deployment/CONNECTER_S25_ANDROID.md)** — Connexion Android
- **[INDEX_DOCUMENTATION.md](./INDEX_DOCUMENTATION.md)** — Index complet de la documentation

---

*Dernière mise à jour : Janvier 2025*

