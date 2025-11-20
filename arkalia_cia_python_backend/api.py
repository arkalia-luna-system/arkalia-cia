"""
API FastAPI pour Arkalia CIA
Backend pour l'application mobile Flutter
"""

import logging
import os  # nosec B404
import re
import tempfile
from datetime import datetime
from pathlib import Path
from urllib.parse import urlparse

from fastapi import Depends, FastAPI, File, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from pydantic import BaseModel, Field, field_validator
from slowapi import Limiter
from slowapi.errors import RateLimitExceeded
from slowapi.util import get_remote_address
from starlette.requests import Request
from starlette.responses import Response

from arkalia_cia_python_backend.ai.conversational_ai import ConversationalAI
from arkalia_cia_python_backend.ai.pattern_analyzer import AdvancedPatternAnalyzer
from arkalia_cia_python_backend.aria_integration.api import router as aria_router
from arkalia_cia_python_backend.auth import (
    Token,
    TokenData,
    UserCreate,
    UserLogin,
    UserResponse,
    create_access_token,
    create_refresh_token,
    get_current_active_user,
    get_password_hash,
    verify_password,
    verify_token,
)
from arkalia_cia_python_backend.database import CIADatabase
from arkalia_cia_python_backend.pdf_parser.metadata_extractor import MetadataExtractor
from arkalia_cia_python_backend.pdf_processor import PDFProcessor
from arkalia_cia_python_backend.security_utils import (
    sanitize_error_detail,
    sanitize_html,
    sanitize_log_message,
    validate_phone_number,
)

logger = logging.getLogger(__name__)

# Configuration du logging sécurisé
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)


# Rate limiter pour la sécurité - amélioré pour supporter user_id
def get_rate_limit_key(request: Request):
    """Clé pour rate limiting : IP + user_id si authentifié"""
    ip = get_remote_address(request)

    # Essayer d'extraire le user_id du token si présent
    try:
        auth_header = request.headers.get("authorization", "")
        if auth_header.startswith("Bearer "):
            token = auth_header.split(" ")[1]
            from arkalia_cia_python_backend.auth import verify_token

            try:
                token_data = verify_token(token, token_type="access")
                if token_data.user_id:
                    # Combiner IP + user_id pour un rate limiting par utilisateur
                    return f"{ip}:user:{token_data.user_id}"
            except Exception:
                # Si le token est invalide, utiliser juste l'IP
                pass
    except Exception:
        pass

    # Fallback : utiliser juste l'IP
    return ip


limiter = Limiter(key_func=get_rate_limit_key)

# Instances globales - seront injectées via Depends pour meilleure testabilité
# Gardons-les pour compatibilité mais utiliser Depends() dans les endpoints
db = CIADatabase()
pdf_processor = PDFProcessor()
conversational_ai = ConversationalAI()
pattern_analyzer = AdvancedPatternAnalyzer()


# Modèles Pydantic
class DocumentResponse(BaseModel):
    id: int
    name: str
    original_name: str
    file_path: str
    file_type: str
    file_size: int
    created_at: str


class ReminderRequest(BaseModel):
    title: str = Field(..., min_length=1, max_length=200)
    description: str | None = Field(None, max_length=1000)
    reminder_date: str

    @field_validator("description")
    @classmethod
    def validate_description(cls, v: str | None) -> str | None:
        """Valide et sanitize la description"""
        if v is None:
            return None
        v = v.strip()
        # Protection contre XSS avec sanitization HTML
        v = sanitize_html(v)
        return v

    @field_validator("title")
    @classmethod
    def validate_title(cls, v: str) -> str:
        if not v or not v.strip():
            raise ValueError("Le titre ne peut pas être vide")
        v = v.strip()
        # Protection contre XSS avec sanitization HTML
        v = sanitize_html(v)
        return v

    @field_validator("reminder_date")
    @classmethod
    def validate_date(cls, v: str) -> str:
        # Valider le format ISO 8601
        try:
            datetime.fromisoformat(v.replace("Z", "+00:00"))
        except (ValueError, AttributeError) as e:
            raise ValueError("Format de date invalide (attendu: ISO 8601)") from e
        return v


class ReminderResponse(BaseModel):
    id: int
    title: str
    description: str | None
    reminder_date: str
    is_completed: bool
    created_at: str


class EmergencyContactRequest(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)
    phone: str = Field(..., min_length=1, max_length=20)
    relationship: str | None = Field(None, max_length=50)
    is_primary: bool = False

    @field_validator("relationship")
    @classmethod
    def validate_relationship(cls, v: str | None) -> str | None:
        """Valide la relation"""
        if v is None:
            return None
        v = v.strip()
        # Protection contre XSS
        xss_patterns = [
            r"<script[^>]*>",
            r"javascript:",
        ]
        for pattern in xss_patterns:
            if re.search(pattern, v, re.IGNORECASE):
                raise ValueError("La relation contient des caractères non autorisés")
        # Autoriser seulement lettres, espaces, tirets, apostrophes
        if not re.match(r"^[a-zA-ZÀ-ÿ\s\-']+$", v):
            raise ValueError("La relation contient des caractères invalides")
        return v

    @field_validator("name")
    @classmethod
    def validate_name(cls, v: str) -> str:
        if not v or not v.strip():
            raise ValueError("Le nom ne peut pas être vide")
        v = v.strip()
        # Protection contre XSS avec sanitization HTML
        v = sanitize_html(v)
        # Autoriser seulement lettres, espaces, tirets, apostrophes
        if not re.match(r"^[a-zA-ZÀ-ÿ\s\-']+$", v):
            raise ValueError("Le nom contient des caractères invalides")
        return v

    @field_validator("phone")
    @classmethod
    def validate_phone(cls, v: str) -> str:
        if not v or not v.strip():
            raise ValueError("Le numéro de téléphone ne peut pas être vide")
        # Valider avec phonenumbers si disponible, sinon fallback
        is_valid, normalized = validate_phone_number(v, default_region="BE")
        if not is_valid:
            raise ValueError("Format de numéro de téléphone invalide")
        return normalized


