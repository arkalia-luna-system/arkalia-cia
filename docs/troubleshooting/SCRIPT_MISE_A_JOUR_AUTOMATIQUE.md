# 🚀 Script de Mise à Jour Automatique - Arkalia CIA

**Date** : 19 novembre 2025  
**Version** : 1.0.0  
**Sécurité** : ✅ **100% SÉCURISÉ** - Ne supprime JAMAIS les données utilisateur

---

## 🎯 **FONCTIONNALITÉS**

### ✅ **Ce que le script fait :**

1. **Détecte automatiquement** tous les appareils disponibles :
   - iPad/iPhone (iOS)
   - Samsung S25 (Android)
   - Mac (macOS)

2. **Met à jour l'app** sur chaque appareil automatiquement

3. **Nettoie les builds anciens** (> 7 jours) pour libérer de l'espace

4. **Préserve les données utilisateur** :
   - ✅ Documents PDF
   - ✅ Rappels
   - ✅ Contacts d'urgence
   - ✅ Informations médicales
   - ✅ Paramètres utilisateur
   - ✅ Base de données SQLite
   - ✅ SharedPreferences

### ❌ **Ce que le script NE fait JAMAIS :**

- ❌ Ne supprime JAMAIS les données utilisateur
- ❌ Ne touche JAMAIS aux fichiers dans les répertoires de données
- ❌ Ne supprime que les builds de compilation (> 7 jours)
- ❌ Ne modifie JAMAIS les préférences utilisateur

---

## 🚀 **UTILISATION**

### **Méthode 1 : Mise à jour simple (recommandée)**

```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia
./update_all_devices.sh
```

Le script va :
1. Détecter automatiquement tous les appareils
2. Mettre à jour l'app sur chaque appareil
3. Nettoyer les builds anciens
4. Afficher un résumé

### **Méthode 2 : Avec reconnexion WiFi Android**

Si votre S25 est configuré pour WiFi ADB :

```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia
./update_all_devices.sh
```

Le script reconnectera automatiquement le S25 via WiFi si l'IP est sauvegardée.

---

## 🔒 **SÉCURITÉ DES DONNÉES**

### **Données préservées automatiquement :**

#### **iOS (iPad/iPhone) :**
- `~/Library/Containers/com.example.arkaliaCia/Data/`
- `~/Library/Application Support/com.example.arkaliaCia/`
- `~/Library/Preferences/com.example.arkaliaCia/`

#### **Android (S25) :**
- `/data/data/com.example.arkalia_cia/`
- `/sdcard/Android/data/com.example.arkalia_cia/`

#### **macOS :**
- `~/Library/Application Support/arkalia_cia/`
- `~/Library/Preferences/com.example.arkaliaCia/`

### **Vérification automatique :**

Le script vérifie automatiquement que les données utilisateur existent et les préserve avant toute opération.

---

## 📋 **CE QUI EST NETTOYÉ**

### **Builds supprimés (après 7 jours) :**

- ✅ `build/ios/*.app` (anciennes versions iOS)
- ✅ `build/app/*.apk` (anciens APK Android)
- ✅ `build/app/*.aab` (anciens AAB Android)
- ✅ `build/macos/*.app` (anciennes versions macOS)
- ✅ Fichiers macOS cachés `._*`

### **Ce qui N'EST PAS supprimé :**

- ❌ Aucune donnée utilisateur
- ❌ Aucun fichier PDF
- ❌ Aucune base de données
- ❌ Aucune préférence
- ❌ Aucun document

---

## 🔍 **DÉTAILS TECHNIQUES**

### **Détection automatique des appareils :**

Le script utilise `flutter devices` pour détecter :
- Appareils iOS (iPad/iPhone) via USB ou WiFi
- Appareils Android (S25) via USB ou WiFi ADB
- macOS (Mac local)

### **Gestion des erreurs :**

- ✅ Mode strict activé (`set -euo pipefail`)
- ✅ Arrêt en cas d'erreur critique
- ✅ Logs détaillés pour chaque appareil
- ✅ Résumé des succès/échecs

### **Performance :**

- ✅ Nettoyage intelligent (seulement builds > 7 jours)
- ✅ Mise à jour parallèle possible
- ✅ Pause entre les appareils pour éviter la surcharge

---

## 📊 **EXEMPLE DE SORTIE**

