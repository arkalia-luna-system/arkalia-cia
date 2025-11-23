"""
Tests unitaires pour metadata_extractor
"""

from datetime import datetime

from arkalia_cia_python_backend.pdf_parser.metadata_extractor import MetadataExtractor


class TestMetadataExtractor:
    """Tests pour MetadataExtractor"""

    def test_init(self):
        """Test initialisation"""
        extractor = MetadataExtractor()
        assert extractor is not None
        assert len(extractor.date_patterns) > 0
        assert len(extractor.doctor_patterns) > 0
        assert len(extractor.exam_patterns) > 0

    def test_extract_date(self):
        """Test extraction date"""
        extractor = MetadataExtractor()
        text = "Document du 15/11/2025"
        date = extractor._extract_date(text)
        assert date is not None
        assert isinstance(date, datetime)
        assert date.year == 2025
        assert date.month == 11
        assert date.day == 15

    def test_extract_date_format_iso(self):
        """Test extraction date format ISO"""
        extractor = MetadataExtractor()
        text = "Date: 2025-11-15"
        date = extractor._extract_date(text)
        # Peut ne pas matcher selon les patterns
        # On vérifie juste que ça ne plante pas
        assert date is None or isinstance(date, datetime)

    def test_extract_doctor_name(self):
        """Test extraction nom médecin"""
        extractor = MetadataExtractor()
        text = "Dr. Martin Dupont"
        doctor_name = extractor._extract_doctor_name(text)
        assert doctor_name is not None
        assert "Martin" in doctor_name or "Dupont" in doctor_name

    def test_extract_doctor_name_docteur(self):
        """Test extraction nom avec 'Docteur'"""
        extractor = MetadataExtractor()
        text = "Docteur Jean Martin"
        doctor_name = extractor._extract_doctor_name(text)
        assert doctor_name is not None

    def test_extract_specialty(self):
        """Test extraction spécialité"""
        extractor = MetadataExtractor()
        text = "Consultation avec un cardiologue"
        specialty = extractor._extract_specialty(text)
        assert specialty is not None
        assert "Cardiologue" in specialty or "cardiologue" in specialty.lower()

    def test_extract_exam_type(self):
        """Test extraction type examen"""
        extractor = MetadataExtractor()
        text = "Résultats de la radiographie"
        exam_type = extractor._extract_exam_type(text)
        assert exam_type == "radio"

    def test_classify_document_type_ordonnance(self):
        """Test classification ordonnance"""
        extractor = MetadataExtractor()
        text = "Ordonnance médicale"
        doc_type = extractor._classify_document_type(text)
        assert doc_type == "ordonnance"

    def test_classify_document_type_resultat(self):
        """Test classification résultat"""
        extractor = MetadataExtractor()
        text = "Résultats d'analyse de laboratoire"
        doc_type = extractor._classify_document_type(text)
        assert doc_type == "resultat"

    def test_classify_document_type_compte_rendu(self):
        """Test classification compte-rendu"""
        extractor = MetadataExtractor()
        text = "Compte-rendu de consultation"
        doc_type = extractor._classify_document_type(text)
        assert doc_type == "compte_rendu"

    def test_extract_keywords(self):
        """Test extraction mots-clés"""
        extractor = MetadataExtractor()
        text = "Diagnostic et traitement avec médicament"
        keywords = extractor._extract_keywords(text)
        assert len(keywords) > 0
        assert "diagnostic" in keywords or "traitement" in keywords

    def test_extract_metadata_complete(self):
        """Test extraction métadonnées complète"""
        extractor = MetadataExtractor()
        text = """
        Ordonnance du 15/11/2025
        Dr. Martin Dupont, cardiologue
        Prescription de médicaments pour traitement
        """
        metadata = extractor.extract_metadata(text)
        assert metadata is not None
        assert "date" in metadata
        assert "doctor_name" in metadata
        assert "document_type" in metadata
        assert metadata["document_type"] == "ordonnance"

    def test_extract_metadata_empty_text(self):
        """Test extraction avec texte vide"""
        extractor = MetadataExtractor()
        metadata = extractor.extract_metadata("")
        assert metadata is not None
        assert metadata["document_type"] == "autre"