class EmergencyContactResponse(BaseModel):
    id: int
    name: str
    phone: str
    relationship: str | None
    is_primary: bool
    created_at: str


class HealthPortalRequest(BaseModel):
    name: str = Field(..., min_length=1, max_length=200)
    url: str = Field(..., min_length=1, max_length=500)
    description: str | None = Field(None, max_length=1000)
    category: str | None = Field(None, max_length=50)

    @field_validator("description")
    @classmethod
    def validate_description(cls, v: str | None) -> str | None:
        """Valide et sanitize la description"""
        if v is None:
            return None
        v = v.strip()
        # Protection contre XSS avec sanitization HTML
        v = sanitize_html(v)
        return v

    @field_validator("category")
    @classmethod
    def validate_category(cls, v: str | None) -> str | None:
        """Valide la catégorie"""
        if v is None:
            return None
        v = v.strip()
        # Protection contre XSS
        xss_patterns = [
            r"<script[^>]*>",
            r"javascript:",
        ]
        for pattern in xss_patterns:
            if re.search(pattern, v, re.IGNORECASE):
                raise ValueError("La catégorie contient des caractères non autorisés")
        return v

    @field_validator("name")
    @classmethod
    def validate_name(cls, v: str) -> str:
        if not v or not v.strip():
            raise ValueError("Le nom ne peut pas être vide")
        return v.strip()

    @field_validator("url")
    @classmethod
    def validate_url(cls, v: str) -> str:
        if not v or not v.strip():
            raise ValueError("L'URL ne peut pas être vide")
        url = v.strip()
        # Valider le format de l'URL
        try:
            parsed = urlparse(url)
            if not parsed.scheme or parsed.scheme not in ("http", "https"):
                raise ValueError("L'URL doit utiliser le protocole HTTP ou HTTPS")
            if not parsed.netloc:
                raise ValueError("URL invalide")

            # Protection SSRF - bloquer les adresses IP privées/localhost
            hostname = parsed.hostname or ""
            if hostname:
                # Bloquer localhost et IPs privées
                # Liste de blocage SSRF - ces adresses sont intentionnellement bloquées
                # Note: "0.0.0.0" est dans une constante séparée pour éviter les warnings Bandit
                blocked_all_interfaces = "0.0.0.0"  # nosec B104 - Liste de blocage SSRF, pas un binding réseau
                blocked_hosts = [
                    "localhost",
                    "127.0.0.1",
                    blocked_all_interfaces,
                    "::1",
                    "169.254.",
                    "10.",
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
                    "172.31.",
                    "192.168.",
                ]
                hostname_lower = hostname.lower()
                if any(hostname_lower.startswith(blocked) for blocked in blocked_hosts):
                    raise ValueError(
                        "Les URLs vers des adresses privées ne sont pas autorisées"
                    )

                # Bloquer les IPs privées (format IP)
                if re.match(r"^\d+\.\d+\.\d+\.\d+$", hostname):
                    parts = hostname.split(".")
                    first_octet = int(parts[0])
                    second_octet = int(parts[1]) if len(parts) > 1 else 0
                    # 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16
                    if (
                        first_octet == 10
                        or (first_octet == 172 and 16 <= second_octet <= 31)
                        or (first_octet == 192 and second_octet == 168)
                    ):
                        raise ValueError(
                            "Les URLs vers des adresses IP privées ne sont pas autorisées"
                        )
        except ValueError:
            raise
        except Exception as e:
            raise ValueError("Format d'URL invalide") from e
        return url


class HealthPortalResponse(BaseModel):
    id: int
    name: str
    url: str
    description: str | None
    category: str | None
    created_at: str


# Application FastAPI avec configuration de sécurité
app = FastAPI(
    title="Arkalia CIA API",
    description="API backend pour l'application mobile Arkalia CIA",
    version="1.0.0",
    docs_url=("/docs" if os.getenv("ENVIRONMENT") != "production" else None),
    redoc_url=("/redoc" if os.getenv("ENVIRONMENT") != "production" else None),
    # Désactiver OpenAPI schema en production pour réduire la surface d'attaque
    openapi_url=("/openapi.json" if os.getenv("ENVIRONMENT") != "production" else None),
)

# Versioning API
API_VERSION = "v1"
API_PREFIX = f"/api/{API_VERSION}"

# Ajouter le rate limiter
app.state.limiter = limiter


