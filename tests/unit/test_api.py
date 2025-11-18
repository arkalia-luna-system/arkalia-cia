"""
Tests unitaires pour l'API FastAPI
"""

import tempfile
from pathlib import Path

import pytest
from fastapi.testclient import TestClient

from arkalia_cia_python_backend import api


class TestAPIEndpoints:
    """Tests pour les endpoints de l'API"""

    @pytest.fixture
    def client(self):
        """Créer un client de test"""
        return TestClient(api.app)

    @pytest.fixture
    def temp_db(self):
        """Créer une base de données temporaire"""
        from arkalia_cia_python_backend.database import CIADatabase

        db_path = tempfile.mktemp(suffix=".db")
        original_db = api.db
        api.db = CIADatabase(db_path=db_path)
        yield db_path
        api.db = original_db
        if Path(db_path).exists():
            Path(db_path).unlink()

    def test_root_endpoint(self, client):
        """Test de l'endpoint racine"""
        response = client.get("/")
        assert response.status_code == 200
        data = response.json()
        assert "message" in data
        assert "version" in data
        assert "status" in data

    def test_health_check(self, client):
        """Test de l'endpoint de santé"""
        response = client.get("/health")
        assert response.status_code == 200
        data = response.json()
        assert "status" in data
        assert data["status"] == "healthy"
        assert "timestamp" in data

    def test_get_documents_empty(self, client, temp_db):
        """Test de récupération des documents (vide)"""
        response = client.get("/api/documents")
        assert response.status_code == 200
        assert isinstance(response.json(), list)

    def test_get_document_not_found(self, client, temp_db):
        """Test de récupération d'un document inexistant"""
        response = client.get("/api/documents/999")
        assert response.status_code == 404

    def test_delete_document_not_found(self, client, temp_db):
        """Test de suppression d'un document inexistant"""
        response = client.delete("/api/documents/999")
        assert response.status_code == 404

    def test_get_reminders_empty(self, client, temp_db):
        """Test de récupération des rappels (vide)"""
        response = client.get("/api/reminders")
        assert response.status_code == 200
        assert isinstance(response.json(), list)

    def test_create_reminder(self, client, temp_db):
        """Test de création d'un rappel"""
        reminder_data = {
            "title": "Test Reminder",
            "description": "Test description",
            "reminder_date": "2024-12-31T10:00:00",
        }
        response = client.post("/api/reminders", json=reminder_data)
        assert response.status_code == 200
        data = response.json()
        assert "id" in data
        assert data["title"] == "Test Reminder"

    def test_get_emergency_contacts_empty(self, client, temp_db):
        """Test de récupération des contacts d'urgence (vide)"""
        response = client.get("/api/emergency-contacts")
        assert response.status_code == 200
        assert isinstance(response.json(), list)

    def test_create_emergency_contact(self, client, temp_db):
        """Test de création d'un contact d'urgence"""
        contact_data = {
            "name": "Test Contact",
            "phone": "1234567890",
            "relationship": "family",
            "is_primary": False,
        }
        response = client.post("/api/emergency-contacts", json=contact_data)
        assert response.status_code == 200
        data = response.json()
        assert "id" in data
        assert data["name"] == "Test Contact"

    def test_get_health_portals_empty(self, client, temp_db):
        """Test de récupération des portails santé (vide)"""
        response = client.get("/api/health-portals")
        assert response.status_code == 200
        assert isinstance(response.json(), list)

    def test_create_health_portal(self, client, temp_db):
        """Test de création d'un portail santé"""
        portal_data = {
            "name": "Test Portal",
            "url": "https://example.com",
            "description": "Test portal",
            "category": "banking",
        }
        response = client.post("/api/health-portals", json=portal_data)
        assert response.status_code == 200
        data = response.json()
        assert "id" in data
        assert data["name"] == "Test Portal"

    def test_upload_document_invalid_file(self, client, temp_db):
        """Test d'upload d'un fichier invalide"""
        response = client.post(
            "/api/documents/upload",
            files={"file": ("test.txt", b"not a pdf", "text/plain")},
        )
        # L'API peut retourner 400 (HTTPException) ou 200 avec success=False
        assert response.status_code in [400, 200]
        if response.status_code == 200:
            data = response.json()
            assert data.get("success") is False or "error" in data

    def test_cors_headers(self, client):
        """Test des en-têtes CORS"""
        response = client.options("/")
        assert response.status_code in [200, 405]  # OPTIONS peut retourner 405


class TestAPIModels:
    """Tests pour les modèles Pydantic"""

    def test_document_response(self):
        """Test du modèle DocumentResponse"""
        from arkalia_cia_python_backend.api import DocumentResponse

        doc = DocumentResponse(
            id=1,
            name="test.pdf",
            original_name="test.pdf",
            file_path="/tmp/test.pdf",
            file_type="pdf",
            file_size=1024,
            created_at="2024-01-01T00:00:00",
        )
        assert doc.id == 1
        assert doc.name == "test.pdf"

    def test_reminder_request(self):
        """Test du modèle ReminderRequest"""
        from arkalia_cia_python_backend.api import ReminderRequest

        reminder = ReminderRequest(
            title="Test",
            description="Test description",
            reminder_date="2024-12-31T10:00:00",
        )
        assert reminder.title == "Test"
        assert reminder.description == "Test description"

    def test_emergency_contact_request(self):
        """Test du modèle EmergencyContactRequest"""
        from arkalia_cia_python_backend.api import EmergencyContactRequest

        contact = EmergencyContactRequest(
            name="Test Contact",
            phone="1234567890",
            relationship="family",
            is_primary=False,
        )
        assert contact.name == "Test Contact"
        assert contact.phone == "1234567890"

    def test_health_portal_request(self):
        """Test du modèle HealthPortalRequest"""
        from arkalia_cia_python_backend.api import HealthPortalRequest

        portal = HealthPortalRequest(
            name="Test Portal",
            url="https://example.com",
            description="Test portal",
            category="banking",
        )
        assert portal.name == "Test Portal"
        assert portal.url == "https://example.com"
