"""
Tests pour le service de gestion des documents
"""

import os
import tempfile
from unittest.mock import MagicMock, patch

import pytest

from arkalia_cia_python_backend.pdf_processor import PDFProcessor
from arkalia_cia_python_backend.services.document_service import DocumentService


class TestDocumentService:
    """Tests pour DocumentService"""

    @pytest.fixture
    def mock_db(self):
        """Créer une base de données mock"""
        db = MagicMock()
        db.add_document.return_value = 1
        db.associate_document_to_user.return_value = None
        db.add_document_metadata.return_value = None
        return db

    @pytest.fixture
    def mock_pdf_processor(self):
        """Créer un processeur PDF mock"""
        processor = MagicMock(spec=PDFProcessor)
        processor.process_pdf.return_value = {
            "success": True,
            "filename": "test.pdf",
            "original_name": "test.pdf",
            "file_path": "/tmp/test.pdf",
            "file_size": 1024,
        }
        processor.extract_text_from_pdf.return_value = "Test content"
        return processor

    @pytest.fixture
    def document_service(self, mock_db, mock_pdf_processor):
        """Créer un service de documents pour les tests"""
        return DocumentService(db=mock_db, pdf_processor=mock_pdf_processor)

    def test_validate_filename_valid(self, document_service):
        """Test validation d'un nom de fichier valide"""
        filename = document_service.validate_filename("test.pdf")
        assert filename == "test.pdf"

    def test_validate_filename_none(self, document_service):
        """Test validation avec None"""
        with pytest.raises(ValueError, match="requis"):
            document_service.validate_filename(None)

    def test_validate_filename_invalid_path(self, document_service):
        """Test validation avec chemin invalide"""
        with pytest.raises(ValueError, match="invalide"):
            document_service.validate_filename("../test.pdf")

    def test_validate_filename_not_pdf(self, document_service):
        """Test validation avec fichier non-PDF"""
        with pytest.raises(ValueError, match="PDF"):
            document_service.validate_filename("test.txt")

    @pytest.mark.asyncio
    async def test_save_uploaded_file_success(self, document_service):
        """Test sauvegarde d'un fichier uploadé"""
        content = b"PDF content"
        filename = "test.pdf"
        file_path, size = await document_service.save_uploaded_file(content, filename)
        assert os.path.exists(file_path)
        assert size == len(content)
        # Nettoyer
        if os.path.exists(file_path):
            os.unlink(file_path)

    @pytest.mark.asyncio
    async def test_save_uploaded_file_too_large(self, document_service):
        """Test sauvegarde avec fichier trop volumineux"""
        # Créer un contenu trop volumineux (> 50 MB)
        large_content = b"x" * (51 * 1024 * 1024)
        with pytest.raises(ValueError, match="volumineux"):
            await document_service.save_uploaded_file(large_content, "test.pdf")

    @pytest.mark.asyncio
    async def test_process_uploaded_file_success(
        self, document_service, mock_pdf_processor
    ):
        """Test traitement d'un fichier uploadé"""
        content = b"PDF content"
        filename = "test.pdf"
        result = await document_service.process_uploaded_file(content, filename)
        assert result["success"] is True
        assert result["filename"] == "test.pdf"
        mock_pdf_processor.process_pdf.assert_called_once()

    @pytest.mark.asyncio
    async def test_process_uploaded_file_failure(
        self, document_service, mock_pdf_processor
    ):
        """Test traitement avec échec"""
        mock_pdf_processor.process_pdf.return_value = {
            "success": False,
            "error": "Erreur traitement",
        }
        content = b"PDF content"
        with pytest.raises(ValueError, match="Erreur traitement"):
            await document_service.process_uploaded_file(content, "test.pdf")

    def test_extract_metadata_success(self, document_service, mock_pdf_processor):
        """Test extraction de métadonnées réussie"""
        with patch(
            "arkalia_cia_python_backend.services.document_service.MetadataExtractor"
        ) as mock_extractor:
            mock_extractor.return_value.extract_metadata.return_value = {
                "date": None,
                "doctor_name": "Dr. Test",
            }
            metadata = document_service.extract_metadata("/tmp/test.pdf")
            assert metadata is not None
            assert metadata["doctor_name"] == "Dr. Test"

    def test_extract_metadata_with_ocr(self, document_service, mock_pdf_processor):
        """Test extraction avec OCR si peu de texte"""
        mock_pdf_processor.extract_text_from_pdf.return_value = "Short"  # < 100 chars
        with patch(
            "arkalia_cia_python_backend.services.document_service.MetadataExtractor"
        ) as mock_extractor:
            mock_extractor.return_value.extract_metadata.return_value = {}
            document_service.extract_metadata("/tmp/test.pdf")
            # Vérifier que OCR a été appelé
            assert mock_pdf_processor.extract_text_from_pdf.call_count == 2

    def test_extract_metadata_error(self, document_service, mock_pdf_processor):
        """Test extraction avec erreur"""
        mock_pdf_processor.extract_text_from_pdf.side_effect = Exception("Erreur")
        metadata = document_service.extract_metadata("/tmp/test.pdf")
        assert metadata is None

    def test_save_document_with_metadata_success(
        self, document_service, mock_db, mock_pdf_processor
    ):
        """Test sauvegarde document avec métadonnées"""
        result = {
            "filename": "test.pdf",
            "original_name": "test.pdf",
            "file_path": "/tmp/test.pdf",
            "file_size": 1024,
        }
        metadata = {"doctor_name": "Dr. Test", "date": None}
        doc_id = document_service.save_document_with_metadata(
            result, user_id=1, metadata=metadata
        )
        assert doc_id == 1
        mock_db.add_document.assert_called_once()
        mock_db.associate_document_to_user.assert_called_once_with(1, 1)

    def test_save_document_without_metadata(self, document_service, mock_db):
        """Test sauvegarde document sans métadonnées"""
        result = {
            "filename": "test.pdf",
            "original_name": "test.pdf",
            "file_path": "/tmp/test.pdf",
            "file_size": 1024,
        }
        doc_id = document_service.save_document_with_metadata(result, user_id=1)
        assert doc_id == 1
        mock_db.add_document.assert_called_once()

    def test_save_document_failure(self, document_service, mock_db):
        """Test sauvegarde avec échec"""
        mock_db.add_document.return_value = None
        result = {
            "filename": "test.pdf",
            "original_name": "test.pdf",
            "file_path": "/tmp/test.pdf",
            "file_size": 1024,
        }
        with pytest.raises(ValueError, match="sauvegarde"):
            document_service.save_document_with_metadata(result, user_id=1)

    def test_cleanup_temp_file(self, document_service):
        """Test nettoyage fichier temporaire"""
        # Créer un fichier temporaire
        with tempfile.NamedTemporaryFile(delete=False) as tmp:
            tmp_path = tmp.name
        assert os.path.exists(tmp_path)
        document_service._cleanup_temp_file(tmp_path)
        assert not os.path.exists(tmp_path)

    def test_cleanup_temp_file_nonexistent(self, document_service):
        """Test nettoyage fichier inexistant"""
        # Ne devrait pas lever d'exception
        document_service._cleanup_temp_file("/tmp/nonexistent.pdf")
