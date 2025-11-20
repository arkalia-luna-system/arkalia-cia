"""
Exceptions personnalisées pour Arkalia CIA
Gestion d'erreurs spécifiques et sécurisées
"""

from fastapi import HTTPException, status


class ArkaliaException(HTTPException):
    """Exception de base pour Arkalia CIA"""

    pass


class ValidationError(ArkaliaException):
    """Erreur de validation"""

    def __init__(self, detail: str):
        super().__init__(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=detail,
        )


class AuthenticationError(ArkaliaException):
    """Erreur d'authentification"""

    def __init__(self, detail: str = "Authentification requise"):
        super().__init__(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=detail,
        )


class AuthorizationError(ArkaliaException):
    """Erreur d'authorization"""

    def __init__(self, detail: str = "Permissions insuffisantes"):
        super().__init__(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=detail,
        )


class NotFoundError(ArkaliaException):
    """Ressource non trouvée"""

    def __init__(self, resource: str = "Ressource"):
        super().__init__(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"{resource} non trouvé(e)",
        )


class FileValidationError(ArkaliaException):
    """Erreur de validation de fichier"""

    def __init__(self, detail: str):
        super().__init__(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=detail,
        )


class RateLimitError(ArkaliaException):
    """Erreur de rate limiting"""

    def __init__(self, detail: str = "Trop de requêtes"):
        super().__init__(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail=detail,
        )


class DatabaseError(ArkaliaException):
    """Erreur de base de données"""

    def __init__(self, detail: str = "Erreur de base de données"):
        super().__init__(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=detail,
        )


class ProcessingError(ArkaliaException):
    """Erreur de traitement"""

    def __init__(self, detail: str = "Erreur lors du traitement"):
        super().__init__(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=detail,
        )