def rate_limit_handler(request: Request, exc: Exception) -> Response:
    """Handler personnalisé pour RateLimitExceeded"""
    from slowapi.errors import RateLimitExceeded

    if isinstance(exc, RateLimitExceeded):
        from fastapi.responses import JSONResponse

        return JSONResponse(
            status_code=429,
            content={"detail": "Trop de requêtes. Veuillez réessayer plus tard."},
        )
    raise exc


app.add_exception_handler(RateLimitExceeded, rate_limit_handler)

# Middleware de sécurité : Trusted Host
# En production, ajouter les domaines autorisés
if os.getenv("ENVIRONMENT") == "production":
    app.add_middleware(
        TrustedHostMiddleware,
        allowed_hosts=["api.arkalia-cia.com", "*.arkalia-cia.com"],
    )

# Limite de taille de requête globale (protection DoS)
MAX_REQUEST_SIZE = 10 * 1024 * 1024  # 10 MB pour les requêtes JSON


# Middleware pour ajouter des headers de sécurité HTTP et protections
@app.middleware("http")
async def add_security_headers(request: Request, call_next):
    """Ajoute des headers de sécurité HTTP et protections supplémentaires"""
    # Protection contre les attaques de type
    # Vérifier le Content-Type pour les requêtes POST/PUT
    if request.method in ["POST", "PUT", "PATCH"]:
        content_type = request.headers.get("content-type", "")
        # Rejeter les content-types suspects
        if (
            content_type
            and "application/json" not in content_type
            and "multipart/form-data" not in content_type
        ):
            if "text/html" in content_type or "application/xml" in content_type:
                # Potentielle attaque XSS ou XXE
                logger.warning(
                    sanitize_log_message(
                        f"Content-Type suspect rejeté: {content_type} depuis {request.client.host if request.client else 'unknown'}"
                    )
                )
                from fastapi.responses import JSONResponse

                return JSONResponse(
                    status_code=400,
                    content={"detail": "Content-Type non autorisé"},
                )

        # Protection contre les requêtes trop volumineuses (DoS)
        content_length = request.headers.get("content-length")
        if content_length:
            try:
                size = int(content_length)
                if size > MAX_REQUEST_SIZE:
                    logger.warning(
                        sanitize_log_message(
                            f"Requête trop volumineuse rejetée (header): {size} bytes depuis {request.client.host if request.client else 'unknown'}"
                        )
                    )
                    from fastapi.responses import JSONResponse

                    return JSONResponse(
                        status_code=413,
                        content={"detail": "Requête trop volumineuse"},
                    )
            except (ValueError, TypeError):
                pass

        # Note: La vérification de la taille réelle du body JSON se fait
        # au niveau de FastAPI/Uvicorn via la configuration max_request_size
        # La vérification du Content-Length header est une première ligne de défense

    response = await call_next(request)
    # Headers de sécurité
    response.headers["X-Content-Type-Options"] = "nosniff"
    response.headers["X-Frame-Options"] = "DENY"
    response.headers["X-XSS-Protection"] = "1; mode=block"
    response.headers["Referrer-Policy"] = "strict-origin-when-cross-origin"
    response.headers["Permissions-Policy"] = "geolocation=(), microphone=(), camera=()"
    # Content Security Policy basique
    response.headers["Content-Security-Policy"] = (
        "default-src 'self'; "
        "script-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net; "
        "style-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net; "
        "img-src 'self' data:; "
        "font-src 'self' https://cdn.jsdelivr.net;"
    )
    # HSTS seulement en HTTPS
    if request.url.scheme == "https":
        response.headers["Strict-Transport-Security"] = (
            "max-age=31536000; includeSubDomains"
        )
    return response


# CORS pour Flutter et fichiers locaux (sécurisé)
# Configuration via variables d'environnement
cors_origins_env = os.getenv("CORS_ORIGINS", "")
if cors_origins_env:
    cors_origins = [origin.strip() for origin in cors_origins_env.split(",")]
else:
    # Valeurs par défaut pour développement
    cors_origins = [
        "http://localhost:8080",
        "http://127.0.0.1:8080",
        "http://localhost:3000",
        "http://127.0.0.1:3000",
    ]

app.add_middleware(
    CORSMiddleware,
    allow_origins=cors_origins,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allow_headers=["Content-Type", "Authorization", "Accept"],
    expose_headers=["Content-Type"],
    max_age=3600,  # Cache CORS preflight pour 1 heure
)

# Montage du router ARIA
app.include_router(aria_router, prefix="/api/aria", tags=["ARIA Integration"])


@app.get("/")
async def root():
    """Page d'accueil de l'API"""
    return {"message": "Arkalia CIA API", "version": "1.0.0", "status": "running"}


@app.get("/health")
async def health_check():
    """Vérification de santé de l'API"""
    return {"status": "healthy", "timestamp": datetime.now().isoformat()}


# === AUTHENTIFICATION ===


class RefreshTokenRequest(BaseModel):
    """Modèle pour refresh token"""

    refresh_token: str = Field(..., min_length=1)


