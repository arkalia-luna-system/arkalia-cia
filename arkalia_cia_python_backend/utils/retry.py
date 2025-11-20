"""
Utilitaires de retry avec exponential backoff
Pour appels externes fragiles (réseau, APIs)
"""

import logging
import time
from collections.abc import Callable
from functools import wraps
from typing import Any, TypeVar

from arkalia_cia_python_backend.config import get_settings

logger = logging.getLogger(__name__)

T = TypeVar("T")


def retry_with_backoff(
    max_retries: int | None = None,
    backoff_factor: float | None = None,
    exceptions: tuple[type[Exception], ...] = (Exception,),
) -> Callable[[Callable[..., T]], Callable[..., T]]:
    """
    Décorateur pour retry avec exponential backoff

    Args:
        max_retries: Nombre max de tentatives (défaut: depuis config)
        backoff_factor: Facteur de backoff (défaut: depuis config)
        exceptions: Types d'exceptions à retry (défaut: toutes)

    Returns:
        Fonction décorée avec retry logic
    """

    def decorator(func: Callable[..., T]) -> Callable[..., T]:
        @wraps(func)
        def wrapper(*args: Any, **kwargs: Any) -> T:
            settings = get_settings()
            retries = max_retries or settings.max_retries
            factor = backoff_factor or settings.retry_backoff_factor

            last_exception: Exception | None = None

            for attempt in range(retries):
                try:
                    return func(*args, **kwargs)
                except exceptions as e:
                    last_exception = e
                    if attempt < retries - 1:
                        wait_time = factor**attempt
                        logger.warning(
                            f"Tentative {attempt + 1}/{retries} échouée "
                            f"pour {func.__name__}: {e}. "
                            f"Retry dans {wait_time:.2f}s"
                        )
                        time.sleep(wait_time)
                    else:
                        logger.error(
                            f"Toutes les tentatives échouées pour {func.__name__}: {e}"
                        )

            # Si on arrive ici, toutes les tentatives ont échoué
            if last_exception:
                raise last_exception

            # Ne devrait jamais arriver
            raise RuntimeError("Retry logic failed unexpectedly")

        return wrapper

    return decorator
