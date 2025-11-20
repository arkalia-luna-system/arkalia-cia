"""
Helpers pour les tests d'authentification
Évite les problèmes avec bcrypt lors de l'initialisation
"""

import uuid
from pathlib import Path

from arkalia_cia_python_backend import api
from arkalia_cia_python_backend.auth import create_access_token, get_password_hash
from arkalia_cia_python_backend.database import CIADatabase


def create_test_user_and_token():
    """Crée un utilisateur de test et retourne un token d'authentification"""
    # Créer une DB temporaire
    test_db_dir = Path.cwd() / "test_temp"
    test_db_dir.mkdir(exist_ok=True)
    db_path = str(test_db_dir / f"test_{uuid.uuid4().hex}.db")

    original_db = api.db
    api.db = CIADatabase(db_path=db_path)

    try:
        # Utiliser un mot de passe court pour éviter les problèmes avec bcrypt
        password_hash = get_password_hash("test123")
        user_id = api.db.create_user(
            username="testuser", password_hash=password_hash, email="test@example.com"
        )
        token = create_access_token(
            data={"sub": str(user_id), "username": "testuser", "role": "user"}
        )
        return token, db_path, original_db
    except Exception:
        # Si erreur, restaurer et relancer
        api.db = original_db
        if Path(db_path).exists():
            Path(db_path).unlink()
        raise