```
═══════════════════════════════════════════════════════════════
🚀 Mise à jour automatique Arkalia CIA
═══════════════════════════════════════════════════════════════

ℹ️  Vérification de la sécurité des données utilisateur...
✅ Données iOS trouvées : Library/Containers/com.example.arkaliaCia
✅ Vérification sécurité terminée - données utilisateur préservées

ℹ️  Nettoyage des builds anciens (> 7 jours)...
✅ Nettoyage terminé : 3 ancien(s) build(s) supprimé(s)

ℹ️  Détection des appareils...
ℹ️  Appareil détecté : 00008112-000631060A8B401E
ℹ️  Appareil détecté : 192.168.129.46:5555
ℹ️  Appareil détecté : macos

───────────────────────────────────────────────────────────
ℹ️  Traitement : iPad de Athalia (00008112-000631060A8B401E)
───────────────────────────────────────────────────────────
ℹ️  Mise à jour sur iPad de Athalia (00008112-000631060A8B401E)...
ℹ️  Mode : iOS
✅ Mise à jour réussie sur iPad de Athalia

───────────────────────────────────────────────────────────
ℹ️  Traitement : SM S938B (192.168.129.46:5555)
───────────────────────────────────────────────────────────
ℹ️  Mise à jour sur SM S938B (192.168.129.46:5555)...
ℹ️  Mode : Android WiFi
✅ Mise à jour réussie sur SM S938B

═══════════════════════════════════════════════════════════════
📊 RÉSUMÉ
═══════════════════════════════════════════════════════════════
✅ Mises à jour réussies : 2
✅ Données utilisateur préservées (aucune suppression)
✅ Builds anciens nettoyés
═══════════════════════════════════════════════════════════════
```

---

## 🐛 **DÉPANNAGE**

### **"Aucun appareil détecté"**

**Solutions :**
1. Vérifiez que les appareils sont connectés et déverrouillés
2. Pour Android : Vérifiez `adb devices`
3. Pour iOS : Vérifiez que l'appareil est approuvé dans Xcode
4. Pour WiFi Android : Vérifiez que l'IP est sauvegardée dans `.wifi_adb_ip`

### **"Échec de la mise à jour"**

**Solutions :**
1. Vérifiez les logs : `/tmp/flutter_update_[DEVICE_ID].log`
2. Vérifiez que Flutter est à jour : `flutter doctor`
3. Nettoyez et réessayez : `flutter clean && flutter pub get`

### **"Permission denied"**

**Solution :**
```bash
chmod +x update_all_devices.sh
```

---

## ⚙️ **CONFIGURATION**

### **Modifier la durée de conservation des builds :**

Éditez le script et modifiez :
```bash
BUILD_CLEANUP_DAYS=7  # Changer 7 par le nombre de jours souhaité
```

### **Désactiver le nettoyage automatique :**

Commentez la ligne dans le script :
```bash
# cleanup_old_builds
```

---

## 🔐 **SÉCURITÉ**

### **Garanties de sécurité :**

1. ✅ **Mode strict** : Le script s'arrête en cas d'erreur
2. ✅ **Vérification des données** : Vérifie que les données existent avant toute opération
3. ✅ **Patterns exclus** : Les chemins de données utilisateur sont explicitement exclus
4. ✅ **Logs détaillés** : Toutes les opérations sont loggées
5. ✅ **Aucune suppression de données** : Seuls les builds sont nettoyés

### **Vérification manuelle :**

Avant d'exécuter le script, vous pouvez vérifier les chemins de données :

```bash
# iOS
ls -la ~/Library/Containers/com.example.arkaliaCia/

# Android (via ADB)
adb shell "ls -la /data/data/com.example.arkalia_cia/"

# macOS
ls -la ~/Library/Application\ Support/arkalia_cia/
```

---

## 📝 **RÉSUMÉ**

### **Avantages :**

- ✅ **Automatique** : Détecte et met à jour tous les appareils
- ✅ **Sécurisé** : Ne supprime JAMAIS les données utilisateur
- ✅ **Performant** : Nettoie les builds anciens automatiquement
- ✅ **Intelligent** : Reconnexion WiFi Android automatique
- ✅ **Robuste** : Gestion d'erreurs complète

### **Utilisation quotidienne :**

```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia
./update_all_devices.sh
```

**C'est tout !** Le script fait le reste automatiquement. 🎉

---

## Voir aussi

- [MISE_A_JOUR_S25_CORRIGEE.md](MISE_A_JOUR_S25_CORRIGEE.md) - Guide de mise à jour corrigé
- [MISE_A_JOUR_S25_WIFI.md](MISE_A_JOUR_S25_WIFI.md) - Guide de mise à jour via WiFi
-  - Optimisations des scripts
- [deployment/GUIDE_DEPLOIEMENT_FINAL.md](deployment/GUIDE_DEPLOIEMENT_FINAL.md) - Guide de déploiement final
- [INDEX_DOCUMENTATION.md](INDEX_DOCUMENTATION.md) - Index de la documentation

---

**Dernière mise à jour** : 19 novembre 2025

