# 📱 Standalone App Operation - iPad/iPhone Independence

> **Can the app work without being connected to Mac?**

**Last Updated**: November 19, 2025  
**Version**: 1.2.0  
**Platform**: iOS

---

## ✅ Quick Answer

**YES!** Once the app is installed on your iPad/iPhone, you can **disconnect the device from Mac** and the app will work normally! 🎉

---

## 🎯 How It Works

### During Installation

| Requirement | Status |
|-------------|--------|
| **iPad/iPhone connected** to Mac via USB | ✅ Required |
| **Xcode/Flutter** installs the app | ✅ Automatic |
| **App launches** automatically | ✅ Yes |

### After Installation

| Feature | Status |
|---------|--------|
| **Disconnect iPad** from Mac | ✅ Allowed |
| **App works independently** | ✅ Yes |
| **Normal usage** on iPad | ✅ Yes |
| **All features work** without Mac | ✅ Yes |

---

## ⏰ App Validity Duration

### Free Apple ID Account

- ✅ App works for **7 days**
- ⚠️ After 7 days, app expires and won't launch
- 🔄 **To continue**: Reconnect iPad and relaunch from Xcode/Flutter

### Paid Developer Account (€100/year)

- ✅ App works **indefinitely**
- ✅ No need to reconnect after 7 days
- ✅ No expiration issues

> **Note**: See [IOS_DEPLOYMENT_GUIDE.md](IOS_DEPLOYMENT_GUIDE.md) for details on free vs paid accounts.

---

## 🔄 Updating the App

If you modify the code and want to update the app on your iPad:

### Method 1: From Xcode (Recommended)

1. **Reconnect iPad** to Mac via USB
2. **In Xcode**, click **▶️ Play** (or press **Cmd+R**)
3. App will update and relaunch automatically

### Method 2: From Flutter CLI

```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia
flutter run
```

> **Note**: You can disconnect the iPad after the update completes.

---

## 📱 Daily Usage

Once the app is installed:

### What You Can Do Without Mac

- ✅ **Use the app normally** on your iPad
- ✅ **All features work**:
  - Navigation within the app
  - Data saving and storage
  - Notifications
  - All app functionality
- ✅ **Take it anywhere** - fully portable
- ✅ **Use offline** - no internet required for core features

### What Requires Mac

- ❌ **Initial app installation**
- ❌ **App updates** (after code modifications)
- ❌ **Certificate renewal** (after 7-day expiration with free account)

---

## 📊 Summary Table

| Action | Mac Connection Required? |
|--------|-------------------------|
| **Install app** | ✅ Yes |
| **Use app** | ❌ No |
| **Update app** | ✅ Yes |
| **Use after installation** | ❌ No |
| **Daily usage** | ❌ No |
| **All app features** | ❌ No |

---

## ⚠️ Important Notes

### Certificate Expiration (Free Account)

- Development certificates expire after **7 days**
- App will stop launching after expiration
- **Solution**: Reconnect to Mac and relaunch from Xcode/Flutter
- Takes only **2 minutes** to renew

### App Updates

- Mac connection required **only** when updating code
- After update, you can disconnect immediately
- App continues working independently

### Data Persistence

- ✅ **All data is stored locally** on the device
- ✅ **No Mac dependency** for data access
- ✅ **Works completely offline**

---

## 🎯 Use Cases

### Scenario 1: Daily Use

1. Install app once (requires Mac)
2. Disconnect iPad
3. Use app normally for 7 days
4. Reconnect to renew (if using free account)

### Scenario 2: Development

1. Make code changes
2. Reconnect iPad to Mac
3. Update app via Xcode/Flutter
4. Disconnect and test independently

### Scenario 3: Travel

1. Install app before travel
2. Disconnect from Mac
3. Use app during travel (no Mac needed)
4. Reconnect after 7 days if needed

---

## 🔧 Troubleshooting

### App Won't Launch After Disconnecting

**Possible causes**:
1. Certificate expired (7-day limit with free account)
2. Developer Mode disabled
3. Certificate not trusted

**Solutions**:
- Reconnect to Mac and relaunch from Xcode
- Check Developer Mode is enabled
- Trust certificate in Settings (see [APPROUVER_CERTIFICAT_DEVELOPPEUR.md](APPROUVER_CERTIFICAT_DEVELOPPEUR.md))

### App Works But Features Don't

- Check app permissions in Settings
- Verify data was saved before disconnecting
- Some features may require initial setup with Mac connected

---

## 📚 Related Documentation

- **[IOS_DEPLOYMENT_GUIDE.md](IOS_DEPLOYMENT_GUIDE.md)** - Complete iOS deployment guide
- **[APPROUVER_CERTIFICAT_DEVELOPPEUR.md](APPROUVER_CERTIFICAT_DEVELOPPEUR.md)** - Certificate trust guide
- **[INDEX_DOCUMENTATION.md](INDEX_DOCUMENTATION.md)** - Full documentation index

---

## 🎉 Conclusion

**Once installed, the app works completely independently from Mac!**

You can:
- ✅ Disconnect your iPad
- ✅ Use the app normally
- ✅ Take it anywhere
- ✅ Use it without Mac

**Mac is only needed for installation or updates.**

---

**For questions or issues, refer to the troubleshooting section or see [IOS_DEPLOYMENT_GUIDE.md](IOS_DEPLOYMENT_GUIDE.md).**

