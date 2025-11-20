# Plan 01 : Parser PDF médicaux

**Version** : 1.0.0  
**Date** : 20 novembre 2025  
**Statut** : ✅ Implémenté

---

## Vue d'ensemble

Import intelligent des données depuis Andaman 7, MaSanté et autres sources.

---

## 🎯 **OBJECTIF**

Permettre à votre mère d'importer facilement tous ses documents médicaux depuis les apps qu'elle utilise déjà (Andaman 7, MaSanté, Réseau Santé Wallon) pour avoir **tout au même endroit** dans CIA.

---

## 📋 **BESOINS IDENTIFIÉS**

### **Besoin Principal**
- ✅ Importer documents depuis Andaman 7 (export PDF)
- ✅ Importer documents depuis MaSanté (export PDF)
- ✅ Importer depuis Réseau Santé Wallon (export PDF)
- ✅ Parsing automatique pour extraire métadonnées
- ✅ Interface simple : drag & drop ou sélection fichier

### **Fonctionnalités Requises**
- 📥 Import manuel PDF (drag & drop)
- 🔍 Extraction automatique métadonnées (médecin, date, type examen)
- 📋 Détection type document (ordonnance, résultat, compte-rendu)
- 🏷️ Classification automatique par catégorie
- 🔗 Association automatique avec médecins existants
- ✅ Validation et prévisualisation avant import

---

## 🏗️ **ARCHITECTURE**

### **Stack Technique**

```
Frontend (Flutter)
├── file_picker (sélection fichiers)
├── pdfx ou syncfusion_flutter_pdf (lecture PDF)
└── drag_and_drop (interface drag & drop)

Backend (Python FastAPI)
├── PyPDF2 / pdfplumber (extraction texte)
├── Tesseract OCR (PDF scannés)
├── spaCy / NLTK (NLP santé)
└── regex (extraction métadonnées)
```

### **Structure Fichiers**

```
arkalia_cia/
├── lib/
│   ├── screens/
│   │   └── import_documents_screen.dart      # Interface import
│   ├── services/
│   │   ├── pdf_parser_service.dart           # Service parsing PDF
│   │   └── document_import_service.dart      # Service import documents
│   └── widgets/
│       ├── pdf_preview_widget.dart           # Prévisualisation PDF
│       └── import_progress_widget.dart        # Barre progression
└── arkalia_cia_python_backend/
    ├── pdf_parser/
    │   ├── __init__.py
    │   ├── pdf_extractor.py                 # Extraction texte PDF
    │   ├── ocr_processor.py                 # OCR pour PDF scannés
    │   ├── metadata_extractor.py            # Extraction métadonnées
    │   └── document_classifier.py           # Classification documents
    └── api/
        └── import_api.py                    # API import documents
```

---

## 🔧 **IMPLÉMENTATION DÉTAILLÉE**

### **Étape 1 : Backend - Extraction Texte PDF**

**Fichier** : `arkalia_cia_python_backend/pdf_parser/pdf_extractor.py`

