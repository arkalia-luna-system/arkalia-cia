"""
Utilitaires de sécurité pour Arkalia CIA
Fonctions helper pour la sécurité et la sanitization
"""

import re
from typing import Any

try:
    import bleach

    BLEACH_AVAILABLE = True
except ImportError:
    BLEACH_AVAILABLE = False

try:
    import phonenumbers
    from phonenumbers import NumberParseException

    PHONENUMBERS_AVAILABLE = True
except ImportError:
    PHONENUMBERS_AVAILABLE = False


def sanitize_log_message(message: str) -> str:
    """
    Nettoie un message de log pour éviter d'exposer des informations sensibles.
    Supprime les mots de passe, tokens, clés API, etc.
    """
    if not message:
        return ""

    # Patterns à masquer (mots-clés sensibles suivis de valeurs)
    sensitive_patterns = [
        (r"(?i)(password|passwd|pwd)\s*[:=]\s*([^\s]+)", r"\1: ***"),
        (r"(?i)(api[_-]?key|apikey)\s*[:=]\s*([^\s]+)", r"\1: ***"),
        (r"(?i)(token|secret|credential)\s*[:=]\s*([^\s]+)", r"\1: ***"),
        (r"(?i)(authorization|bearer)\s+([^\s]+)", r"\1 ***"),
        (r"(?i)(db[_-]?password|database[_-]?password)\s*[:=]\s*([^\s]+)", r"\1: ***"),
    ]

    sanitized = message
    for pattern, replacement in sensitive_patterns:
        sanitized = re.sub(pattern, replacement, sanitized)

    # Masquer les emails dans les logs (garder seulement le domaine)
    sanitized = re.sub(
        r"\b([a-zA-Z0-9._%+-]+)@([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})\b",
        r"***@\2",
        sanitized,
    )

    # Masquer les numéros de téléphone (garder seulement les 4 derniers chiffres)
    sanitized = re.sub(
        r"\b(\+?\d{1,3}[-.\s]?)?\(?\d{1,4}\)?[-.\s]?\d{1,4}[-.\s]?(\d{4})\b",
        r"***-****-\2",
        sanitized,
    )

    return sanitized


def sanitize_error_detail(error: Exception) -> str:
    """
    Retourne un message d'erreur sécurisé sans exposer de détails techniques.
    """
    error_type = type(error).__name__
    error_message = str(error)

    # Masquer les chemins de fichiers complets
    error_message = re.sub(
        r"/[^\s]+/([^/\s]+)", r".../\1", error_message
    )  # Garder seulement le nom du fichier

    # Masquer les informations sensibles
    error_message = sanitize_log_message(error_message)

    # Messages d'erreur génériques pour certains types
    if "Permission" in error_type or "Access" in error_type:
        return "Erreur d'accès - permissions insuffisantes"
    elif "Connection" in error_type or "Network" in error_type:
        return "Erreur de connexion - vérifiez votre réseau"
    elif "Timeout" in error_type:
        return "Délai d'attente dépassé - réessayez plus tard"
    elif "FileNotFound" in error_type:
        return "Fichier non trouvé"
    elif "ValueError" in error_type:
        # Garder le message ValueError car il est souvent utile pour la validation
        return error_message
    else:
        # Pour les autres erreurs, retourner un message générique
        return f"Erreur {error_type}: {error_message[:100]}"


def validate_file_extension(filename: str, allowed_extensions: list[str]) -> bool:
    """Valide l'extension d'un fichier"""
    if not filename:
        return False
    ext = filename.lower().split(".")[-1] if "." in filename else ""
    return ext in [e.lower().lstrip(".") for e in allowed_extensions]


def sanitize_filename(filename: str, max_length: int = 255) -> str:
    """
    Nettoie un nom de fichier pour qu'il soit sûr.
    Supprime les caractères dangereux et limite la longueur.
    """
    if not filename:
        return "file"

    # Protection contre path traversal - remplacer tous les ".."
    safe_chars = filename.replace("..", "_")

    # Remplacer les caractères dangereux
    safe_chars = re.sub(r'[<>:"/\\|?*\x00-\x1f]', "_", safe_chars)

    # Supprimer les espaces en début/fin
    safe_chars = safe_chars.strip()

    # Supprimer les points multiples consécutifs
    safe_chars = re.sub(r"\.{2,}", ".", safe_chars)

    # Limiter la longueur
    if len(safe_chars) > max_length:
        name, ext = safe_chars.rsplit(".", 1) if "." in safe_chars else (safe_chars, "")
        safe_chars = name[: max_length - len(ext) - 1] + ("." + ext if ext else "")

    return safe_chars or "file"