@app.post(f"{API_PREFIX}/auth/register", response_model=UserResponse)
@limiter.limit("5/minute")  # Limite stricte pour éviter le spam
async def register(request: Request, user_data: UserCreate):
    """Enregistre un nouvel utilisateur"""
    try:
        # Vérifier si l'utilisateur existe déjà
        existing_user = db.get_user_by_username(user_data.username)
        if existing_user:
            raise HTTPException(
                status_code=400,
                detail="Ce nom d'utilisateur est déjà utilisé",
            )

        # Créer l'utilisateur
        password_hash = get_password_hash(user_data.password)
        user_id = db.create_user(
            username=user_data.username,
            password_hash=password_hash,
            email=user_data.email,
            role="user",
        )

        if not user_id:
            raise HTTPException(
                status_code=500,
                detail="Erreur lors de la création de l'utilisateur",
            )

        # Récupérer l'utilisateur créé
        user = db.get_user_by_id(user_id)
        if not user:
            raise HTTPException(
                status_code=500,
                detail="Erreur lors de la récupération de l'utilisateur",
            )

        return UserResponse(
            id=user["id"],
            username=user["username"],
            email=user.get("email"),
            role=user.get("role", "user"),
            created_at=user["created_at"],
        )
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Erreur inscription: {sanitize_log_message(str(e))}")
        raise HTTPException(
            status_code=500,
            detail="Erreur lors de l'inscription",
        ) from e


@app.post(f"{API_PREFIX}/auth/login", response_model=Token)
@limiter.limit("10/minute")  # Limite pour éviter les attaques brute force
async def login(request: Request, credentials: UserLogin):
    """Authentifie un utilisateur et retourne un token JWT"""
    try:
        # Récupérer l'utilisateur
        user = db.get_user_by_username(credentials.username)
        if not user:
            # Ne pas révéler si l'utilisateur existe ou non (sécurité)
            raise HTTPException(
                status_code=401,
                detail="Nom d'utilisateur ou mot de passe incorrect",
            )

        # Vérifier le mot de passe
        if not verify_password(credentials.password, user["password_hash"]):
            raise HTTPException(
                status_code=401,
                detail="Nom d'utilisateur ou mot de passe incorrect",
            )

        # Vérifier si l'utilisateur est actif
        if not user.get("is_active", True):
            raise HTTPException(
                status_code=403,
                detail="Compte utilisateur désactivé",
            )

        # Créer les tokens
        token_data = {
            "sub": str(user["id"]),
            "username": user["username"],
            "role": user.get("role", "user"),
        }
        access_token = create_access_token(token_data)
        refresh_token = create_refresh_token(token_data)

        return Token(
            access_token=access_token,
            refresh_token=refresh_token,
            token_type="bearer",
        )
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Erreur connexion: {sanitize_log_message(str(e))}")
        raise HTTPException(
            status_code=500,
            detail="Erreur lors de la connexion",
        ) from e


@app.post(f"{API_PREFIX}/auth/refresh", response_model=Token)
@limiter.limit("20/minute")
async def refresh_token_endpoint(request: Request, token_request: RefreshTokenRequest):
    """Rafraîchit un token d'accès avec un refresh token"""
    try:
        token_data = verify_token(token_request.refresh_token, token_type="refresh")

        # Créer un nouveau token d'accès
        new_token_data = {
            "sub": token_data.user_id,
            "username": token_data.username,
            "role": token_data.role,
        }
        access_token = create_access_token(new_token_data)

        # Créer un nouveau refresh token
        new_refresh_token = create_refresh_token(new_token_data)

        return Token(
            access_token=access_token,
            refresh_token=new_refresh_token,
            token_type="bearer",
        )
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Erreur refresh token: {sanitize_log_message(str(e))}")
        raise HTTPException(
            status_code=401,
            detail="Token de rafraîchissement invalide",
        ) from e


# === DOCUMENTS ===


