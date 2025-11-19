"""
Intégration OCR complète pour PDF scannés
Utilise Tesseract OCR pour extraire texte depuis images
"""

import logging
import os
from typing import Any

logger = logging.getLogger(__name__)

# Vérifier disponibilité OCR
try:
    import pytesseract
    from pdf2image import convert_from_path
    from PIL import Image

    OCR_AVAILABLE = True
except ImportError:
    OCR_AVAILABLE = False
    logger.warning("OCR non disponible: pytesseract, pdf2image ou PIL non installés")


class OCRIntegration:
    """Intégration OCR complète pour PDF scannés"""

    def __init__(self, tesseract_cmd: str | None = None):
        """
        Initialise l'intégration OCR

        Args:
            tesseract_cmd: Chemin vers tesseract (optionnel, auto-détecté si None)
        """
        self.ocr_available = OCR_AVAILABLE

        if OCR_AVAILABLE:
            if tesseract_cmd:
                pytesseract.pytesseract.tesseract_cmd = tesseract_cmd
            else:
                # Essayer de trouver tesseract automatiquement
                possible_paths = [
                    "/usr/local/bin/tesseract",
                    "/usr/bin/tesseract",
                    "/opt/homebrew/bin/tesseract",  # macOS Homebrew
                ]
                for path in possible_paths:
                    if os.path.exists(path):
                        pytesseract.pytesseract.tesseract_cmd = path
                        break

            # Configuration Tesseract pour français et anglais
            self.tesseract_config = "--oem 3 --psm 6 -l fra+eng"
        else:
            self.tesseract_config: str | None = None

    def is_available(self) -> bool:
        """Vérifie si OCR est disponible"""
        return self.ocr_available

    def process_scanned_pdf(
        self, pdf_path: str, dpi: int = 300, max_pages: int = 50
    ) -> dict[str, Any]:
        """
        Traite un PDF scanné avec OCR

        Args:
            pdf_path: Chemin vers le PDF
            dpi: Résolution DPI pour conversion (défaut: 300)
            max_pages: Nombre max de pages à traiter (défaut: 50)

        Returns:
            {
                'text': str,
                'pages': List[str],
                'confidence': float,
                'is_scanned': True,
                'page_count': int,
                'processing_time': float
            }
        """
        if not self.ocr_available:
            return {
                "text": "",
                "pages": [],
                "confidence": 0.0,
                "is_scanned": True,
                "error": "OCR non disponible. Installez pytesseract et pdf2image.",
            }

        import time

        start_time = time.time()

        try:
            # Convertir PDF en images
            logger.info(f"Conversion PDF en images: {pdf_path}")
            images = convert_from_path(
                pdf_path, dpi=dpi, first_page=1, last_page=max_pages
            )

            if not images:
                return {
                    "text": "",
                    "pages": [],
                    "confidence": 0.0,
                    "is_scanned": True,
                    "error": "Aucune page trouvée dans le PDF",
                }

            text_pages = []
            total_confidence = 0.0
            pages_with_text = 0

            for i, image in enumerate(images):
                try:
                    logger.debug(f"Traitement OCR page {i+1}/{len(images)}")

                    # OCR sur chaque page
                    ocr_data = pytesseract.image_to_data(
                        image,
                        config=self.tesseract_config,
                        output_type=pytesseract.Output.DICT,
                    )

                    # Extraire texte et confiance
                    page_text = ""
                    page_confidences = []

                    for j, word in enumerate(ocr_data["text"]):
                        if word.strip():
                            page_text += word + " "
                            conf = float(ocr_data["conf"][j])
                            if conf > 0:
                                page_confidences.append(conf)

                    page_text = page_text.strip()

                    if page_text:
                        text_pages.append(page_text)
                        if page_confidences:
                            avg_conf = sum(page_confidences) / len(page_confidences)
                            total_confidence += avg_conf
                            pages_with_text += 1
                    else:
                        text_pages.append("")

                except Exception as e:
                    logger.warning(f"Erreur OCR page {i+1}: {e}")
                    text_pages.append("")

            avg_confidence = (
                total_confidence / pages_with_text if pages_with_text > 0 else 0.0
            )
            processing_time = time.time() - start_time

            return {
                "text": "\n\n".join(text_pages),
                "pages": text_pages,
                "confidence": round(avg_confidence, 2),
                "is_scanned": True,
                "page_count": len(images),
                "processing_time": round(processing_time, 2),
                "pages_with_text": pages_with_text,
            }

        except Exception as e:
            logger.error(f"Erreur OCR: {e}")
            return {
                "text": "",
                "pages": [],
                "confidence": 0.0,
                "is_scanned": True,
                "error": str(e),
                "processing_time": time.time() - start_time,
            }

    def detect_if_scanned(self, pdf_path: str) -> bool:
        """
        Détecte si un PDF est scanné (image) ou contient du texte

        Args:
            pdf_path: Chemin vers le PDF

        Returns:
            True si le PDF semble être scanné
        """
        try:
            from pypdf import PdfReader

            reader = PdfReader(pdf_path)
            total_chars = 0

            # Analyser les premières pages
            for _i, page in enumerate(reader.pages[:3]):
                text = page.extract_text()
                total_chars += len(text.strip())

            # Si très peu de texte, probablement scanné
            return total_chars < 100
        except Exception as e:
            logger.warning(f"Erreur détection PDF scanné: {e}")
            return False  # Par défaut, considérer comme texte
