"""
Validateur SSRF (Server-Side Request Forgery)
Extrait la logique de validation SSRF pour la rendre testable et configurable
"""

import re
from urllib.parse import urlparse


class SSRFValidator:
    """Validateur pour prévenir les attaques SSRF"""

    def __init__(self, blocked_ranges: list[str] | None = None):
        """
        Initialise le validateur SSRF

        Args:
            blocked_ranges: Liste personnalisée de plages bloquées (optionnel)
        """
        self.blocked_ranges = blocked_ranges or self._default_blocked_ranges()

    def _default_blocked_ranges(self) -> list[str]:
        """Retourne les plages IP bloquées par défaut"""
        return [
            "localhost",
            "127.0.0.1",
            "0.0.0.0",
            "::1",
            "169.254.",  # Link-local
            "10.",  # Private range 10.0.0.0/8
            "172.16.",
            "172.17.",
            "172.18.",
            "172.19.",
            "172.20.",
            "172.21.",
            "172.22.",
            "172.23.",
            "172.24.",
            "172.25.",
            "172.26.",
            "172.27.",
            "172.28.",
            "172.29.",
            "172.30.",
            "172.31.",  # Private range 172.16.0.0/12
            "192.168.",  # Private range 192.168.0.0/16
        ]

    def validate(self, url: str) -> str:
        """
        Valide qu'une URL n'est pas une attaque SSRF

        Args:
            url: URL à valider

        Returns:
            URL validée (normalisée)

        Raises:
            ValueError: Si l'URL est bloquée (SSRF détecté)
        """
        if not url or not isinstance(url, str):
            raise ValueError("URL invalide ou vide")

        # Parser l'URL
        try:
            parsed = urlparse(url)
        except Exception as e:
            raise ValueError(f"Format d'URL invalide: {e}") from e

        # Vérifier le schéma
        if parsed.scheme not in ["http", "https"]:
            raise ValueError("Seuls les schémas http et https sont autorisés")

        # Vérifier le hostname
        hostname = parsed.hostname or ""
        if not hostname:
            raise ValueError("Hostname manquant dans l'URL")

        # Bloquer les hostnames dans la liste noire
        hostname_lower = hostname.lower()
        if any(hostname_lower.startswith(blocked) for blocked in self.blocked_ranges):
            raise ValueError(
                "Les URLs vers des adresses privées ne sont pas autorisées"
            )

        # Bloquer les IPs privées (format IP numérique)
        if re.match(r"^\d+\.\d+\.\d+\.\d+$", hostname):
            parts = hostname.split(".")
            if len(parts) != 4:
                raise ValueError("Format d'adresse IP invalide")

            try:
                first_octet = int(parts[0])
                second_octet = int(parts[1]) if len(parts) > 1 else 0
            except ValueError as e:
                raise ValueError("Format d'adresse IP invalide") from e

            # Vérifier les plages privées:
            # - 10.0.0.0/8
            # - 172.16.0.0/12
            # - 192.168.0.0/16
            if (
                first_octet == 10
                or (first_octet == 172 and 16 <= second_octet <= 31)
                or (first_octet == 192 and second_octet == 168)
            ):
                raise ValueError(
                    "Les URLs vers des adresses IP privées ne sont pas autorisées"
                )

        return url


# Instance globale pour utilisation facile
_validator: SSRFValidator | None = None


def get_ssrf_validator() -> SSRFValidator:
    """Retourne l'instance du validateur SSRF (singleton)"""
    global _validator
    if _validator is None:
        _validator = SSRFValidator()
    return _validator
