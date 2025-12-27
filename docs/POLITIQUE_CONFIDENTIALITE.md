# 🔐 Politique de Confidentialité - Arkalia CIA

**Version** : 1.0  
**Date** : 10 décembre 2025  
**Dernière mise à jour** : 10 décembre 2025

---

## 📋 1. INFORMATIONS GÉNÉRALES

**Arkalia CIA** ("nous", "notre", "l'application") s'engage à protéger votre vie privée et vos données personnelles.

Cette politique de confidentialité explique comment nous collectons, utilisons, stockons et protégeons vos informations lorsque vous utilisez notre application mobile.

---

## 🎯 2. PRINCIPES FONDAMENTAUX

### 2.1 Privacy by Design
- ✅ **100% Local-First** : Toutes vos données sont stockées localement sur votre appareil
- ✅ **Aucune collecte automatique** : Nous ne collectons aucune donnée sans votre consentement explicite
- ✅ **Chiffrement bout-en-bout** : Toutes les données sensibles sont chiffrées avec AES-256-GCM

### 2.2 Minimisation des Données
- Nous ne collectons que les données strictement nécessaires au fonctionnement de l'application
- Aucune donnée n'est partagée avec des tiers sans votre consentement explicite
- Vous pouvez supprimer toutes vos données à tout moment

---

## 📊 3. DONNÉES COLLECTÉES

### 3.1 Données Stockées Localement

L'application stocke les données suivantes **uniquement sur votre appareil** :

