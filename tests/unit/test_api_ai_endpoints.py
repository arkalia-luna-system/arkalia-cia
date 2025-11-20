"""
Tests unitaires pour les endpoints AI de l'API
"""

from pathlib import Path

import pytest
from fastapi.testclient import TestClient

from arkalia_cia_python_backend import api
from arkalia_cia_python_backend.auth import create_access_token
from arkalia_cia_python_backend.database import CIADatabase


class TestAIChatEndpoint:
    """Tests pour l'endpoint de chat AI"""

    @pytest.fixture
    def client(self):
        """Créer un client de test"""
        return TestClient(api.app)

    @pytest.fixture
    def temp_db(self):
        """Créer une base de données temporaire"""
        import uuid
        from pathlib import Path

        test_db_dir = Path.cwd() / "test_temp"
        test_db_dir.mkdir(exist_ok=True)
        db_path = str(test_db_dir / f"test_{uuid.uuid4().hex}.db")

        original_db = api.db
        api.db = CIADatabase(db_path=db_path)
        yield db_path
        api.db = original_db
        if Path(db_path).exists():
            Path(db_path).unlink()

    @pytest.fixture
    def auth_token(self, temp_db):
        """Créer un utilisateur de test et retourner un token"""
        # Créer un utilisateur de test avec mot de passe court pour éviter problèmes bcrypt
        import bcrypt

        password_hash = bcrypt.hashpw(
            b"test123", bcrypt.gensalt()
        ).decode("utf-8")
        user_id = api.db.create_user(
            username="testuser", password_hash=password_hash, email="test@example.com"
        )
        # Créer un token d'accès
        token = create_access_token(
            data={"sub": str(user_id), "username": "testuser", "role": "user"}
        )
        return token

    def test_ai_chat_basic(self, client, temp_db, auth_token):
        """Test de chat AI basique"""
        chat_data = {
            "question": "Quels sont mes derniers examens ?",
            "user_data": {"documents": [], "doctors": []},
        }
        headers = {"Authorization": f"Bearer {auth_token}"}
        response = client.post("/api/v1/ai/chat", json=chat_data, headers=headers)
        assert response.status_code == 200
        data = response.json()
        assert "answer" in data
        assert "suggestions" in data
        assert isinstance(data["answer"], str)

    def test_ai_chat_with_documents(self, client, temp_db, auth_token):
        """Test de chat AI avec documents"""
        chat_data = {
            "question": "Quels sont mes examens ?",
            "user_data": {
                "documents": [
                    {
                        "id": "1",
                        "original_name": "Examen sanguin",
                        "category": "examen",
                        "created_at": "2024-01-01",
                    }
                ],
                "doctors": [],
            },
        }
        headers = {"Authorization": f"Bearer {auth_token}"}
        response = client.post("/api/v1/ai/chat", json=chat_data, headers=headers)
        assert response.status_code == 200
        data = response.json()
        assert "answer" in data
        assert len(data["answer"]) > 0

    def test_ai_chat_empty_question(self, client, temp_db, auth_token):
        """Test de chat AI avec question vide"""
        chat_data = {"question": "", "user_data": {}}
        headers = {"Authorization": f"Bearer {auth_token}"}
        response = client.post("/api/v1/ai/chat", json=chat_data, headers=headers)
        # Devrait accepter ou rejeter selon validation
        assert response.status_code in [200, 400, 422]

    def test_ai_chat_missing_fields(self, client, temp_db, auth_token):
        """Test de chat AI avec champs manquants"""
        headers = {"Authorization": f"Bearer {auth_token}"}
        response = client.post("/api/v1/ai/chat", json={}, headers=headers)
        assert response.status_code in [400, 422]


class TestPatternAnalysisEndpoint:
    """Tests pour l'endpoint d'analyse de patterns"""

    @pytest.fixture
    def client(self):
        """Créer un client de test"""
        return TestClient(api.app)

    @pytest.fixture
    def auth_token(self):
        """Créer un utilisateur de test et retourner un token"""
        import uuid

        import bcrypt

        test_db_dir = Path.cwd() / "test_temp"
        test_db_dir.mkdir(exist_ok=True)
        db_path = str(test_db_dir / f"test_{uuid.uuid4().hex}.db")
        original_db = api.db
        api.db = CIADatabase(db_path=db_path)
        # Utiliser bcrypt directement pour éviter problèmes avec passlib
        password_hash = bcrypt.hashpw(
            b"test123", bcrypt.gensalt()
        ).decode("utf-8")
        user_id = api.db.create_user(
            username="testuser", password_hash=password_hash, email="test@example.com"
        )
        token = create_access_token(
            data={"sub": str(user_id), "username": "testuser", "role": "user"}
        )
        yield token
        api.db = original_db
        if Path(db_path).exists():
            Path(db_path).unlink()

    def test_pattern_analysis_basic(self, client, auth_token):
        """Test d'analyse de patterns basique"""
        pattern_data = {
            "data": [
                {"date": "2024-01-01", "value": 5},
                {"date": "2024-01-02", "value": 6},
                {"date": "2024-01-03", "value": 7},
            ]
        }
        headers = {"Authorization": f"Bearer {auth_token}"}
        response = client.post(
            "/api/v1/patterns/analyze", json=pattern_data, headers=headers
        )
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, dict)

    def test_pattern_analysis_empty_data(self, client, auth_token):
        """Test d'analyse de patterns avec données vides"""
        pattern_data = {"data": []}
        headers = {"Authorization": f"Bearer {auth_token}"}
        response = client.post(
            "/api/v1/patterns/analyze", json=pattern_data, headers=headers
        )
        assert response.status_code == 400

    def test_pattern_analysis_missing_data(self, client, auth_token):
        """Test d'analyse de patterns sans données"""
        headers = {"Authorization": f"Bearer {auth_token}"}
        response = client.post("/api/v1/patterns/analyze", json={}, headers=headers)
        assert response.status_code in [400, 422]


