"""
Tests unitaires pour extraction enrichie (adresse, téléphone, email)
"""

from arkalia_cia_python_backend.pdf_parser.metadata_extractor import MetadataExtractor


class TestMetadataExtractorEnriched:
    """Tests pour extraction enrichie des métadonnées"""

    def test_extract_address_belgian_format(self):
        """Test extraction adresse format belge"""
        extractor = MetadataExtractor()
        text = "Dr. Martin, Rue de la Paix 12, 1000 Bruxelles"
        address = extractor._extract_address(text)
        assert address is not None
        assert "Rue" in address or "12" in address

    def test_extract_address_with_postal_code(self):
        """Test extraction adresse avec code postal"""
        extractor = MetadataExtractor()
        text = "Avenue Louise 123, 1050 Ixelles"
        address = extractor._extract_address(text)
        assert address is not None
        assert "1050" in address

    def test_extract_phone_belgian_format(self):
        """Test extraction téléphone format belge"""
        extractor = MetadataExtractor()
        text = "Téléphone: 0470 12 34 56"
        phone = extractor._extract_phone(text)
        assert phone is not None
        assert "+32" in phone or "470" in phone

    def test_extract_phone_international_format(self):
        """Test extraction téléphone format international"""
        extractor = MetadataExtractor()
        text = "Tel: +32 470 12 34 56"
        phone = extractor._extract_phone(text)
        assert phone is not None
        assert "+32" in phone

    def test_extract_phone_normalized(self):
        """Test normalisation téléphone"""
        extractor = MetadataExtractor()
        text = "0470123456"
        phone = extractor._extract_phone(text)
        assert phone is not None
        # Devrait être normalisé en +32
        assert phone.startswith("+32") or "470" in phone

    def test_extract_email(self):
        """Test extraction email"""
        extractor = MetadataExtractor()
        text = "Contact: dr.martin@example.com"
        email = extractor._extract_email(text)
        assert email is not None
        assert "@" in email
        assert "example.com" in email

    def test_extract_email_lowercase(self):
        """Test que l'email est en minuscules"""
        extractor = MetadataExtractor()
        text = "Email: DR.MARTIN@EXAMPLE.COM"
        email = extractor._extract_email(text)
        assert email is not None
        assert email == email.lower()

    def test_extract_metadata_complete_enriched(self):
        """Test extraction métadonnées complète avec données enrichies"""
        extractor = MetadataExtractor()
        text = """
        Dr. Martin Dupont, Cardiologue
        Rue de la Paix 12, 1000 Bruxelles
        Téléphone: 0470 12 34 56
        Email: dr.martin@example.com
        """
        metadata = extractor.extract_metadata(text)
        assert metadata is not None
        assert "doctor_name" in metadata
        assert "doctor_address" in metadata
        assert "doctor_phone" in metadata
        assert "doctor_email" in metadata
        assert metadata["doctor_address"] is not None
        assert metadata["doctor_phone"] is not None
        assert metadata["doctor_email"] is not None

    def test_extract_address_not_found(self):
        """Test extraction adresse non trouvée"""
        extractor = MetadataExtractor()
        text = "Document médical sans adresse"
        address = extractor._extract_address(text)
        assert address is None

    def test_extract_phone_not_found(self):
        """Test extraction téléphone non trouvé"""
        extractor = MetadataExtractor()
        text = "Document médical sans téléphone"
        phone = extractor._extract_phone(text)
        assert phone is None

    def test_extract_email_not_found(self):
        """Test extraction email non trouvé"""
        extractor = MetadataExtractor()
        text = "Document médical sans email"
        email = extractor._extract_email(text)
        assert email is None