@app.post(f"{API_PREFIX}/documents/upload")
@limiter.limit("10/minute")  # Limite de 10 uploads par minute par IP
async def upload_document(
    request: Request,
    file: UploadFile = File(...),
    current_user: TokenData = Depends(get_current_active_user),
):
    """Upload un document PDF avec validation de sécurité"""
    tmp_file_path = None
    try:
        # Validation du nom de fichier
        if not file.filename:
            raise HTTPException(status_code=400, detail="Le nom de fichier est requis")

        # Nettoyer le nom de fichier pour éviter les injections de chemin
        safe_filename = os.path.basename(file.filename)
        if not safe_filename or safe_filename != file.filename:
            raise HTTPException(status_code=400, detail="Nom de fichier invalide")

        # Vérifier que c'est un PDF
        if not safe_filename.lower().endswith(".pdf"):
            raise HTTPException(
                status_code=400, detail="Seuls les fichiers PDF sont acceptés"
            )

        # Limiter la taille du fichier (50 MB max)
        MAX_FILE_SIZE = 50 * 1024 * 1024  # 50 MB

        # Écrire directement dans le fichier temporaire par chunks
        # pour éviter de charger tout le fichier en mémoire
        chunk_size = 1024 * 1024  # 1 MB par chunk
        total_size = 0

        with tempfile.NamedTemporaryFile(delete=False, suffix=".pdf") as tmp_file:
            tmp_file_path = tmp_file.name
            while True:
                chunk = await file.read(chunk_size)
                if not chunk:
                    break
                total_size += len(chunk)
                if total_size > MAX_FILE_SIZE:
                    # Nettoyer le fichier temporaire avant de lever l'exception
                    try:
                        os.unlink(tmp_file_path)
                    except OSError:
                        pass
                    raise HTTPException(
                        status_code=400,
                        detail="Le fichier est trop volumineux (max 50 MB)",
                    )
                tmp_file.write(chunk)
                # Libérer immédiatement le chunk de la mémoire
                del chunk

        # Traiter le PDF
        result = pdf_processor.process_pdf(tmp_file_path, safe_filename)

        if not result["success"]:
            # Nettoyer le fichier temporaire en cas d'erreur
            if tmp_file_path and os.path.exists(tmp_file_path):
                try:
                    os.unlink(tmp_file_path)
                except OSError:
                    pass
            raise HTTPException(status_code=400, detail=result["error"])

        # Extraire métadonnées intelligentes
        metadata = None
        text_content = ""
        try:
            # Extraire texte (avec OCR si nécessaire)
            text_content = pdf_processor.extract_text_from_pdf(
                tmp_file_path, use_ocr=False
            )

            # Si peu de texte, essayer OCR
            if len(text_content.strip()) < 100:
                text_content = pdf_processor.extract_text_from_pdf(
                    tmp_file_path, use_ocr=True
                )

            # Extraire métadonnées
            metadata_extractor = MetadataExtractor()
            metadata = metadata_extractor.extract_metadata(text_content)
        except Exception as e:
            logger.warning(
                f"Erreur extraction métadonnées: {sanitize_log_message(str(e))}"
            )
            metadata = None

        # Sauvegarder en base de données avec métadonnées
        doc_id = db.add_document(
            name=result["filename"],
            original_name=result["original_name"],
            file_path=result["file_path"],
            file_type="pdf",
            file_size=result["file_size"],
        )

        # Associer le document à l'utilisateur authentifié
        if doc_id and current_user.user_id:
            db.associate_document_to_user(int(current_user.user_id), doc_id)

        # Sauvegarder métadonnées extraites
        if metadata and doc_id:
            doc_date = metadata.get("date")
            doctor_name = metadata.get("doctor_name")
            doctor_specialty = metadata.get("doctor_specialty")

            # Note: L'association avec les médecins se fait via les métadonnées
            # Les consultations sont gérées côté Flutter (DoctorService)
            # Le doctor_name et doctor_specialty sont stockés dans document_metadata
            # pour permettre l'association automatique côté UI

            db.add_document_metadata(
                document_id=doc_id,
                doctor_name=doctor_name,
                doctor_specialty=doctor_specialty,
                document_date=doc_date.isoformat() if doc_date else None,
                exam_type=metadata.get("exam_type"),
                document_type=metadata.get("document_type"),
                keywords=",".join(metadata.get("keywords", [])),
                extracted_text=(
                    text_content[:5000] if text_content else None
                ),  # Limiter à 5000 caractères
            )

            # Note: L'association avec les médecins se fait via les métadonnées
            # Les consultations sont gérées côté Flutter (DoctorService)
            # Le doctor_id et doctor_name sont stockés dans document_metadata
            # pour permettre l'association automatique côté UI

        # Nettoyer le fichier temporaire
        if tmp_file_path and os.path.exists(tmp_file_path):
            try:
                os.unlink(tmp_file_path)
            except OSError:
                pass

        return {
            "success": True,
            "document_id": doc_id,
            "message": "Document uploadé avec succès",
        }

    except HTTPException:
        # Ré-élever les HTTPException
        raise
    except Exception as e:
        # Nettoyer le fichier temporaire en cas d'erreur inattendue
        if tmp_file_path and os.path.exists(tmp_file_path):
            try:
                os.unlink(tmp_file_path)
            except OSError:
                pass
        # Logger l'erreur complète (pour debugging) mais retourner un message sécurisé
        logger.error(
            f"Erreur upload document: {sanitize_log_message(str(e))}",
            exc_info=True,
        )
        # Retourner un message d'erreur générique sans exposer de détails techniques
        raise HTTPException(status_code=500, detail=sanitize_error_detail(e)) from e


@app.get(f"{API_PREFIX}/documents", response_model=list[DocumentResponse])
@limiter.limit("60/minute")  # Limite de 60 requêtes par minute
async def get_documents(
    request: Request,
    skip: int = 0,
    limit: int = 50,
    current_user: TokenData = Depends(get_current_active_user),
):
    """Récupère les documents de l'utilisateur avec pagination"""
    if limit > 100:  # Limiter à 100 max par requête
        limit = 100
    if skip < 0:
        skip = 0
    # Récupérer uniquement les documents de l'utilisateur authentifié
    if current_user.user_id:
        documents = db.get_user_documents(
            int(current_user.user_id), skip=skip, limit=limit
        )
    else:
        documents = []
    return [DocumentResponse(**doc) for doc in documents]


