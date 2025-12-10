# 📦 Branches Backup - Arkalia CIA

**Date** : 10 décembre 2025  
**Statut** : ✅ **Backup v1.3.1 créé**

---

## 📊 BRANCHES BACKUP EXISTANTES

| Branche | Version | Statut | Dernière mise à jour |
|---------|---------|--------|---------------------|
| `backup/v1.3.0` | 1.3.0 | ⚠️ Ancien | 0d851a8 (119 commits en retard) |
| `backup/v1.3.1` | 1.3.1+5 | ✅ À jour | 64272dc (même niveau que develop) |

---

## 🎯 STRATÉGIE BACKUP

### Quand créer une branche backup ?

**Créer une branche backup quand** :
- ✅ Version stable publiée
- ✅ Version majeure (1.3.0 → 1.3.1)
- ✅ Avant changements majeurs

### Naming Convention

**Format** : `backup/v{MAJOR}.{MINOR}.{PATCH}`

**Exemples** :
- `backup/v1.3.0` - Version 1.3.0
- `backup/v1.3.1` - Version 1.3.1
- `backup/v2.0.0` - Version 2.0.0 (future)

---

## ✅ BACKUP v1.3.1

### Création

**Date** : 10 décembre 2025  
**Commit** : 64272dc  
**Niveau** : Même niveau que `develop` et `main`

**Contenu** :
- ✅ Authentification PIN web (PWA)
- ✅ PWA déployée sur GitHub Pages
- ✅ Nettoyage références Play Store
- ✅ Documentation complète
- ✅ Tests passent (16 tests PinAuthService)

### Utilisation

**Pour restaurer la version 1.3.1** :
```bash
git checkout backup/v1.3.1
```

**Pour créer une nouvelle branche depuis le backup** :
```bash
git checkout backup/v1.3.1
git checkout -b feature/nouvelle-fonctionnalite
```

---

## 📋 MAINTENANCE

### Synchronisation

**Les branches backup ne sont PAS synchronisées automatiquement** avec `develop` ou `main`.

**Raison** : Les backups sont des **points de restauration fixes** pour une version spécifique.

**Si tu veux mettre à jour un backup** (rare) :
```bash
git checkout backup/v1.3.1
git merge develop --no-edit
git push origin backup/v1.3.1
```

**⚠️ Attention** : Mettre à jour un backup change sa nature (ce n'est plus un point fixe).

---

## 🔄 WORKFLOW RECOMMANDÉ

### Création d'un nouveau backup

1. **Vérifier la version** dans `arkalia_cia/pubspec.yaml`
2. **Vérifier si backup existe** : `git branch -a | grep backup`
3. **Créer le backup** :
   ```bash
   git checkout develop
   git checkout -b backup/v1.3.1
   git push -u origin backup/v1.3.1
   ```
4. **Retourner sur develop** : `git checkout develop`

---

## 📊 RÉSUMÉ

| Action | Statut |
|--------|--------|
| Backup v1.3.0 | ✅ Existe (ancien, conservé) |
| Backup v1.3.1 | ✅ Créé (10 décembre 2025) |
| Synchronisation | ✅ Même niveau que develop |

---

**Date** : 10 décembre 2025

