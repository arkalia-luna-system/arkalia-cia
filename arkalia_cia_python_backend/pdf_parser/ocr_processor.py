"""
OCR pour PDF scannés (Tesseract)
"""

try:
    import pytesseract  # type: ignore[import-not-found]
    from pdf2image import convert_from_path  # type: ignore[import-not-found]

    OCR_AVAILABLE = True
except ImportError:
    OCR_AVAILABLE = False

import logging
from typing import Any

logger = logging.getLogger(__name__)


class OCRProcessor:
    """Processeur OCR pour PDF scannés"""

    def __init__(self):
        if not OCR_AVAILABLE:
            logger.warning("OCR non disponible: pytesseract ou pdf2image non installés")
        # Configuration Tesseract pour français
        self.tesseract_config = "--oem 3 --psm 6 -l fra+eng"

    def is_available(self) -> bool:
        """Vérifie si OCR est disponible"""
        return OCR_AVAILABLE

    def process_scanned_pdf(self, pdf_path: str) -> dict[str, Any]:
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
        if not OCR_AVAILABLE:
            return {
                "text": "",
                "pages": [],
                "confidence": 0.0,
                "is_scanned": True,
                "error": "OCR non disponible",
            }

        try:
            # Convertir PDF en images
            images = convert_from_path(pdf_path, dpi=300)

            text_pages = []
            total_confidence = 0.0

            for i, image in enumerate(images):
                # OCR sur chaque page
                try:
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

                    text_pages.append(page_text.strip())

                    if page_confidences:
                        avg_conf = sum(page_confidences) / len(page_confidences)
                        total_confidence += avg_conf
                except Exception as e:
                    logger.warning(f"Erreur OCR page {i}: {e}")
                    text_pages.append("")

            avg_confidence = total_confidence / len(images) if images else 0.0

            return {
                "text": "\n\n".join(text_pages),
                "pages": text_pages,
                "confidence": avg_confidence,
                "is_scanned": True,
                "page_count": len(images),
            }

        except Exception as e:
            logger.error(f"Erreur OCR: {e}")
            return {
                "text": "",
                "pages": [],
                "confidence": 0.0,
                "is_scanned": True,
                "error": str(e),
            }
