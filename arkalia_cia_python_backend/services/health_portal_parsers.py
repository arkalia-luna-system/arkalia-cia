"""
Parsers spécifiques pour portails santé (Andaman 7, MaSanté)
Utilise l'infrastructure existante (PDFProcessor, MetadataExtractor)
"""

import logging
import re
from datetime import datetime
from typing import Any

from arkalia_cia_python_backend.pdf_parser.metadata_extractor import MetadataExtractor
from arkalia_cia_python_backend.pdf_processor import PDFProcessor

logger = logging.getLogger(__name__)


class HealthPortalParser:
    """Parser générique pour portails santé avec parsers spécifiques"""

    def __init__(self):
        self.pdf_processor = PDFProcessor()
        self.metadata_extractor = MetadataExtractor()

    def parse_portal_pdf(
        self, file_path: str, portal: str, text: str | None = None
    ) -> dict[str, Any]:
        """
        Parse un PDF selon le portail (Andaman 7, MaSanté, ou générique)

        Args:
            file_path: Chemin vers le PDF
            portal: 'andaman7', 'masante', ou 'generic'
            text: Texte extrait (optionnel, sera extrait si None)

        Returns:
            {
                'documents': List[Dict],  # Documents extraits
                'metadata': Dict,  # Métadonnées globales
                'portal': str,  # Portail source
            }
        """
        try:
            # Extraire texte si non fourni
            if text is None:
                text = self.pdf_processor.extract_text_from_pdf(file_path)

            # Parser selon portail
            if portal.lower() == "andaman7":
                documents = self._parse_andaman7(text)
            elif portal.lower() == "masante":
                documents = self._parse_masante(text)
            else:
                documents = self._parse_generic(text)

            # Métadonnées globales
            metadata = self.metadata_extractor.extract_metadata(text)

            return {
                "documents": documents,
                "metadata": metadata,
                "portal": portal,
                "total_documents": len(documents),
            }

        except Exception as e:
            logger.error(f"Erreur parsing portail {portal}: {e}", exc_info=True)
            raise

    def _parse_andaman7(self, text: str) -> list[dict[str, Any]]:
        """Parser spécifique Andaman 7"""
        documents = []

        # Patterns spécifiques Andaman 7
        patterns = {
            "Ordonnance": r"Ordonnance.*?(?=Consultation|Résultats|Examen|$)",
            "Consultation": r"Consultation.*?(?=Ordonnance|Résultats|Examen|$)",
            "Résultats": r"Résultats.*?(?=Consultation|Ordonnance|Examen|$)",
            "Examen": r"Examen.*?(?=Consultation|Ordonnance|Résultats|$)",
        }

        # Patterns communs
        date_pattern = r"(\d{1,2})[/-](\d{1,2})[/-](\d{2,4})"
        practitioner_pattern = r"Dr\.?\s+([A-Z][a-zÀ-ÿ]+(?:\s+[A-Z][a-zÀ-ÿ]+)*)"

        for doc_type, pattern in patterns.items():
            for match in re.finditer(pattern, text, re.IGNORECASE | re.DOTALL):
                section = match.group(0)

                # Extraire date
                date_match = re.search(date_pattern, section)
                date_str = None
                if date_match:
                    date_str = date_match.group(0)
                    # Normaliser format date
                    try:
                        parts = re.split(r"[/-]", date_str)
                        if len(parts) == 3:
                            if len(parts[2]) == 2:
                                parts[2] = "20" + parts[2]
                            date_str = (
                                f"{parts[2]}-{parts[1].zfill(2)}-{parts[0].zfill(2)}"
                            )
                    except Exception:
                        pass

                # Extraire médecin
                practitioner_match = re.search(practitioner_pattern, section)
                practitioner = (
                    practitioner_match.group(1).strip()
                    if practitioner_match
                    else "Inconnu"
                )

                # Extraire résultats labo si type "Résultats"
                results = None
                if doc_type == "Résultats":
                    results = self._extract_lab_results(section)

                if date_str:
                    documents.append(
                        {
                            "type": doc_type,
                            "date": date_str,
                            "practitioner": practitioner,
                            "description": section[:500],  # Limiter longueur
                            "full_text": section,
                            "results": results,
                            "source": "Andaman 7",
                        }
                    )

        return documents

    def _parse_masante(self, text: str) -> list[dict[str, Any]]:
        """Parser spécifique MaSanté (format légèrement différent)"""
        documents = []

        # MaSanté utilise souvent des en-têtes en majuscules
        patterns = {
            "Ordonnance": r"(?:ORDONNANCE|Ordonnance).*?(?=CONSULTATION|Consultation|RÉSULTATS|Résultats|EXAMEN|Examen|$)",
            "Consultation": r"(?:CONSULTATION|Consultation).*?(?=ORDONNANCE|Ordonnance|RÉSULTATS|Résultats|EXAMEN|Examen|$)",
            "Résultats": r"(?:RÉSULTATS|Résultats).*?(?=CONSULTATION|Consultation|ORDONNANCE|Ordonnance|EXAMEN|Examen|$)",
            "Examen": r"(?:EXAMEN|Examen).*?(?=CONSULTATION|Consultation|ORDONNANCE|Ordonnance|RÉSULTATS|Résultats|$)",
        }

        # Patterns communs
        date_pattern = r"(\d{1,2})[/-](\d{1,2})[/-](\d{2,4})"
        practitioner_pattern = (
            r"(?:Dr\.?|Docteur)\s+([A-Z][a-zÀ-ÿ]+(?:\s+[A-Z][a-zÀ-ÿ]+)*)"
        )

        for doc_type, pattern in patterns.items():
            for match in re.finditer(pattern, text, re.IGNORECASE | re.DOTALL):
                section = match.group(0)

                # Extraire date
                date_match = re.search(date_pattern, section)
                date_str = None
                if date_match:
                    date_str = date_match.group(0)
                    try:
                        parts = re.split(r"[/-]", date_str)
                        if len(parts) == 3:
                            if len(parts[2]) == 2:
                                parts[2] = "20" + parts[2]
                            date_str = (
                                f"{parts[2]}-{parts[1].zfill(2)}-{parts[0].zfill(2)}"
                            )
                    except Exception:
                        pass

                # Extraire médecin
                practitioner_match = re.search(practitioner_pattern, section)
                practitioner = (
                    practitioner_match.group(1).strip()
                    if practitioner_match
                    else "Inconnu"
                )

                # Extraire résultats si type "Résultats"
                results = None
                if doc_type == "Résultats":
                    results = self._extract_lab_results(section)

                if date_str:
                    documents.append(
                        {
                            "type": doc_type,
                            "date": date_str,
                            "practitioner": practitioner,
                            "description": section[:500],
                            "full_text": section,
                            "results": results,
                            "source": "MaSanté",
                        }
                    )

        return documents

    def _parse_generic(self, text: str) -> list[dict[str, Any]]:
        """Parser générique (fallback)"""
        documents = []

        # Utiliser metadata_extractor existant
        metadata = self.metadata_extractor.extract_metadata(text)

        # Créer un document générique
        if metadata.get("date") or metadata.get("doctor_name"):
            documents.append(
                {
                    "type": metadata.get("document_type", "Document"),
                    "date": (
                        metadata["date"].isoformat()
                        if metadata.get("date")
                        else datetime.now().isoformat()
                    ),
                    "practitioner": metadata.get("doctor_name", "Non disponible"),
                    "description": text[:500],
                    "full_text": text,
                    "source": "Générique",
                }
            )

        return documents

    def _extract_lab_results(self, text: str) -> dict[str, str]:
        """Extraction des valeurs de laboratoire"""
        results = {}

        # Patterns courants pour résultats labo belges
        patterns = {
            "Glucose": r"Glucose[:\s]+(\d+(?:[.,]\d+)?)\s*(mg/dL|mmol/L|g/L)?",
            "Hémoglobine": r"Hémoglobine[:\s]+(\d+(?:[.,]\d+)?)\s*(g/dL|g/L)?",
            "Créatinine": r"Créatinine[:\s]+(\d+(?:[.,]\d+)?)\s*(mg/dL|μmol/L|μmol/L)?",
            "Cholestérol": r"Cholestérol[:\s]+(\d+(?:[.,]\d+)?)\s*(mg/dL|mmol/L)?",
            "Potassium": r"Potassium[:\s]+(\d+(?:[.,]\d+)?)\s*(mEq/L|mmol/L)?",
            "Sodium": r"Sodium[:\s]+(\d+(?:[.,]\d+)?)\s*(mEq/L|mmol/L)?",
            "Hémoglobine glyquée": r"(?:HbA1c|Hémoglobine\s+glyquée)[:\s]+(\d+(?:[.,]\d+)?)\s*%?",
            "TSH": r"TSH[:\s]+(\d+(?:[.,]\d+)?)\s*(mUI/L|μUI/mL)?",
        }

        for key, pattern in patterns.items():
            match = re.search(pattern, text, re.IGNORECASE)
            if match:
                value = match.group(1)
                unit = (
                    match.group(2) if match.lastindex and match.lastindex >= 2 else ""
                )
                results[key] = f"{value} {unit}".strip()

        return results


# Instance globale pour utilisation dans API
_parser_instance: HealthPortalParser | None = None


def get_health_portal_parser() -> HealthPortalParser:
    """Récupère l'instance du parser (singleton)"""
    global _parser_instance
    if _parser_instance is None:
        _parser_instance = HealthPortalParser()
    return _parser_instance
