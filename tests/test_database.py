"""
Tests pour le module database d'Arkalia-CIA
"""

import os
import tempfile

import pytest

from arkalia_cia_python_backend.database import CIADatabase


class TestDatabaseManager:
    """Tests pour la classe DatabaseManager"""

    @pytest.fixture(scope="class")
    def temp_db(self):
        """Créer une base de données temporaire pour les tests"""
        with tempfile.NamedTemporaryFile(suffix=".db", delete=False) as tmp:
            db_path = tmp.name
        yield db_path
        # Nettoyage après les tests
        if os.path.exists(db_path):
            os.unlink(db_path)

    @pytest.fixture(scope="class")
    def db_manager(self, temp_db):
        """Créer un gestionnaire de base de données pour les tests"""
        db = CIADatabase(db_path=temp_db)
        db.init_db()  # Initialiser une seule fois pour toute la classe
        return db

    def test_init_db(self, db_manager):
        """Test de l'initialisation de la base de données"""
        # La DB est déjà initialisée par la fixture
        assert db_manager.db_path is not None

    def test_add_document(self, db_manager):
        """Test d'ajout d'un document"""
        # La DB est déjà initialisée par la fixture

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
        # La DB est déjà initialisée par la fixture

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
        # La DB est déjà initialisée par la fixture

        # Nettoyer les documents existants pour isoler ce test
        existing_docs = db_manager.list_documents()
        for doc in existing_docs:
            db_manager.delete_document(doc["id"])

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
        # La DB est déjà initialisée par la fixture

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
        # La DB est déjà initialisée par la fixture

        reminder_id = db_manager.add_reminder(
            title="Test Reminder",
            description="Test description",
            reminder_date="2024-12-31",
        )

        assert reminder_id is not None
        assert isinstance(reminder_id, int)

    def test_add_contact(self, db_manager):
        """Test d'ajout d'un contact"""
        # La DB est déjà initialisée par la fixture

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
        # La DB est déjà initialisée par la fixture

        portal_id = db_manager.add_health_portal(
            name="Test Portal",
            url="https://example.com",
            description="Test portal",
            category="banking",
        )

        assert portal_id is not None
        assert isinstance(portal_id, int)

    def test_get_reminder(self, db_manager):
        """Test de récupération d'un rappel"""
        # La DB est déjà initialisée par la fixture

        reminder_id = db_manager.add_reminder(
            title="Test Reminder",
            description="Test description",
            reminder_date="2024-12-31",
        )

        reminder = db_manager.get_reminder(reminder_id)
        assert reminder is not None
        assert reminder["title"] == "Test Reminder"

    def test_get_contact(self, db_manager):
        """Test de récupération d'un contact"""
        # La DB est déjà initialisée par la fixture

        contact_id = db_manager.add_emergency_contact(
            name="Test Contact",
            phone="1234567890",
            relationship="family",
            is_primary=False,
        )

        contact = db_manager.get_contact(contact_id)
        assert contact is not None
        assert contact["name"] == "Test Contact"

    def test_get_portal(self, db_manager):
        """Test de récupération d'un portail"""
        # La DB est déjà initialisée par la fixture

        portal_id = db_manager.add_health_portal(
            name="Test Portal",
            url="https://example.com",
            description="Test portal",
            category="banking",
        )

        portal = db_manager.get_portal(portal_id)
        assert portal is not None
        assert portal["name"] == "Test Portal"

    def test_delete_reminder(self, db_manager):
        """Test de suppression d'un rappel"""
        # La DB est déjà initialisée par la fixture

        reminder_id = db_manager.add_reminder(
            title="Test Reminder",
            description="Test description",
            reminder_date="2024-12-31",
        )

        result = db_manager.delete_reminder(reminder_id)
        assert result is True

        reminder = db_manager.get_reminder(reminder_id)
        assert reminder is None

    def test_delete_contact(self, db_manager):
        """Test de suppression d'un contact"""
        # La DB est déjà initialisée par la fixture

        contact_id = db_manager.add_emergency_contact(
            name="Test Contact",
            phone="1234567890",
            relationship="family",
            is_primary=False,
        )

        result = db_manager.delete_contact(contact_id)
        assert result is True

        contact = db_manager.get_contact(contact_id)
        assert contact is None

    def test_delete_portal(self, db_manager):
        """Test de suppression d'un portail"""
        # La DB est déjà initialisée par la fixture

        portal_id = db_manager.add_health_portal(
            name="Test Portal",
            url="https://example.com",
            description="Test portal",
            category="banking",
        )

        result = db_manager.delete_portal(portal_id)
        assert result is True

        portal = db_manager.get_portal(portal_id)
        assert portal is None

    def test_list_reminders(self, db_manager):
        """Test de liste des rappels"""
        # La DB est déjà initialisée par la fixture

        # Nettoyer les rappels existants pour isoler ce test
        existing_reminders = db_manager.list_reminders()
        for reminder in existing_reminders:
            db_manager.delete_reminder(reminder["id"])

        db_manager.add_reminder(
            title="Reminder 1",
            description="Description 1",
            reminder_date="2024-12-31",
        )
        db_manager.add_reminder(
            title="Reminder 2",
            description="Description 2",
            reminder_date="2024-12-30",
        )

        reminders = db_manager.list_reminders()
        assert len(reminders) == 2

    def test_list_contacts(self, db_manager):
        """Test de liste des contacts"""
        # La DB est déjà initialisée par la fixture

        # Nettoyer les contacts existants pour isoler ce test
        existing_contacts = db_manager.list_contacts()
        for contact in existing_contacts:
            db_manager.delete_contact(contact["id"])

        db_manager.add_emergency_contact(
            name="Contact 1",
            phone="1111111111",
            relationship="family",
            is_primary=False,
        )
        db_manager.add_emergency_contact(
            name="Contact 2",
            phone="2222222222",
            relationship="friend",
            is_primary=True,
        )

        contacts = db_manager.list_contacts()
        assert len(contacts) == 2

    def test_list_portals(self, db_manager):
        """Test de liste des portails"""
        # La DB est déjà initialisée par la fixture

        # Nettoyer les portails existants pour isoler ce test
        existing_portals = db_manager.list_portals()
        for portal in existing_portals:
            db_manager.delete_portal(portal["id"])

        db_manager.add_health_portal(
            name="Portal 1",
            url="https://example1.com",
            description="Portal 1",
            category="banking",
        )
        db_manager.add_health_portal(
            name="Portal 2",
            url="https://example2.com",
            description="Portal 2",
            category="medical",
        )

        portals = db_manager.list_portals()
        assert len(portals) == 2

    def test_save_document(self, db_manager):
        """Test de sauvegarde d'un document"""
        # La DB est déjà initialisée par la fixture

        doc_id = db_manager.save_document(
            filename="test.pdf",
            content="test content",
            metadata="test metadata",
        )

        assert doc_id is not None

    def test_save_reminder(self, db_manager):
        """Test de sauvegarde d'un rappel"""
        # La DB est déjà initialisée par la fixture

        reminder_id = db_manager.save_reminder(
            title="Test Reminder",
            description="Test description",
            reminder_date="2024-12-31",
        )

        assert reminder_id is not None

    def test_save_contact(self, db_manager):
        """Test de sauvegarde d'un contact"""
        # La DB est déjà initialisée par la fixture

        contact_id = db_manager.save_contact(
            name="Test Contact",
            phone="1234567890",
            relationship="family",
            is_primary=False,
        )

        assert contact_id is not None

    def test_save_portal(self, db_manager):
        """Test de sauvegarde d'un portail"""
        # La DB est déjà initialisée par la fixture

        portal_id = db_manager.save_portal(
            name="Test Portal",
            url="https://example.com",
            description="Test portal",
            category="banking",
        )

        assert portal_id is not None