```python
"""
Extraction texte depuis PDF médicaux
Inspiration : EDS-NLP (APHP) pour techniques extraction
"""
import pdfplumber
import PyPDF2
from typing import Optional, Dict, List
import logging

logger = logging.getLogger(__name__)


class PDFExtractor:
    """Extracteur texte depuis PDF médicaux"""
    
    def __init__(self):
        self.supported_formats = ['.pdf']
    
    def extract_text(self, pdf_path: str) -> Dict[str, any]:
        """
        Extrait le texte d'un PDF médical
        
        Returns:
            {
                'text': str,           # Texte complet
                'pages': List[str],     # Texte par page
                'metadata': Dict,        # Métadonnées PDF
                'is_scanned': bool       # Si PDF scanné (nécessite OCR)
            }
        """
        try:
            # Essayer avec pdfplumber (meilleur pour PDF texte)
            with pdfplumber.open(pdf_path) as pdf:
                text_pages = []
                full_text = ""
                
                for page in pdf.pages:
                    page_text = page.extract_text()
                    if page_text:
                        text_pages.append(page_text)
                        full_text += page_text + "\n"
                
                # Si pas de texte, c'est probablement scanné
                is_scanned = len(full_text.strip()) < 100
                
                return {
                    'text': full_text,
                    'pages': text_pages,
                    'metadata': pdf.metadata,
                    'is_scanned': is_scanned,
                    'page_count': len(pdf.pages)
                }
        
        except Exception as e:
            logger.error(f"Erreur extraction PDF: {e}")
            # Fallback sur PyPDF2
            return self._extract_with_pypdf2(pdf_path)
    
    def _extract_with_pypdf2(self, pdf_path: str) -> Dict[str, any]:
        """Fallback avec PyPDF2"""
        try:
            with open(pdf_path, 'rb') as file:
                pdf_reader = PyPDF2.PdfReader(file)
                text_pages = []
                full_text = ""
                
                for page in pdf_reader.pages:
                    page_text = page.extract_text()
                    text_pages.append(page_text)
                    full_text += page_text + "\n"
                
                return {
                    'text': full_text,
                    'pages': text_pages,
                    'metadata': pdf_reader.metadata,
                    'is_scanned': len(full_text.strip()) < 100,
                    'page_count': len(pdf_reader.pages)
                }
        except Exception as e:
            logger.error(f"Erreur PyPDF2: {e}")
            raise
```

---

### **Étape 2 : Backend - OCR pour PDF Scannés**

**Fichier** : `arkalia_cia_python_backend/pdf_parser/ocr_processor.py`

```python
"""
OCR pour PDF scannés (Tesseract)
"""
import pytesseract
from pdf2image import convert_from_path
from typing import Dict, List
import logging
import tempfile
import os

logger = logging.getLogger(__name__)


class OCRProcessor:
    """Processeur OCR pour PDF scannés"""
    
    def __init__(self):
        # Configuration Tesseract pour français
        self.tesseract_config = '--oem 3 --psm 6 -l fra+eng'
    
    def process_scanned_pdf(self, pdf_path: str) -> Dict[str, any]:
        """
        Traite un PDF scanné avec OCR
        
        Returns:
            {
                'text': str,
                'pages': List[str],
                'confidence': float,  # Confiance moyenne OCR
                'is_scanned': True
            }
        """
        try:
            # Convertir PDF en images
            images = convert_from_path(pdf_path, dpi=300)
            
            text_pages = []
            total_confidence = 0.0
            
            for i, image in enumerate(images):
                # OCR sur chaque page
                ocr_data = pytesseract.image_to_data(
                    image,
                    config=self.tesseract_config,
                    output_type=pytesseract.Output.DICT
                )
                
                # Extraire texte et confiance
                page_text = ""
                page_confidences = []
                
                for j, word in enumerate(ocr_data['text']):
                    if word.strip():
                        page_text += word + " "
                        conf = float(ocr_data['conf'][j])
                        if conf > 0:
                            page_confidences.append(conf)
                
                text_pages.append(page_text.strip())
                
                if page_confidences:
                    avg_conf = sum(page_confidences) / len(page_confidences)
                    total_confidence += avg_conf
            
            avg_confidence = total_confidence / len(images) if images else 0.0
            
            return {
                'text': "\n\n".join(text_pages),
                'pages': text_pages,
                'confidence': avg_confidence,
                'is_scanned': True,
                'page_count': len(images)
            }
        
        except Exception as e:
            logger.error(f"Erreur OCR: {e}")
            raise
```

---

### **Étape 3 : Backend - Extraction Métadonnées**

**Fichier** : `arkalia_cia_python_backend/pdf_parser/metadata_extractor.py`

