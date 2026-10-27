# Vision Écosystème Arkalia Luna System

**Version** : 1.1.0  
**Date** : 27 octobre 2026  
**Statut** : Vision stratégique (CIA + ARIA)

---

## 🎯 Vue d'ensemble

**Arkalia Luna System** est un écosystème modulaire de santé personnelle centré sur le **patient et sa famille**, contrairement aux solutions existantes souvent centrées sur les professionnels de santé ou les institutions.

### Principe Fondamental

> **"L'utilisateur contrôle totalement ses données, avec des outils qui travaillent pour lui, pas contre lui."**

---

## 🏗️ Architecture Modulaire

### Les deux piliers actifs

```mermaid
graph TB
    subgraph "Esprit & Santé"
        A[CIA<br/>Conversational Intelligence Assistant]
        B[ARIA<br/>Arkalia Research Intelligence Assistant]
    end

    A <-->|Sync Health Data| B

    A --> D[Documents<br/>Rappels<br/>Urgences]
    B --> E[Douleur<br/>Patterns<br/>Métriques]
```

### Positionnement de chaque composant

| Composant | Rôle | Métaphore | Données |
|-----------|------|-----------|---------|
| **CIA** | Assistant santé généraliste | "Coffre-fort santé" | Documents médicaux, rappels, contacts urgence, agrégats |
| **ARIA** | Laboratoire personnel | "Microscope douleur/mental" | Données douleur fine-grain, patterns psychologiques, métriques |

---

## 🔄 Flux de Données

### CIA ↔ ARIA (Intégration principale)

**CIA → ARIA** (Données agrégées) :
- Documents médicaux pertinents (extraits, métadonnées)
- Dates de consultations
- Médicaments prescrits
- Examens réalisés

**Pourquoi** : ARIA peut corréler les douleurs avec les événements médicaux

**ARIA → CIA** (Données fines) :
- Enregistrements douleur (intensité, localisation, contexte)
- Patterns détectés (corrélations, saisonnalité, tendances)
- Métriques santé (sommeil, activité, stress)

**Pourquoi** : Enrichir l'IA conversationnelle de CIA, préparer rapports médicaux

**Exemple concret** :
```
Scénario : Avant un RDV médical
1. ARIA détecte pattern : "Douleur ↑ 40% les jours où sommeil <6h"
2. ARIA envoie cette info à CIA
3. CIA génère rapport combinant :
   - Documents médicaux (CIA)
   - Timeline douleur 30 jours (ARIA)
   - Patterns détectés (ARIA)
   - Résumé consultations (CIA)
4. Médecin reçoit document structuré au lieu de "je ne sais pas trop"
```

---

## 🎯 Avantages Concurrentiels

### Comparaison avec solutions existantes

| Aspect | Solutions Existantes | Arkalia Luna System |
|--------|---------------------|---------------------|
| **Cible** | Professionnels médicaux / Hôpitaux | **Patient + Famille** (personnalisé) |
| **UX** | Complexe, technique | **Ultra-simple, senior-friendly** |
| **Contrôle** | Institutionnel | **Utilisateur contrôle total** |
| **Local-First** | Souvent cloud obligatoire | **100% local, optionnel cloud** |
| **Partage Familial** | Limité | **Contrôle granulaire complet** |
| **Modularité** | Monolithique | **Architecture modulaire** (CIA / ARIA) |
| **Innovation** | Centré institution | **Dossier Patient IA centré patient/famille** |

### Innovation clé

✅ **"Dossier Patient IA centré patient/famille"** — rare et innovant.

La plupart des solutions santé sont conçues pour les professionnels. Arkalia inverse cette logique : **l'utilisateur est au centre**, avec des outils qui l'aident à comprendre et gérer sa santé.

---

## 📊 Matrice de Fonctionnalités

| Fonctionnalité | CIA | ARIA |
|----------------|-----|------|
| **Documents médicaux** | ✅ Principal | ⚠️ Contexte |
| **Rappels santé** | ✅ Principal | ❌ |
| **Contacts urgence** | ✅ Principal | ❌ |
| **Suivi douleur** | ⚠️ Agrégats | ✅ Principal |
| **Patterns psychologiques** | ⚠️ Contexte | ✅ Principal |
| **Métriques santé** | ⚠️ Contexte | ✅ Principal |
| **IA conversationnelle** | ✅ Principal | ⚠️ Enrichissement |
| **Export médical** | ✅ Principal | ⚠️ Données fines |

