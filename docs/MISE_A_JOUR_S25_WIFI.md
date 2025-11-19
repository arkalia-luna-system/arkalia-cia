# 🚀 Mise à jour S25 via WiFi - Guide Rapide

**Date** : 19 novembre 2025  
**IP WiFi** : `192.168.129.46:5555`

---

## ✅ **CONFIGURATION TERMINÉE !**

Le S25 est maintenant configuré pour le déploiement WiFi. **Vous pouvez débrancher le câble USB !**

---

## 📱 **POUR METTRE À JOUR L'APP (SANS CÂBLE)**

### **Méthode 1 : Via Flutter (Recommandé)**

```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia
source ~/.zshrc

# Vérifier que le S25 est connecté via WiFi
flutter devices

# Mettre à jour l'app
flutter run --release -d 192.168.129.46:5555
```

### **Méthode 2 : Via le script**

```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia
source ~/.zshrc

# Reconnecter si nécessaire
./connect_wifi_adb.sh reconnect

# Mettre à jour l'app
flutter run --release -d 192.168.129.46:5555
```

---

## 🔄 **SI LA CONNEXION WiFi EST PERDUE**

### **Option 1 : Reconnecter automatiquement**

```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia
source ~/.zshrc
./connect_wifi_adb.sh reconnect
```

### **Option 2 : Reconnecter manuellement**

```bash
source ~/.zshrc
adb connect 192.168.129.46:5555
```

---

## ⚠️ **IMPORTANT**

### **Conditions pour que le WiFi fonctionne :**

1. ✅ Le S25 et le Mac sont sur le **même réseau WiFi**
2. ✅ Le S25 est **allumé et déverrouillé**
3. ✅ Le débogage USB était activé au moins une fois (déjà fait ✅)

### **Si l'IP WiFi change :**

Si vous changez de réseau WiFi, l'IP peut changer. Dans ce cas :

1. **Branchez le S25 une fois** via USB
2. Trouvez la nouvelle IP :
   ```bash
   adb shell "ip addr show wlan0 | grep 'inet ' | awk '{print \$2}' | cut -d/ -f1"
   ```
3. Configurez à nouveau :
   ```bash
   adb tcpip 5555
   adb connect NOUVELLE_IP:5555
   ```

---

## 📋 **COMMANDES RAPIDES**

### **Vérifier les appareils connectés :**
```bash
source ~/.zshrc
adb devices
flutter devices
```

### **Mettre à jour l'app :**
```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia
source ~/.zshrc
flutter run --release -d 192.168.129.46:5555
```

### **Reconnecter via WiFi :**
```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia
source ~/.zshrc
adb connect 192.168.129.46:5555
```

---

## 🎯 **RÉSUMÉ**

✅ **Configuration terminée**  
✅ **IP sauvegardée** : `192.168.129.46`  
✅ **Port** : `5555`  
✅ **Vous pouvez débrancher le câble USB**  

**Pour mettre à jour l'app** :
```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia
source ~/.zshrc
flutter run --release -d 192.168.129.46:5555
```

---

**Dernière mise à jour** : 19 novembre 2025