#### Documents Médicaux
- Fichiers PDF uploadés par vous
- Métadonnées extraites (date, médecin, type d'examen)
- Texte extrait pour recherche

#### Informations Santé
- Médecins et leurs coordonnées
- Consultations et rendez-vous
- Pathologies et suivis
- Médicaments et rappels
- Données d'hydratation

#### Paramètres
- Préférences utilisateur
- Configuration de l'application
- Tokens d'authentification (stockés de manière sécurisée)

### 3.2 Données Non Collectées

Nous **NE collectons PAS** :
- ❌ Données de localisation
- ❌ Identifiants publicitaires
- ❌ Données de navigation web
- ❌ Informations sur d'autres applications
- ❌ Données biométriques (stockées localement uniquement)

---

## 🔒 4. SÉCURITÉ DES DONNÉES

### 4.1 Chiffrement
- **Chiffrement AES-256-GCM** pour toutes les données sensibles
- **Clés stockées dans Keychain (iOS) / Keystore (Android)** avec protection matérielle
- **Chiffrement bout-en-bout** pour le partage familial

### 4.2 Authentification
- **Authentification PIN** (code PIN local sur web uniquement)
- **Authentification PIN** pour le web
- **Tokens JWT** avec rotation automatique et blacklist

### 4.3 Protection Runtime
- **Détection root/jailbreak** pour alerter en cas de compromission
- **Vérification d'intégrité** de l'application
- **Protection anti-tampering**

---

## 👨‍👩‍👧 5. PARTAGE FAMILIAL

### 5.1 Consentement Explicite
- ✅ **Consentement requis** avant tout partage
- ✅ **Choix document par document** : vous choisissez exactement ce qui est partagé
- ✅ **Révocable à tout moment** : vous pouvez arrêter le partage à tout moment

### 5.2 Sécurité du Partage
- **Chiffrement bout-en-bout** : chaque membre famille a sa propre clé
- **Audit log** : traçabilité de tous les accès
- **Permissions granulaires** : contrôle fin des accès

### 5.3 Données Partagées
Lors du partage familial, seules les données que vous **choisissez explicitement** sont partagées :
- Documents médicaux sélectionnés
- Informations de santé pertinentes
- Aucune donnée sensible non sélectionnée

---

## 🌐 6. INTÉGRATION PORTAILS SANTÉ

### 6.1 Portails Supportés
- **eHealth** (Belgique)
- **Andaman 7** (Belgique)
- **MaSanté** (Belgique)

### 6.2 Données Importées
- Les données importées depuis les portails santé sont stockées **localement uniquement**
- Aucune donnée n'est transmise à des tiers
- Vous pouvez supprimer les données importées à tout moment

### 6.3 Authentification OAuth
- Les tokens OAuth sont stockés **localement uniquement**
- Aucun token n'est partagé avec des tiers
- Refresh automatique des tokens pour sécurité

---

## 🔄 7. VOS DROITS (RGPD)

Conformément au RGPD, vous avez les droits suivants :

### 7.1 Droit d'Accès
- ✅ Accéder à toutes vos données stockées dans l'application
- ✅ Exporter vos données en format JSON/CSV/PDF

### 7.2 Droit de Rectification
- ✅ Modifier toutes vos données à tout moment
- ✅ Corriger les informations incorrectes

### 7.3 Droit à l'Oubli
- ✅ Supprimer toutes vos données
- ✅ Supprimer votre compte utilisateur
- ✅ Export avant suppression disponible

### 7.4 Droit à la Portabilité
- ✅ Exporter toutes vos données dans un format structuré
- ✅ Formats supportés : JSON, CSV, PDF

### 7.5 Droit d'Opposition
- ✅ Refuser le partage familial
- ✅ Désactiver les fonctionnalités optionnelles

### 7.6 Exercice de vos Droits
Pour exercer vos droits, contactez-nous à : **arkalia.luna.system@gmail.com**

---

## 📱 8. DONNÉES SUR APPAREILS MOBILES

### 8.1 Stockage Local
- Toutes les données sont stockées dans la base de données SQLite locale
- Chiffrement AES-256 pour données sensibles
- Aucune synchronisation cloud automatique

### 8.2 Synchronisation Optionnelle
- Si vous activez la synchronisation avec le backend :
  - Données chiffrées avant transmission
  - HTTPS obligatoire
  - Tokens d'authentification sécurisés
  - Vous pouvez désactiver la synchronisation à tout moment

---

## 🚫 9. PARTAGE AVEC DES TIERS

### 9.1 Aucun Partage Automatique
- ❌ **Aucune donnée** n'est partagée avec des tiers sans votre consentement
- ❌ **Aucune publicité** : l'application ne contient pas de publicité
- ❌ **Aucun tracking** : pas d'analyse d'utilisation

### 9.2 Partage Volontaire
- Partage familial : uniquement avec votre consentement explicite
- Export de données : vous contrôlez ce qui est exporté
- Portails santé : uniquement si vous vous connectez volontairement

---

## 🔐 10. SÉCURITÉ TECHNIQUE

### 10.1 Mesures de Sécurité
- ✅ Chiffrement AES-256-GCM
- ✅ Authentification PIN (web uniquement)
- ✅ Tokens JWT avec rotation
- ✅ Blacklist de tokens révoqués
- ✅ Audit log complet
- ✅ Validation stricte des entrées
- ✅ Protection contre injection SQL/XSS
- ✅ Rate limiting par utilisateur

### 10.2 Stockage Sécurisé
- **iOS** : Keychain avec protection matérielle
- **Android** : Keystore avec protection matérielle
- **Web** : FlutterSecureStorage avec fallback SharedPreferences

---

## 📅 11. CONSERVATION DES DONNÉES

### 11.1 Durée de Conservation
- Vos données sont conservées **tant que vous utilisez l'application**
- Vous pouvez supprimer vos données à tout moment
- Lors de la suppression du compte, toutes les données sont supprimées définitivement

### 11.2 Suppression
- Suppression immédiate sur l'appareil
- Suppression du backend (si synchronisation activée) dans les 30 jours
- Aucune copie de sauvegarde conservée

---

## 🔔 12. NOTIFICATIONS ET RAPPELS

### 12.1 Notifications Locales
- Les notifications sont générées **localement** sur votre appareil
- Aucune donnée n'est envoyée à des serveurs externes
- Vous pouvez désactiver les notifications à tout moment

### 12.2 Données de Rappels
- Les rappels sont stockés **localement uniquement**
- Intégration avec le calendrier système (optionnel)
- Aucune synchronisation avec des services externes

---

## 🌍 13. TRANSFERT INTERNATIONAL

### 13.1 Stockage Local
- Toutes les données sont stockées **localement sur votre appareil**
- Aucun transfert international de données
- Si synchronisation activée : données stockées dans l'UE (si backend hébergé en UE)

---

## 📝 14. MODIFICATIONS DE CETTE POLITIQUE

### 14.1 Notification des Changements
- Nous vous informerons de toute modification importante
- La date de dernière mise à jour est indiquée en haut de ce document
- Vous serez notifié dans l'application en cas de changement majeur

### 14.2 Acceptation
- L'utilisation de l'application implique l'acceptation de cette politique
- Vous pouvez refuser et supprimer l'application à tout moment

---

## 📧 15. CONTACT

Pour toute question concernant cette politique de confidentialité ou vos données :

**Email** : arkalia.luna.system@gmail.com  
**Sujet** : [CONFIDENTIALITÉ] Votre question

---

## ✅ 16. CONFORMITÉ

### 16.1 RGPD
- ✅ Conforme au Règlement Général sur la Protection des Données (RGPD)
- ✅ Tous les droits RGPD respectés
- ✅ Traçabilité complète via audit log

### 16.2 Standards de Sécurité
- ✅ OWASP Mobile Top 10
- ✅ OWASP API Security Top 10
- ✅ NIST Cybersecurity Framework

---

## 📋 17. RÉSUMÉ

**En bref** :
- ✅ Vos données sont **100% locales** sur votre appareil
- ✅ **Aucune collecte automatique** de données
- ✅ **Chiffrement fort** (AES-256-GCM)
- ✅ **Contrôle total** : vous choisissez ce qui est partagé
- ✅ **Conforme RGPD** : tous vos droits respectés
- ✅ **Transparence totale** : vous savez exactement ce qui est stocké

**Votre vie privée est notre priorité absolue.**

---

**Dernière mise à jour** : 10 décembre 2025  
**Version** : 1.0
