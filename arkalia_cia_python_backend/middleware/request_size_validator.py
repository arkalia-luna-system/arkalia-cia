"""
Middleware pour valider la taille réelle des payloads JSON
Protection contre DoS par payloads énormes
"""

import logging

from fastapi import HTTPException, Request, status
from starlette.middleware.base import BaseHTTPMiddleware

from arkalia_cia_python_backend.config import get_settings

logger = logging.getLogger(__name__)


class RequestSizeValidatorMiddleware(BaseHTTPMiddleware):
    """Middleware pour valider la taille réelle des requêtes JSON"""

    async def dispatch(self, request: Request, call_next):
        # Vérifier uniquement pour les requêtes POST/PUT/PATCH avec body
        if request.method in ("POST", "PUT", "PATCH"):
            # Lire le body pour vérifier la taille réelle
            body = await request.body()
            settings = get_settings()
            max_size = settings.max_request_size_bytes

            if len(body) > max_size:
                logger.warning(
                    f"Requête trop volumineuse: {len(body)} bytes (max: {max_size} bytes)"
                )
                raise HTTPException(
                    status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
                    detail=f"Payload trop volumineux: {len(body)} bytes (max: {max_size} bytes)",
                )

            # Reconstruire le request avec le body (car il a été consommé)
            async def receive():
                return {"type": "http.request", "body": body}

            request._receive = receive

        response = await call_next(request)
        return response
