"""
Module d'authentification et d'authorization pour Arkalia CIA
Gestion des JWT tokens et permissions avec RBAC
"""

import logging
import os
import secrets
import uuid
from datetime import datetime, timedelta
from typing import Any

import jwt
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from passlib.context import CryptContext
from pydantic import BaseModel, Field

logger = logging.getLogger(__name__)

# Configuration de sécurité
SECRET_KEY = os.getenv("JWT_SECRET_KEY", secrets.token_urlsafe(32))
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30
REFRESH_TOKEN_EXPIRE_DAYS = 7

# Rôles disponibles
ROLES = {
    "admin": ["admin", "user", "family_viewer", "family_editor"],
    "user": ["user"],
    "family_viewer": ["user", "family_viewer"],
    "family_editor": ["user", "family_viewer", "family_editor"],
}

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
    role: str = Field(
        default="user", pattern="^(admin|user|family_viewer|family_editor)$"
    )


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
    """Crée un token JWT d'accès avec JTI (JWT ID) pour rotation"""
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    # Ajouter JTI (JWT ID) unique pour permettre la blacklist
    jti = str(uuid.uuid4())
    to_encode.update({"exp": expire, "type": "access", "jti": jti})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt


def create_refresh_token(data: dict) -> str:
    """Crée un token JWT de rafraîchissement avec JTI pour rotation"""
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS)
    # Ajouter JTI (JWT ID) unique pour permettre la blacklist et rotation
    jti = str(uuid.uuid4())
    to_encode.update({"exp": expire, "type": "refresh", "jti": jti})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt


def verify_token(
    token: str, token_type: str = "access", db: Any = None
) -> TokenData:  # nosec B107
    """Vérifie et décode un token JWT avec vérification blacklist"""
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])

        # Vérifier le type de token
        if payload.get("type") != token_type:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Type de token invalide",
            )

        # Vérifier si le token est dans la blacklist (si DB fournie)
        if db is not None:
            jti = payload.get("jti")
            if jti and db.is_token_blacklisted(jti):
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Token révoqué",
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
    except HTTPException:
        raise
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
    """Dépendance FastAPI pour obtenir l'utilisateur actuel (sans DB pour compatibilité)"""
    token = credentials.credentials
    token_data = verify_token(token, token_type="access")  # nosec B106
    return token_data


async def get_current_user_with_db(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Any = None,  # Sera injecté via Depends(get_database) dans api.py
) -> TokenData:
    """Dépendance FastAPI pour obtenir l'utilisateur actuel avec vérification blacklist"""
    token = credentials.credentials
    # Vérifier blacklist si DB disponible
    token_data = verify_token(token, token_type="access", db=db)  # nosec B106
    return token_data


async def get_current_active_user(
    current_user: TokenData = Depends(get_current_user),
) -> TokenData:
    """Vérifie que l'utilisateur est actif (sans DB pour compatibilité)"""
    # Note: Vérification DB sera ajoutée dans les endpoints qui ont besoin
    return current_user


async def get_current_active_user_with_db(
    current_user: TokenData = Depends(get_current_user_with_db),
    db: Any = None,  # Sera injecté via Depends(get_database) dans api.py
) -> TokenData:
    """Vérifie que l'utilisateur est actif avec vérification DB et blacklist"""
    # Vérifier dans la DB si l'utilisateur est actif (si DB disponible)
    if db is not None and current_user.user_id:
        try:
            user_data = db.get_user_by_id(int(current_user.user_id))
            if user_data and not user_data.get("is_active", True):
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail="Compte utilisateur désactivé",
                )
        except (ValueError, TypeError):
            # Si user_id n'est pas un nombre valide, ignorer la vérification DB
            pass
    return current_user


def has_permission(user_role: str, required_permission: str) -> bool:
    """Vérifie si un rôle a une permission donnée (RBAC)"""
    user_permissions = ROLES.get(user_role, [])
    return required_permission in user_permissions


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


def require_permission(required_permission: str):
    """Décorateur pour vérifier une permission spécifique (RBAC)"""

    async def permission_checker(
        current_user: TokenData = Depends(get_current_active_user),
    ):
        if not has_permission(current_user.role or "user", required_permission):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Permission '{required_permission}' requise",
            )
        return current_user

    return permission_checker
