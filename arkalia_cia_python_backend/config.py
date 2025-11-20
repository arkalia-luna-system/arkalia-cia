"""
Configuration centralisée avec Pydantic Settings
Remplace les magic numbers hardcodés par configuration configurable
"""

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Configuration de l'application"""

    # Limites de fichiers
    max_file_size_mb: int = 50
    chunk_size_mb: int = 1
    max_request_size_mb: int = 10

    # Limites de texte
    min_text_length_for_ocr: int = 100
    max_extracted_text_length: int = 5000

    # Limites de listes
    max_reminders_list: int = 10
    max_contacts_list: int = 5

    # Validation filename
    max_filename_length: int = 255
    allowed_filename_chars: str = (
        r"^[a-zA-Z0-9._-]+$"  # Lettres, chiffres, points, tirets, underscores
    )

    # Retry logic
    max_retries: int = 3
    retry_backoff_factor: float = 1.5
    retry_timeout_seconds: int = 10

    # Health checks
    health_check_timeout_seconds: int = 5

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore",
    )

    @property
    def max_file_size_bytes(self) -> int:
        """Retourne la taille max de fichier en bytes"""
        return self.max_file_size_mb * 1024 * 1024

    @property
    def chunk_size_bytes(self) -> int:
        """Retourne la taille de chunk en bytes"""
        return self.chunk_size_mb * 1024 * 1024

    @property
    def max_request_size_bytes(self) -> int:
        """Retourne la taille max de requête en bytes"""
        return self.max_request_size_mb * 1024 * 1024


# Instance globale de configuration (singleton)
_settings: Settings | None = None


def get_settings() -> Settings:
    """Retourne l'instance de configuration (singleton)"""
    global _settings
    if _settings is None:
        _settings = Settings()
    return _settings
