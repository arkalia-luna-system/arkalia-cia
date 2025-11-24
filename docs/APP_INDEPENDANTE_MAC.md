# Application iOS indépendante du Mac

**Version** : 1.3.0  
**Date** : 24 novembre 2025  
**Plateforme** : iOS

---

## Réponse rapide

**Oui !** Une fois l'application installée sur votre iPad/iPhone, vous pouvez **déconnecter l'appareil du Mac** et l'application fonctionnera normalement !

---

## Fonctionnement

### Pendant l'installation

| Exigence | Statut |
|----------|--------|
| **iPad/iPhone connecté** au Mac via USB | ✅ Requis |
| **Xcode/Flutter** installe l'application | ✅ Automatique |
| **L'application se lance** automatiquement | ✅ Oui |

### Après l'installation

| Fonctionnalité | Statut |
|----------------|--------|
| **Déconnecter l'iPad** du Mac | ✅ Autorisé |
| **L'application fonctionne indépendamment** | ✅ Oui |
| **Utilisation normale** sur l'iPad | ✅ Oui |
| **Toutes les fonctionnalités fonctionnent** sans Mac | ✅ Oui |

---

## Durée de validité de l'application

### Compte Apple ID gratuit

- Application fonctionne pendant **7 jours**
- Après 7 jours, l'application expire et ne se lancera plus
- **Pour continuer** : Reconnecter l'iPad et relancer depuis Xcode/Flutter

### Compte développeur payant (100 €/an)

- Application fonctionne **indéfiniment**
- Pas besoin de reconnecter après 7 jours
- Aucun problème d'expiration

> **Note** : Voir [deployment/IOS_DEPLOYMENT_GUIDE.md](deployment/IOS_DEPLOYMENT_GUIDE.md) pour les détails sur les comptes gratuits vs payants.

---

## Mise à jour de l'application

Si vous modifiez le code et souhaitez mettre à jour l'application sur votre iPad :

### Méthode 1 : Depuis Xcode (Recommandé)

1. **Reconnecter l'iPad** au Mac via USB
2. **Dans Xcode**, cliquer sur **▶️ Play** (ou appuyer sur **Cmd+R**)
3. L'application se mettra à jour et se relancera automatiquement

### Méthode 2 : Depuis Flutter CLI

```bash
cd /Volumes/T7/arkalia-cia/arkalia_cia
flutter run
```

> **Note** : Vous pouvez déconnecter l'iPad après la fin de la mise à jour.

---

## Utilisation quotidienne

Une fois l'application installée :

### Ce que vous pouvez faire sans Mac

- Utiliser l'application normalement sur votre iPad
- Toutes les fonctionnalités fonctionnent :
  - Navigation dans l'application
  - Sauvegarde et stockage des données
  - Notifications
  - Toutes les fonctionnalités de l'application
- L'emporter partout - entièrement portable
- Utiliser hors ligne - pas besoin d'Internet pour les fonctionnalités principales

### Ce qui nécessite le Mac

- Installation initiale de l'application
- Mises à jour de l'application (après modifications du code)
- Renouvellement du certificat (après expiration de 7 jours avec compte gratuit)

---

## Tableau récapitulatif

| Action | Connexion Mac requise ? |
|--------|-------------------------|
| **Installer l'application** | ✅ Oui |
| **Utiliser l'application** | ❌ Non |
| **Mettre à jour l'application** | ✅ Oui |
| **Utiliser après installation** | ❌ Non |
| **Utilisation quotidienne** | ❌ Non |
| **Toutes les fonctionnalités** | ❌ Non |

---

## Notes importantes

### Expiration du certificat (Compte gratuit)

- Les certificats de développement expirent après **7 jours**
- L'application ne se lancera plus après expiration
- **Solution** : Reconnecter au Mac et relancer depuis Xcode/Flutter
- Ne prend que **2 minutes** pour renouveler

### Mises à jour de l'application

- Connexion Mac requise **uniquement** lors de la mise à jour du code
- Après la mise à jour, vous pouvez déconnecter immédiatement
- L'application continue de fonctionner indépendamment

### Persistance des données

- Toutes les données sont stockées localement sur l'appareil
- Aucune dépendance Mac pour l'accès aux données
- Fonctionne complètement hors ligne

---

## Cas d'usage

### Scénario 1 : Utilisation quotidienne

1. Installer l'application une fois (nécessite Mac)
2. Déconnecter l'iPad
3. Utiliser l'application normalement pendant 7 jours
4. Reconnecter pour renouveler (si utilisation d'un compte gratuit)

### Scénario 2 : Développement

1. Modifier le code
2. Reconnecter l'iPad au Mac
3. Mettre à jour l'application via Xcode/Flutter
4. Déconnecter et tester indépendamment

### Scénario 3 : Voyage

1. Installer l'application avant le voyage
2. Déconnecter du Mac
3. Utiliser l'application pendant le voyage (pas besoin de Mac)
4. Reconnecter après 7 jours si nécessaire

---

## Dépannage

### L'application ne se lance pas après déconnexion

**Causes possibles** :
1. Certificat expiré (limite de 7 jours avec compte gratuit)
2. Mode développeur désactivé
3. Certificat non approuvé

**Solutions** :
- Reconnecter au Mac et relancer depuis Xcode
- Vérifier que le mode développeur est activé
- Approuver le certificat dans Réglages (voir [troubleshooting/APPROUVER_CERTIFICAT_DEVELOPPEUR.md](troubleshooting/APPROUVER_CERTIFICAT_DEVELOPPEUR.md))

### L'application fonctionne mais pas les fonctionnalités

- Vérifier les permissions de l'application dans Réglages
- Vérifier que les données ont été sauvegardées avant la déconnexion
- Certaines fonctionnalités peuvent nécessiter une configuration initiale avec le Mac connecté

---

## Voir aussi

- [deployment/IOS_DEPLOYMENT_GUIDE.md](deployment/IOS_DEPLOYMENT_GUIDE.md) - Guide complet de déploiement iOS
- [troubleshooting/APPROUVER_CERTIFICAT_DEVELOPPEUR.md](troubleshooting/APPROUVER_CERTIFICAT_DEVELOPPEUR.md) - Guide d'approbation du certificat
- [INDEX_DOCUMENTATION.md](INDEX_DOCUMENTATION.md) - Index complet de la documentation

---

## Conclusion

**Une fois installée, l'application fonctionne complètement indépendamment du Mac !**

Vous pouvez :
- Déconnecter votre iPad
- Utiliser l'application normalement
- L'emporter partout
- L'utiliser sans Mac

**Le Mac n'est nécessaire que pour l'installation ou les mises à jour.**

---

**Pour toute question ou problème, consultez la section dépannage ou voir [deployment/IOS_DEPLOYMENT_GUIDE.md](deployment/IOS_DEPLOYMENT_GUIDE.md).**

