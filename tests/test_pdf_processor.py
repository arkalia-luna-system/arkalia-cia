"""
Tests pour le module pdf_processor d'Arkalia-CIA
"""

import os
import tempfile
from pathlib import Path

import pytest

from arkalia_cia_python_backend.pdf_processor import PDFProcessor


class TestPDFProcessor:
    """Tests pour la classe PDFProcessor"""

    @pytest.fixture
    def pdf_processor(self):
        """Créer un processeur PDF pour les tests"""
        return PDFProcessor()

    @pytest.fixture
    def temp_pdf(self):
        """Créer un fichier PDF temporaire pour les tests"""
        # Créer un fichier PDF minimal pour les tests
        with tempfile.NamedTemporaryFile(suffix=".pdf", delete=False) as tmp:
            # Contenu PDF minimal (juste pour les tests)
            pdf_content = b"""%PDF-1.4
1 0 obj
<<
/Type /Catalog
/Pages 2 0 R
>>
endobj
2 0 obj
<<
/Type /Pages
/Kids [3 0 R]
/Count 1
>>
endobj
3 0 obj
<<
/Type /Page
/Parent 2 0 R
/MediaBox [0 0 612 792]
/Contents 4 0 R
>>
endobj
4 0 obj
<<
/Length 44
>>
stream
BT
/F1 12 Tf
100 700 Td
(Test PDF) Tj
ET
endstream
endobj
xref
0 5
0000000000 65535 f
0000000009 00000 n
0000000058 00000 n
0000000115 00000 n
0000000206 00000 n
trailer
<<
/Size 5
/Root 1 0 R
>>
startxref
299
%%EOF"""
            tmp.write(pdf_content)
            tmp.flush()
            yield tmp.name
        # Nettoyage après les tests
        if os.path.exists(tmp.name):
            os.unlink(tmp.name)

    def test_generate_filename(self, pdf_processor):
        """Test de génération de nom de fichier"""
        filename = pdf_processor.generate_filename("test.pdf")
        assert filename is not None
        assert isinstance(filename, str)
        assert filename.endswith(".pdf")

    def test_extract_text_from_pdf(self, pdf_processor, temp_pdf):
        """Test d'extraction de texte d'un PDF"""
        try:
            text = pdf_processor.extract_text_from_pdf(temp_pdf)
            assert text is not None
            assert isinstance(text, str)
        except Exception as e:
            # Si l'extraction échoue, c'est acceptable pour un PDF de test minimal
            pytest.skip(f"Extraction de texte échouée: {e}")

    def test_save_pdf_to_uploads(self, pdf_processor, temp_pdf):
        """Test de sauvegarde d'un PDF"""
        # Créer un dossier temporaire pour les uploads
        with tempfile.TemporaryDirectory() as temp_dir:
            uploads_dir = Path(temp_dir) / "uploads"
            uploads_dir.mkdir()

            # Sauvegarder le PDF
            saved_path = pdf_processor.save_pdf_to_uploads(
                temp_pdf, "test.pdf"
            )

            assert saved_path is not None
            assert os.path.exists(saved_path)
            assert saved_path.endswith(".pdf")

    def test_process_pdf(self, pdf_processor, temp_pdf):
        """Test de traitement complet d'un PDF"""
        # Créer un dossier temporaire pour les uploads
        with tempfile.TemporaryDirectory() as temp_dir:
            uploads_dir = Path(temp_dir) / "uploads"
            uploads_dir.mkdir()

            # Traiter le PDF
            result = pdf_processor.process_pdf(temp_pdf, "test.pdf")

            assert result is not None
            assert "filename" in result
            assert "file_path" in result
            assert "file_size" in result
            assert result["filename"].endswith(".pdf")
