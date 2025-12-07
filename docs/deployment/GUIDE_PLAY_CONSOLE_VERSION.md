# Guide : Gérer les Versions sur Google Play Console

**Date** : 7 décembre 2025  
**Version app** : 1.3.1 (version code auto-incrémenté)

---

## 🎯 Problème : L'app n'est pas disponible après upload

### Causes possibles

1. **Délai de synchronisation normal** : 2-4 heures (parfois jusqu'à 24h)
2. **Version incorrecte** : Le versionCode ou versionName ne correspond pas
3. **Problème de signature** : L'app n'est pas signée correctement
4. **Statut de publication** : L'app n'est pas en statut "Publié"
5. **Problème de track** : L'app est sur un track qui n'est pas accessible

---

## ✅ Vérification 1 : Configuration de Version Locale

### Vérifier `pubspec.yaml`

```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia
cat pubspec.yaml | grep version
```

**Attendu** : `version: 1.3.1+XXXXX` (où XXXXX est un timestamp)
- `1.3.1` = versionName (affichée aux utilisateurs)
- `XXXXX` = versionCode (auto-incrémenté avec timestamp YYMMDDHHMM)

### Vérifier le build.gradle.kts

Le fichier `android/app/build.gradle.kts` doit utiliser les valeurs de Flutter :

```kotlin
versionCode = flutter.versionCode  // Doit être 1
versionName = flutter.versionName  // Doit être "1.3.1"
```

**⚠️ IMPORTANT** : Le fichier `init.gradle` contient des valeurs par défaut (`versionCode: 1, versionName: "1.0.0"`), mais elles ne sont utilisées que si Flutter ne fournit pas les valeurs. Normalement, Flutter les écrase avec celles de `pubspec.yaml`.

---

## ✅ Vérification 2 : Sur Google Play Console

### Étape 1 : Vérifier la Version Uploadée

1. Aller sur [Google Play Console](https://play.google.com/console)
2. Sélectionner l'app **Arkalia CIA**
3. Aller dans **Production** → **Versions** (ou **Tests internes** → **Versions**)
4. Vérifier la version affichée :
   - **Version** : Doit être `1.3.1`
   - **Code de version** : Doit être `1`

### Étape 2 : Vérifier le Statut

Dans la liste des versions, vérifier la colonne **Statut** :
- ✅ **Publié** : L'app devrait être disponible
- ⏸️ **En attente de publication** : Normal, peut prendre 2-4h
- ❌ **Rejeté** : Il y a un problème, voir les détails
- ⚠️ **Brouillon** : L'app n'est pas publiée, cliquer sur "Publier"

### Étape 3 : Vérifier le Track

Vérifier dans quel **track** l'app est publiée :
- **Production** : Disponible pour tous (après validation)
- **Tests internes** : Disponible uniquement pour les testeurs ajoutés
- **Tests fermés** : Disponible pour un groupe limité
- **Tests ouverts** : Disponible pour tous (bêta)

**Pour les tests internes** :
1. Aller dans **Tests internes** → **Testeurs**
2. Vérifier que les emails sont bien ajoutés
3. Vérifier que le lien de test est actif

---

## 🔧 Correction : Si la Version est Incorrecte

### Option 1 : Build Automatique (Recommandé) ✅

**Le version code est maintenant auto-incrémenté automatiquement !**

```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia
./scripts/build-release-clean.sh
```

Le script va :
1. ✅ Auto-incrémenter le version code avec un timestamp unique (YYMMDDHHMM)
2. ✅ Mettre à jour `pubspec.yaml` automatiquement
3. ✅ Builder l'App Bundle avec la nouvelle version
4. ✅ Garantir un version code toujours supérieur et unique

**Plus besoin de modifier manuellement le version code !**

### Option 2 : Changer la Version Name

Si tu veux changer la version affichée (ex: 1.3.1) :

```yaml
version: 1.3.1+2  # Nouvelle version + nouveau build number
```

**⚠️ RÈGLE IMPORTANTE** : Le `versionCode` (le nombre après `+`) doit **TOUJOURS** être supérieur à la version précédente. Google Play refuse les versions avec un code inférieur.

---

## 📱 Vérification 3 : Sur l'Appareil

### Pour les Tests Internes

1. **Vérifier que tu es connecté avec le bon compte Google** :
   - Le compte doit être dans la liste des testeurs
   - Aller dans **Paramètres** → **Compte Google** → Vérifier l'email

2. **Utiliser le lien de test direct** :
   - Le lien devrait être : `https://play.google.com/apps/internaltest/...`
   - Ouvrir ce lien sur l'appareil Android
   - Cliquer sur "Devenir testeur" si nécessaire

3. **Vider le cache du Play Store** :
   - Aller dans **Paramètres** → **Applications** → **Google Play Store**
   - **Vider le cache** et **Vider les données**
   - Redémarrer le Play Store

4. **Attendre 2-4 heures** après la publication

### Pour la Production

- L'app sera disponible pour tous après validation Google (peut prendre 1-3 jours pour une nouvelle app)
- Vérifier le statut dans **Production** → **Statut de l'app**

---

## 🚨 Problèmes Courants et Solutions

### Problème 1 : "L'app n'apparaît pas dans le Play Store"

**Solutions** :
1. Vérifier que tu es sur le bon track (Tests internes vs Production)
2. Vérifier que tu es connecté avec le bon compte Google
3. Attendre 2-4 heures (délai de synchronisation)
4. Vérifier que l'app est bien "Publiée" (pas en brouillon)

### Problème 2 : "Erreur : versionCode déjà utilisé"

**Solution** :
- ✅ **Automatique** : Utiliser `./scripts/build-release-clean.sh` qui auto-incrémente le version code
- Le script détecte automatiquement les conflits et génère un version code unique
- Si deux builds sont faits dans la même minute, le script incrémente de +1 automatiquement

### Problème 3 : "L'app est rejetée"

**Solution** :
1. Aller dans **Production** → **Versions** → Voir les détails
2. Lire les raisons du rejet
3. Corriger les problèmes
4. Uploader une nouvelle version avec un `versionCode` incrémenté

### Problème 4 : "Signature invalide"

**Solution** :
1. Vérifier que `key.properties` existe et est correct
2. Vérifier que le keystore est le même que celui utilisé précédemment
3. Rebuild avec la bonne signature

---

## 📝 Checklist Avant Upload

- [ ] Version dans `pubspec.yaml` est correcte
- [ ] `versionCode` est supérieur à la version précédente
- [ ] Build App Bundle réussi sans erreur
- [ ] App Bundle signé correctement
- [ ] Tous les tests passent
- [ ] Aucune erreur de lint
- [ ] Notes de version complétées sur Play Console
- [ ] Track sélectionné (Tests internes ou Production)

---

## 🔄 Processus Complet de Re-Upload

Si tu dois refaire un upload avec une nouvelle version :

```bash
# 1. Build automatique (version code auto-incrémenté)
cd /Volumes/T7/arkalia-cia/arkalia_cia
./scripts/build-release-clean.sh

# Le script fait tout automatiquement :
# - Auto-incrémente le version code (timestamp YYMMDDHHMM)
# - Met à jour pubspec.yaml
# - Nettoie et build l'App Bundle
# - Vérifie la signature

# 2. Vérifier que le fichier existe
ls -lh build/app/outputs/bundle/release/app-release.aab

# 3. Uploader sur Play Console
# (Via l'interface web : Tests internes → Créer une version)
```

**Note** : Le version code est maintenant géré automatiquement, plus besoin de l'incrémenter manuellement !

---

## 📞 Support

Si le problème persiste après 24 heures :
1. Vérifier les emails de Google Play Console (notifications)
2. Consulter la section **Aide** dans Play Console
3. Vérifier le statut de validation du compte développeur

---

**Dernière mise à jour** : 7 décembre 2025

