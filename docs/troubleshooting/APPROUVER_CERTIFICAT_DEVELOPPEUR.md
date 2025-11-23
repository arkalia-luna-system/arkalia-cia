# 🔐 Trust Developer Certificate on iPad/iPhone

> **iOS Development Certificate Trust Guide** - First-time app installation

**Last Updated**: November 23, 2025  
**Version**: 1.3.0  
**Platform**: iOS 16+

---

## 🎯 Problem

Xcode displays:
```
The application could not be launched because the Developer App Certificate is not trusted.
```

**This is normal!** iOS requires you to trust the developer certificate before running apps from Xcode.

---

## ✅ Solution: Trust the Certificate

### Step 1: Open Settings on Your iPad/iPhone

1. Open the **Settings** app on your device
2. Navigate to **General**
3. Scroll down to find one of these options:
   - **Device Management** (most common)
   - **VPN & Device Management** (iOS 15+)
   - **Profiles & Device Management** (older iOS versions)

> **Note**: On recent iOS versions, it's often located under **"VPN & Device Management"**.

---

### Step 2: Locate the Developer Certificate

1. Look for a section labeled **"DEVELOPER APP"** or **"Apple Development"**
2. You should see your email address:
   - `siwekathalia@gmail.com`
   - Or: `Apple Development: siwekathalia@gmail.com`
3. **Tap on it** to open certificate details

---

### Step 3: Trust the Certificate

1. A new page opens showing certificate details
2. **Tap the "Trust" button** in the top-right corner
3. A confirmation popup appears
4. **Tap "Trust" again** to confirm

---

### Step 4: Verify Trust Status

1. Return to **Settings** > **General** > **Device Management**
2. You should now see **"Trusted"** next to your certificate
3. The certificate status should show as verified

---

## 🚀 After Trusting the Certificate

Once the certificate is trusted, you can launch your app:

### Option A: Launch from Xcode (Recommended)

1. In **Xcode**, select your device from the device list
2. Click the **▶️ Play** button (or press **Cmd+R**)
3. The app will install and launch automatically! 🎉

### Option B: Launch from Flutter CLI

```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia
flutter run
```

Flutter will automatically detect your device and install the app.

---

## 📍 Finding Device Management

If you can't find "Device Management", check these locations:

| iOS Version | Location |
|-------------|----------|
| **iOS 15+** | Settings > General > **VPN & Device Management** |
| **iOS 13-14** | Settings > General > **Device Management** |
| **iOS 12** | Settings > General > **Profiles & Device Management** |

> **Tip**: On recent iOS versions, it's most commonly under **"VPN & Device Management"**.

---

## ⚠️ Important Notes

### Security

- ✅ **100% Secure**: This is your own development certificate
- ✅ **One-Time Setup**: You only need to do this once per certificate
- ✅ **Required**: This step is mandatory for first-time app installation

### Certificate Expiration

- Development certificates expire after **7 days** (free Apple ID)
- You may need to re-trust if the certificate is renewed
- See [IOS_DEPLOYMENT_GUIDE.md](IOS_DEPLOYMENT_GUIDE.md) for more details

---

## 🔧 Troubleshooting

### Certificate Not Appearing

If the certificate doesn't appear in Settings:

1. **In Xcode**, click **▶️ Play** again
2. Xcode will create/refresh the certificate
3. **Wait a few seconds** for the certificate to sync
4. Return to **Settings** on your device
5. The certificate should now appear

### Still Not Working?

1. **Disconnect and reconnect** your device via USB
2. **Unlock your device** and ensure it's not locked
3. **Restart Xcode** and try again
4. Check that **Developer Mode** is enabled (iOS 16+)
   - See [IOS_DEPLOYMENT_GUIDE.md](IOS_DEPLOYMENT_GUIDE.md#developer-mode)

---

## ✅ Verification

To verify everything works:

```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia
flutter devices
flutter run
```

The app should install and launch without errors.

---

## 📚 Related Documentation

- **[IOS_DEPLOYMENT_GUIDE.md](IOS_DEPLOYMENT_GUIDE.md)** - Complete iOS deployment guide
- **[INDEX_DOCUMENTATION.md](INDEX_DOCUMENTATION.md)** - Full documentation index

---

**For additional help, see the troubleshooting section in [IOS_DEPLOYMENT_GUIDE.md](IOS_DEPLOYMENT_GUIDE.md).**