def is_safe_path(file_path: str, allowed_dir: str) -> bool:
    """
    Vérifie qu'un chemin de fichier est dans le répertoire autorisé.
    Protection contre les path traversal attacks.
    """
    from pathlib import Path

    try:
        file_path_obj = Path(file_path).resolve()
        allowed_dir_obj = Path(allowed_dir).resolve()

        # Vérifier que le fichier est dans le répertoire autorisé
        return (
            allowed_dir_obj in file_path_obj.parents
            or file_path_obj.parent == allowed_dir_obj
        )
    except (ValueError, OSError):
        return False


def mask_sensitive_data(
    data: dict[str, Any], sensitive_keys: list[str] | None = None
) -> dict[str, Any]:
    """
    Masque les données sensibles dans un dictionnaire.
    """
    if sensitive_keys is None:
        sensitive_keys = [
            "password",
            "passwd",
            "pwd",
            "api_key",
            "apikey",
            "token",
            "secret",
            "credential",
            "authorization",
            "bearer",
        ]

    masked: dict[str, Any] = {}
    for key, value in data.items():
        key_lower = key.lower()
        if any(sensitive in key_lower for sensitive in sensitive_keys):
            masked[key] = "***"
        elif isinstance(value, dict):
            masked[key] = mask_sensitive_data(value, sensitive_keys)
        elif isinstance(value, list):
            masked[key] = [
                (
                    mask_sensitive_data(item, sensitive_keys)
                    if isinstance(item, dict)
                    else item
                )
                for item in value
            ]
        else:
            masked[key] = value

    return masked


def sanitize_html(text: str, allowed_tags: list[str] | None = None) -> str:
    """
    Sanitize HTML pour prévenir les attaques XSS.
    Utilise bleach si disponible, sinon fallback sur regex basique.
    """
    if not text:
        return ""

    if BLEACH_AVAILABLE:
        # Utiliser bleach pour une sanitization robuste
        if allowed_tags is None:
            # Tags autorisés par défaut (texte brut seulement)
            allowed_tags = []
        cleaned_text: str = bleach.clean(text, tags=allowed_tags, strip=True)
        return cleaned_text
    else:
        # Fallback : supprimer tous les tags HTML
        # Protection basique contre XSS
        # Utiliser des regex plus robustes pour éviter les contournements
        # Supprimer les balises script (y compris avec attributs malformés)
        text = re.sub(
            r"<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>", "", text, flags=re.IGNORECASE | re.DOTALL
        )
        # Supprimer les balises iframe
        text = re.sub(
            r"<iframe\b[^<]*(?:(?!<\/iframe>)<[^<]*)*<\/iframe>", "", text, flags=re.IGNORECASE | re.DOTALL
        )
        # Supprimer les protocoles javascript: (y compris avec variations)
        text = re.sub(r"javascript\s*:", "", text, flags=re.IGNORECASE)
        # Supprimer les gestionnaires d'événements inline
        text = re.sub(r"on\w+\s*=", "", text, flags=re.IGNORECASE)
        # Supprimer tous les autres tags HTML
        text = re.sub(r"<[^>]+>", "", text)
        return text.strip()


def validate_phone_number(phone: str, default_region: str = "BE") -> tuple[bool, str]:
    """
    Valide un numéro de téléphone international.
    Retourne (is_valid, normalized_number)
    """
    if not phone:
        return False, ""

    # Nettoyer le numéro
    cleaned = re.sub(r"[\s\-\(\)]", "", phone.strip())

    if PHONENUMBERS_AVAILABLE:
        try:
            parsed = phonenumbers.parse(cleaned, default_region)
            if phonenumbers.is_valid_number(parsed):
                # Formater en format international
                normalized = phonenumbers.format_number(
                    parsed, phonenumbers.PhoneNumberFormat.E164
                )
                return True, normalized
            else:
                return False, cleaned
        except NumberParseException:
            # Si le parsing échoue, essayer avec le format nettoyé
            return False, cleaned
    else:
        # Fallback : validation basique
        # Format belge ou international
        if re.match(r"^(?:\+32|0)?4[0-9]{8}$|^\+\d{8,15}$", cleaned):
            return True, cleaned
        else:
            return False, cleaned