class TestPrepareAppointmentEndpoint:
    """Tests pour l'endpoint de préparation de rendez-vous"""

    @pytest.fixture
    def client(self):
        """Créer un client de test"""
        return TestClient(api.app)

    @pytest.fixture
    def auth_token(self):
        """Créer un utilisateur de test et retourner un token"""
        import uuid

        import bcrypt

        test_db_dir = Path.cwd() / "test_temp"
        test_db_dir.mkdir(exist_ok=True)
        db_path = str(test_db_dir / f"test_{uuid.uuid4().hex}.db")
        original_db = api.db
        api.db = CIADatabase(db_path=db_path)
        # Utiliser bcrypt directement pour éviter problèmes avec passlib
        password_hash = bcrypt.hashpw(
            b"test123", bcrypt.gensalt()
        ).decode("utf-8")
        user_id = api.db.create_user(
            username="testuser", password_hash=password_hash, email="test@example.com"
        )
        token = create_access_token(
            data={"sub": str(user_id), "username": "testuser", "role": "user"}
        )
        yield token
        api.db = original_db
        if Path(db_path).exists():
            Path(db_path).unlink()

    def test_prepare_appointment_basic(self, client, auth_token):
        """Test de préparation de rendez-vous basique"""
        appointment_data = {
            "doctor_id": "doc1",
            "user_data": {"consultations": [], "doctors": []},
        }
        headers = {"Authorization": f"Bearer {auth_token}"}
        response = client.post(
            "/api/v1/ai/prepare-appointment", json=appointment_data, headers=headers
        )
        assert response.status_code == 200
        data = response.json()
        assert "questions" in data
        assert isinstance(data["questions"], list)
        assert len(data["questions"]) > 0

    def test_prepare_appointment_with_history(self, client, auth_token):
        """Test de préparation de rendez-vous avec historique"""
        appointment_data = {
            "doctor_id": "doc1",
            "user_data": {
                "consultations": [
                    {
                        "doctor_id": "doc1",
                        "date": "2024-01-01T10:00:00",
                        "notes": "Consultation précédente",
                    }
                ],
                "doctors": [],
            },
        }
        headers = {"Authorization": f"Bearer {auth_token}"}
        response = client.post(
            "/api/v1/ai/prepare-appointment", json=appointment_data, headers=headers
        )
        assert response.status_code == 200
        data = response.json()
        assert "questions" in data
        assert len(data["questions"]) > 0

    def test_prepare_appointment_missing_fields(self, client, auth_token):
        """Test de préparation de rendez-vous avec champs manquants"""
        headers = {"Authorization": f"Bearer {auth_token}"}
        response = client.post(
            "/api/v1/ai/prepare-appointment", json={}, headers=headers
        )
        assert response.status_code in [400, 422]


class TestAIConversationsEndpoint:
    """Tests pour l'endpoint de récupération des conversations"""

    @pytest.fixture
    def client(self):
        """Créer un client de test"""
        return TestClient(api.app)

    @pytest.fixture
    def temp_db(self):
        """Créer une base de données temporaire"""
        import uuid
        from pathlib import Path

        from arkalia_cia_python_backend.database import CIADatabase

        test_db_dir = Path.cwd() / "test_temp"
        test_db_dir.mkdir(exist_ok=True)
        db_path = str(test_db_dir / f"test_{uuid.uuid4().hex}.db")

        original_db = api.db
        api.db = CIADatabase(db_path=db_path)
        yield db_path
        api.db = original_db
        if Path(db_path).exists():
            Path(db_path).unlink()

    @pytest.fixture
    def auth_token(self, temp_db):
        """Créer un utilisateur de test et retourner un token"""
        import bcrypt

        # Utiliser bcrypt directement pour éviter problèmes avec passlib
        password_hash = bcrypt.hashpw(
            b"test123", bcrypt.gensalt()
        ).decode("utf-8")
        user_id = api.db.create_user(
            username="testuser", password_hash=password_hash, email="test@example.com"
        )
        token = create_access_token(
            data={"sub": str(user_id), "username": "testuser", "role": "user"}
        )
        return token

    def test_get_conversations_empty(self, client, temp_db, auth_token):
        """Test de récupération des conversations (vide)"""
        headers = {"Authorization": f"Bearer {auth_token}"}
        response = client.get("/api/v1/ai/conversations", headers=headers)
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)

    def test_get_conversations_with_limit(self, client, temp_db, auth_token):
        """Test de récupération des conversations avec limite"""
        headers = {"Authorization": f"Bearer {auth_token}"}
        response = client.get("/api/v1/ai/conversations?limit=10", headers=headers)
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)


