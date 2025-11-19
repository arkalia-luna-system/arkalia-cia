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

from fastapi import FastAPI, File, HTTPException, Request, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from pydantic import BaseModel, Field, field_validator
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded
from slowapi.util import get_remote_address

from arkalia_cia_python_backend.aria_integration.api import router as aria_router
from arkalia_cia_python_backend.database import CIADatabase
from arkalia_cia_python_backend.pdf_processor import PDFProcessor
from arkalia_cia_python_backend.security_utils import (
    sanitize_error_detail,
    sanitize_log_message,
)

logger = logging.getLogger(__name__)

# Configuration du logging sécurisé
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)

# Rate limiter pour la sécurité
limiter = Limiter(key_func=get_remote_address)

# Instances globales
db = CIADatabase()
pdf_processor = PDFProcessor()


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
        # Protection contre XSS dans la description
        xss_patterns = [
            r"<script[^>]*>",
            r"</script>",
            r"javascript:",
            r"onerror\s*=",
            r"onload\s*=",
        ]
        for pattern in xss_patterns:
            if re.search(pattern, v, re.IGNORECASE):
                raise ValueError("La description contient des caractères non autorisés")
        return v

    @field_validator("title")
    @classmethod
    def validate_title(cls, v: str) -> str:
        if not v or not v.strip():
            raise ValueError("Le titre ne peut pas être vide")
        v = v.strip()
        # Protection contre XSS - rejeter les balises HTML/JavaScript
        xss_patterns = [
            r"<script[^>]*>",
            r"</script>",
            r"<iframe[^>]*>",
            r"javascript:",
            r"onerror\s*=",
            r"onload\s*=",
            r"onclick\s*=",
            r"<svg[^>]*onload",
            r"<img[^>]*onerror",
        ]
        for pattern in xss_patterns:
            if re.search(pattern, v, re.IGNORECASE):
                raise ValueError("Le titre contient des caractères non autorisés")
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
        # Protection contre XSS
        xss_patterns = [
            r"<script[^>]*>",
            r"</script>",
            r"javascript:",
            r"onerror\s*=",
            r"onload\s*=",
        ]
        for pattern in xss_patterns:
            if re.search(pattern, v, re.IGNORECASE):
                raise ValueError("Le nom contient des caractères non autorisés")
        # Autoriser seulement lettres, espaces, tirets, apostrophes
        if not re.match(r"^[a-zA-ZÀ-ÿ\s\-']+$", v):
            raise ValueError("Le nom contient des caractères invalides")
        return v

    @field_validator("phone")
    @classmethod
    def validate_phone(cls, v: str) -> str:
        if not v or not v.strip():
            raise ValueError("Le numéro de téléphone ne peut pas être vide")
        # Nettoyer le numéro
        cleaned = re.sub(r"[\s\-\(\)]", "", v.strip())
        # Valider format belge ou international
        if not re.match(r"^(?:\+32|0)?4[0-9]{8}$|^\+\d{8,15}$", cleaned):
            raise ValueError("Format de numéro de téléphone invalide")
        return cleaned


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
        # Protection contre XSS dans la description
        xss_patterns = [
            r"<script[^>]*>",
            r"</script>",
            r"javascript:",
            r"onerror\s*=",
            r"onload\s*=",
        ]
        for pattern in xss_patterns:
            if re.search(pattern, v, re.IGNORECASE):
                raise ValueError("La description contient des caractères non autorisés")
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
    docs_url=(
        "/docs" if os.getenv("ENVIRONMENT") != "production" else None
    ),
    redoc_url=(
        "/redoc" if os.getenv("ENVIRONMENT") != "production" else None
    ),
    # Désactiver OpenAPI schema en production pour réduire la surface d'attaque
    openapi_url=(
        "/openapi.json" if os.getenv("ENVIRONMENT") != "production" else None
    ),
)

# Ajouter le rate limiter
app.state.limiter = limiter
# Type ignore pour compatibilité avec Starlette/FastAPI
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)  # type: ignore[arg-type]

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
                            f"Requête trop volumineuse rejetée: {size} bytes depuis {request.client.host if request.client else 'unknown'}"
                        )
                    )
                    from fastapi.responses import JSONResponse

                    return JSONResponse(
                        status_code=413,
                        content={"detail": "Requête trop volumineuse"},
                    )
            except (ValueError, TypeError):
                pass

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
# Note: file:// et null sont nécessaires pour les fichiers HTML locaux mais limités
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:8080",
        "http://127.0.0.1:8080",
        "http://localhost:3000",
        "http://127.0.0.1:3000",
        # file:// et null sont nécessaires pour le dashboard HTML local
        # mais sont limités par la validation des endpoints
    ],
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


