# 📱 INTÉGRATION ANDAMAN 7 ET MASANTÉ - GUIDE COMPLET

**Date** : 26 novembre 2025  
**Statut** : Import manuel uniquement (pas d'API publique)

---

## 📊 RÉSUMÉ EXÉCUTIF

### Andaman 7
- ❌ **Pas d'API publique** avec OAuth
- ❌ **Pas d'endpoints ouverts** pour apps tierces
- ✅ **Export manuel** : PDF, CSV, HL7, eHealth XML
- ⚠️ **Intégration automatique** : Uniquement via partenariat commercial (payant)

### MaSanté
- ❌ **Pas d'API publique** ou OAuth pour apps tierces
- ❌ **Pas d'endpoints** disponibles
- ✅ **Export manuel** : PDF, CSV depuis portail web
- ⚠️ **Intégration automatique** : Uniquement via convention institutionnelle

---

## 🔄 SOLUTION : IMPORT MANUEL + PARSING

### Workflow Utilisateur

1. **L'utilisateur exporte ses documents** depuis Andaman 7 ou MaSanté
2. **L'utilisateur upload le fichier** dans l'app Arkalia CIA
3. **Le backend parse le fichier** (PDF/CSV) et extrait les données
4. **Les données sont importées** dans la base de données

---

## 📋 IMPLÉMENTATION

### 1. Interface Utilisateur

**Écran d'import manuel** :
- Bouton "Importer depuis Andaman 7"
- Bouton "Importer depuis MaSanté"
- Instructions claires pour l'utilisateur
- Upload de fichier (PDF ou CSV)

### 2. Parsing Backend

**Fichiers à créer/modifier** :

- `arkalia_cia_python_backend/services/health_portal_parsers.py`
  - `parse_andaman7_pdf(file_path)` : Parser PDF Andaman 7
  - `parse_andaman7_csv(file_path)` : Parser CSV Andaman 7
  - `parse_masante_pdf(file_path)` : Parser PDF MaSanté
  - `parse_masante_csv(file_path)` : Parser CSV MaSanté

### 3. Endpoints Backend

**Nouveaux endpoints** :

- `POST /api/v1/health-portals/import/manual`
  - Body : `file` (PDF/CSV), `portal` (andaman7/masante)
  - Retourne : données parsées et importées

---

## 📄 FORMATS DE FICHIERS

### Andaman 7

**Export PDF** :
- Structure standardisée
- Tableaux de données (examens, médicaments, etc.)
- Dates formatées
- ⚠️ Format peut changer avec MAJ app

**Export CSV** :
- Colonnes : Date, Type, Description, Médecin, etc.
- Encodage UTF-8
- Séparateur : virgule ou point-virgule

**Export HL7** :
- Format standard HL7
- Structure complexe
- Nécessite parser HL7 spécialisé

**Export eHealth XML** :
- Format XML eHealth
- Structure standardisée
- Plus facile à parser que PDF

### MaSanté

**Export PDF** :
- Documents individuels
- Format variable selon type de document
- Dates et identifiants présents

**Export CSV** :
- Si disponible (à vérifier)
- Structure similaire à Andaman 7

---

## 🔧 PARSING PDF

### Stratégie

1. **Extraction texte** : Utiliser `pdf_processor.py` existant
2. **Recherche patterns** : Regex pour dates, médecins, types d'examens
3. **Extraction structurée** : Tables, listes, métadonnées
4. **Validation** : Vérifier cohérence des données

### Exemples de Patterns

```python
# Date
DATE_PATTERN = r'\d{2}[/-]\d{2}[/-]\d{4}'

# Médecin
DOCTOR_PATTERN = r'Dr\.?\s+[A-Z][a-z]+\s+[A-Z][a-z]+'

# Type examen
EXAM_PATTERN = r'(Analyse|IRM|Scanner|Radiographie|Échographie)'

# Résultats
RESULT_PATTERN = r'([A-Za-z]+)\s*:\s*([0-9.,]+)\s*([A-Za-z/]+)?'
```

---

## 🔧 PARSING CSV

### Stratégie

1. **Détection format** : Séparateur, encodage, en-têtes
2. **Mapping colonnes** : Identifier colonnes pertinentes
3. **Extraction données** : Parser chaque ligne
4. **Normalisation** : Format standardisé

### Exemple

```python
import csv
from datetime import datetime

def parse_andaman7_csv(file_path):
    documents = []
    with open(file_path, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            doc = {
                'name': row.get('Titre', row.get('Title', 'Document')),
                'date': parse_date(row.get('Date', '')),
                'type': row.get('Type', 'document'),
                'doctor': row.get('Médecin', row.get('Doctor', '')),
                'source': 'Andaman 7',
            }
            documents.append(doc)
    return documents
```

---

## ⚠️ POINTS D'ATTENTION

### 1. Format PDF Variable

- **Problème** : Format peut changer avec MAJ app
- **Solution** : Parser robuste avec fallbacks, tests réguliers

### 2. OCR pour PDF Scannés

- **Problème** : PDF scanné = image, pas de texte
- **Solution** : Utiliser OCR (Tesseract) si nécessaire

### 3. Validation Données

- **Problème** : Données parsées peuvent être incorrectes
- **Solution** : Validation stricte, permettre correction utilisateur

### 4. Consentement Utilisateur

- **Problème** : RGPD, consentement nécessaire
- **Solution** : Demander consentement explicite avant import

### 5. Volume de Données

- **Problème** : Fichiers volumineux
- **Solution** : Traitement asynchrone, progress bar

---

## 📋 CHECKLIST IMPLÉMENTATION

### Phase 1 : UI (1 semaine)

- [ ] Créer écran "Import depuis portail"
- [ ] Ajouter boutons Andaman 7 / MaSanté
- [ ] Ajouter instructions utilisateur
- [ ] Implémenter upload fichier
- [ ] Afficher progression import

### Phase 2 : Parsing (2 semaines)

- [ ] Parser PDF Andaman 7
- [ ] Parser CSV Andaman 7
- [ ] Parser PDF MaSanté
- [ ] Parser CSV MaSanté (si disponible)
- [ ] Tests avec fichiers réels

### Phase 3 : Backend (1 semaine)

- [ ] Endpoint import manuel
- [ ] Validation fichiers
- [ ] Traitement asynchrone
- [ ] Gestion erreurs
- [ ] Logs détaillés

### Phase 4 : Tests (1 semaine)

- [ ] Tests unitaires parsers
- [ ] Tests intégration
- [ ] Tests avec utilisateurs réels
- [ ] Validation données importées

---

## 🎯 ALTERNATIVES

### Si Parsing Trop Complexe

1. **Guide utilisateur détaillé** : Instructions pas-à-pas pour export
2. **Import assisté** : Formulaire pour saisie manuelle des données clés
3. **Partage direct** : Utilisateur partage fichier, traitement manuel

### Partenariats

- **Andaman 7** : Contacter pour partenariat commercial
- **MaSanté** : Contacter pour convention institutionnelle

---

## 📚 RESSOURCES

### Andaman 7

- Site : https://www.andaman7.com
- Support : support@andaman7.com
- Services partenaires : https://www.andaman7.com/en/additional-services

### MaSanté

- Portail : https://www.masante.belgique.be
- Documentation technique : https://www.ehealth.fgov.be/ehealthplatform/fr/service-architectures

---

**Dernière mise à jour** : 26 novembre 2025

