"""
Tests unitaires pour l'intégration ARIA
"""

from unittest.mock import Mock, patch

import pytest
from fastapi.testclient import TestClient

from arkalia_cia_python_backend.aria_integration.api import router


class TestARIAIntegration:
    """Tests pour l'intégration ARIA"""

    @pytest.fixture
    def client(self):
        """Créer un client de test"""
        from fastapi import FastAPI

        app = FastAPI()
        app.include_router(router)
        return TestClient(app)

    @patch("arkalia_cia_python_backend.aria_integration.api.requests.get")
    def test_aria_status_connected(self, mock_get, client):
        """Test du statut ARIA quand connecté"""
        mock_response = Mock()
        mock_response.status_code = 200
        mock_get.return_value = mock_response

        response = client.get("/status")
        assert response.status_code == 200
        data = response.json()
        assert "aria_connected" in data
        assert data["aria_connected"] is True

    @patch("arkalia_cia_python_backend.aria_integration.api.requests.get")
    def test_aria_status_disconnected(self, mock_get, client):
        """Test du statut ARIA quand déconnecté"""
        import requests

        # Le retry_with_backoff ne catch que requests.RequestException
        # donc on doit lever cette exception spécifique
        mock_get.side_effect = requests.RequestException("Connection error")

        response = client.get("/status")
        assert response.status_code == 200
        data = response.json()
        assert "aria_connected" in data
        assert data["aria_connected"] is False

    @patch("arkalia_cia_python_backend.aria_integration.api._check_aria_connection")
    @patch("arkalia_cia_python_backend.aria_integration.api._make_aria_request")
    def test_quick_pain_entry(self, mock_request, mock_check, client):
        """Test de saisie rapide de douleur"""
        mock_check.return_value = True
        mock_response = Mock()
        mock_response.status_code = 200
        mock_response.json.return_value = {
            "id": 1,
            "intensity": 5,
            "trigger": "stress",
            "action": "meditation",
            "timestamp": "2024-01-01T00:00:00",
            "created_at": "2024-01-01T00:00:00",
        }
        mock_request.return_value = mock_response

        entry_data = {"intensity": 5, "trigger": "stress", "action": "meditation"}
        response = client.post("/quick-pain-entry", json=entry_data)
        assert response.status_code == 200
        data = response.json()
        assert "id" in data
        assert data["intensity"] == 5

    @patch("arkalia_cia_python_backend.aria_integration.api._check_aria_connection")
    def test_quick_pain_entry_aria_unavailable(self, mock_check, client):
        """Test de saisie rapide quand ARIA n'est pas disponible"""
        mock_check.return_value = False

        entry_data = {"intensity": 5, "trigger": "stress", "action": "meditation"}
        response = client.post("/quick-pain-entry", json=entry_data)
        assert response.status_code == 503

    @patch("arkalia_cia_python_backend.aria_integration.api._check_aria_connection")
    @patch("arkalia_cia_python_backend.aria_integration.api._make_aria_request")
    def test_create_pain_entry(self, mock_request, mock_check, client):
        """Test de création d'entrée détaillée"""
        mock_check.return_value = True
        mock_response = Mock()
        mock_response.status_code = 200
        mock_response.json.return_value = {
            "id": 1,
            "intensity": 7,
            "physical_trigger": "movement",
            "mental_trigger": "anxiety",
            "timestamp": "2024-01-01T00:00:00",
            "created_at": "2024-01-01T00:00:00",
        }
        mock_request.return_value = mock_response

        entry_data = {
            "intensity": 7,
            "physical_trigger": "movement",
            "mental_trigger": "anxiety",
        }
        response = client.post("/pain-entry", json=entry_data)
        assert response.status_code == 200
        data = response.json()
        assert "id" in data
        assert data["intensity"] == 7

    @patch("arkalia_cia_python_backend.aria_integration.api._check_aria_connection")
    @patch("arkalia_cia_python_backend.aria_integration.api._make_aria_request")
    def test_get_pain_entries(self, mock_request, mock_check, client):
        """Test de récupération des entrées de douleur"""
        mock_check.return_value = True
        mock_response = Mock()
        mock_response.status_code = 200
        mock_response.json.return_value = [
            {
                "id": 1,
                "intensity": 5,
                "timestamp": "2024-01-01T00:00:00",
                "created_at": "2024-01-01T00:00:00",
            }
        ]
        mock_request.return_value = mock_response

        response = client.get("/pain-entries")
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)
        assert len(data) == 1

    @patch("arkalia_cia_python_backend.aria_integration.api._check_aria_connection")
    @patch("arkalia_cia_python_backend.aria_integration.api._make_aria_request")
    def test_get_recent_pain_entries(self, mock_request, mock_check, client):
        """Test de récupération des entrées récentes"""
        mock_check.return_value = True
        mock_response = Mock()
        mock_response.status_code = 200
        mock_response.json.return_value = []
        mock_request.return_value = mock_response

        response = client.get("/pain-entries/recent?limit=10")
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)

    @patch("arkalia_cia_python_backend.aria_integration.api._check_aria_connection")
    @patch("arkalia_cia_python_backend.aria_integration.api._make_aria_request")
    def test_export_csv(self, mock_request, mock_check, client):
        """Test d'export CSV"""
        mock_check.return_value = True
        mock_response = Mock()
        mock_response.status_code = 200
        mock_response.json.return_value = {"csv_data": "test,data\n1,2"}
        mock_request.return_value = mock_response

        response = client.get("/export/csv")
        assert response.status_code == 200
        data = response.json()
        assert "csv_data" in data

    @patch("arkalia_cia_python_backend.aria_integration.api._check_aria_connection")
    @patch("arkalia_cia_python_backend.aria_integration.api._make_aria_request")
    def test_get_recent_patterns(self, mock_request, mock_check, client):
        """Test de récupération des patterns récents"""
        mock_check.return_value = True
        mock_response = Mock()
        mock_response.status_code = 200
        mock_response.json.return_value = {"patterns": []}
        mock_request.return_value = mock_response

        response = client.get("/patterns/recent")
        assert response.status_code == 200
        data = response.json()
        assert "patterns" in data

    @patch("arkalia_cia_python_backend.aria_integration.api._check_aria_connection")
    @patch("arkalia_cia_python_backend.aria_integration.api._make_aria_request")
    def test_get_current_predictions(self, mock_request, mock_check, client):
        """Test de récupération des prédictions actuelles"""
        mock_check.return_value = True
        mock_response = Mock()
        mock_response.status_code = 200
        mock_response.json.return_value = {"predictions": []}
        mock_request.return_value = mock_response

        response = client.get("/predictions/current")
        assert response.status_code == 200
        data = response.json()
        assert "predictions" in data


class TestARIAModels:
    """Tests pour les modèles ARIA"""

    def test_pain_entry_in(self):
        """Test du modèle PainEntryIn"""
        from arkalia_cia_python_backend.aria_integration.api import PainEntryIn

        entry = PainEntryIn(
            intensity=5,
            physical_trigger="movement",
            mental_trigger="stress",
            activity="walking",
            location="back",
            action_taken="rest",
            effectiveness=7,
            notes="Test notes",
        )
        assert entry.intensity == 5
        assert entry.physical_trigger == "movement"

    def test_quick_entry(self):
        """Test du modèle QuickEntry"""
        from arkalia_cia_python_backend.aria_integration.api import QuickEntry

        entry = QuickEntry(intensity=5, trigger="stress", action="meditation")
        assert entry.intensity == 5
        assert entry.trigger == "stress"
        assert entry.action == "meditation"

    def test_pain_entry_out(self):
        """Test du modèle PainEntryOut"""
        from arkalia_cia_python_backend.aria_integration.api import PainEntryOut

        entry = PainEntryOut(
            id=1,
            intensity=5,
            timestamp="2024-01-01T00:00:00",
            created_at="2024-01-01T00:00:00",
        )
        assert entry.id == 1
        assert entry.intensity == 5