```python
"""
Extraction métadonnées depuis texte PDF médical
Inspiration : EDS-NLP pour extraction entités nommées santé
"""
import re
from datetime import datetime
from typing import Dict, Optional, List
import logging

logger = logging.getLogger(__name__)


class MetadataExtractor:
    """Extracteur métadonnées documents médicaux"""
    
    def __init__(self):
        # Patterns pour détection dates (format belge)
        self.date_patterns = [
            r'\d{1,2}[/-]\d{1,2}[/-]\d{2,4}',  # 15/11/2025 ou 15-11-2025
            r'\d{1,2}\s+\w+\s+\d{4}',           # 15 novembre 2025
            r'\d{4}[/-]\d{1,2}[/-]\d{1,2}',     # 2025-11-15
        ]
        
        # Patterns pour détection médecins
        self.doctor_patterns = [
            r'Dr\.?\s+([A-Z][a-z]+(?:\s+[A-Z][a-z]+)*)',  # Dr. Dupont
            r'Docteur\s+([A-Z][a-z]+(?:\s+[A-Z][a-z]+)*)',  # Docteur Martin
            r'([A-Z][a-z]+(?:\s+[A-Z][a-z]+)*),\s*Dr\.?',  # Dupont, Dr.
        ]
        
        # Patterns pour détection types examens
        self.exam_patterns = {
            'radio': r'(?:radio|radiographie|RX|X-ray)',
            'analyse': r'(?:analyse|prélèvement|sang|urine)',
            'scanner': r'(?:scanner|CT|tomodensitométrie)',
            'irm': r'(?:IRM|imagerie par résonance)',
            'echographie': r'(?:échographie|échographie|ultrasons)',
            'biopsie': r'(?:biopsie|prélèvement)',
        }
    
    def extract_metadata(self, text: str) -> Dict[str, any]:
        """
        Extrait métadonnées depuis texte PDF
        
        Returns:
            {
                'date': Optional[datetime],
                'doctor_name': Optional[str],
                'doctor_specialty': Optional[str],
                'exam_type': Optional[str],
                'document_type': str,  # 'ordonnance', 'resultat', 'compte_rendu'
                'keywords': List[str]
            }
        """
        metadata = {
            'date': self._extract_date(text),
            'doctor_name': self._extract_doctor_name(text),
            'doctor_specialty': self._extract_specialty(text),
            'exam_type': self._extract_exam_type(text),
            'document_type': self._classify_document_type(text),
            'keywords': self._extract_keywords(text)
        }
        
        return metadata
    
    def _extract_date(self, text: str) -> Optional[datetime]:
        """Extrait la date du document"""
        for pattern in self.date_patterns:
            matches = re.findall(pattern, text)
            if matches:
                try:
                    # Essayer de parser la date
                    date_str = matches[0]
                    # Normaliser format
                    if '/' in date_str:
                        parts = date_str.split('/')
                        if len(parts) == 3:
                            day, month, year = parts
                            if len(year) == 2:
                                year = '20' + year
                            return datetime(int(year), int(month), int(day))
                except:
                    continue
        return None
    
    def _extract_doctor_name(self, text: str) -> Optional[str]:
        """Extrait le nom du médecin"""
        for pattern in self.doctor_patterns:
            matches = re.findall(pattern, text, re.IGNORECASE)
            if matches:
                return matches[0].strip()
        return None
    
    def _extract_specialty(self, text: str) -> Optional[str]:
        """Extrait la spécialité du médecin"""
        specialties = [
            'cardiologue', 'dermatologue', 'gynécologue', 'ophtalmologue',
            'orthopédiste', 'pneumologue', 'rhumatologue', 'neurologue',
            'généraliste', 'médecin général'
        ]
        
        text_lower = text.lower()
        for specialty in specialties:
            if specialty in text_lower:
                return specialty.capitalize()
        return None
    
    def _extract_exam_type(self, text: str) -> Optional[str]:
        """Extrait le type d'examen"""
        text_lower = text.lower()
        for exam_type, pattern in self.exam_patterns.items():
            if re.search(pattern, text_lower, re.IGNORECASE):
                return exam_type
        return None
    
    def _classify_document_type(self, text: str) -> str:
        """Classifie le type de document"""
        text_lower = text.lower()
        
        # Mots-clés pour classification
        if any(word in text_lower for word in ['ordonnance', 'prescription', 'médicament']):
            return 'ordonnance'
        elif any(word in text_lower for word in ['résultat', 'analyse', 'laboratoire']):
            return 'resultat'
        elif any(word in text_lower for word in ['compte-rendu', 'rapport', 'consultation']):
            return 'compte_rendu'
        else:
            return 'autre'
    
    def _extract_keywords(self, text: str) -> List[str]:
        """Extrait mots-clés importants"""
        # Mots-clés médicaux communs
        medical_keywords = [
            'diagnostic', 'traitement', 'symptôme', 'pathologie',
            'médicament', 'posologie', 'dosage', 'effet secondaire'
        ]
        
        found_keywords = []
        text_lower = text.lower()
        for keyword in medical_keywords:
            if keyword in text_lower:
                found_keywords.append(keyword)
        
        return found_keywords
```

