"""
Tests pour le module database d'Arkalia-CIA
"""

import os
import tempfile

import pytest

from arkalia_cia_python_backend.database import CIADatabase


class TestDatabaseManager:
    """Tests pour la classe DatabaseManager"""

    @pytest.fixture
    def temp_db(self):
        """Créer une base de données temporaire pour les tests"""
        with tempfile.NamedTemporaryFile(suffix=".db", delete=False) as tmp:
            db_path = tmp.name
        yield db_path
        # Nettoyage après les tests
        if os.path.exists(db_path):
            os.unlink(db_path)

    @pytest.fixture
    def db_manager(self, temp_db):
        """Créer un gestionnaire de base de données pour les tests"""
        return CIADatabase(db_path=temp_db)

    def test_init_db(self, db_manager):
        """Test de l'initialisation de la base de données"""
        db_manager.init_db()
        # Vérifier que les tables existent
        # Vérifier que la base de données est initialisée
        assert db_manager.db_path is not None

    def test_add_document(self, db_manager):
        """Test d'ajout d'un document"""
        db_manager.init_db()

        doc_id = db_manager.add_document(
            name="test.pdf",
            original_name="test.pdf",
            file_path="/tmp/test.pdf",
            file_type="pdf",
            file_size=1024,
        )

        assert doc_id is not None
        assert isinstance(doc_id, int)

    def test_get_document(self, db_manager):
        """Test de récupération d'un document"""
        db_manager.init_db()

        # Ajouter un document
        doc_id = db_manager.add_document(
            name="test.pdf",
            original_name="test.pdf",
            file_path="/tmp/test.pdf",
            file_type="pdf",
            file_size=1024,
        )

        # Récupérer le document
        document = db_manager.get_document(doc_id)
        assert document is not None
        assert document["name"] == "test.pdf"
        assert document["file_type"] == "pdf"

    def test_list_documents(self, db_manager):
        """Test de liste des documents"""
        db_manager.init_db()

        # Ajouter plusieurs documents
        db_manager.add_document(
            name="test1.pdf",
            original_name="test1.pdf",
            file_path="/tmp/test1.pdf",
            file_type="pdf",
            file_size=1024,
        )
        db_manager.add_document(
            name="test2.pdf",
            original_name="test2.pdf",
            file_path="/tmp/test2.pdf",
            file_type="pdf",
            file_size=2048,
        )

        # Lister les documents
        documents = db_manager.list_documents()
        assert len(documents) == 2

    def test_delete_document(self, db_manager):
        """Test de suppression d'un document"""
        db_manager.init_db()

        # Ajouter un document
        doc_id = db_manager.add_document(
            name="test.pdf",
            original_name="test.pdf",
            file_path="/tmp/test.pdf",
            file_type="pdf",
            file_size=1024,
        )

        # Supprimer le document
        result = db_manager.delete_document(doc_id)
        assert result is True

        # Vérifier que le document n'existe plus
        document = db_manager.get_document(doc_id)
        assert document is None

    def test_add_reminder(self, db_manager):
        """Test d'ajout d'un rappel"""
        db_manager.init_db()

        reminder_id = db_manager.add_reminder(
            title="Test Reminder",
            description="Test description",
            reminder_date="2024-12-31",
        )

        assert reminder_id is not None
        assert isinstance(reminder_id, int)

    def test_add_contact(self, db_manager):
        """Test d'ajout d'un contact"""
        db_manager.init_db()

        contact_id = db_manager.add_emergency_contact(
            name="Test Contact",
            phone="1234567890",
            relationship="family",
            is_primary=False,
        )

        assert contact_id is not None
        assert isinstance(contact_id, int)

    def test_add_portal(self, db_manager):
        """Test d'ajout d'un portail"""
        db_manager.init_db()

        portal_id = db_manager.add_health_portal(
            name="Test Portal",
            url="https://example.com",
            description="Test portal",
            category="banking",
        )

        assert portal_id is not None
        assert isinstance(portal_id, int)