**Légende** :
- ✅ **Principal** : Fonctionnalité principale du composant
- ⚠️ **Contexte/Support** : Utilisé pour enrichir ou supporter
- ❌ **Non applicable** : Pas dans le scope du composant

---

## 🚀 Roadmap Écosystème

### Phase actuelle

**CIA** :
- ✅ Modules base (documents, santé, rappels, urgence)
- ✅ Intégration ARIA basique
- ✅ Interface senior-friendly
- ✅ Sécurité AES-256

**ARIA** :
- ✅ Tracking douleur
- ✅ Patterns détectés
- ✅ Métriques santé
- ✅ Sync CIA ↔ ARIA

### Suite prévue

**CIA** :
- 🔄 Génération automatique rapports médicaux avec contexte ARIA
- 🔄 Partage familial sécurisé
- 🔄 Import données externes (Andaman 7, MaSanté)

**ARIA** :
- 🔄 Modèles ML avancés pour prédiction
- 🔄 Export multi-format (PDF, CSV, JSON)
- 🔄 Anonymisation pour partage

**Écosystème** :
- 📋 Dashboard unifié famille
- 📋 API publique pour intégrations externes

---

## 🔐 Principes de Sécurité et Confidentialité

### Local-First

**Principe** : Toutes les données restent sur l'appareil de l'utilisateur par défaut

- **CIA** : Stockage local chiffré AES-256
- **ARIA** : Base de données locale, pas de cloud obligatoire

### Consentement explicite

**Principe** : Aucune synchronisation automatique sans consentement

- L'utilisateur doit **activer explicitement** chaque intégration
- L'utilisateur peut **choisir quelles données** partager
- L'utilisateur peut **désactiver** à tout moment

### Contrôle granulaire

**Exemple** :
```dart
ARIAIntegrationSettings(
  enabled: true,  // L'utilisateur a activé
  sharePainRecords: true,  // Partager entrées douleur
  sharePatterns: true,  // Partager patterns
  shareHealthMetrics: false,  // Ne pas partager métriques
  anonymizeForExport: true,  // Anonymiser pour export
)
```

---

## 📈 Vision long terme

### Écosystème cible

```
┌─────────────────────────────────────────────────────────┐
│        Arkalia Luna System                              │
└─────────────────────────────────────────────────────────┘
                            │
              ┌─────────────┴─────────────┐
              │                           │
          ┌───▼───┐                   ┌───▼───┐
          │  CIA  │◄─────────────────►│ ARIA  │
          │ Docs  │  Health Data Sync │ Pain  │
          │ Remind│                   │Pattern│
          └───┬───┘                   └───┬───┘
              └─────────────┬─────────────┘
                            │
                    ┌───────▼────────┐
                    │ Unified        │
                    │ Dashboard      │
                    │ Family View    │
                    └────────────────┘
```

### Objectifs

1. **Synchronisation CIA ↔ ARIA** robuste et consentie
2. **Dashboard unifié** pour vue d'ensemble famille
3. **API publique** pour intégrations tierces (si besoin)
4. **Communauté open source** active

---

## 🔗 Voir aussi

### Documentation CIA
- **[README.md](../../README.md)** — Vue d'ensemble du projet CIA
- **[ARIA_INTEGRATION.md](./ARIA_INTEGRATION.md)** — Détails intégration CIA ↔ ARIA
- **[ARCHITECTURE.md](../ARCHITECTURE.md)** — Architecture technique
- **[VUE_ENSEMBLE_PROJET.md](../VUE_ENSEMBLE_PROJET.md)** — Vue d'ensemble visuelle

### Documentation projets liés
- **[README ARIA](https://github.com/arkalia-luna-system/arkalia-aria/blob/main/README.md)** — Vue d'ensemble ARIA

---

**Dernière mise à jour** : 27 octobre 2026  
**Maintenu par** : Arkalia Luna System
