"""
Intégration ARIA pour enrichir l'IA conversationnelle
Récupère données douleurs et patterns depuis ARIA
"""
from typing import Any
import logging
import requests

logger = logging.getLogger(__name__)


class ARIAIntegration:
    """Intégration avec ARIA pour données douleurs"""
    
    def __init__(self, aria_base_url: str = "http://localhost:8001"):
        self.aria_base_url = aria_base_url
        self.session = requests.Session()
        self.session.timeout = 5  # Timeout court pour éviter blocage
    
    def get_pain_records(self, user_id: str, limit: int = 10) -> list[dict[str, Any]]:
        """
        Récupère les enregistrements de douleur depuis ARIA
        
        Args:
            user_id: ID utilisateur
            limit: Nombre max d'enregistrements (défaut: 10)
        
        Returns:
            Liste d'enregistrements douleur
        """
        try:
            response = self.session.get(
                f"{self.aria_base_url}/api/pain-records",
                params={"user_id": user_id, "limit": limit},
                timeout=5
            )
            
            if response.status_code == 200:
                data = response.json()
                return data.get('records', [])
            else:
                logger.warning(f"ARIA non disponible: {response.status_code}")
                return []
        except Exception as e:
            logger.debug(f"ARIA non accessible: {e}")
            return []  # Retourner liste vide si ARIA non disponible
    
    def get_patterns(self, user_id: str) -> dict[str, Any]:
        """
        Récupère les patterns détectés depuis ARIA
        
        Args:
            user_id: ID utilisateur
        
        Returns:
            Dict avec patterns détectés
        """
        try:
            response = self.session.get(
                f"{self.aria_base_url}/api/patterns",
                params={"user_id": user_id},
                timeout=5
            )
            
            if response.status_code == 200:
                return response.json()
            else:
                return {}
        except Exception as e:
            logger.debug(f"ARIA patterns non accessible: {e}")
            return {}
    
    def get_health_metrics(self, user_id: str, days: int = 30) -> dict[str, Any]:
        """
        Récupère métriques santé depuis ARIA
        
        Args:
            user_id: ID utilisateur
            days: Nombre de jours à récupérer
        
        Returns:
            Dict avec métriques (sommeil, activité, stress, etc.)
        """
        try:
            response = self.session.get(
                f"{self.aria_base_url}/api/health-metrics",
                params={"user_id": user_id, "days": days},
                timeout=5
            )
            
            if response.status_code == 200:
                return response.json()
            else:
                return {}
        except Exception as e:
            logger.debug(f"ARIA métriques non accessible: {e}")
            return {}

