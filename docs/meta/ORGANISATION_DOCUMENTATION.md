# 📚 ORGANISATION DOCUMENTATION - 27 novembre 2025

**Objectif** : Organiser et nettoyer les 122 fichiers MD pour améliorer la maintenabilité

---

## 📊 ÉTAT ACTUEL

- **Total fichiers MD** : 122 fichiers
- **Fichiers macOS cachés** : ~700 fichiers `._*` et `.!*!._*` (à supprimer)
- **Doublons identifiés** : Plusieurs fichiers avec contenu similaire

---

## 🔍 DOUBLONS IDENTIFIÉS

### Audits
- `docs/AUDIT_COMPLET_26_NOVEMBRE.md` (229 lignes)
- `docs/audits/AUDIT_COMPLET_PROJET_2025.md` (319 lignes)
- `docs/audits/AUDIT_FINAL_26_NOVEMBRE_2025.md` (339 lignes)
- **Action** : Fusionner en un seul fichier `docs/audits/AUDIT_COMPLET_27_NOVEMBRE_2025.md`

### Statuts
- `docs/STATUT_ACTUEL_26_NOVEMBRE.md` (146 lignes) - **GARDE** (statut actuel)
- `docs/STATUT_FINAL_PROJET.md` (inconnu) - **VÉRIFIER** si redondant
- `docs/audits/STATUT_CORRECTIONS.md` (inconnu) - **VÉRIFIER** si redondant
- **Action** : Garder `STATUT_ACTUEL_27_NOVEMBRE.md` comme référence principale

### Corrections
- `docs/CORRECTIONS_AUDIT_CONSOLIDEES.md` (inconnu)
- `docs/CORRECTIONS_CONSOLIDEES.md` (inconnu)
- **Action** : Fusionner en un seul fichier

---

## 📁 STRUCTURE PROPOSÉE

```
docs/
├── README.md (index principal)
├── CHANGELOG.md
├── CONTRIBUTING.md
├── ARCHITECTURE.md
├── API_DOCUMENTATION.md
│
├── guides/              # Guides utilisateur
│   ├── POUR_MAMAN.md
│   ├── GUIDE_TESTEURS.md
│   └── GUIDE_UTILISATION_MERE.md
│
├── deployment/          # Déploiement
│   ├── BUILD_RELEASE_ANDROID.md
│   ├── PLAY_STORE_SETUP.md
│   └── GUIDE_DEPLOIEMENT_FINAL.md
│
├── audits/              # Audits et analyses
│   ├── AUDIT_COMPLET_27_NOVEMBRE_2025.md (fusionné)
│   ├── AUDITS_CONSOLIDES.md
│   └── ANALYSES_CONSOLIDEES.md
│
├── troubleshooting/     # Dépannage
│   ├── GRADLE_FIX_GUIDE.md
│   └── SOLUTION_FICHIERS_MACOS.md
│
├── plans/               # Plans d'implémentation
│   └── ...
│
└── archive/             # Fichiers obsolètes
    └── old_status/
```

---

## ✅ ACTIONS À FAIRE

### Phase 1 : Nettoyage (1 heure)
- [ ] Supprimer tous les fichiers macOS cachés (`._*`, `.!*!._*`)
- [ ] Identifier les fichiers vraiment redondants
- [ ] Créer le dossier `archive/` pour fichiers obsolètes

### Phase 2 : Fusion (1 heure)
- [ ] Fusionner les audits en un seul fichier
- [ ] Fusionner les corrections en un seul fichier
- [ ] Garder seulement les fichiers les plus récents

### Phase 3 : Organisation (30 minutes)
- [ ] Déplacer les fichiers dans la bonne structure
- [ ] Mettre à jour les liens dans les fichiers MD
- [ ] Créer un README.md dans docs/ avec index

---

## 📋 FICHIERS À GARDER (Prioritaires)

### Essentiels
- `README.md` (racine)
- `CHANGELOG.md`
- `CONTRIBUTING.md`
- `ARCHITECTURE.md`
- `API_DOCUMENTATION.md`

### Guides
- `POUR_MAMAN.md`
- `GUIDE_TESTEURS.md`
- `GUIDE_DEPLOIEMENT_FINAL.md`

### Audits (fusionnés)
- `audits/AUDIT_COMPLET_27_NOVEMBRE_2025.md` (à créer)
- `audits/AUDITS_CONSOLIDES.md`

### Statut
- `STATUT_ACTUEL_27_NOVEMBRE.md` (mis à jour)

---

## 🗑️ FICHIERS À ARCHIVER

- Fichiers avec dates anciennes (20 novembre, 23 novembre)
- Fichiers redondants identifiés
- Fichiers de brouillon

---

**Dernière mise à jour** : 27 novembre 2025

