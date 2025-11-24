# 📱 What You Should See - Samsung S25 Ultra

> **Visual verification guide for Android app installation**

**Last Updated**: November 24, 2025  
**Version**: 1.3.0  
**Platform**: Android

---

## 📋 Table of Contents

1. [After APK Installation](#after-apk-installation)
2. [App Launch Screen](#app-launch-screen)
3. [Visual Design](#visual-design)
4. [Troubleshooting](#troubleshooting)
5. [Available Features](#available-features)

---

## ✅ After APK Installation

### 1. Application Icon

- Look for **"Arkalia CIA"** icon in app drawer
- Icon should be visible in applications menu
- Icon design: Blue medical cross with "CIA" text

---

## 🚀 App Launch Screen

### AppBar (Top Bar)

| Element | Value |
|---------|-------|
| **Title** | "Arkalia CIA" (white text) |
| **Background** | Dark blue (Colors.blue[600]) |
| **Height** | Standard AppBar height |

### Main Content

**Main Title** (top, centered):
- Text: **"Assistant Personnel"**
- Style: Large, bold, blue color
- Size: 24sp (accessibility compliant)

---

## 📱 Button Grid (2 columns, 3 rows)

Each button is a clickable card with icon, title, and subtitle:

### Button 1: Documents 📄

| Property | Value |
|----------|-------|
| **Color** | Green |
| **Icon** | Document icon |
| **Title** | "Documents" |
| **Subtitle** | "Import/voir docs" |
| **Action** | Opens DocumentsScreen |

### Button 2: Health 🏥

| Property | Value |
|----------|-------|
| **Color** | Red |
| **Icon** | Medical bag |
| **Title** | "Santé" |
| **Subtitle** | "Portails santé" |
| **Action** | Opens HealthScreen |

### Button 3: Reminders 🔔

| Property | Value |
|----------|-------|
| **Color** | Orange |
| **Icon** | Bell |
| **Title** | "Rappels" |
| **Subtitle** | "Rappels simples" |
| **Action** | Opens RemindersScreen |

### Button 4: Emergency 📞

| Property | Value |
|----------|-------|
| **Color** | Purple |
| **Icon** | Emergency phone |
| **Title** | "Urgence" |
| **Subtitle** | "ICE - Contacts" |
| **Action** | Opens EmergencyScreen |

### Button 5: ARIA ❤️

| Property | Value |
|----------|-------|
| **Color** | Red |
| **Icon** | Heart/pulse |
| **Title** | "ARIA" |
| **Subtitle** | "Laboratoire Santé" |
| **Action** | Opens ARIAScreen |

### Button 6: Sync 🔄

| Property | Value |
|----------|-------|
| **Color** | Orange |
| **Icon** | Synchronization |
| **Title** | "Sync" |
| **Subtitle** | "CIA ↔ ARIA" |
| **Action** | Shows message: "Synchronisation disponible prochainement" |

---

## 🎨 Visual Design

### Design System

| Aspect | Specification |
|--------|---------------|
| **Style** | Material Design 3 |
| **Primary Color** | Blue (Colors.blue[600]) |
| **Button Colors** | Green, Red, Orange, Purple |
| **Layout** | Responsive 2x3 grid |
| **Interactions** | InkWell tap effects |
| **Text Size** | Minimum 16sp (accessibility) |

### Color Scheme

- **Primary**: Blue (#1976D2)
- **Documents**: Green
- **Health**: Red
- **Reminders**: Orange
- **Emergency**: Purple
- **ARIA**: Red
- **Sync**: Orange

---

## 🔍 Troubleshooting

### App Not Visible

**Check 1: Verify Installation**
```bash
adb shell pm list packages | grep arkalia
```

Expected output:
```
package:com.example.arkaliaCia
```

**Check 2: Launch Manually**
```bash
adb shell am start -n com.example.arkaliaCia/com.example.arkaliaCia.MainActivity
```

**Check 3: View Logs**
```bash
flutter logs
```

### Visual Issues

| Issue | Solution |
|-------|----------|
| **Buttons not visible** | Check screen size, ensure responsive layout |
| **Text too small** | Verify text size ≥ 16sp |
| **Colors incorrect** | Check Material Design theme |
| **Icons missing** | Verify icon assets are included |

---

## 📋 Available Features

| Feature | Status | Description |
|---------|--------|-------------|
| **Documents** | ✅ Available | Import and view PDF documents |
| **Health** | ✅ Available | Access health portals |
| **Reminders** | ✅ Available | Simple reminder management |
| **Emergency** | ✅ Available | ICE (In Case of Emergency) contacts |
| **ARIA** | ✅ Available | ARIA health lab interface |
| **Sync** | 🚧 In Development | CIA ↔ ARIA synchronization |

---

## 🎯 Next Steps

Once the app is launched, you can:

1. ✅ **Test each button** - Navigate to corresponding screens
2. ✅ **Import PDF documents** - Test document functionality
3. ✅ **Configure reminders** - Set up health reminders
4. ✅ **Add emergency contacts** - Set up ICE contacts
5. ✅ **Explore ARIA interface** - Test ARIA integration

---

## Voir aussi

- **[deployment/BUILD_RELEASE_ANDROID.md](./deployment/BUILD_RELEASE_ANDROID.md)** — Guide build Android
- **[TESTER_ET_METTRE_A_JOUR.md](./TESTER_ET_METTRE_A_JOUR.md)** — Guide de test et mise à jour
- **[deployment/CONNECTER_S25_ANDROID.md](./deployment/CONNECTER_S25_ANDROID.md)** — Connexion Android
- **[SCREENSHOTS_GUIDE.md](./SCREENSHOTS_GUIDE.md)** — Guide des screenshots
- **[INDEX_DOCUMENTATION.md](./INDEX_DOCUMENTATION.md)** — Index complet de la documentation

---

*Dernière mise à jour : Janvier 2025*

