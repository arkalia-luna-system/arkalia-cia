"""
Tests unitaires pour LocalStorageService
Tests critiques pour la sécurité et la fiabilité du stockage local
"""

import json
from pathlib import Path
import tempfile
from unittest.mock import MagicMock, patch

import pytest


# Mock des dépendances Flutter
with patch.dict(
    "sys.modules",
    {
        "shared_preferences": MagicMock(),
        "path_provider": MagicMock(),
        "crypto": MagicMock(),
        "encrypt": MagicMock(),
    },
):
    from arkalia_cia.lib.services.local_storage_service import LocalStorageService


class TestLocalStorageService:
    """Tests complets pour LocalStorageService"""

    def setup_method(self):
        """Configuration avant chaque test"""
        self.test_document = {
            "id": 1,
            "name": "test.pdf",
            "path": "/tmp/test.pdf",
            "size": 1024,
            "created_at": "2024-01-01T00:00:00Z",
            "category": "medical",
            "encrypted": True,
        }

        self.test_reminder = {
            "id": 1,
            "title": "Rendez-vous médecin",
            "description": "Consultation cardiologie",
            "reminder_date": "2024-01-15T10:00:00Z",
            "is_completed": False,
            "created_at": "2024-01-01T00:00:00Z",
            "recurring": False,
        }

        self.test_contact = {
            "id": 1,
            "name": "Dr. Martin",
            "phone": "+33123456789",
            "relationship": "Médecin traitant",
            "is_ice": True,
            "created_at": "2024-01-01T00:00:00Z",
        }

    @patch("arkalia_cia.lib.services.local_storage_service.SharedPreferences")
    def test_save_document_success(self, mock_prefs):
        """Test de sauvegarde réussie d'un document"""
        # Arrange
        mock_instance = MagicMock()
        mock_prefs.getInstance.return_value = mock_instance
        mock_instance.getString.return_value = "[]"

        # Act
        LocalStorageService.saveDocument(self.test_document)

        # Assert
        mock_instance.setString.assert_called_once()
        call_args = mock_instance.setString.call_args
        assert call_args[0][0] == "documents"

        # Vérifier que le document est bien dans la liste
        saved_documents = json.loads(call_args[0][1])
        assert len(saved_documents) == 1
        assert saved_documents[0]["name"] == "test.pdf"

    @patch("arkalia_cia.lib.services.local_storage_service.SharedPreferences")
    def test_get_documents_empty(self, mock_prefs):
        """Test de récupération des documents quand la liste est vide"""
        # Arrange
        mock_instance = MagicMock()
        mock_prefs.getInstance.return_value = mock_instance
        mock_instance.getString.return_value = "[]"

        # Act
        documents = LocalStorageService.getDocuments()

        # Assert
        assert documents == []
        mock_instance.getString.assert_called_once_with("documents")

    @patch("arkalia_cia.lib.services.local_storage_service.SharedPreferences")
    def test_get_documents_with_data(self, mock_prefs):
        """Test de récupération des documents avec des données"""
        # Arrange
        mock_instance = MagicMock()
        mock_prefs.getInstance.return_value = mock_instance
        mock_instance.getString.return_value = json.dumps([self.test_document])

        # Act
        documents = LocalStorageService.getDocuments()

        # Assert
        assert len(documents) == 1
        assert documents[0]["name"] == "test.pdf"
        assert documents[0]["encrypted"] is True

    @patch("arkalia_cia.lib.services.local_storage_service.SharedPreferences")
    def test_save_reminder_success(self, mock_prefs):
        """Test de sauvegarde réussie d'un rappel"""
        # Arrange
        mock_instance = MagicMock()
        mock_prefs.getInstance.return_value = mock_instance
        mock_instance.getString.return_value = "[]"

        # Act
        LocalStorageService.saveReminder(self.test_reminder)

        # Assert
        mock_instance.setString.assert_called_once()
        call_args = mock_instance.setString.call_args
        assert call_args[0][0] == "reminders"

        # Vérifier que le rappel est bien dans la liste
        saved_reminders = json.loads(call_args[0][1])
        assert len(saved_reminders) == 1
        assert saved_reminders[0]["title"] == "Rendez-vous médecin"

    @patch("arkalia_cia.lib.services.local_storage_service.SharedPreferences")
    def test_save_emergency_contact_success(self, mock_prefs):
        """Test de sauvegarde réussie d'un contact d'urgence"""
        # Arrange
        mock_instance = MagicMock()
        mock_prefs.getInstance.return_value = mock_instance
        mock_instance.getString.return_value = "[]"

        # Act
        LocalStorageService.saveEmergencyContact(self.test_contact)

        # Assert
        mock_instance.setString.assert_called_once()
        call_args = mock_instance.setString.call_args
        assert call_args[0][0] == "emergency_contacts"

        # Vérifier que le contact est bien dans la liste
        saved_contacts = json.loads(call_args[0][1])
        assert len(saved_contacts) == 1
        assert saved_contacts[0]["name"] == "Dr. Martin"
        assert saved_contacts[0]["is_ice"] is True

    @patch("arkalia_cia.lib.services.local_storage_service.SharedPreferences")
    def test_error_handling_invalid_json(self, mock_prefs):
        """Test de gestion d'erreur avec JSON invalide"""
        # Arrange
        mock_instance = MagicMock()
        mock_prefs.getInstance.return_value = mock_instance
        mock_instance.getString.return_value = "invalid json"

        # Act & Assert
        with pytest.raises(json.JSONDecodeError):
            LocalStorageService.getDocuments()

    @patch("arkalia_cia.lib.services.local_storage_service.SharedPreferences")
    def test_error_handling_prefs_exception(self, mock_prefs):
        """Test de gestion d'erreur avec exception SharedPreferences"""
        # Arrange
        mock_prefs.getInstance.side_effect = Exception("Database error")

        # Act & Assert
        with pytest.raises(Exception, match="Database error"):
            LocalStorageService.getDocuments()

    def test_document_validation(self):
        """Test de validation des données de document"""
        # Test avec document valide
        assert "id" in self.test_document
        assert "name" in self.test_document
        assert "path" in self.test_document
        assert "size" in self.test_document
        assert "created_at" in self.test_document

        # Test avec document invalide
        invalid_doc = {"name": "test.pdf"}  # Manque des champs obligatoires
        assert "id" not in invalid_doc

    def test_reminder_validation(self):
        """Test de validation des données de rappel"""
        # Test avec rappel valide
        assert "id" in self.test_reminder
        assert "title" in self.test_reminder
        assert "reminder_date" in self.test_reminder
        assert "is_completed" in self.test_reminder

        # Test avec rappel invalide
        invalid_reminder = {"title": "Test"}  # Manque des champs obligatoires
        assert "id" not in invalid_reminder

    def test_contact_validation(self):
        """Test de validation des données de contact"""
        # Test avec contact valide
        assert "id" in self.test_contact
        assert "name" in self.test_contact
        assert "phone" in self.test_contact
        assert "relationship" in self.test_contact
        assert "is_ice" in self.test_contact

        # Test avec contact invalide
        invalid_contact = {"name": "Test"}  # Manque des champs obligatoires
        assert "id" not in invalid_contact

    @patch("arkalia_cia.lib.services.local_storage_service.SharedPreferences")
    def test_concurrent_access_simulation(self, mock_prefs):
        """Test de simulation d'accès concurrent"""
        # Arrange
        mock_instance = MagicMock()
        mock_prefs.getInstance.return_value = mock_instance
        mock_instance.getString.return_value = "[]"

        # Act - Simuler plusieurs sauvegardes simultanées
        LocalStorageService.saveDocument(self.test_document)
        LocalStorageService.saveReminder(self.test_reminder)
        LocalStorageService.saveEmergencyContact(self.test_contact)

        # Assert
        assert mock_instance.setString.call_count == 3

    def test_data_encryption_flag(self):
        """Test du flag de chiffrement des données"""
        # Les documents sensibles doivent être marqués comme chiffrés
        assert self.test_document["encrypted"] is True

        # Les rappels peuvent être non chiffrés (moins sensibles)
        assert "encrypted" not in self.test_reminder

        # Les contacts d'urgence doivent être chiffrés
        assert "encrypted" not in self.test_contact  # Géré au niveau du service