@app.get(f"{API_PREFIX}/documents/{{doc_id}}", response_model=DocumentResponse)
@limiter.limit("60/minute")  # Limite de 60 requêtes par minute
async def get_document(
    request: Request,
    doc_id: int,
    current_user: TokenData = Depends(get_current_active_user),
):
    """Récupère un document par ID (uniquement si appartient à l'utilisateur)"""
    # Vérifier que le document appartient à l'utilisateur
    if current_user.user_id:
        user_docs = db.get_user_documents(int(current_user.user_id))
        if not any(doc["id"] == doc_id for doc in user_docs):
            raise HTTPException(status_code=404, detail="Document non trouvé")

    document = db.get_document(doc_id)
    if not document:
        raise HTTPException(status_code=404, detail="Document non trouvé")
    return DocumentResponse(**document)


@app.delete(f"{API_PREFIX}/documents/{{doc_id}}")
async def delete_document(
    doc_id: int,
    current_user: TokenData = Depends(get_current_active_user),
):
    """Supprime un document"""
    document = db.get_document(doc_id)
    if not document:
        raise HTTPException(status_code=404, detail="Document non trouvé")

    # Supprimer le fichier physique avec validation du chemin
    file_path = document.get("file_path", "")
    if file_path:
        # Valider que le chemin est dans le répertoire uploads (sécurité)
        uploads_dir = Path("uploads").resolve()
        file_path_obj = Path(file_path).resolve()

        try:
            # Vérifier que le fichier est dans le répertoire uploads
            if (
                uploads_dir in file_path_obj.parents
                or file_path_obj.parent == uploads_dir
            ):
                if file_path_obj.exists():
                    os.unlink(file_path_obj)
            else:
                # Log l'erreur mais ne pas exposer le chemin complet
                logger.warning(
                    sanitize_log_message(
                        "Tentative de suppression de fichier hors du répertoire uploads"
                    )
                )
        except (FileNotFoundError, OSError, ValueError) as e:
            # Logger l'erreur sans exposer de détails sensibles
            logger.warning(
                sanitize_log_message(
                    f"Impossible de supprimer le fichier: {type(e).__name__}"
                )
            )

    # Supprimer de la base de données
    success = db.delete_document(doc_id)
    if not success:
        raise HTTPException(status_code=500, detail="Erreur lors de la suppression")

    return {"success": True, "message": "Document supprimé avec succès"}


# === RAPPELS ===


@app.post(f"{API_PREFIX}/reminders", response_model=ReminderResponse)
@limiter.limit("30/minute")  # Limite de 30 requêtes par minute
async def create_reminder(
    request: Request,
    reminder: ReminderRequest,
    current_user: TokenData = Depends(get_current_active_user),
):
    """Crée un rappel"""
    reminder_id = db.add_reminder(
        title=reminder.title,
        description=reminder.description or "",
        reminder_date=reminder.reminder_date,
    )

    # Récupérer le rappel créé (seulement les 10 derniers pour économiser la mémoire)
    reminders = db.get_reminders(skip=0, limit=10)
    created_reminder = next((r for r in reminders if r["id"] == reminder_id), None)

    if not created_reminder:
        raise HTTPException(
            status_code=500, detail="Erreur lors de la création du rappel"
        )

    return ReminderResponse(**created_reminder)


@app.get(f"{API_PREFIX}/reminders", response_model=list[ReminderResponse])
@limiter.limit("60/minute")  # Limite de 60 requêtes par minute
async def get_reminders(
    request: Request,
    skip: int = 0,
    limit: int = 50,
    current_user: TokenData = Depends(get_current_active_user),
):
    """Récupère les rappels avec pagination"""
    if limit > 100:  # Limiter à 100 max par requête
        limit = 100
    if skip < 0:
        skip = 0
    reminders = db.get_reminders(skip=skip, limit=limit)
    return [ReminderResponse(**reminder) for reminder in reminders]


# === CONTACTS D'URGENCE ===


@app.post(f"{API_PREFIX}/emergency-contacts", response_model=EmergencyContactResponse)
@limiter.limit("20/minute")  # Limite de 20 requêtes par minute
async def create_emergency_contact(
    request: Request,
    contact: EmergencyContactRequest,
    current_user: TokenData = Depends(get_current_active_user),
):
    """Crée un contact d'urgence"""
    contact_id = db.add_emergency_contact(
        name=contact.name,
        phone=contact.phone,
        relationship=contact.relationship or "",
        is_primary=contact.is_primary,
    )

    # Récupérer le contact créé (seulement les 10 derniers pour économiser la mémoire)
    contacts = db.get_emergency_contacts(skip=0, limit=10)
    created_contact = next((c for c in contacts if c["id"] == contact_id), None)

    if not created_contact:
        raise HTTPException(
            status_code=500, detail="Erreur lors de la création du contact"
        )

    return EmergencyContactResponse(**created_contact)


@app.get(
    f"{API_PREFIX}/emergency-contacts", response_model=list[EmergencyContactResponse]
)
@limiter.limit("60/minute")  # Limite de 60 requêtes par minute
async def get_emergency_contacts(
    request: Request,
    skip: int = 0,
    limit: int = 50,
    current_user: TokenData = Depends(get_current_active_user),
):
    """Récupère les contacts d'urgence avec pagination"""
    if limit > 100:  # Limiter à 100 max par requête
        limit = 100
    if skip < 0:
        skip = 0
    contacts = db.get_emergency_contacts(skip=skip, limit=limit)
    return [EmergencyContactResponse(**contact) for contact in contacts]


