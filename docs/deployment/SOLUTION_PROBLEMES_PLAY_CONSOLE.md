# Solution aux Problèmes Play Console

**Date** : 27 novembre 2025

---

## 🔴 Problème 1 : VersionCode Déjà Utilisé

### Erreur
```
Le code de version 1 a déjà été utilisé. Veuillez essayer un autre code de version.
```

### ✅ Solution Appliquée

La version a été incrémentée dans `pubspec.yaml` :
- **Avant** : `version: 1.3.0+1`
- **Après** : `version: 1.3.0+2`

### Prochaines Étapes

1. **Rebuilder l'App Bundle** :
```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia
./scripts/build-release-clean.sh
```

2. **Uploader la nouvelle version** sur Play Console (versionCode sera maintenant 2)

---

## 🔴 Problème 2 : Politique de Confidentialité Manquante

### Erreur
```
Votre fichier APK ou application Android utilise des autorisations qui nécessitent une politique de confidentialité : (android.permission.READ_CONTACTS)
```

### ✅ Solution : Héberger la Politique de Confidentialité

Tu as deux options :

#### Option 1 : GitHub Pages (Recommandé - Gratuit et Simple)

1. **Créer un fichier HTML** à partir de `PRIVACY_POLICY.txt` :
```bash
cd /Volumes/T7/arkalia-cia
# Le fichier PRIVACY_POLICY.txt existe déjà
```

2. **Créer un dépôt GitHub Pages** (ou utiliser le dépôt existant) :
   - Aller sur https://github.com/arkalia-luna-system/arkalia-cia
   - Créer un fichier `docs/privacy-policy.html` ou `privacy-policy.html`
   - Copier le contenu de `PRIVACY_POLICY.txt` dans le HTML
   - Activer GitHub Pages dans les paramètres du dépôt
   - L'URL sera : `https://arkalia-luna-system.github.io/arkalia-cia/privacy-policy.html`

3. **Alternative simple** : Créer un fichier Markdown et utiliser GitHub pour l'afficher :
   - Créer `docs/PRIVACY_POLICY.md`
   - GitHub l'affichera automatiquement à : `https://github.com/arkalia-luna-system/arkalia-cia/blob/main/docs/PRIVACY_POLICY.md`

#### Option 2 : Service d'Hébergement Simple

- **GitHub Gist** : https://gist.github.com (gratuit, URL permanente)
- **Pastebin** : https://pastebin.com (gratuit)
- **Notion** : Créer une page publique (gratuit)

---

## 📝 Instructions Complètes : GitHub Pages

### Étape 1 : Créer le Fichier HTML

```bash
cd /Volumes/T7/arkalia-cia
```

Créer un fichier `privacy-policy.html` à la racine du projet :

```html
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Politique de Confidentialité - Arkalia CIA</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            line-height: 1.6;
        }
        h1 { color: #0175C2; }
        h2 { color: #333; margin-top: 30px; }
    </style>
</head>
<body>
    <h1>Politique de Confidentialité - Arkalia CIA</h1>
    <p><strong>Dernière mise à jour :</strong> 17 novembre 2025</p>
    
    <!-- Copier le contenu de PRIVACY_POLICY.txt ici, en convertissant les sections en HTML -->
    <!-- Voir le fichier PRIVACY_POLICY.txt pour le contenu complet -->
</body>
</html>
```

### Étape 2 : Push sur GitHub

```bash
git add privacy-policy.html
git commit -m "docs: Ajouter politique de confidentialité HTML"
git push origin main
```

### Étape 3 : Activer GitHub Pages

1. Aller sur https://github.com/arkalia-luna-system/arkalia-cia/settings/pages
2. Activer GitHub Pages
3. Sélectionner la branche `main` et le dossier `/ (root)`
4. L'URL sera : `https://arkalia-luna-system.github.io/arkalia-cia/privacy-policy.html`

### Étape 4 : Ajouter l'URL dans Play Console

1. Aller sur [Google Play Console](https://play.google.com/console)
2. Sélectionner **Arkalia CIA**
3. Aller dans **Politique** → **Politique de confidentialité**
4. Ajouter l'URL : `https://arkalia-luna-system.github.io/arkalia-cia/privacy-policy.html`
5. Sauvegarder

---

## 🚀 Solution Rapide (Sans GitHub Pages)

Si tu veux une solution immédiate sans configurer GitHub Pages :

### Option : Utiliser GitHub Raw

1. **Créer un fichier Markdown** :
```bash
cd /Volumes/T7/arkalia-cia
cp PRIVACY_POLICY.txt docs/PRIVACY_POLICY.md
git add docs/PRIVACY_POLICY.md
git commit -m "docs: Ajouter politique de confidentialité"
git push origin main
```

2. **Utiliser l'URL GitHub** :
   - URL : `https://raw.githubusercontent.com/arkalia-luna-system/arkalia-cia/main/PRIVACY_POLICY.txt`
   - Ou mieux : `https://github.com/arkalia-luna-system/arkalia-cia/blob/main/PRIVACY_POLICY.txt`

3. **Ajouter dans Play Console** :
   - Play Console → Politique → Politique de confidentialité
   - Coller l'URL GitHub

**Note** : Google Play préfère les URLs HTTPS avec un contenu HTML formaté, mais GitHub Markdown peut fonctionner.

---

## ✅ Checklist Finale

- [ ] Version incrémentée dans `pubspec.yaml` (1.3.0+2) ✅
- [ ] Rebuild App Bundle avec nouvelle version
- [ ] Héberger la politique de confidentialité (GitHub Pages ou autre)
- [ ] Ajouter l'URL dans Play Console → Politique
- [ ] Uploader la nouvelle version (versionCode 2)
- [ ] Vérifier que les deux problèmes sont résolus

---

## 📞 En Cas de Problème

Si Google Play refuse l'URL GitHub :
1. Utiliser un service d'hébergement web simple (GitHub Pages recommandé)
2. Vérifier que l'URL est accessible publiquement (sans authentification)
3. Vérifier que l'URL utilise HTTPS

---

**Dernière mise à jour** : 27 novembre 2025

