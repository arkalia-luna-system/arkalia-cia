"""
Tests unitaires pour dependencies
"""

from arkalia_cia_python_backend.dependencies import (
    get_conversational_ai,
    get_database,
    get_document_service,
    get_pattern_analyzer,
    get_pdf_processor,
)


class TestDependencies:
    """Tests pour les dépendances FastAPI"""

    def test_get_database(self):
        """Test get_database retourne une instance"""
        db = get_database()
        assert db is not None
        # Vérifier que c'est la même instance (cache)
        db2 = get_database()
        assert db is db2

    def test_get_pdf_processor(self):
        """Test get_pdf_processor retourne une instance"""
        processor = get_pdf_processor()
        assert processor is not None
        # Vérifier que c'est la même instance (cache)
        processor2 = get_pdf_processor()
        assert processor is processor2

    def test_get_conversational_ai(self):
        """Test get_conversational_ai retourne une instance"""
        ai = get_conversational_ai()
        assert ai is not None
        # Vérifier que c'est la même instance (cache)
        ai2 = get_conversational_ai()
        assert ai is ai2

    def test_get_pattern_analyzer(self):
        """Test get_pattern_analyzer retourne une instance"""
        analyzer = get_pattern_analyzer()
        assert analyzer is not None
        # Vérifier que c'est la même instance (cache)
        analyzer2 = get_pattern_analyzer()
        assert analyzer is analyzer2

    def test_get_document_service(self):
        """Test get_document_service retourne une instance"""
        service = get_document_service()
        assert service is not None
        # Vérifier que c'est la même instance (cache)
        service2 = get_document_service()
        assert service is service2

    def test_document_service_has_dependencies(self):
        """Test que DocumentService a ses dépendances"""
        service = get_document_service()
        assert hasattr(service, "db") or hasattr(service, "_db")
        assert hasattr(service, "pdf_processor") or hasattr(service, "_pdf_processor")