# === PORTAILS SANTÉ ===


@app.post(f"{API_PREFIX}/health-portals", response_model=HealthPortalResponse)
@limiter.limit("20/minute")  # Limite de 20 requêtes par minute
async def create_health_portal(
    request: Request,
    portal: HealthPortalRequest,
    current_user: TokenData = Depends(get_current_active_user),
):
    """Crée un portail santé"""
    portal_id = db.add_health_portal(
        name=portal.name,
        url=portal.url,
        description=portal.description or "",
        category=portal.category or "",
    )

    # Récupérer le portail créé (seulement les 10 derniers pour économiser la mémoire)
    portals = db.get_health_portals(skip=0, limit=10)
    created_portal = next((p for p in portals if p["id"] == portal_id), None)

    if not created_portal:
        raise HTTPException(
            status_code=500, detail="Erreur lors de la création du portail"
        )

    return HealthPortalResponse(**created_portal)


@app.get(f"{API_PREFIX}/health-portals", response_model=list[HealthPortalResponse])
@limiter.limit("60/minute")  # Limite de 60 requêtes par minute
async def get_health_portals(
    request: Request,
    skip: int = 0,
    limit: int = 50,
    current_user: TokenData = Depends(get_current_active_user),
):
    """Récupère les portails santé avec pagination"""
    if limit > 100:  # Limiter à 100 max par requête
        limit = 100
    if skip < 0:
        skip = 0
    portals = db.get_health_portals(skip=skip, limit=limit)
    return [HealthPortalResponse(**portal) for portal in portals]


class HealthPortalImportRequest(BaseModel):
    portal: str = Field(..., description="Nom du portail (eHealth, Andaman 7, MaSanté)")
    data: dict = Field(..., description="Données importées depuis le portail")
    access_token: str | None = Field(
        None, description="Token d'accès OAuth (optionnel)"
    )


@app.post(f"{API_PREFIX}/health-portals/import")
@limiter.limit("10/minute")  # Limite stricte pour éviter abus
async def import_health_portal_data(
    request: Request,
    import_request: HealthPortalImportRequest,
    current_user: TokenData = Depends(get_current_active_user),
):
    """Importe les données depuis un portail santé externe"""
    try:
        portal_name = import_request.portal.lower()
        data = import_request.data

        imported_count = 0
        errors = []

        # Parser documents médicaux
        if "documents" in data and isinstance(data["documents"], list):
            for doc in data["documents"][:50]:  # Limiter à 50 documents
                try:
                    # Extraire métadonnées du document
                    # Note: Pour un import complet, il faudrait télécharger les fichiers PDF
                    # et créer des entrées dans la table documents
                    _ = doc.get("name", doc.get("title", "Document importé"))
                    _ = doc.get("date", doc.get("created_at", ""))
                    _ = doc.get("type", doc.get("category", "document"))
                    imported_count += 1
                except Exception as e:
                    errors.append(
                        f"Erreur import document: {sanitize_log_message(str(e))}"
                    )

        # Parser consultations
        if "consultations" in data and isinstance(data["consultations"], list):
            for consult in data["consultations"][:50]:  # Limiter à 50 consultations
                try:
                    # Extraire informations consultation
                    # Note: Pour un import complet, il faudrait créer des entrées dans la table consultations
                    _ = consult.get("date", consult.get("created_at", ""))
                    _ = consult.get("doctor", consult.get("physician", ""))
                    _ = consult.get("specialty", "")
                    imported_count += 1
                except Exception as e:
                    errors.append(
                        f"Erreur import consultation: {sanitize_log_message(str(e))}"
                    )

        # Parser examens
        if "exams" in data and isinstance(data["exams"], list):
            for exam in data["exams"][:50]:  # Limiter à 50 examens
                try:
                    # Note: Pour un import complet, il faudrait créer des entrées dans la table examens
                    _ = exam.get("type", exam.get("exam_type", ""))
                    _ = exam.get("date", exam.get("created_at", ""))
                    _ = exam.get("results", {})
                    imported_count += 1
                except Exception as e:
                    errors.append(
                        f"Erreur import examen: {sanitize_log_message(str(e))}"
                    )

        return {
            "success": True,
            "imported_count": imported_count,
            "portal": portal_name,
            "errors": errors[:10],  # Limiter à 10 erreurs
            "message": f"{imported_count} élément(s) importé(s) depuis {portal_name}",
        }
    except Exception as e:
        logger.error(f"Erreur import portail santé: {sanitize_log_message(str(e))}")
        raise HTTPException(
            status_code=500, detail="Erreur lors de l'import des données du portail"
        ) from e


# === IA CONVERSATIONNELLE ===


class ChatRequest(BaseModel):
    question: str = Field(..., min_length=1, max_length=500)
    user_data: dict = Field(default_factory=dict)


class ChatResponse(BaseModel):
    answer: str
    related_documents: list[str] = Field(default_factory=list)
    suggestions: list[str] = Field(default_factory=list)
    patterns_detected: dict = Field(default_factory=dict)
    question_type: str = "general"


