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

        # Patterns pour détection médecins (enrichis)
        self.doctor_patterns = [
            r"Dr\.?\s+([A-Z][a-z]+(?:\s+[A-Z][a-z]+)*)",  # Dr. Dupont
            r"Docteur\s+([A-Z][a-z]+(?:\s+[A-Z][a-z]+)*)",  # Docteur Martin
            r"([A-Z][a-z]+(?:\s+[A-Z][a-z]+)*),\s*Dr\.?",  # Dupont, Dr.
            r"Pr\.?\s+([A-Z][a-z]+(?:\s+[A-Z][a-z]+)*)",  # Pr. Dupont (Professeur)
            r"Professeur\s+([A-Z][a-z]+(?:\s+[A-Z][a-z]+)*)",  # Professeur Martin
            r"M\.?\s+([A-Z][a-z]+(?:\s+[A-Z][a-z]+)*)",  # M. Dupont
            r"Mme\.?\s+([A-Z][a-z]+(?:\s+[A-Z][a-z]+)*)",  # Mme Dupont
            r"([A-Z][a-z]+(?:\s+[A-Z][a-z]+)*)\s+MD",  # Dupont MD
        ]

        # Patterns pour détection types examens (enrichis avec synonymes et abréviations)
        self.exam_patterns = {
            "radio": r"(?:radio|radiographie|RX|X-ray|rayon\s*X|radiologie)",
            "analyse": r"(?:analyse|prélèvement|sang|urine|sanguin|urinaire|labo|laboratoire|test\s*sanguin)",
            "scanner": r"(?:scanner|CT|tomodensitométrie|TDM|scanner\s*CT)",
            "irm": r"(?:IRM|imagerie\s*par\s*résonance|résonance\s*magnétique|MRI)",
            "echographie": r"(?:échographie|échographie|ultrasons|ultrason|écho|US)",
            "biopsie": r"(?:biopsie|prélèvement\s*biopsique|biopsie\s*chirurgicale)",
            "mammographie": r"(?:mammographie|mammo)",
            "densitometrie": r"(?:densitométrie|densitométrie\s*osseuse|DEXA)",
            "endoscopie": r"(?:endoscopie|fibroscopie|coloscopie|gastroscopie)",
            "electrocardiogramme": r"(?:électrocardiogramme|ECG|électrocardiographie)",
            "electroencephalogramme": r"(?:électroencéphalogramme|EEG)",
        }

        # Patterns pour extraction enrichie (adresse, téléphone, email)
        self.address_patterns = [
            r"(?:rue|avenue|boulevard|chaussée|place|allée)\s+[A-Za-z0-9\s]+",
            r"\d+\s+(?:rue|avenue|boulevard|chaussée|place|allée)\s+[A-Za-z\s]+",
        ]
        self.postal_code_pattern = r"\b\d{4}\b"  # Code postal belge (4 chiffres)
        self.phone_patterns = [
            r"\+32\s*\d{1,2}\s*/\s*\d{2}\s*\.\s*\d{2}\s*\.\s*\d{2}",
            r"0\d{1}\s*/\s*\d{2}\s*\.\s*\d{2}\s*\.\s*\d{2}",
            r"0\d{1}\s*\d{2}\s*\d{2}\s*\d{2}",
            r"\+32\d{9}",
        ]
        self.email_pattern = r"\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b"

        # Patterns pour adresses belges
        self.address_patterns = [
            r"(?:rue|avenue|boulevard|chaussée|place|allée|chemin)\s+[A-Z][a-z]+(?:\s+[A-Z][a-z]+)*\s+\d+[a-z]?",  # Rue de la Paix 12
            r"\d+\s+(?:rue|avenue|boulevard|chaussée|place|allée|chemin)\s+[A-Z][a-z]+",  # 12 rue de la Paix
            r"[A-Z][a-z]+(?:\s+[A-Z][a-z]+)*\s+\d+[a-z]?",  # Nom de rue avec numéro
        ]

        # Patterns pour codes postaux belges (4 chiffres)
        self.postal_code_pattern = r"\b[1-9]\d{3}\b"

        # Patterns pour téléphones belges
        self.phone_patterns = [
            r"\+32\s?\d{1,2}\s?\d{2}\s?\d{2}\s?\d{2}\s?\d{2}",  # +32 470 12 34 56
            r"0[1-9]\s?\d{2}\s?\d{2}\s?\d{2}\s?\d{2}",  # 0470 12 34 56
            r"0[1-9]\d{8}",  # 0470123456
            r"04\d{2}\s?[/.-]?\s?\d{2}\s?[/.-]?\s?\d{2}\s?[/.-]?\s?\d{2}",  # 0470/12.34.56
        ]

        # Pattern pour emails
        self.email_pattern = r"\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b"

    def extract_metadata(self, text: str) -> dict[str, Any]:
        """
        Extrait métadonnées depuis texte PDF

        Returns:
            {
                'date': Optional[datetime],
                'doctor_name': Optional[str],
                'doctor_specialty': Optional[str],
                'exam_type': Optional[str],
                'exam_type_confidence': Optional[float],  # Score de confiance 0-1
                'document_type': str,  # 'ordonnance', 'resultat', 'compte_rendu'
                'keywords': List[str],
                'needs_verification': bool,  # True si confiance < 0.7
                'doctor_address': Optional[str],
                'doctor_phone': Optional[str],
                'doctor_email': Optional[str],
            }
        """
        exam_result = self._extract_exam_type_with_confidence(text)

        metadata = {
            "date": self._extract_date(text),
            "doctor_name": self._extract_doctor_name(text),
            "doctor_specialty": self._extract_specialty(text),
            "exam_type": exam_result.get("type"),
            "exam_type_confidence": exam_result.get("confidence"),
            "document_type": self._classify_document_type(text),
            "keywords": self._extract_keywords(text),
            "needs_verification": (
                exam_result.get("confidence", 1.0) < 0.7
                if exam_result.get("type")
                else False
            ),
            "doctor_address": self._extract_address(text),
            "doctor_phone": self._extract_phone(text),
            "doctor_email": self._extract_email(text),
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
                    # Ignorer les formats de date invalides et continuer
                    # avec les suivants
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
        """Extrait le type d'examen (méthode legacy)"""
        result = self._extract_exam_type_with_confidence(text)
        exam_type = result.get("type")
        return str(exam_type) if exam_type is not None else None

    def _extract_exam_type_with_confidence(self, text: str) -> dict[str, Any]:
        """
        Extrait le type d'examen avec score de confiance

        Returns:
            {'type': str | None, 'confidence': float}
        """
        text_lower = text.lower()
        best_match = None
        best_confidence = 0.0

        for exam_type, pattern in self.exam_patterns.items():
            matches = re.findall(pattern, text_lower, re.IGNORECASE)
            if matches:
                # Calculer confiance basée sur nombre de matches et longueur
                match_count = len(matches)
                # Confiance de base : 0.8 si match unique, 0.9 si multiple
                confidence = (
                    0.8 if match_count == 1 else min(0.95, 0.8 + (match_count * 0.05))
                )

                # Bonus si le terme exact apparaît (pas juste dans un mot)
                exact_match = re.search(rf"\b{pattern}\b", text_lower, re.IGNORECASE)
                if exact_match:
                    confidence = min(1.0, confidence + 0.1)

                if confidence > best_confidence:
                    best_match = exam_type
                    best_confidence = confidence

        return {
            "type": best_match,
            "confidence": best_confidence,
        }

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

    def _extract_address(self, text: str) -> str | None:
        """Extrait l'adresse du médecin (format belge)"""
        # Chercher une adresse avec code postal
        for pattern in self.address_patterns:
            matches = re.findall(pattern, text, re.IGNORECASE)
            if matches:
                address = matches[0].strip()
                # Chercher le code postal à proximité (dans les 50 caractères suivants)
                address_pos = text.find(address)
                if address_pos != -1:
                    following_text = text[address_pos : address_pos + 100]
                    postal_match = re.search(self.postal_code_pattern, following_text)
                    if postal_match:
                        # Chercher la ville après le code postal
                        city_match = re.search(
                            r"\d{4}\s+([A-Z][a-z]+(?:\s+[A-Z][a-z]+)*)",
                            following_text,
                        )
                        if city_match:
                            return str(
                                f"{address}, {postal_match.group()} {city_match.group(1)}"
                            )
                        return str(f"{address}, {postal_match.group()}")
                return str(address)
        return None

    def _extract_phone(self, text: str) -> str | None:
        """Extrait le numéro de téléphone (format belge)"""
        for pattern in self.phone_patterns:
            matches = re.findall(pattern, text)
            if matches:
                phone = matches[0].strip()
                # Nettoyer le format
                phone = re.sub(r"[\s\-/\.]", "", phone)
                # Normaliser en format +32 si commence par 0
                if phone.startswith("0"):
                    phone = "+32" + phone[1:]
                elif not phone.startswith("+32"):
                    phone = "+32" + phone
                return str(phone)
        return None

    def _extract_email(self, text: str) -> str | None:
        """Extrait l'email"""
        matches = re.findall(self.email_pattern, text)
        if matches:
            # Retourner le premier email trouvé
            return str(matches[0].strip().lower())
        return None
