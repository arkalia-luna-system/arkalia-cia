"""
Tests unitaires pour les endpoints AI de l'API
"""

import pytest
from fastapi.testclient import TestClient

from arkalia_cia_python_backend import api


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

    def test_ai_chat_basic(self, client, temp_db):
        """Test de chat AI basique"""
        chat_data = {
            "question": "Quels sont mes derniers examens ?",
            "user_data": {"documents": [], "doctors": []},
        }
        response = client.post("/api/ai/chat", json=chat_data)
        assert response.status_code == 200
        data = response.json()
        assert "answer" in data
        assert "suggestions" in data
        assert isinstance(data["answer"], str)

    def test_ai_chat_with_documents(self, client, temp_db):
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
        response = client.post("/api/ai/chat", json=chat_data)
        assert response.status_code == 200
        data = response.json()
        assert "answer" in data
        assert len(data["answer"]) > 0

    def test_ai_chat_empty_question(self, client, temp_db):
        """Test de chat AI avec question vide"""
        chat_data = {"question": "", "user_data": {}}
        response = client.post("/api/ai/chat", json=chat_data)
        # Devrait accepter ou rejeter selon validation
        assert response.status_code in [200, 400, 422]

    def test_ai_chat_missing_fields(self, client, temp_db):
        """Test de chat AI avec champs manquants"""
        response = client.post("/api/ai/chat", json={})
        assert response.status_code in [400, 422]


class TestPatternAnalysisEndpoint:
    """Tests pour l'endpoint d'analyse de patterns"""

    @pytest.fixture
    def client(self):
        """Créer un client de test"""
        return TestClient(api.app)

    def test_pattern_analysis_basic(self, client):
        """Test d'analyse de patterns basique"""
        pattern_data = {
            "data": [
                {"date": "2024-01-01", "value": 5},
                {"date": "2024-01-02", "value": 6},
                {"date": "2024-01-03", "value": 7},
            ]
        }
        response = client.post("/api/patterns/analyze", json=pattern_data)
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, dict)

    def test_pattern_analysis_empty_data(self, client):
        """Test d'analyse de patterns avec données vides"""
        pattern_data = {"data": []}
        response = client.post("/api/patterns/analyze", json=pattern_data)
        assert response.status_code == 400

    def test_pattern_analysis_missing_data(self, client):
        """Test d'analyse de patterns sans données"""
        response = client.post("/api/patterns/analyze", json={})
        assert response.status_code in [400, 422]


class TestPrepareAppointmentEndpoint:
    """Tests pour l'endpoint de préparation de rendez-vous"""

    @pytest.fixture
    def client(self):
        """Créer un client de test"""
        return TestClient(api.app)

    def test_prepare_appointment_basic(self, client):
        """Test de préparation de rendez-vous basique"""
        appointment_data = {
            "doctor_id": "doc1",
            "user_data": {"consultations": [], "doctors": []},
        }
        response = client.post("/api/ai/prepare-appointment", json=appointment_data)
        assert response.status_code == 200
        data = response.json()
        assert "questions" in data
        assert isinstance(data["questions"], list)
        assert len(data["questions"]) > 0

    def test_prepare_appointment_with_history(self, client):
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
        response = client.post("/api/ai/prepare-appointment", json=appointment_data)
        assert response.status_code == 200
        data = response.json()
        assert "questions" in data
        assert len(data["questions"]) > 0

    def test_prepare_appointment_missing_fields(self, client):
        """Test de préparation de rendez-vous avec champs manquants"""
        response = client.post("/api/ai/prepare-appointment", json={})
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

    def test_get_conversations_empty(self, client, temp_db):
        """Test de récupération des conversations (vide)"""
        response = client.get("/api/ai/conversations")
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)

    def test_get_conversations_with_limit(self, client, temp_db):
        """Test de récupération des conversations avec limite"""
        response = client.get("/api/ai/conversations?limit=10")
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)
