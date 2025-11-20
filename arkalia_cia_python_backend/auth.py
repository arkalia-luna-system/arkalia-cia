"""
Module d'authentification et d'authorization pour Arkalia CIA
Gestion des JWT tokens et permissions
"""

import logging
import os
import secrets
from datetime import datetime, timedelta

import jwt
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from passlib.context import CryptContext  # type: ignore[import-untyped]
from pydantic import BaseModel, Field

logger = logging.getLogger(__name__)

# Configuration de sécurité
SECRET_KEY = os.getenv("JWT_SECRET_KEY", secrets.token_urlsafe(32))
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30
REFRESH_TOKEN_EXPIRE_DAYS = 7

# Contexte de hachage de mot de passe
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# Security scheme pour FastAPI
security = HTTPBearer()


class Token(BaseModel):
    """Modèle de token JWT"""

    access_token: str
    refresh_token: str
    token_type: str = "bearer"


class TokenData(BaseModel):
    """Données contenues dans le token"""

    user_id: str | None = None
    username: str | None = None
    role: str | None = "user"


class UserCreate(BaseModel):
    """Modèle pour création d'utilisateur"""

    username: str = Field(..., min_length=3, max_length=50)
    password: str = Field(..., min_length=8, max_length=100)
    email: str | None = None


class UserLogin(BaseModel):
    """Modèle pour connexion utilisateur"""

    username: str = Field(..., min_length=1)
    password: str = Field(..., min_length=1)


class UserResponse(BaseModel):
    """Modèle de réponse utilisateur"""

    id: int
    username: str
    email: str | None = None
    role: str
    created_at: str


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Vérifie un mot de passe contre son hash"""
    result: bool = pwd_context.verify(plain_password, hashed_password)
    return result


def get_password_hash(password: str) -> str:
    """Hash un mot de passe"""
    result: str = pwd_context.hash(password)
    return result


def create_access_token(data: dict, expires_delta: timedelta | None = None) -> str:
    """Crée un token JWT d'accès"""
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire, "type": "access"})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt


def create_refresh_token(data: dict) -> str:
    """Crée un token JWT de rafraîchissement"""
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS)
    to_encode.update({"exp": expire, "type": "refresh"})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt


def verify_token(token: str, token_type: str = "access") -> TokenData:  # nosec B107
    """Vérifie et décode un token JWT"""
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])

        # Vérifier le type de token
        if payload.get("type") != token_type:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Type de token invalide",
            )

        user_id: str = payload.get("sub")
        username: str = payload.get("username")
        role: str = payload.get("role", "user")

        if user_id is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Token invalide",
            )

        return TokenData(user_id=user_id, username=username, role=role)
    except jwt.ExpiredSignatureError as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token expiré",
        ) from e
    except jwt.PyJWTError as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token invalide",
        ) from e


async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
) -> TokenData:
    """Dépendance FastAPI pour obtenir l'utilisateur actuel"""
    token = credentials.credentials
    token_data = verify_token(token, token_type="access")  # nosec B106
    return token_data


async def get_current_active_user(
    current_user: TokenData = Depends(get_current_user),
) -> TokenData:
    """Vérifie que l'utilisateur est actif"""
    # Ici on pourrait vérifier dans la DB si l'utilisateur est actif
    # Pour l'instant, on retourne simplement l'utilisateur
    return current_user


def require_role(allowed_roles: list[str]):
    """Décorateur pour vérifier les rôles"""

    async def role_checker(current_user: TokenData = Depends(get_current_active_user)):
        if current_user.role not in allowed_roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Permissions insuffisantes",
            )
        return current_user

    return role_checker
