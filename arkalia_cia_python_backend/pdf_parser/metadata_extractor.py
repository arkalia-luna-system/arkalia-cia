"""
Extraction métadonnées depuis texte PDF médical
Inspiration : EDS-NLP pour extraction entités nommées santé
"""

import logging
import re
from datetime import datetime
from typing import Any

logger = logging.getLogger(__name__)


class MetadataExtractor:
    """Extracteur métadonnées documents médicaux"""

    def __init__(self):
        # Patterns pour détection dates (format belge)
        self.date_patterns = [
            r"\d{1,2}[/-]\d{1,2}[/-]\d{2,4}",  # 15/11/2025 ou 15-11-2025
            r"\d{1,2}\s+\w+\s+\d{4}",  # 15 novembre 2025
            r"\d{4}[/-]\d{1,2}[/-]\d{1,2}",  # 2025-11-15
        ]

        # Patterns pour détection médecins
        self.doctor_patterns = [
            r"Dr\.?\s+([A-Z][a-z]+(?:\s+[A-Z][a-z]+)*)",  # Dr. Dupont
            r"Docteur\s+([A-Z][a-z]+(?:\s+[A-Z][a-z]+)*)",  # Docteur Martin
            r"([A-Z][a-z]+(?:\s+[A-Z][a-z]+)*),\s*Dr\.?",  # Dupont, Dr.
        ]

        # Patterns pour détection types examens
        self.exam_patterns = {
            "radio": r"(?:radio|radiographie|RX|X-ray)",
            "analyse": r"(?:analyse|prélèvement|sang|urine)",
            "scanner": r"(?:scanner|CT|tomodensitométrie)",
            "irm": r"(?:IRM|imagerie par résonance)",
            "echographie": r"(?:échographie|échographie|ultrasons)",
            "biopsie": r"(?:biopsie|prélèvement)",
        }

    def extract_metadata(self, text: str) -> dict[str, Any]:
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
            "date": self._extract_date(text),
            "doctor_name": self._extract_doctor_name(text),
            "doctor_specialty": self._extract_specialty(text),
            "exam_type": self._extract_exam_type(text),
            "document_type": self._classify_document_type(text),
            "keywords": self._extract_keywords(text),
        }

        return metadata

    def _extract_date(self, text: str) -> datetime | None:
        """Extrait la date du document"""
        for pattern in self.date_patterns:
            matches = re.findall(pattern, text)
            if matches:
                try:
                    # Essayer de parser la date
                    date_str = matches[0]
                    # Normaliser format
                    if "/" in date_str:
                        parts = date_str.split("/")
                        if len(parts) == 3:
                            day, month, year = parts
                            if len(year) == 2:
                                year = "20" + year
                            return datetime(int(year), int(month), int(day))
                except Exception:
                    # Ignorer les formats de date invalides et continuer avec les suivants
                    continue  # nosec B112
        return None

    def _extract_doctor_name(self, text: str) -> str | None:
        """Extrait le nom du médecin"""
        for pattern in self.doctor_patterns:
            matches = re.findall(pattern, text, re.IGNORECASE)
            if matches:
                result = matches[0].strip()
                return str(result) if result else None
        return None

    def _extract_specialty(self, text: str) -> str | None:
        """Extrait la spécialité du médecin"""
        specialties = [
            "cardiologue",
            "dermatologue",
            "gynécologue",
            "ophtalmologue",
            "orthopédiste",
            "pneumologue",
            "rhumatologue",
            "neurologue",
            "généraliste",
            "médecin général",
        ]

        text_lower = text.lower()
        for specialty in specialties:
            if specialty in text_lower:
                return specialty.capitalize()
        return None

    def _extract_exam_type(self, text: str) -> str | None:
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
        if any(
            word in text_lower for word in ["ordonnance", "prescription", "médicament"]
        ):
            return "ordonnance"
        elif any(word in text_lower for word in ["résultat", "analyse", "laboratoire"]):
            return "resultat"
        elif any(
            word in text_lower for word in ["compte-rendu", "rapport", "consultation"]
        ):
            return "compte_rendu"
        else:
            return "autre"

    def _extract_keywords(self, text: str) -> list[str]:
        """Extrait mots-clés importants"""
        # Mots-clés médicaux communs
        medical_keywords = [
            "diagnostic",
            "traitement",
            "symptôme",
            "pathologie",
            "médicament",
            "posologie",
            "dosage",
            "effet secondaire",
        ]

        found_keywords = []
        text_lower = text.lower()
        for keyword in medical_keywords:
            if keyword in text_lower:
                found_keywords.append(keyword)

        return found_keywords
