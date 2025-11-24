"""
Tests pour les exceptions personnalisées d'Arkalia CIA
"""

from fastapi import status

from arkalia_cia_python_backend.exceptions import (
    ArkaliaException,
    AuthenticationError,
    AuthorizationError,
    DatabaseError,
    FileValidationError,
    NotFoundError,
    ProcessingError,
    RateLimitError,
    ValidationError,
)


class TestArkaliaException:
    """Tests pour ArkaliaException"""

    def test_arkalia_exception_base(self):
        """Test de l'exception de base"""
        exception = ArkaliaException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Test error"
        )
        assert exception.status_code == status.HTTP_500_INTERNAL_SERVER_ERROR
        assert exception.detail == "Test error"


class TestValidationError:
    """Tests pour ValidationError"""

    def test_validation_error_default(self):
        """Test ValidationError avec message personnalisé"""
        error = ValidationError("Champ invalide")
        assert error.status_code == status.HTTP_400_BAD_REQUEST
        assert error.detail == "Champ invalide"


class TestAuthenticationError:
    """Tests pour AuthenticationError"""

    def test_authentication_error_default(self):
        """Test AuthenticationError avec message par défaut"""
        error = AuthenticationError()
        assert error.status_code == status.HTTP_401_UNAUTHORIZED
        assert error.detail == "Authentification requise"

    def test_authentication_error_custom(self):
        """Test AuthenticationError avec message personnalisé"""
        error = AuthenticationError("Token expiré")
        assert error.status_code == status.HTTP_401_UNAUTHORIZED
        assert error.detail == "Token expiré"


class TestAuthorizationError:
    """Tests pour AuthorizationError"""

    def test_authorization_error_default(self):
        """Test AuthorizationError avec message par défaut"""
        error = AuthorizationError()
        assert error.status_code == status.HTTP_403_FORBIDDEN
        assert error.detail == "Permissions insuffisantes"

    def test_authorization_error_custom(self):
        """Test AuthorizationError avec message personnalisé"""
        error = AuthorizationError("Accès refusé")
        assert error.status_code == status.HTTP_403_FORBIDDEN
        assert error.detail == "Accès refusé"


class TestNotFoundError:
    """Tests pour NotFoundError"""

    def test_not_found_error_default(self):
        """Test NotFoundError avec ressource par défaut"""
        error = NotFoundError()
        assert error.status_code == status.HTTP_404_NOT_FOUND
        assert error.detail == "Ressource non trouvé(e)"

    def test_not_found_error_custom(self):
        """Test NotFoundError avec ressource personnalisée"""
        error = NotFoundError("Document")
        assert error.status_code == status.HTTP_404_NOT_FOUND
        assert error.detail == "Document non trouvé(e)"


class TestFileValidationError:
    """Tests pour FileValidationError"""

    def test_file_validation_error(self):
        """Test FileValidationError"""
        error = FileValidationError("Format de fichier invalide")
        assert error.status_code == status.HTTP_400_BAD_REQUEST
        assert error.detail == "Format de fichier invalide"


class TestRateLimitError:
    """Tests pour RateLimitError"""

    def test_rate_limit_error_default(self):
        """Test RateLimitError avec message par défaut"""
        error = RateLimitError()
        assert error.status_code == status.HTTP_429_TOO_MANY_REQUESTS
        assert error.detail == "Trop de requêtes"

    def test_rate_limit_error_custom(self):
        """Test RateLimitError avec message personnalisé"""
        error = RateLimitError("Limite atteinte: 100 requêtes/heure")
        assert error.status_code == status.HTTP_429_TOO_MANY_REQUESTS
        assert error.detail == "Limite atteinte: 100 requêtes/heure"


class TestDatabaseError:
    """Tests pour DatabaseError"""

    def test_database_error_default(self):
        """Test DatabaseError avec message par défaut"""
        error = DatabaseError()
        assert error.status_code == status.HTTP_500_INTERNAL_SERVER_ERROR
        assert error.detail == "Erreur de base de données"

    def test_database_error_custom(self):
        """Test DatabaseError avec message personnalisé"""
        error = DatabaseError("Connexion à la base de données échouée")
        assert error.status_code == status.HTTP_500_INTERNAL_SERVER_ERROR
        assert error.detail == "Connexion à la base de données échouée"


class TestProcessingError:
    """Tests pour ProcessingError"""

    def test_processing_error_default(self):
        """Test ProcessingError avec message par défaut"""
        error = ProcessingError()
        assert error.status_code == status.HTTP_500_INTERNAL_SERVER_ERROR
        assert error.detail == "Erreur lors du traitement"

    def test_processing_error_custom(self):
        """Test ProcessingError avec message personnalisé"""
        error = ProcessingError("Erreur lors de l'extraction du PDF")
        assert error.status_code == status.HTTP_500_INTERNAL_SERVER_ERROR
        assert error.detail == "Erreur lors de l'extraction du PDF"
