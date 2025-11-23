"""
Tests unitaires pour ocr_integration
"""

from unittest.mock import MagicMock, patch

from arkalia_cia_python_backend.pdf_parser.ocr_integration import OCRIntegration


class TestOCRIntegration:
    """Tests pour OCRIntegration"""

    def test_init(self):
        """Test initialisation"""
        integration = OCRIntegration()
        assert integration is not None
        assert hasattr(integration, "ocr_available")
        assert hasattr(integration, "tesseract_config")

    def test_init_with_tesseract_cmd(self):
        """Test initialisation avec chemin tesseract"""
        integration = OCRIntegration(tesseract_cmd="/usr/bin/tesseract")
        assert integration is not None

    def test_is_available(self):
        """Test vérification disponibilité"""
        integration = OCRIntegration()
        result = integration.is_available()
        assert isinstance(result, bool)

    def test_process_scanned_pdf_not_available(self):
        """Test traitement PDF sans OCR"""
        with patch(
            "arkalia_cia_python_backend.pdf_parser.ocr_integration.OCR_AVAILABLE", False
        ):
            integration = OCRIntegration()
            result = integration.process_scanned_pdf("/path/to/file.pdf")
            assert result is not None
            assert result["text"] == ""
            assert "error" in result

    def test_process_scanned_pdf_with_mock(self):
        """Test traitement PDF avec mock"""
        integration = OCRIntegration()
        # Test que la fonction retourne un résultat valide
        result = integration.process_scanned_pdf("/path/to/file.pdf")
        assert result is not None
        assert "text" in result
        assert "pages" in result
        assert "confidence" in result
        assert "is_scanned" in result
        # Si OCR disponible, devrait avoir processing_time
        if integration.is_available():
            assert "processing_time" in result or "error" in result

    def test_process_scanned_pdf_no_images(self):
        """Test traitement PDF sans images"""
        integration = OCRIntegration()
        # Test avec un fichier inexistant
        result = integration.process_scanned_pdf("/nonexistent/file.pdf")
        assert result is not None
        # Devrait retourner une erreur ou un résultat vide
        assert "text" in result
        if not integration.is_available():
            assert "error" in result

    def test_detect_if_scanned_with_text(self):
        """Test détection PDF avec texte"""
        with patch("pypdf.PdfReader") as mock_reader:
            mock_page = MagicMock()
            mock_page.extract_text.return_value = "A" * 200  # Beaucoup de texte
            mock_reader.return_value.pages = [mock_page, mock_page, mock_page]

            integration = OCRIntegration()
            result = integration.detect_if_scanned("/path/to/file.pdf")
            assert result is False  # Pas scanné car beaucoup de texte

    def test_detect_if_scanned_scanned_pdf(self):
        """Test détection PDF scanné"""
        with patch("pypdf.PdfReader") as mock_reader:
            mock_page = MagicMock()
            mock_page.extract_text.return_value = "A" * 10  # Peu de texte
            mock_reader.return_value.pages = [mock_page, mock_page, mock_page]

            integration = OCRIntegration()
            result = integration.detect_if_scanned("/path/to/file.pdf")
            assert result is True  # Scanné car peu de texte

    def test_detect_if_scanned_error(self):
        """Test détection avec erreur"""
        with patch("pypdf.PdfReader") as mock_reader:
            mock_reader.side_effect = ValueError("Error")

            integration = OCRIntegration()
            result = integration.detect_if_scanned("/path/to/file.pdf")
            assert result is False  # Par défaut False en cas d'erreur
