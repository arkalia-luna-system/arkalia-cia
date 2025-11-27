# 📍 Finding "Connect via Network" in Xcode

> **Step-by-step guide to enable wireless iOS deployment**

**Last Updated**: November 24, 2025  
**Version**: 1.3.1  
**Platform**: iOS / Xcode

---

## 📋 Table of Contents

1. [In Devices and Simulators Window](#in-devices-and-simulators-window)
2. [If You Can't See the Option](#if-you-cant-see-the-option)
3. [Verification](#verification)
4. [After Activation](#after-activation)
5. [Visual Guide](#visual-guide)

---

## 🎯 In Devices and Simulators Window

### Method 1: Checkbox Next to iPad Name

1. **In the left sidebar**, look next to "iPad de Nathalie (2)"
2. You should see a **checkbox** labeled "Connect via network" or "Connect via WiFi"
3. **Check this box**
4. Wait a few seconds - a WiFi icon 🌐 will appear

### Method 2: In Device Details Panel

1. **Select your iPad** from the left sidebar
2. **In the right panel** (where you see iPad information)
3. Look for a section or checkbox labeled **"Connect via network"**
4. It may be located:
   - At the top, near the iPad name
   - In a "Connection" or "Network" section
   - As a checkbox with text "Connect via network"

---

## 🔍 If You Can't See the Option

### Reason 1: iPad Not Connected via USB

The "Connect via network" option only appears if iPad is **currently connected via USB**.

**Solution**:
1. **Connect iPad** to Mac via USB
2. **Wait** for Xcode to detect the iPad
3. The option should now appear

### Reason 2: Option Already Enabled

If iPad appears with a **WiFi icon 🌐** next to it, it's already configured!

**Verification**:
- Look next to "iPad de Nathalie (2)" in the list
- If you see a WiFi icon, it's already activated
- You can disconnect iPad and it should remain connected

### Reason 3: Xcode Version

On some Xcode versions, the option may be in a context menu.

**Solution**:
1. **Right-click** on "iPad de Nathalie (2)" in the list
2. Look for "Connect via network" in the menu

---

## ✅ Verification

Once the option is checked:

1. **Disconnect iPad** from Mac
2. **Look in the list** - iPad should still appear
3. **Next to the name**, you should see a **WiFi icon 🌐**
4. If visible, setup is complete! ✅

---

## 🚀 After Activation

Once configured:

1. **Disconnect iPad** - it stays connected via WiFi
2. **In Xcode**, select your iPad (with WiFi icon 🌐)
3. **Click ▶️ Play** - app updates via WiFi!

---

## 📸 Visual Guide

### In Left Sidebar

**Before activation**:
```
📱 iPad de Nathalie (2)  [☐ Connect via network]
```

**After activation**:
```
📱 iPad de Nathalie (2)  🌐
```

### Icon Meanings

| Icon | Meaning |
|------|---------|
| 🔌 | Connected via USB |
| 🌐 | Connected via WiFi |
| ⚠️ | Connection issue |

---

## 📚 Related Documentation

- **[DEPLOIEMENT_WIFI_IOS.md](DEPLOIEMENT_WIFI_IOS.md)** - Complete WiFi deployment guide
- **[IOS_DEPLOYMENT_GUIDE.md](IOS_DEPLOYMENT_GUIDE.md)** - Complete iOS deployment guide
- **[INDEX_DOCUMENTATION.md](INDEX_DOCUMENTATION.md)** - Full documentation index

---

**Last Updated**: November 19, 2025