class TestPatternPredictEventsEndpoint:
    """Tests pour l'endpoint de prédiction d'événements futurs"""

    @pytest.fixture
    def client(self):
        """Créer un client de test"""
        return TestClient(api.app)

    @pytest.fixture
    def auth_token(self):
        """Créer un utilisateur de test et retourner un token"""
        import uuid

        import bcrypt

        test_db_dir = Path.cwd() / "test_temp"
        test_db_dir.mkdir(exist_ok=True)
        db_path = str(test_db_dir / f"test_{uuid.uuid4().hex}.db")
        original_db = api.db
        api.db = CIADatabase(db_path=db_path)
        # Utiliser bcrypt directement pour éviter problèmes avec passlib
        password_hash = bcrypt.hashpw(
            b"test123", bcrypt.gensalt()
        ).decode("utf-8")
        user_id = api.db.create_user(
            username="testuser", password_hash=password_hash, email="test@example.com"
        )
        token = create_access_token(
            data={"sub": str(user_id), "username": "testuser", "role": "user"}
        )
        yield token
        api.db = original_db
        if Path(db_path).exists():
            Path(db_path).unlink()

    def test_predict_events_basic(self, client, auth_token):
        """Test de prédiction d'événements basique"""
        predict_data = {
            "data": [
                {"date": "2024-01-01", "value": 1, "type": "document"},
                {"date": "2024-01-15", "value": 1, "type": "document"},
                {"date": "2024-02-01", "value": 1, "type": "document"},
            ],
            "event_type": "document",
            "days_ahead": 30,
        }
        headers = {"Authorization": f"Bearer {auth_token}"}
        response = client.post(
            "/api/v1/patterns/predict-events", json=predict_data, headers=headers
        )
        assert response.status_code == 200
        data = response.json()
        assert "predicted_dates" in data
        assert "confidence" in data
        assert "pattern_based" in data
        assert isinstance(data["predicted_dates"], list)

    def test_predict_events_empty_data(self, client, auth_token):
        """Test de prédiction avec données vides"""
        predict_data = {"data": [], "event_type": "document", "days_ahead": 30}
        headers = {"Authorization": f"Bearer {auth_token}"}
        response = client.post(
            "/api/v1/patterns/predict-events", json=predict_data, headers=headers
        )
        # L'endpoint retourne 400 pour données vides (comportement attendu)
        assert response.status_code == 400


class TestHealthPortalImportEndpoint:
    """Tests pour l'endpoint d'import portails santé"""

    @pytest.fixture
    def client(self):
        """Créer un client de test"""
        return TestClient(api.app)

    @pytest.fixture
    def auth_token(self):
        """Créer un utilisateur de test et retourner un token"""
        import uuid

        import bcrypt

        test_db_dir = Path.cwd() / "test_temp"
        test_db_dir.mkdir(exist_ok=True)
        db_path = str(test_db_dir / f"test_{uuid.uuid4().hex}.db")
        original_db = api.db
        api.db = CIADatabase(db_path=db_path)
        # Utiliser bcrypt directement pour éviter problèmes avec passlib
        password_hash = bcrypt.hashpw(
            b"test123", bcrypt.gensalt()
        ).decode("utf-8")
        user_id = api.db.create_user(
            username="testuser", password_hash=password_hash, email="test@example.com"
        )
        token = create_access_token(
            data={"sub": str(user_id), "username": "testuser", "role": "user"}
        )
        yield token
        api.db = original_db
        if Path(db_path).exists():
            Path(db_path).unlink()

    def test_import_portal_basic(self, client, auth_token):
        """Test d'import portail basique"""
        import_data = {
            "portal": "eHealth",
            "data": {
                "documents": [
                    {"name": "Test Document", "date": "2024-01-01", "type": "examen"}
                ],
                "consultations": [],
                "exams": [],
            },
        }
        headers = {"Authorization": f"Bearer {auth_token}"}
        response = client.post(
            "/api/v1/health-portals/import", json=import_data, headers=headers
        )
        assert response.status_code == 200
        data = response.json()
        assert "success" in data
        assert "imported_count" in data
        assert data["success"] is True

    def test_import_portal_empty_data(self, client, auth_token):
        """Test d'import avec données vides"""
        import_data = {"portal": "eHealth", "data": {}}
        headers = {"Authorization": f"Bearer {auth_token}"}
        response = client.post(
            "/api/v1/health-portals/import", json=import_data, headers=headers
        )
        assert response.status_code == 200
        data = response.json()
        assert data["imported_count"] == 0
