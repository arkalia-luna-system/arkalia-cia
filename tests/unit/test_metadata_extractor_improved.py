"""Tests pour améliorations extraction métadonnées Phase 4"""

import pytest
from arkalia_cia_python_backend.pdf_parser.metadata_extractor import MetadataExtractor


class TestMetadataExtractorImproved:
    """Tests améliorations extraction Phase 4"""

    def test_extract_exam_type_with_confidence(self):
        """Test extraction type examen avec score de confiance"""
        extractor = MetadataExtractor()

        # Test scanner avec confiance élevée
        text1 = "Résultat du scanner CT de la tête"
        result = extractor._extract_exam_type_with_confidence(text1)
        assert result["type"] == "scanner"
        assert result["confidence"] > 0.7

        # Test IRM
        text2 = "IRM du genou droit"
        result = extractor._extract_exam_type_with_confidence(text2)
        assert result["type"] == "irm"
        assert result["confidence"] > 0.7

        # Test avec synonymes
        text3 = "Tomodensitométrie thoracique"
        result = extractor._extract_exam_type_with_confidence(text3)
        assert result["type"] == "scanner"
        assert result["confidence"] > 0.7

        # Test sans type d'examen
        text4 = "Document médical général"
        result = extractor._extract_exam_type_with_confidence(text4)
        assert result["type"] is None
        assert result["confidence"] == 0.0

    def test_extract_metadata_with_confidence(self):
        """Test extraction métadonnées avec confiance"""
        extractor = MetadataExtractor()

        text = "Scanner du 15/11/2025 - Dr. Dupont"
        metadata = extractor.extract_metadata(text)

        assert metadata["exam_type"] == "scanner"
        assert metadata["exam_type_confidence"] is not None
        assert isinstance(metadata["exam_type_confidence"], float)
        assert 0.0 <= metadata["exam_type_confidence"] <= 1.0
        assert metadata["needs_verification"] is False  # Confiance > 0.7

    def test_needs_verification_flag(self):
        """Test flag needs_verification quand confiance faible"""
        extractor = MetadataExtractor()

        # Texte ambigu (peut être scanner ou autre)
        text = "Examen médical"
        metadata = extractor.extract_metadata(text)

        # Si aucun type détecté, needs_verification devrait être False
        if metadata["exam_type"] is None:
            assert metadata["needs_verification"] is False
        else:
            # Si type détecté mais confiance faible
            if metadata["exam_type_confidence"] < 0.7:
                assert metadata["needs_verification"] is True

    def test_enriched_doctor_patterns(self):
        """Test patterns médecins enrichis"""
        extractor = MetadataExtractor()

        # Test Pr.
        text1 = "Pr. Martin, cardiologue"
        metadata = extractor.extract_metadata(text1)
        assert metadata["doctor_name"] is not None
        assert "Martin" in metadata["doctor_name"]

        # Test Professeur
        text2 = "Professeur Dupont"
        metadata = extractor.extract_metadata(text2)
        assert metadata["doctor_name"] is not None

        # Test Mme
        text3 = "Mme. Dubois, gynécologue"
        metadata = extractor.extract_metadata(text3)
        assert metadata["doctor_name"] is not None

    def test_enriched_exam_patterns(self):
        """Test patterns examens enrichis avec synonymes"""
        extractor = MetadataExtractor()

        # Test synonymes scanner
        texts = [
            "Scanner CT",
            "Tomodensitométrie",
            "TDM",
        ]
        for text in texts:
            result = extractor._extract_exam_type_with_confidence(text)
            assert result["type"] == "scanner"

        # Test synonymes IRM
        texts_irm = [
            "IRM",
            "Imagerie par résonance magnétique",
            "MRI",
        ]
        for text in texts_irm:
            result = extractor._extract_exam_type_with_confidence(text)
            assert result["type"] == "irm"

    def test_extract_address(self):
        """Test extraction adresse"""
        extractor = MetadataExtractor()

        text = "Dr. Dupont, Rue de la Paix 12, 1000 Bruxelles"
        address = extractor._extract_address(text)
        assert address is not None
        assert "Rue" in address or "1000" in address

    def test_extract_phone(self):
        """Test extraction téléphone"""
        extractor = MetadataExtractor()

        texts = [
            "Téléphone: 0470/12.34.56",
            "Tel: +32 470 12 34 56",
            "04 70 12 34 56",
        ]

        for text in texts:
            phone = extractor._extract_phone(text)
            assert phone is not None
            # Vérifier format normalisé
            assert "+32" in phone or phone.startswith("0")

    def test_extract_email(self):
        """Test extraction email"""
        extractor = MetadataExtractor()

        text = "Contact: docteur.dupont@example.com"
        email = extractor._extract_email(text)
        assert email is not None
        assert "@" in email
        assert ".com" in email

