# 🔥 Solution Surchauffe RAM

**Date** : 24 novembre 2025  
**Problème** : RAM surchauffe, Mac lent

---

## 🔍 DIAGNOSTIC

### Processus qui consomment le plus :

1. **Cursor Helper (Renderer)** - PID 1092
   - **CPU** : 96.9%
   - **RAM** : 2.1 GB (13.1%)
   - **Problème** : Trop d'onglets ouverts ou extension qui bug

2. **mds_stores** (indexation macOS)
   - **CPU** : 78.8%
   - **Problème** : Indexation en cours (normal mais peut être lourd)

3. **Flutter** - Plusieurs processus
   - **Problème** : Processus orphelins qui tournent encore

---

## ✅ SOLUTIONS RAPIDES

### Solution 1 : Nettoyer les processus du projet (RECOMMANDÉ)

```bash
cd /Volumes/T7/arkalia-cia
./scripts/fix_ram_overheat.sh
```

Ce script :
- ✅ Nettoie tous les processus Flutter orphelins
- ✅ Nettoie tous les processus pytest
- ✅ Nettoie tous les processus du projet
- ✅ Purge les caches
- ✅ Affiche les statistiques

---

### Solution 2 : Nettoyer manuellement

```bash
cd /Volumes/T7/arkalia-cia
./scripts/cleanup_all.sh --all
```

---

### Solution 3 : Redémarrer Cursor (si Cursor consomme trop)

1. **Sauvegarder ton travail**
2. **Quitter Cursor** complètement (Cmd+Q)
3. **Attendre 10 secondes**
4. **Rouvrir Cursor**

**Pourquoi ?** : Cursor Helper (Renderer) consomme 2.1 GB RAM et 96.9% CPU. C'est probablement un onglet ou une extension qui bug.

---

### Solution 4 : Fermer des onglets dans Cursor/Comet

Si tu as beaucoup d'onglets ouverts :
- Ferme les onglets inutiles
- Ferme les fichiers très gros
- Ferme les previews de markdown

---

### Solution 5 : Attendre que mds_stores termine

`mds_stores` est l'indexation macOS. C'est normal qu'il consomme beaucoup au début, mais ça devrait se calmer après quelques minutes.

**Si ça dure trop longtemps** (>30 min) :
```bash
sudo mdutil -a -i off  # Désactiver l'indexation
sudo mdutil -a -i on   # Réactiver l'indexation
```

---

## 🚨 URGENT : Si le Mac est vraiment lent

1. **Fermer toutes les applications inutiles**
2. **Redémarrer le Mac** (solution radicale mais efficace)
3. **Vérifier l'activité** : Applications → Utilitaires → Moniteur d'activité

---

## 📊 VÉRIFIER L'ÉTAT ACTUEL

```bash
# Voir les processus les plus lourds
ps aux | sort -rk 4,4 | head -10

# Voir la RAM utilisée
ps aux | awk '{sum+=$4} END {print "RAM: " sum "%"}'

# Voir le CPU utilisé
ps aux | awk '{sum+=$3} END {print "CPU: " sum "%"}'
```

---

## 🔧 PRÉVENTION

Pour éviter que ça se reproduise :

1. **Utiliser les scripts "safe"** :
   - `./scripts/start_backend_safe.sh` (au lieu de `start_backend.sh`)
   - `./scripts/start_flutter_safe.sh` (au lieu de `start_flutter.sh`)

2. **Nettoyer régulièrement** :
   ```bash
   ./scripts/cleanup_all.sh
   ```

3. **Fermer les processus Flutter** quand tu n'en as plus besoin :
   ```bash
   ./scripts/cleanup_all.sh
   ```

---

## 💡 ASTUCE

Si Cursor consomme toujours trop après redémarrage :
- Désactiver les extensions inutiles
- Réduire le nombre d'onglets ouverts
- Fermer les previews markdown

---

*Dernière mise à jour : 24 novembre 2025*