# === DOCUMENTS ===


@app.post("/api/documents/upload")
@limiter.limit("10/minute")  # Limite de 10 uploads par minute par IP
async def upload_document(request: Request, file: UploadFile = File(...)):
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

        # Sauvegarder en base de données
        doc_id = db.add_document(
            name=result["filename"],
            original_name=result["original_name"],
            file_path=result["file_path"],
            file_type="pdf",
            file_size=result["file_size"],
        )

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


@app.get("/api/documents", response_model=list[DocumentResponse])
@limiter.limit("60/minute")  # Limite de 60 requêtes par minute
async def get_documents(request: Request):
    """Récupère tous les documents"""
    documents = db.get_documents()
    return [DocumentResponse(**doc) for doc in documents]


@app.get("/api/documents/{doc_id}", response_model=DocumentResponse)
@limiter.limit("60/minute")  # Limite de 60 requêtes par minute
async def get_document(request: Request, doc_id: int):
    """Récupère un document par ID"""
    document = db.get_document(doc_id)
    if not document:
        raise HTTPException(status_code=404, detail="Document non trouvé")
    return DocumentResponse(**document)


@app.delete("/api/documents/{doc_id}")
async def delete_document(doc_id: int):
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


@app.post("/api/reminders", response_model=ReminderResponse)
@limiter.limit("30/minute")  # Limite de 30 requêtes par minute
async def create_reminder(request: Request, reminder: ReminderRequest):
    """Crée un rappel"""
    reminder_id = db.add_reminder(
        title=reminder.title,
        description=reminder.description or "",
        reminder_date=reminder.reminder_date,
    )

    # Récupérer le rappel créé
    reminders = db.get_reminders()
    created_reminder = next((r for r in reminders if r["id"] == reminder_id), None)

    if not created_reminder:
        raise HTTPException(
            status_code=500, detail="Erreur lors de la création du rappel"
        )

    return ReminderResponse(**created_reminder)


@app.get("/api/reminders", response_model=list[ReminderResponse])
@limiter.limit("60/minute")  # Limite de 60 requêtes par minute
async def get_reminders(request: Request):
    """Récupère tous les rappels"""
    reminders = db.get_reminders()
    return [ReminderResponse(**reminder) for reminder in reminders]


# === CONTACTS D'URGENCE ===


@app.post("/api/emergency-contacts", response_model=EmergencyContactResponse)
@limiter.limit("20/minute")  # Limite de 20 requêtes par minute
async def create_emergency_contact(request: Request, contact: EmergencyContactRequest):
    """Crée un contact d'urgence"""
    contact_id = db.add_emergency_contact(
        name=contact.name,
        phone=contact.phone,
        relationship=contact.relationship or "",
        is_primary=contact.is_primary,
    )

    # Récupérer le contact créé
    contacts = db.get_emergency_contacts()
    created_contact = next((c for c in contacts if c["id"] == contact_id), None)

    if not created_contact:
        raise HTTPException(
            status_code=500, detail="Erreur lors de la création du contact"
        )

    return EmergencyContactResponse(**created_contact)


@app.get("/api/emergency-contacts", response_model=list[EmergencyContactResponse])
@limiter.limit("60/minute")  # Limite de 60 requêtes par minute
async def get_emergency_contacts(request: Request):
    """Récupère tous les contacts d'urgence"""
    contacts = db.get_emergency_contacts()
    return [EmergencyContactResponse(**contact) for contact in contacts]


# === PORTAILS SANTÉ ===


@app.post("/api/health-portals", response_model=HealthPortalResponse)
@limiter.limit("20/minute")  # Limite de 20 requêtes par minute
async def create_health_portal(request: Request, portal: HealthPortalRequest):
    """Crée un portail santé"""
    portal_id = db.add_health_portal(
        name=portal.name,
        url=portal.url,
        description=portal.description or "",
        category=portal.category or "",
    )

    # Récupérer le portail créé
    portals = db.get_health_portals()
    created_portal = next((p for p in portals if p["id"] == portal_id), None)

    if not created_portal:
        raise HTTPException(
            status_code=500, detail="Erreur lors de la création du portail"
        )

    return HealthPortalResponse(**created_portal)


@app.get("/api/health-portals", response_model=list[HealthPortalResponse])
@limiter.limit("60/minute")  # Limite de 60 requêtes par minute
async def get_health_portals(request: Request):
    """Récupère tous les portails santé"""
    portals = db.get_health_portals()
    return [HealthPortalResponse(**portal) for portal in portals]


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="127.0.0.1", port=8000)
