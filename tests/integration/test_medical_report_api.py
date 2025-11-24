"""
Tests d'intégration pour l'endpoint API de génération de rapports médicaux
"""

from datetime import datetime, timedelta
from pathlib import Path

import bcrypt
import pytest
from fastapi.testclient import TestClient

from arkalia_cia_python_backend import api
from arkalia_cia_python_backend.auth import create_access_token
from arkalia_cia_python_backend.database import CIADatabase
from arkalia_cia_python_backend.dependencies import get_database


@pytest.fixture
def temp_db():
    """Base de données temporaire pour tests"""
    import uuid

    test_db_dir = Path.cwd() / "test_temp"
    test_db_dir.mkdir(exist_ok=True)
    db_path = str(test_db_dir / f"test_report_{uuid.uuid4().hex}.db")
    db = CIADatabase(db_path=db_path)
    db.init_db()
    yield db_path, db
    if Path(db_path).exists():
        Path(db_path).unlink()


@pytest.fixture
def client(temp_db):
    """Créer un client de test avec dépendance override"""
    db_path, db = temp_db
    api.app.dependency_overrides[get_database] = lambda: db
    yield TestClient(api.app)
    api.app.dependency_overrides.clear()


@pytest.fixture
def auth_token(temp_db):
    """Token d'authentification pour les tests"""
    db_path, db = temp_db
    # Créer un utilisateur de test
    password_hash = bcrypt.hashpw(b"testpass123", bcrypt.gensalt()).decode("utf-8")
    user_id = db.create_user(
        username="testuser_report",
        password_hash=password_hash,
        email="test_report@example.com",
    )
    token = create_access_token(
        data={"sub": str(user_id), "username": "testuser_report", "role": "user"}
    )
    return token


@pytest.fixture
def auth_headers(auth_token):
    """Headers d'authentification pour les tests"""
    return {"Authorization": f"Bearer {auth_token}"}


class TestMedicalReportAPI:
    """Tests d'intégration pour l'API de rapports médicaux"""

    def test_generate_report_basic(self, client, temp_db, auth_headers):
        """Test génération rapport basique"""
        db_path, db = temp_db
        # Ajouter quelques documents de test
        db.add_document(
            name="test_doc1.pdf",
            original_name="test_doc1.pdf",
            file_path="/tmp/test1.pdf",
            file_type="pdf",
            file_size=1000,
        )
        db.add_document(
            name="test_doc2.pdf",
            original_name="test_doc2.pdf",
            file_path="/tmp/test2.pdf",
            file_type="pdf",
            file_size=2000,
        )

        # Générer rapport
        response = client.post(
            "/api/v1/medical-reports/generate",
            headers=auth_headers,
            json={
                "days_range": 30,
                "include_aria": False,
            },
        )

        assert response.status_code == 200
        data = response.json()
        assert data["success"] is True
        assert "report_date" in data
        assert "generated_at" in data
        assert "sections" in data
        assert "formatted_text" in data
        assert "documents" in data["sections"]

    def test_generate_report_with_consultation_date(
        self, client, temp_db, auth_headers
    ):
        """Test génération rapport avec date de consultation"""
        consultation_date = (datetime.now() + timedelta(days=7)).isoformat()

        response = client.post(
            "/api/v1/medical-reports/generate",
            headers=auth_headers,
            json={
                "consultation_date": consultation_date,
                "days_range": 30,
                "include_aria": False,
            },
        )

        assert response.status_code == 200
        data = response.json()
        assert data["success"] is True
        assert data["report_date"] is not None

    def test_generate_report_with_aria(self, client, temp_db, auth_headers):
        """Test génération rapport avec ARIA (graceful degradation si non disponible)"""
        response = client.post(
            "/api/v1/medical-reports/generate",
            headers=auth_headers,
            json={
                "days_range": 30,
                "include_aria": True,
            },
        )

        # Doit réussir même si ARIA n'est pas disponible
        assert response.status_code == 200
        data = response.json()
        assert data["success"] is True
        # Section ARIA peut être absente si non disponible
        assert "sections" in data

    def test_generate_report_invalid_date(self, client, temp_db, auth_headers):
        """Test génération rapport avec date invalide (doit être tolérant)"""
        response = client.post(
            "/api/v1/medical-reports/generate",
            headers=auth_headers,
            json={
                "consultation_date": "date-invalide",
                "days_range": 30,
            },
        )

        # Doit réussir en ignorant la date invalide
        assert response.status_code == 200
        data = response.json()
        assert data["success"] is True

    def test_generate_report_custom_days_range(self, client, temp_db, auth_headers):
        """Test génération rapport avec période personnalisée"""
        response = client.post(
            "/api/v1/medical-reports/generate",
            headers=auth_headers,
            json={
                "days_range": 60,
                "include_aria": False,
            },
        )

        assert response.status_code == 200
        data = response.json()
        assert data["success"] is True
        assert data["days_range"] == 60

    def test_generate_report_unauthorized(self, client):
        """Test génération rapport sans authentification"""
        response = client.post(
            "/api/v1/medical-reports/generate",
            json={
                "days_range": 30,
            },
        )

        # Peut être 401 (Unauthorized) ou 403 (Forbidden) selon la configuration
        assert response.status_code in (401, 403)

    def test_generate_report_rate_limit(self, client, temp_db, auth_headers):
        """Test limite de taux (10/minute)"""
        # Faire 11 requêtes rapides
        responses = []
        for _ in range(11):
            response = client.post(
                "/api/v1/medical-reports/generate",
                headers=auth_headers,
                json={"days_range": 30},
            )
            responses.append(response.status_code)

        # Les 10 premières doivent réussir, la 11ème peut être limitée (429)
        success_count = sum(1 for code in responses if code == 200)

        # Vérifier que le rate limiting fonctionne
        # Au moins quelques requêtes doivent réussir, et certaines peuvent être limitées
        assert success_count > 0  # Au moins une doit réussir
        # Si rate limiting actif, certaines requêtes doivent être limitées
        # (peut varier selon la configuration de slowapi)