---

### **Étape 4 : Backend - Classification Documents**

**Fichier** : `arkalia_cia_python_backend/pdf_parser/document_classifier.py`

```python
"""
Classification intelligente des documents médicaux
Utilise NLP pour classification précise
"""
from typing import Dict
import logging

logger = logging.getLogger(__name__)


class DocumentClassifier:
    """Classificateur de documents médicaux"""
    
    def classify(self, text: str, metadata: Dict) -> Dict[str, any]:
        """
        Classifie le document avec score de confiance
        
        Returns:
            {
                'category': str,        # 'consultation', 'examen', 'ordonnance', etc.
                'confidence': float,     # 0.0 à 1.0
                'tags': List[str]       # Tags supplémentaires
            }
        """
        # Classification basée sur métadonnées et texte
        doc_type = metadata.get('document_type', 'autre')
        
        # Mapping document_type → category
        category_mapping = {
            'ordonnance': 'ordonnance',
            'resultat': 'examen',
            'compte_rendu': 'consultation',
            'autre': 'document_general'
        }
        
        category = category_mapping.get(doc_type, 'document_general')
        
        # Calculer confiance basée sur métadonnées complètes
        confidence = self._calculate_confidence(metadata)
        
        # Générer tags
        tags = self._generate_tags(metadata, text)
        
        return {
            'category': category,
            'confidence': confidence,
            'tags': tags
        }
    
    def _calculate_confidence(self, metadata: Dict) -> float:
        """Calcule score de confiance"""
        score = 0.0
        
        if metadata.get('date'):
            score += 0.3
        if metadata.get('doctor_name'):
            score += 0.3
        if metadata.get('exam_type'):
            score += 0.2
        if len(metadata.get('keywords', [])) > 0:
            score += 0.2
        
        return min(score, 1.0)
    
    def _generate_tags(self, metadata: Dict, text: str) -> List[str]:
        """Génère tags pour le document"""
        tags = []
        
        if metadata.get('exam_type'):
            tags.append(metadata['exam_type'])
        
        if metadata.get('doctor_specialty'):
            tags.append(metadata['doctor_specialty'])
        
        # Ajouter tags depuis keywords
        tags.extend(metadata.get('keywords', [])[:3])  # Max 3 keywords
        
        return tags
```

---

### **Étape 5 : Backend - API Import**

**Fichier** : `arkalia_cia_python_backend/api/import_api.py`

