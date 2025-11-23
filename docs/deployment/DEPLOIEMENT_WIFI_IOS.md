# 📡 Wireless iOS Deployment (WiFi) - Arkalia CIA

> **Deploy and update your iOS app wirelessly without USB cable**

**Last Updated**: November 23, 2025  
**Version**: 1.3.0  
**Platform**: iOS / Xcode

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Initial Setup](#initial-setup)
3. [Daily Usage](#daily-usage)
4. [Requirements](#requirements)
5. [Verification](#verification)
6. [Troubleshooting](#troubleshooting)
7. [Comparison](#comparison)

---

## 🎯 Overview

**Objective**: Update your app on iPad **without reconnecting the USB cable**, using the same WiFi network.

### Benefits

- ✅ **No USB cable needed** after initial setup
- ✅ **More convenient** - iPad can stay where it is
- ✅ **Quick updates** - Just click Play in Xcode
- ✅ **Same features** - Hot reload, debugging, etc.

---

## ✅ Initial Setup (One-Time Configuration)

### Step 1: Connect iPad via USB (First Time)

1. **Connect iPad** to Mac via USB cable
2. **Open Xcode**
3. Navigate to: **Window** > **Devices and Simulators** (or **Cmd+Shift+2**)
4. **Select your iPad** from the left sidebar

### Step 2: Enable Wireless Deployment

1. In the "Devices and Simulators" window
2. **Check the box** "Connect via network" (or "Connect via WiFi")
3. Xcode will configure iPad for wireless deployment
4. **Wait a few seconds** - you'll see a WiFi icon 🌐 appear next to your iPad

### Step 3: Verify Connection

1. **Disconnect iPad** from Mac
2. iPad should still appear in Xcode with WiFi icon 🌐
3. If visible, setup is complete! ✅

---

## 🚀 Daily Usage

Once configured, you can update your app wirelessly:

### Method 1: From Xcode (Recommended)

1. **Open Xcode** with your project (`Runner.xcworkspace`)
2. **Ensure iPad is selected** (with WiFi icon 🌐)
3. **Click ▶️ Play** (or press **Cmd+R**)
4. App will update **via WiFi** without USB cable! 🎉

### Method 2: From Flutter CLI (Recommended)

**If WiFi is already configured**, you can use Flutter directly:

```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia
flutter run
```

Flutter will automatically detect iPad via WiFi if configured.

**If multiple devices are available**, Flutter will ask you to choose:

```text
[1]: macOS (macos)
[2]: iPad de Athalia (wireless) (00008112-000631060A8B401E)
Please choose one (or "q" to quit):
```

**Or specify the device directly**:

```bash
flutter run -d "iPad de Athalia"
# Or using UUID:
flutter run -d 00008112-000631060A8B401E
```

**Advantages of Flutter CLI**:

- ✅ **Simpler** - One command
- ✅ **Faster** - No need to open Xcode
- ✅ **Works via WiFi** - If configured
- ✅ **Hot reload** - Changes reflect automatically

---

## ⚠️ Requirements

For wireless deployment to work:

| Requirement | Status |
|-------------|--------|
| **Same WiFi network** | ✅ Mac and iPad must be on same WiFi |
| **iPad powered on** | ✅ iPad must be turned on |
| **iPad unlocked** | ✅ iPad must be unlocked |
| **Xcode open** | ✅ Xcode must be open to detect iPad |
| **Initial setup done** | ✅ One-time USB connection required |

---

## 🔧 Verification

### Check iPad WiFi Connection in Xcode

1. In **Xcode**: **Window** > **Devices and Simulators**
2. Look for your iPad in the list
3. **WiFi icon 🌐** = Connected via WiFi
4. **USB icon 🔌** = Connected via USB

### Verify from Flutter

```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia
flutter devices
```

You should see your iPad listed even without USB cable.

**Expected Output** (WiFi configured):
```
Wirelessly connected devices:
iPad de Athalia (wireless) (mobile) • 00008112-000631060A8B401E • ios • iOS 26.1
```

**If you see "wireless"**, WiFi is already configured! 🎉

**If iPad doesn't appear** without USB cable, WiFi is not configured yet.

---

## 🔍 Finding "Connect via Network" Option

### Where to Look

The "Connect via network" option appears in different places depending on Xcode version:

#### Method 1: Checkbox Next to iPad Name

1. **In the left sidebar**, look next to your iPad name
2. You should see a **checkbox** labeled "Connect via network" or "Connect via WiFi"
3. **Check this box**
4. Wait a few seconds - a WiFi icon 🌐 will appear

#### Method 2: In Device Details Panel

1. **Select your iPad** from the left sidebar
2. **In the right panel** (where you see iPad information)
3. Look for a section or checkbox labeled **"Connect via network"**
4. It may be located:
   - At the top, near the iPad name
   - In a "Connection" or "Network" section
   - As a checkbox with text "Connect via network"

#### Method 3: Context Menu

1. **Right-click** on your iPad in the list
2. Look for "Connect via network" in the menu

### Why You Might Not See It

#### Reason 1: iPad Not Connected via USB

The "Connect via network" option **only appears if iPad is currently connected via USB**.

**Solution**:

1. **Connect iPad** to Mac via USB
2. **Wait** for Xcode to detect the iPad
3. The option should now appear

#### Reason 2: Option Already Enabled

If iPad appears with a **WiFi icon 🌐** next to it, it's already configured!

**Verification**:

- Look next to your iPad name in the list
- If you see a WiFi icon, it's already activated
- You can disconnect iPad and it should remain connected

---

## 🔄 Troubleshooting

### Problem: iPad Not Appearing via WiFi

#### Solution 1: Reconnect via USB

1. Reconnect iPad via USB
2. In Xcode > Devices and Simulators
3. **Uncheck** then **recheck** "Connect via network"
4. Wait a few seconds
5. Disconnect and verify

#### Solution 2: Verify WiFi Connection

**On iPad**:
- Settings > Wi‑Fi
- Verify connected to same network as Mac

**On Mac**:
- System Preferences > Network
- Verify connected to same WiFi network

**Common Issues**:
- Different WiFi networks (2.4GHz vs 5GHz)
- VPN interfering with connection
- Firewall blocking connection

#### Solution 3: Restart Devices

1. **Restart iPad**
2. **Restart Xcode**
3. **Restart Mac** (if needed)
4. Try again

#### Solution 4: Reset Network Settings

If nothing works:

1. Reconnect via USB
2. In Xcode > Devices and Simulators
3. Right-click iPad > **Unpair Device**
4. Reconnect and reconfigure WiFi

---

## 📊 Comparison

| Method | USB Cable Required? | WiFi Required? | Speed | Convenience |
|--------|---------------------|----------------|-------|-------------|
| **USB** | ✅ Yes | ❌ No | Fast | Medium |
| **WiFi** | ❌ No (after setup) | ✅ Yes | Slightly slower | High |

### Speed Comparison

- **USB**: ~50-100 MB/s transfer speed
- **WiFi**: ~10-50 MB/s transfer speed (depends on WiFi speed)

> **Note**: Speed difference is usually negligible for app updates.

---

## ⚠️ Important Notes

### Initial Configuration

- ⚠️ **First-time setup** must be done via USB
- ⚠️ **One-time only** - After setup, USB not needed
- ⚠️ **Same WiFi** - Mac and iPad must be on same network

### Daily Usage

- ✅ **iPad can stay anywhere** - No need to move it
- ✅ **Xcode must be open** - To detect iPad wirelessly
- ✅ **iPad must be unlocked** - For deployment to work

### Limitations

- ⚠️ **WiFi range** - Must be within WiFi range
- ⚠️ **Network stability** - Requires stable WiFi connection
- ⚠️ **Slower than USB** - Slightly slower transfer speed

---

## 🎯 Use Cases

### Scenario 1: Daily Development

1. Configure WiFi deployment once
2. Keep iPad on desk/table
3. Update app wirelessly while coding
4. No need to handle USB cable

### Scenario 2: Multiple Devices

1. Configure WiFi for multiple iPads
2. Switch between devices easily
3. No cable swapping needed

### Scenario 3: Remote Testing

1. iPad in another room
2. Update app wirelessly
3. Test without moving devices

---

## 📚 Related Documentation

- **[TROUVER_CONNECT_VIA_NETWORK.md](TROUVER_CONNECT_VIA_NETWORK.md)** - Detailed guide to find the option
- **[IOS_DEPLOYMENT_GUIDE.md](IOS_DEPLOYMENT_GUIDE.md)** - Complete iOS deployment guide
- **[APP_INDEPENDANTE_MAC.md](APP_INDEPENDANTE_MAC.md)** - Standalone app operation
- **[INDEX_DOCUMENTATION.md](INDEX_DOCUMENTATION.md)** - Full documentation index

---

## 📝 Note on Merged Documentation

The following files have been merged into this guide:

- ~~WIFI_DEJA_CONFIGURE.md~~ → Content integrated above
- ~~POURQUOI_CONNECT_VIA_NETWORK_N_APPARAIT_PAS.md~~ → Content integrated in "Finding Connect via Network" section
- ~~SOLUTION_ALTERNATIVE_WIFI_IOS.md~~ → Content integrated in "Method 2: From Flutter CLI" section

---

## 🎉 Conclusion

Once configured, you can update your app on iPad **without ever reconnecting the USB cable**, as long as you're on the same WiFi network!

**Much more convenient for daily development!** 🚀

---

**For questions or issues, refer to the troubleshooting section or see [IOS_DEPLOYMENT_GUIDE.md](IOS_DEPLOYMENT_GUIDE.md).**
