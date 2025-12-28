"""
Intégration ARIA pour enrichir l'IA conversationnelle
Récupère données douleurs et patterns depuis ARIA
"""

import logging
import time
from typing import Any

import requests

from arkalia_cia_python_backend.config import get_settings

logger = logging.getLogger(__name__)


class ARIAIntegration:
    """Intégration avec ARIA pour données douleurs"""

    def __init__(self, aria_base_url: str | None = None, aria_timeout: int | None = None):
        # Utiliser la configuration centralisée si non fournie
        settings = get_settings()
        if aria_base_url is None:
            aria_base_url = settings.aria_base_url
        if aria_timeout is None:
            aria_timeout = settings.aria_timeout
        self.aria_base_url = aria_base_url
        self.aria_timeout = aria_timeout
        self.session = requests.Session()
        # Note: timeout doit être défini via adapter, pas directement sur session

    def _make_request_with_retry(
        self,
        endpoint: str,
        params: dict[str, Any] | None = None,
        operation_name: str = "ARIA request",
    ) -> requests.Response | None:
        """
        Helper pour effectuer une requête ARIA avec retry logic

        Args:
            endpoint: Endpoint ARIA (ex: "/api/pain-records")
            params: Paramètres de la requête
            operation_name: Nom de l'opération pour le logging

        Returns:
            Response si succès, None si échec après tous les retries
        """
        settings = get_settings()
        max_retries = settings.max_retries
        backoff_factor = settings.retry_backoff_factor

        for attempt in range(max_retries):
            try:
                response = self.session.get(
                    f"{self.aria_base_url}{endpoint}",
                    params=params,
                    timeout=self.aria_timeout,
                )

                if response.status_code == 200:
                    return response
                else:
                    # Si erreur HTTP et pas de retry possible, logger warning
                    if attempt >= max_retries - 1:
                        logger.warning(f"{operation_name}: HTTP {response.status_code}")
                    return None
            except requests.RequestException as e:
                if attempt < max_retries - 1:
                    wait_time = backoff_factor**attempt
                    logger.debug(
                        f"Tentative {attempt + 1}/{max_retries} échouée "
                        f"{operation_name}: {e}. Retry dans {wait_time:.2f}s"
                    )
                    time.sleep(wait_time)
                else:
                    logger.debug(f"{operation_name} non accessible: {e}")
                    return None
            except Exception as e:
                logger.warning(f"Erreur inattendue {operation_name}: {e}")
                return None
        return None

    def get_pain_records(self, user_id: str, limit: int = 10) -> list[dict[str, Any]]:
        """
        Récupère les enregistrements de douleur depuis ARIA avec retry logic

        Args:
            user_id: ID utilisateur
            limit: Nombre max d'enregistrements (défaut: 10)

        Returns:
            Liste d'enregistrements douleur
        """
        response = self._make_request_with_retry(
            "/api/pain-records",
            params={"user_id": str(user_id), "limit": str(limit)},
            operation_name="ARIA pain records",
        )

        if response is None:
            return []

        try:
            data = response.json()
            records = data.get("records", [])
            return [dict(r) for r in records] if records else []
        except Exception as e:
            logger.warning(f"Erreur parsing ARIA pain records: {e}")
            return []

    def get_patterns(self, user_id: str) -> dict[str, Any]:
        """
        Récupère les patterns détectés depuis ARIA avec retry logic

        Args:
            user_id: ID utilisateur

        Returns:
            Dict avec patterns détectés
        """
        response = self._make_request_with_retry(
            "/api/patterns",
            params={"user_id": str(user_id)},
            operation_name="ARIA patterns",
        )

        if response is None:
            return {}

        try:
            data = response.json()
            return dict(data) if isinstance(data, dict) else {}
        except Exception as e:
            logger.warning(f"Erreur parsing ARIA patterns: {e}")
            return {}

    def get_health_metrics(self, user_id: str, days: int = 30) -> dict[str, Any]:
        """
        Récupère métriques santé depuis ARIA avec retry logic

        Args:
            user_id: ID utilisateur
            days: Nombre de jours à récupérer

        Returns:
            Dict avec métriques (sommeil, activité, stress, etc.)
        """
        response = self._make_request_with_retry(
            "/api/health-metrics",
            params={"user_id": str(user_id), "days": str(days)},
            operation_name="ARIA health metrics",
        )

        if response is None:
            return {}

        try:
            data = response.json()
            return dict(data) if isinstance(data, dict) else {}
        except Exception as e:
            logger.warning(f"Erreur parsing ARIA health metrics: {e}")
            return {}
