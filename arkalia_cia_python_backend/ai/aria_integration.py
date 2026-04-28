"""
Intégration ARIA pour enrichir l'IA conversationnelle
Récupère données douleurs et patterns depuis ARIA
"""

import logging
import sqlite3
import time
from typing import Any

import requests

from arkalia_cia_python_backend.config import get_settings
from arkalia_cia_python_backend.database import CIADatabase

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
        self.aria_enabled = settings.aria_enabled
        self.aria_base_url = aria_base_url
        self.aria_timeout = aria_timeout
        self._db = CIADatabase()
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
        if not self.aria_enabled or not self.aria_base_url:
            return None

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
            # Fallback de compatibilité: certaines instances ARIA exposent /api/pain/entries
            response = self._make_request_with_retry(
                "/api/pain/entries",
                params={"limit": str(limit), "offset": "0"},
                operation_name="ARIA pain entries fallback",
            )
            if response is None:
                return self._get_local_pain_records(limit=limit)

        try:
            data = response.json()
            records = []
            if isinstance(data, dict):
                if isinstance(data.get("records"), list):
                    records = data.get("records", [])
                elif isinstance(data.get("entries"), list):
                    records = data.get("entries", [])
            return [dict(r) for r in records] if records else []
        except Exception as e:
            logger.warning(f"Erreur parsing ARIA pain records: {e}")
            return self._get_local_pain_records(limit=limit)

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
            return self._build_local_patterns(user_id)

        try:
            data = response.json()
            return dict(data) if isinstance(data, dict) else {}
        except Exception as e:
            logger.warning(f"Erreur parsing ARIA patterns: {e}")
            return self._build_local_patterns(user_id)

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
            return self._build_local_health_metrics(days)

        try:
            data = response.json()
            return dict(data) if isinstance(data, dict) else {}
        except Exception as e:
            logger.warning(f"Erreur parsing ARIA health metrics: {e}")
            return self._build_local_health_metrics(days)

    def _get_local_pain_records(self, limit: int = 10) -> list[dict[str, Any]]:
        """Fallback local CIA: lit les entrées douleur stockées localement."""
        try:
            with sqlite3.connect(self._db.db_path) as conn:
                conn.row_factory = sqlite3.Row
                cursor = conn.cursor()
                cursor.execute(
                    """
                    SELECT * FROM pain_entries
                    ORDER BY timestamp DESC
                    LIMIT ?
                    """,
                    (limit,),
                )
                return [dict(row) for row in cursor.fetchall()]
        except Exception as e:
            logger.debug(f"Fallback local pain records indisponible: {e}")
            return []

    def _build_local_patterns(self, user_id: str) -> dict[str, Any]:
        """Construit des patterns simples depuis les données locales CIA."""
        records = self._get_local_pain_records(limit=100)
        if len(records) < 3:
            return {}
        trigger_counts: dict[str, int] = {}
        for row in records:
            trigger = str(row.get("physical_trigger") or "").strip()
            if trigger:
                trigger_counts[trigger] = trigger_counts.get(trigger, 0) + 1
        if not trigger_counts:
            return {}
        top_trigger = max(trigger_counts.items(), key=lambda item: item[1])
        return {
            "source": "cia_local",
            "user_id": user_id,
            "top_trigger": top_trigger[0],
            "top_trigger_count": top_trigger[1],
        }

    def _build_local_health_metrics(self, days: int) -> dict[str, Any]:
        """Produit un minimum de métriques santé à partir des entrées douleur."""
        records = self._get_local_pain_records(limit=max(days, 30))
        if not records:
            return {}
        intensities = [int(r.get("intensity", 0)) for r in records if r.get("intensity") is not None]
        if not intensities:
            return {}
        avg = round(sum(intensities) / len(intensities), 2)
        return {
            "source": "cia_local",
            "pain": {
                "avg_30d": avg,
                "entries_count": len(intensities),
                "trend": "stable",
            },
        }
