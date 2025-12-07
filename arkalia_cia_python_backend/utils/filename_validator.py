"""
Validateur de noms de fichiers sécurisé
Validation complète contre injection de chemin et DoS
"""

import os
import re
from pathlib import Path

from arkalia_cia_python_backend.config import get_settings


class FilenameValidator:
    """Validateur pour noms de fichiers sécurisés"""

    # Noms réservés Windows
    WINDOWS_RESERVED_NAMES = {
        "CON",
        "PRN",
        "AUX",
        "NUL",
        "COM1",
        "COM2",
        "COM3",
        "COM4",
        "COM5",
        "COM6",
        "COM7",
        "COM8",
        "COM9",
        "LPT1",
        "LPT2",
        "LPT3",
        "LPT4",
        "LPT5",
        "LPT6",
        "LPT7",
        "LPT8",
        "LPT9",
    }

    def __init__(self):
        """Initialise le validateur"""
        self.settings = get_settings()

    def validate(self, filename: str | None) -> str:
        """
        Valide et nettoie un nom de fichier

        Args:
            filename: Nom de fichier à valider

        Returns:
            Nom de fichier sécurisé

        Raises:
            ValueError: Si le nom de fichier est invalide
        """
        if not filename:
            raise ValueError("Le nom de fichier est requis")

        if not isinstance(filename, str):
            raise ValueError("Le nom de fichier doit être une chaîne")

        # Nettoyer le nom de fichier pour éviter les injections de chemin
        safe_filename = os.path.basename(filename)

        # Vérifier que basename n'a pas modifié le nom (pas de ../)
        if safe_filename != filename:
            raise ValueError("Nom de fichier invalide (chemins relatifs interdits)")

        # Vérifier la longueur
        max_len = self.settings.max_filename_length
        if len(safe_filename) > max_len:
            raise ValueError(f"Nom de fichier trop long (max {max_len} caractères)")

        # Vérifier qu'il n'est pas vide après nettoyage
        if not safe_filename or not safe_filename.strip():
            raise ValueError("Le nom de fichier ne peut pas être vide")

        # Vérifier les caractères autorisés (regex)
        if not re.match(self.settings.allowed_filename_chars, safe_filename):
            raise ValueError("Le nom de fichier contient des caractères non autorisés")

        # Vérifier les noms réservés Windows (même sur Unix pour compatibilité)
        name_without_ext = Path(safe_filename).stem.upper()
        if name_without_ext in self.WINDOWS_RESERVED_NAMES:
            raise ValueError(f"Nom de fichier réservé: {name_without_ext}")

        # Vérifier les caractères interdits Windows
        invalid_chars = r'<>:"|?*\x00-\x1f'
        if re.search(f"[{invalid_chars}]", safe_filename):
            raise ValueError("Le nom de fichier contient des caractères interdits")

        # Vérifier qu'il ne se termine pas par un point ou espace (Windows)
        if safe_filename.endswith((" ", ".")):  # type: ignore[unreachable]
            raise ValueError(
                "Le nom de fichier ne peut pas se terminer par un espace ou un point"
            )

        return safe_filename

    def validate_pdf(self, filename: str | None) -> str:
        """
        Valide spécifiquement un fichier PDF

        Args:
            filename: Nom de fichier à valider

        Returns:
            Nom de fichier PDF sécurisé

        Raises:
            ValueError: Si le nom de fichier n'est pas un PDF valide
        """
        safe_filename = self.validate(filename)

        # Vérifier l'extension PDF
        if not safe_filename.lower().endswith(".pdf"):
            raise ValueError("Seuls les fichiers PDF sont acceptés")

        return safe_filename


# Instance globale pour utilisation facile
_validator: FilenameValidator | None = None


def get_filename_validator() -> FilenameValidator:
    """Retourne l'instance du validateur (singleton)"""
    global _validator
    if _validator is None:
        _validator = FilenameValidator()
    return _validator
