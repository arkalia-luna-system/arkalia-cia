"""
Tests unitaires pour ocr_processor
"""

from unittest.mock import patch

from arkalia_cia_python_backend.pdf_parser.ocr_processor import OCRProcessor


class TestOCRProcessor:
    """Tests pour OCRProcessor"""

    def test_init(self):
        """Test initialisation"""
        processor = OCRProcessor()
        assert processor is not None
        assert hasattr(processor, "tesseract_config")

    def test_is_available(self):
        """Test vérification disponibilité OCR"""
        processor = OCRProcessor()
        # Peut être True ou False selon installation
        result = processor.is_available()
        assert isinstance(result, bool)

    def test_process_scanned_pdf_not_available(self):
        """Test traitement PDF sans OCR disponible"""
        with patch(
            "arkalia_cia_python_backend.pdf_parser.ocr_processor.OCR_AVAILABLE", False
        ):
            processor = OCRProcessor()
            result = processor.process_scanned_pdf("/path/to/file.pdf")
            assert result is not None
            assert result["text"] == ""
            assert result["is_scanned"] is True
            assert "error" in result

    def test_process_scanned_pdf_with_mock(self):
        """Test traitement PDF avec mock OCR"""
        # Test seulement si OCR n'est pas disponible (cas le plus courant)
        processor = OCRProcessor()
        if not processor.is_available():
            # Si OCR n'est pas disponible, on teste le comportement par défaut
            result = processor.process_scanned_pdf("/path/to/file.pdf")
            assert result is not None
            assert result["text"] == ""
            assert "error" in result
        else:
            # Si OCR est disponible, on teste juste que ça ne plante pas
            # (nécessite vraies dépendances)
            result = processor.process_scanned_pdf("/path/to/file.pdf")
            assert result is not None
            assert "text" in result

    def test_process_scanned_pdf_error_handling(self):
        """Test gestion erreurs"""
        processor = OCRProcessor()
        # Test que la fonction gère les erreurs gracieusement
        result = processor.process_scanned_pdf("/nonexistent/file.pdf")
        assert result is not None
        # Soit une erreur, soit un résultat vide selon disponibilité OCR
        assert "text" in result
