"""
API FastAPI pour Arkalia CIA
Backend pour l'application mobile Flutter
"""

from datetime import datetime
import os
import tempfile

from database import CIADatabase
from fastapi import FastAPI, File, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from pdf_processor import PDFProcessor
from pydantic import BaseModel


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
    title: str
    description: str | None = None
    reminder_date: str


class ReminderResponse(BaseModel):
    id: int
    title: str
    description: str | None
    reminder_date: str
    is_completed: bool
    created_at: str


class EmergencyContactRequest(BaseModel):
    name: str
    phone: str
    relationship: str | None = None
    is_primary: bool = False


class EmergencyContactResponse(BaseModel):
    id: int
    name: str
    phone: str
    relationship: str | None
    is_primary: bool
    created_at: str


class HealthPortalRequest(BaseModel):
    name: str
    url: str
    description: str | None = None
    category: str | None = None


class HealthPortalResponse(BaseModel):
    id: int
    name: str
    url: str
    description: str | None
    category: str | None
    created_at: str


# Application FastAPI
app = FastAPI(
    title="Arkalia CIA API",
    description="API backend pour l'application mobile Arkalia CIA",
    version="1.0.0",
)

# CORS pour Flutter et fichiers locaux
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:8080",
        "http://127.0.0.1:8080",
        "http://0.0.0.0:8080",
        "http://localhost:3000",
        "http://127.0.0.1:3000",
        "file://",  # Pour les fichiers HTML locaux
        "null",  # Pour les requêtes depuis fichiers locaux
    ],
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allow_headers=["*"],
)


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
async def upload_document(file: UploadFile = File(...)):
    """Upload un document PDF"""
    try:
        # Vérifier que c'est un PDF
        if not file.filename or not file.filename.lower().endswith(".pdf"):
            raise HTTPException(
                status_code=400, detail="Seuls les fichiers PDF sont acceptés"
            )

        # Sauvegarder le fichier temporairement
        with tempfile.NamedTemporaryFile(delete=False, suffix=".pdf") as tmp_file:
            content = await file.read()
            tmp_file.write(content)
            tmp_file_path = tmp_file.name

        # Traiter le PDF
        result = pdf_processor.process_pdf(
            tmp_file_path, file.filename or "document.pdf"
        )

        if not result["success"]:
            os.unlink(tmp_file_path)  # Nettoyer le fichier temporaire
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
        os.unlink(tmp_file_path)

        return {
            "success": True,
            "document_id": doc_id,
            "message": "Document uploadé avec succès",
        }

    except Exception as e:
        return {"success": False, "error": str(e)}


@app.get("/api/documents", response_model=list[DocumentResponse])
async def get_documents():
    """Récupère tous les documents"""
    documents = db.get_documents()
    return [DocumentResponse(**doc) for doc in documents]


@app.get("/api/documents/{doc_id}", response_model=DocumentResponse)
async def get_document(doc_id: int):
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

    # Supprimer le fichier physique
    try:
        os.unlink(document["file_path"])
    except (FileNotFoundError, OSError) as e:
        print(f"Warning: Impossible de supprimer le fichier: {e}")

    # Supprimer de la base de données
    success = db.delete_document(doc_id)
    if not success:
        raise HTTPException(status_code=500, detail="Erreur lors de la suppression")

    return {"success": True, "message": "Document supprimé avec succès"}


# === RAPPELS ===


@app.post("/api/reminders", response_model=ReminderResponse)
async def create_reminder(reminder: ReminderRequest):
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
async def get_reminders():
    """Récupère tous les rappels"""
    reminders = db.get_reminders()
    return [ReminderResponse(**reminder) for reminder in reminders]


# === CONTACTS D'URGENCE ===


@app.post("/api/emergency-contacts", response_model=EmergencyContactResponse)
async def create_emergency_contact(contact: EmergencyContactRequest):
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
async def get_emergency_contacts():
    """Récupère tous les contacts d'urgence"""
    contacts = db.get_emergency_contacts()
    return [EmergencyContactResponse(**contact) for contact in contacts]


# === PORTAILS SANTÉ ===


@app.post("/api/health-portals", response_model=HealthPortalResponse)
async def create_health_portal(portal: HealthPortalRequest):
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
async def get_health_portals():
    """Récupère tous les portails santé"""
    portals = db.get_health_portals()
    return [HealthPortalResponse(**portal) for portal in portals]


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="127.0.0.1", port=8000)
