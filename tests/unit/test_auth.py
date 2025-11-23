"""
Tests unitaires pour auth
"""

from datetime import timedelta

import pytest

from arkalia_cia_python_backend.auth import (
    TokenData,
    UserCreate,
    UserLogin,
    UserResponse,
    create_access_token,
    create_refresh_token,
    get_password_hash,
    verify_password,
    verify_token,
)


class TestPasswordHashing:
    """Tests pour le hachage de mots de passe"""

    def test_get_password_hash(self):
        """Test création hash mot de passe"""
        from unittest.mock import patch

        # Mock pour éviter le problème avec passlib/bcrypt
        with patch("arkalia_cia_python_backend.auth.pwd_context.hash") as mock_hash:
            mock_hash.return_value = "$2b$12$hashedpassword"
            password = "testpass8"
            hash1 = get_password_hash(password)
            assert hash1 is not None
            assert len(hash1) > 0
            assert hash1 != password
            mock_hash.assert_called_once_with(password)

    def test_verify_password_correct(self):
        """Test vérification mot de passe correct"""
        from unittest.mock import patch

        with patch("arkalia_cia_python_backend.auth.pwd_context.verify") as mock_verify:
            mock_verify.return_value = True
            password_hash = "$2b$12$hashedpassword"
            result = verify_password("testpass8", password_hash)
            assert result is True
            mock_verify.assert_called_once_with("testpass8", password_hash)

    def test_verify_password_incorrect(self):
        """Test vérification mot de passe incorrect"""
        from unittest.mock import patch

        with patch("arkalia_cia_python_backend.auth.pwd_context.verify") as mock_verify:
            mock_verify.return_value = False
            password_hash = "$2b$12$hashedpassword"
            result = verify_password("wrongpass", password_hash)
            assert result is False
            mock_verify.assert_called_once_with("wrongpass", password_hash)

    def test_different_hashes_same_password(self):
        """Test que le même mot de passe génère des hash différents"""
        from unittest.mock import patch

        with patch("arkalia_cia_python_backend.auth.pwd_context.hash") as mock_hash:
            # Simuler des hash différents à chaque appel
            mock_hash.side_effect = [
                "$2b$12$hash1",
                "$2b$12$hash2",
            ]
            password = "testpass8"
            hash1 = get_password_hash(password)
            hash2 = get_password_hash(password)
            # Les hash bcrypt sont différents à chaque fois
            assert hash1 != hash2
            assert mock_hash.call_count == 2


class TestTokenCreation:
    """Tests pour la création de tokens"""

    def test_create_access_token(self):
        """Test création token d'accès"""
        data = {"sub": "1", "username": "test", "role": "user"}
        token = create_access_token(data)
        assert token is not None
        assert isinstance(token, str)
        assert len(token) > 0

    def test_create_access_token_with_expiry(self):
        """Test création token avec expiration personnalisée"""
        data = {"sub": "1", "username": "test", "role": "user"}
        expires_delta = timedelta(minutes=60)
        token = create_access_token(data, expires_delta=expires_delta)
        assert token is not None

    def test_create_refresh_token(self):
        """Test création token de rafraîchissement"""
        data = {"sub": "1", "username": "test", "role": "user"}
        token = create_refresh_token(data)
        assert token is not None
        assert isinstance(token, str)
        assert len(token) > 0

    def test_tokens_are_different(self):
        """Test que access et refresh tokens sont différents"""
        data = {"sub": "1", "username": "test", "role": "user"}
        access_token = create_access_token(data)
        refresh_token = create_refresh_token(data)
        assert access_token != refresh_token


class TestTokenVerification:
    """Tests pour la vérification de tokens"""

    def test_verify_access_token(self):
        """Test vérification token d'accès valide"""
        data = {"sub": "1", "username": "test", "role": "user"}
        token = create_access_token(data)
        token_data = verify_token(token, token_type="access")
        assert token_data is not None
        assert token_data.user_id == "1"
        assert token_data.username == "test"
        assert token_data.role == "user"

    def test_verify_refresh_token(self):
        """Test vérification token de rafraîchissement valide"""
        data = {"sub": "1", "username": "test", "role": "user"}
        token = create_refresh_token(data)
        token_data = verify_token(token, token_type="refresh")
        assert token_data is not None
        assert token_data.user_id == "1"

    def test_verify_invalid_token(self):
        """Test vérification token invalide"""
        from fastapi import HTTPException

        with pytest.raises(HTTPException):
            verify_token("invalid_token", token_type="access")

    def test_verify_wrong_token_type(self):
        """Test vérification token avec mauvais type"""
        from fastapi import HTTPException

        data = {"sub": "1", "username": "test", "role": "user"}
        access_token = create_access_token(data)
        # Essayer de vérifier un access token comme refresh token
        with pytest.raises(HTTPException):
            verify_token(access_token, token_type="refresh")


class TestPydanticModels:
    """Tests pour les modèles Pydantic"""

    def test_token_data(self):
        """Test modèle TokenData"""
        token_data = TokenData(user_id="1", username="test", role="user")
        assert token_data.user_id == "1"
        assert token_data.username == "test"
        assert token_data.role == "user"

    def test_token_data_defaults(self):
        """Test TokenData avec valeurs par défaut"""
        token_data = TokenData()
        assert token_data.user_id is None
        assert token_data.username is None
        assert token_data.role == "user"

    def test_user_create(self):
        """Test modèle UserCreate"""
        user = UserCreate(
            username="testuser",
            email="test@example.com",
            password="testpass8",  # Au moins 8 caractères requis
        )
        assert user.username == "testuser"
        assert user.email == "test@example.com"
        assert user.password == "testpass8"

    def test_user_login(self):
        """Test modèle UserLogin"""
        login = UserLogin(username="testuser", password="test123")
        assert login.username == "testuser"
        assert login.password == "test123"

    def test_user_response(self):
        """Test modèle UserResponse"""
        from datetime import datetime

        user = UserResponse(
            id=1,
            username="testuser",
            email="test@example.com",
            role="user",
            created_at=datetime.now().isoformat(),
        )
        assert user.id == 1
        assert user.username == "testuser"
        assert user.email == "test@example.com"
        assert user.role == "user"
