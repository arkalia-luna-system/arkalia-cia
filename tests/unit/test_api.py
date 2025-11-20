"""
Tests unitaires pour l'API FastAPI
"""

from pathlib import Path

import bcrypt
import pytest
from fastapi.testclient import TestClient

from arkalia_cia_python_backend import api
from arkalia_cia_python_backend.api import API_PREFIX
from arkalia_cia_python_backend.auth import create_access_token
from arkalia_cia_python_backend.dependencies import get_database


class TestAPIEndpoints:
    """Tests pour les endpoints de l'API"""

    @pytest.fixture
    def client(self, temp_db):
        """Créer un client de test avec dépendance override"""
        db_path, db = temp_db
        api.app.dependency_overrides[get_database] = lambda: db
        yield TestClient(api.app)
        api.app.dependency_overrides.clear()

    @pytest.fixture
    def temp_db(self):
        """Créer une base de données temporaire"""
        import uuid

        from arkalia_cia_python_backend.database import CIADatabase

        # Créer le fichier temporaire dans le répertoire courant pour éviter les problèmes de validation
        test_db_dir = Path.cwd() / "test_temp"
        test_db_dir.mkdir(exist_ok=True)
        db_path = str(test_db_dir / f"test_{uuid.uuid4().hex}.db")

        # OPTIMISATION: Créer directement une instance de CIADatabase (api.db n'existe plus)
        db = CIADatabase(db_path=db_path)
        db.init_db()
        yield db_path, db
        if Path(db_path).exists():
            Path(db_path).unlink()

    @pytest.fixture
    def auth_token(self, temp_db):
        """Créer un utilisateur de test et retourner un token"""
        # OPTIMISATION: Utiliser l'instance de DB directement (api.db n'existe plus)
        db_path, db = temp_db
        # Utiliser bcrypt directement pour éviter problèmes avec passlib
        password_hash = bcrypt.hashpw(b"test123", bcrypt.gensalt()).decode("utf-8")
        user_id = db.create_user(
            username="testuser", password_hash=password_hash, email="test@example.com"
        )
        token = create_access_token(
            data={"sub": str(user_id), "username": "testuser", "role": "user"}
        )
        return token

    @pytest.fixture
    def auth_headers(self, auth_token):
        """Retourne les headers d'authentification"""
        return {"Authorization": f"Bearer {auth_token}"}

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

    def test_get_documents_empty(self, client, temp_db, auth_headers):
        """Test de récupération des documents (vide)"""
        response = client.get(f"{API_PREFIX}/documents", headers=auth_headers)
        assert response.status_code == 200
        assert isinstance(response.json(), list)

    def test_get_document_not_found(self, client, temp_db, auth_headers):
        """Test de récupération d'un document inexistant"""
        response = client.get(f"{API_PREFIX}/documents/999", headers=auth_headers)
        assert response.status_code == 404

    def test_delete_document_not_found(self, client, temp_db, auth_headers):
        """Test de suppression d'un document inexistant"""
        response = client.delete(f"{API_PREFIX}/documents/999", headers=auth_headers)
        assert response.status_code == 404

    def test_get_reminders_empty(self, client, temp_db, auth_headers):
        """Test de récupération des rappels (vide)"""
        response = client.get(f"{API_PREFIX}/reminders", headers=auth_headers)
        assert response.status_code == 200
        assert isinstance(response.json(), list)

    def test_create_reminder(self, client, temp_db, auth_headers):
        """Test de création d'un rappel"""
        reminder_data = {
            "title": "Test Reminder",
            "description": "Test description",
            "reminder_date": "2024-12-31T10:00:00",
        }
        response = client.post(
            f"{API_PREFIX}/reminders", json=reminder_data, headers=auth_headers
        )
        assert response.status_code == 200
        data = response.json()
        assert "id" in data
        assert data["title"] == "Test Reminder"

    def test_get_emergency_contacts_empty(self, client, temp_db, auth_headers):
        """Test de récupération des contacts d'urgence (vide)"""
        response = client.get(f"{API_PREFIX}/emergency-contacts", headers=auth_headers)
        assert response.status_code == 200
        assert isinstance(response.json(), list)

    def test_create_emergency_contact(self, client, temp_db, auth_headers):
        """Test de création d'un contact d'urgence"""
        contact_data = {
            "name": "Test Contact",
            "phone": "+32470123456",  # Format belge valide
            "relationship": "family",
            "is_primary": False,
        }
        response = client.post(
            f"{API_PREFIX}/emergency-contacts", json=contact_data, headers=auth_headers
        )
        assert response.status_code == 200
        data = response.json()
        assert "id" in data
        assert data["name"] == "Test Contact"

    def test_get_health_portals_empty(self, client, temp_db, auth_headers):
        """Test de récupération des portails santé (vide)"""
        response = client.get(f"{API_PREFIX}/health-portals", headers=auth_headers)
        assert response.status_code == 200
        assert isinstance(response.json(), list)

    def test_create_health_portal(self, client, temp_db, auth_headers):
        """Test de création d'un portail santé"""
        portal_data = {
            "name": "Test Portal",
            "url": "https://example.com",
            "description": "Test portal",
            "category": "banking",
        }
        response = client.post(
            f"{API_PREFIX}/health-portals", json=portal_data, headers=auth_headers
        )
        assert response.status_code == 200
        data = response.json()
        assert "id" in data
        assert data["name"] == "Test Portal"

    def test_upload_document_invalid_file(self, client, temp_db, auth_headers):
        """Test d'upload d'un fichier invalide"""
        response = client.post(
            f"{API_PREFIX}/documents/upload",
            files={"file": ("test.txt", b"not a pdf", "text/plain")},
            headers=auth_headers,
        )
        # L'API peut retourner 400 (HTTPException) ou 200 avec success=False
        assert response.status_code in [400, 401, 403, 200]
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
            phone="+32470123456",  # Format belge valide
            relationship="family",
            is_primary=False,
        )
        assert contact.name == "Test Contact"
        assert contact.phone == "+32470123456"

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