```python
"""
API pour import documents médicaux
"""
from fastapi import APIRouter, UploadFile, File, HTTPException
from typing import List
import tempfile
import os
from ..pdf_parser.pdf_extractor import PDFExtractor
from ..pdf_parser.ocr_processor import OCRProcessor
from ..pdf_parser.metadata_extractor import MetadataExtractor
from ..pdf_parser.document_classifier import DocumentClassifier
import logging

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api/import", tags=["import"])

extractor = PDFExtractor()
ocr_processor = OCRProcessor()
metadata_extractor = MetadataExtractor()
classifier = DocumentClassifier()


@router.post("/pdf")
async def import_pdf(file: UploadFile = File(...)):
    """
    Import un PDF médical
    
    Returns:
        {
            'success': bool,
            'document_id': Optional[str],
            'metadata': Dict,
            'preview': str,  # Premières lignes texte
            'requires_review': bool  # Si métadonnées incomplètes
        }
    """
    try:
        # Sauvegarder fichier temporaire
        with tempfile.NamedTemporaryFile(delete=False, suffix='.pdf') as tmp_file:
            content = await file.read()
            tmp_file.write(content)
            tmp_path = tmp_file.name
        
        try:
            # Extraire texte
            extraction_result = extractor.extract_text(tmp_path)
            
            # Si PDF scanné, utiliser OCR
            if extraction_result['is_scanned']:
                logger.info("PDF scanné détecté, utilisation OCR")
                ocr_result = ocr_processor.process_scanned_pdf(tmp_path)
                text = ocr_result['text']
            else:
                text = extraction_result['text']
            
            # Extraire métadonnées
            metadata = metadata_extractor.extract_metadata(text)
            
            # Classifier document
            classification = classifier.classify(text, metadata)
            
            # Prévisualisation (premières 500 caractères)
            preview = text[:500] + "..." if len(text) > 500 else text
            
            # Déterminer si révision nécessaire
            requires_review = metadata.get('confidence', 0.0) < 0.7
            
            return {
                'success': True,
                'metadata': {
                    **metadata,
                    **classification
                },
                'preview': preview,
                'requires_review': requires_review,
                'page_count': extraction_result.get('page_count', 0)
            }
        
        finally:
            # Nettoyer fichier temporaire
            if os.path.exists(tmp_path):
                os.unlink(tmp_path)
    
    except Exception as e:
        logger.error(f"Erreur import PDF: {e}")
        raise HTTPException(status_code=500, detail=str(e))
```

---

### **Étape 6 : Frontend - Interface Import**

**Fichier** : `arkalia_cia/lib/screens/import_documents_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import '../services/document_import_service.dart';
import '../widgets/pdf_preview_widget.dart';
import '../widgets/import_progress_widget.dart';

class ImportDocumentsScreen extends StatefulWidget {
  @override
  _ImportDocumentsScreenState createState() => _ImportDocumentsScreenState();
}

class _ImportDocumentsScreenState extends State<ImportDocumentsScreen> {
  final DocumentImportService _importService = DocumentImportService();
  bool _isImporting = false;
  double _progress = 0.0;
  String? _previewText;
  Map<String, dynamic>? _metadata;

  Future<void> _pickAndImportPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        setState(() {
          _isImporting = true;
          _progress = 0.0;
        });

        // Import via service
        final importResult = await _importService.importPDF(
          result.files.single.path!,
          onProgress: (progress) {
            setState(() {
              _progress = progress;
            });
          },
        );

        setState(() {
          _isImporting = false;
          _previewText = importResult['preview'];
          _metadata = importResult['metadata'];
        });

        // Afficher résultat
        _showImportResult(importResult);
      }
    } catch (e) {
      setState(() {
        _isImporting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur import: $e')),
      );
    }
  }

  void _showImportResult(Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Import réussi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (result['metadata'] != null) ...[
              Text('Médecin: ${result['metadata']['doctor_name'] ?? 'Non détecté'}'),
              Text('Date: ${result['metadata']['date'] ?? 'Non détectée'}'),
              Text('Type: ${result['metadata']['document_type'] ?? 'Non détecté'}'),
            ],
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Sauvegarder document
                Navigator.pop(context);
              },
              child: Text('Sauvegarder'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Importer Documents'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Zone drag & drop
            Expanded(
              child: _buildDropZone(),
            ),
            
            // Bouton sélection fichier
            ElevatedButton.icon(
              onPressed: _isImporting ? null : _pickAndImportPDF,
              icon: Icon(Icons.upload_file),
              label: Text('Sélectionner PDF'),
            ),
            
            // Barre progression
            if (_isImporting)
              ImportProgressWidget(progress: _progress),
            
            // Prévisualisation
            if (_previewText != null)
              Expanded(
                child: PdfPreviewWidget(text: _previewText!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropZone() {
    return DragTarget<String>(
      onWillAccept: (data) => true,
      onAccept: (data) {
        // Gérer drop fichier
        _pickAndImportPDF();
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: candidateData.isNotEmpty ? Colors.blue : Colors.grey,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_upload, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Glissez vos PDF ici',
                  style: TextStyle(fontSize: 18),
                ),
                Text('ou cliquez sur le bouton ci-dessous'),
              ],
            ),
          ),
        );
      },
    );
  }
}
```

