"""
Tests pour le module de configuration centralisée
"""

import os

from arkalia_cia_python_backend import config


class TestSettings:
    """Tests pour la classe Settings"""

    def test_default_values(self):
        """Test des valeurs par défaut"""
        settings = config.Settings()
        assert settings.max_file_size_mb == 50
        assert settings.chunk_size_mb == 1
        assert settings.max_request_size_mb == 10
        assert settings.min_text_length_for_ocr == 100
        assert settings.max_extracted_text_length == 5000
        assert settings.max_reminders_list == 10
        assert settings.max_contacts_list == 5
        assert settings.max_filename_length == 255
        assert settings.max_retries == 3
        assert settings.retry_backoff_factor == 1.5
        assert settings.retry_timeout_seconds == 10
        assert settings.health_check_timeout_seconds == 5

    def test_environment_variables(self):
        """Test chargement depuis variables d'environnement"""
        original_value = os.environ.get("MAX_FILE_SIZE_MB")
        try:
            os.environ["MAX_FILE_SIZE_MB"] = "100"
            # Réinitialiser le singleton pour tester
            config._settings = None
            settings = config.get_settings()
            assert settings.max_file_size_mb == 100
        finally:
            if original_value:
                os.environ["MAX_FILE_SIZE_MB"] = original_value
            elif "MAX_FILE_SIZE_MB" in os.environ:
                del os.environ["MAX_FILE_SIZE_MB"]
            # Réinitialiser pour les autres tests
            config._settings = None

    def test_file_size_conversion(self):
        """Test conversion MB → bytes"""
        settings = config.Settings(max_file_size_mb=50)
        assert settings.max_file_size_bytes == 50 * 1024 * 1024

    def test_chunk_size_conversion(self):
        """Test conversion chunk MB → bytes"""
        settings = config.Settings(chunk_size_mb=1)
        assert settings.chunk_size_bytes == 1 * 1024 * 1024

    def test_request_size_conversion(self):
        """Test conversion request MB → bytes"""
        settings = config.Settings(max_request_size_mb=10)
        assert settings.max_request_size_bytes == 10 * 1024 * 1024

    def test_custom_values(self):
        """Test valeurs personnalisées"""
        settings = config.Settings(
            max_file_size_mb=100,
            max_retries=5,
            retry_backoff_factor=2.0,
        )
        assert settings.max_file_size_mb == 100
        assert settings.max_retries == 5
        assert settings.retry_backoff_factor == 2.0


class TestGetSettings:
    """Tests pour la fonction get_settings"""

    def test_singleton_pattern(self):
        """Test que get_settings retourne la même instance"""
        # Réinitialiser le singleton
        config._settings = None
        settings1 = config.get_settings()
        settings2 = config.get_settings()
        assert settings1 is settings2

    def test_settings_persistence(self):
        """Test que les settings persistent entre appels"""
        config._settings = None
        settings1 = config.get_settings()
        original_value = settings1.max_file_size_mb
        settings1.max_file_size_mb = (
            999  # Modification directe (non recommandée mais testable)
        )
        settings2 = config.get_settings()
        assert settings2.max_file_size_mb == 999
        # Réinitialiser
        config._settings = None
        settings3 = config.get_settings()
        assert settings3.max_file_size_mb == original_value