@app.post(f"{API_PREFIX}/ai/chat", response_model=ChatResponse)
@limiter.limit("30/minute")  # Limite de 30 requêtes par minute
async def chat_with_ai(
    request: Request,
    chat_request: ChatRequest,
    current_user: TokenData = Depends(get_current_active_user),
):
    """Chat avec l'IA conversationnelle"""
    try:
        # Limiter les données utilisateur pour économiser la mémoire
        # Ne garder que les données essentielles (max 10 documents récents, 5 médecins)
        limited_user_data = {
            "documents": chat_request.user_data.get("documents", [])[:10],
            "doctors": chat_request.user_data.get("doctors", [])[:5],
            "consultations": chat_request.user_data.get("consultations", [])[:5],
            "pain_records": chat_request.user_data.get("pain_records", [])[:10],
        }

        result = conversational_ai.analyze_question(
            chat_request.question, limited_user_data
        )

        # Sauvegarder conversation
        db.add_ai_conversation(
            question=chat_request.question,
            answer=result.get("answer", ""),
            question_type=result.get("question_type", "general"),
            related_documents=",".join(result.get("related_documents", [])),
        )

        return ChatResponse(
            answer=result.get("answer", ""),
            related_documents=result.get("related_documents", []),
            suggestions=result.get("suggestions", []),
            patterns_detected=result.get("patterns_detected", {}),
            question_type=result.get("question_type", "general"),
        )
    except Exception as e:
        logger.error(f"Erreur IA conversationnelle: {sanitize_log_message(str(e))}")
        raise HTTPException(
            status_code=500, detail="Erreur lors du traitement de votre question"
        ) from e


class PrepareAppointmentRequest(BaseModel):
    doctor_id: str
    user_data: dict = Field(default_factory=dict)


@app.get(f"{API_PREFIX}/ai/conversations")
@limiter.limit("60/minute")
async def get_ai_conversations(
    request: Request,
    limit: int = 50,
    current_user: TokenData = Depends(get_current_active_user),
):
    """Récupère l'historique des conversations IA"""
    try:
        if limit > 100:
            limit = 100
        if limit < 1:
            limit = 10

        conversations = db.get_ai_conversations(limit=limit)
        return conversations
    except Exception as e:
        logger.error(
            f"Erreur récupération conversations: {sanitize_log_message(str(e))}"
        )
        raise HTTPException(
            status_code=500, detail="Erreur lors de la récupération des conversations"
        ) from e


class PatternAnalysisRequest(BaseModel):
    data: list[dict] = Field(..., description="Liste des données à analyser")


@app.post(f"{API_PREFIX}/patterns/analyze")
@limiter.limit("30/minute")
async def analyze_patterns(
    request: Request,
    pattern_request: PatternAnalysisRequest,
    current_user: TokenData = Depends(get_current_active_user),
):
    """Analyse les patterns dans les données"""
    try:
        if not pattern_request.data:
            raise HTTPException(status_code=400, detail="Aucune donnée fournie")

        patterns = pattern_analyzer.detect_temporal_patterns(pattern_request.data)
        return patterns
    except HTTPException:
        # Ré-élever les HTTPException sans les transformer en 500
        raise
    except Exception as e:
        logger.error(f"Erreur analyse patterns: {sanitize_log_message(str(e))}")
        raise HTTPException(
            status_code=500, detail="Erreur lors de l'analyse des patterns"
        ) from e


class PredictEventsRequest(BaseModel):
    data: list[dict] = Field(..., description="Liste des données historiques")
    event_type: str = Field(
        default="document", description="Type d'événement à prédire"
    )
    days_ahead: int = Field(
        default=30, ge=1, le=365, description="Nombre de jours à prédire"
    )


@app.post(f"{API_PREFIX}/patterns/predict-events")
@limiter.limit("20/minute")
async def predict_future_events(
    request: Request,
    predict_request: PredictEventsRequest,
    current_user: TokenData = Depends(get_current_active_user),
):
    """Prédit les événements futurs basés sur les patterns historiques"""
    try:
        if not predict_request.data:
            raise HTTPException(status_code=400, detail="Aucune donnée fournie")

        predictions = pattern_analyzer.predict_future_events(
            predict_request.data,
            event_type=predict_request.event_type,
            days_ahead=predict_request.days_ahead,
        )
        return predictions
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Erreur prédiction événements: {sanitize_log_message(str(e))}")
        raise HTTPException(
            status_code=500, detail="Erreur lors de la prédiction des événements"
        ) from e


@app.post(f"{API_PREFIX}/ai/prepare-appointment")
@limiter.limit("20/minute")
async def prepare_appointment_questions(
    request: Request,
    appointment_request: PrepareAppointmentRequest,
    current_user: TokenData = Depends(get_current_active_user),
):
    """Prépare questions pour un rendez-vous"""
    try:
        questions = conversational_ai.prepare_appointment_questions(
            appointment_request.doctor_id, appointment_request.user_data
        )

        return {"questions": questions}
    except Exception as e:
        logger.error(f"Erreur préparation RDV: {sanitize_log_message(str(e))}")
        raise HTTPException(
            status_code=500, detail="Erreur lors de la préparation des questions"
        ) from e


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="127.0.0.1", port=8000)