---

## ✅ **TESTS**

### **Tests Backend**

```python
# tests/test_pdf_extractor.py
def test_extract_text_from_pdf():
    extractor = PDFExtractor()
    result = extractor.extract_text('test_document.pdf')
    assert result['text'] is not None
    assert len(result['pages']) > 0

def test_detect_scanned_pdf():
    extractor = PDFExtractor()
    result = extractor.extract_text('scanned_document.pdf')
    assert result['is_scanned'] == True

# tests/test_metadata_extractor.py
def test_extract_doctor_name():
    extractor = MetadataExtractor()
    text = "Consultation avec Dr. Dupont le 15/11/2025"
    metadata = extractor.extract_metadata(text)
    assert metadata['doctor_name'] == 'Dupont'
    assert metadata['date'] is not None
```

### **Tests Frontend**

```dart
// test/import_documents_test.dart
void main() {
  testWidgets('Import PDF affiche prévisualisation', (tester) async {
    await tester.pumpWidget(ImportDocumentsScreen());
    
    // Simuler sélection fichier
    await tester.tap(find.text('Sélectionner PDF'));
    await tester.pumpAndSettle();
    
    // Vérifier prévisualisation affichée
    expect(find.byType(PdfPreviewWidget), findsOneWidget);
  });
}
```

---

## 🚀 **PERFORMANCE**

### **Optimisations**

1. **Cache extraction texte** : Ne pas ré-extraire si déjà fait
2. **OCR asynchrone** : Traiter OCR en arrière-plan
3. **Compression images OCR** : Réduire taille avant OCR
4. **Indexation texte** : Indexer pour recherche rapide

### **Limites**

- **Taille max PDF** : 50 MB
- **Pages max** : 100 pages
- **Timeout OCR** : 60 secondes par page

---

## 🔐 **SÉCURITÉ**

1. **Validation fichiers** : Vérifier extension et type MIME
2. **Scan antivirus** : Scanner fichiers uploadés
3. **Limite taille** : Empêcher upload fichiers trop gros
4. **Isolation** : Traiter fichiers dans environnement isolé
5. **Nettoyage** : Supprimer fichiers temporaires après traitement

---

## 📅 **TIMELINE**

### **Semaine 1 : Backend Extraction**
- [ ] Jour 1-2 : PDFExtractor (extraction texte)
- [ ] Jour 3-4 : OCRProcessor (OCR PDF scannés)
- [ ] Jour 5 : Tests extraction

### **Semaine 2 : Backend Métadonnées**
- [ ] Jour 1-2 : MetadataExtractor (extraction métadonnées)
- [ ] Jour 3 : DocumentClassifier (classification)
- [ ] Jour 4-5 : Tests métadonnées

### **Semaine 3 : API & Frontend**
- [ ] Jour 1-2 : API import (import_api.py)
- [ ] Jour 3-4 : Interface Flutter (import_documents_screen.dart)
- [ ] Jour 5 : Tests intégration

### **Semaine 4 : Finalisation**
- [ ] Jour 1-2 : Optimisations performance
- [ ] Jour 3 : Tests finaux
- [ ] Jour 4-5 : Documentation

---

## 📚 **RESSOURCES**

- **PyPDF2** : https://pypdf2.readthedocs.io/
- **pdfplumber** : https://github.com/jsvine/pdfplumber
- **Tesseract OCR** : https://github.com/tesseract-ocr/tesseract
- **spaCy** : https://spacy.io/
- **EDS-NLP (Inspiration)** : https://www.aphp.fr/actualites/ia-en-sante-lentrepot-de-donnees-de-sante-de-lap-hp-confirme-sa-demarche-open-source

---

**Statut** : 📋 **PLAN VALIDÉ**  
**Priorité** : 🔴 **CRITIQUE**  
**Temps estimé** : 3-4 semaines

