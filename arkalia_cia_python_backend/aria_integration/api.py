"""
ARIA Integration API - Pont vers ARIA depuis CIA
Interface optimisée pour accéder aux fonctionnalités ARIA depuis CIA
"""

from datetime import datetime
from typing import Annotated, Any, cast

import requests
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field

router = APIRouter()

# Configuration ARIA
ARIA_BASE_URL = "http://127.0.0.1:8001"  # Port différent de CIA
ARIA_TIMEOUT = 10  # Timeout augmenté pour plus de stabilité

# Schémas pour la compatibilité CIA

Intensity = Annotated[int, Field(ge=0, le=10)]
Effectiveness = Annotated[int, Field(ge=0, le=10)]
ShortText = Annotated[str, Field(min_length=1, max_length=128)]


class PainEntryIn(BaseModel):
    intensity: Intensity
    physical_trigger: ShortText | None = None
    mental_trigger: ShortText | None = None
    activity: ShortText | None = None
    location: ShortText | None = None
    action_taken: ShortText | None = None
    effectiveness: Effectiveness | None = None
    notes: str | None = Field(default=None, max_length=2000)
    timestamp: str | None = None


class PainEntryOut(PainEntryIn):
    id: int
    timestamp: str
    created_at: str


class QuickEntry(BaseModel):
    """Saisie ultra-rapide - 3 questions seulement"""

    intensity: Intensity
    trigger: ShortText  # Déclencheur en un mot
    action: ShortText  # Action immédiate


def _check_aria_connection() -> bool:
    """Vérifie si ARIA est accessible"""
    try:
        response = requests.get(f"{ARIA_BASE_URL}/health", timeout=ARIA_TIMEOUT)
        return bool(response.status_code == 200)
    except Exception:
        return False


def _make_aria_request(method: str, endpoint: str, **kwargs) -> requests.Response:
    """Effectue une requête vers ARIA avec gestion d'erreurs améliorée"""
    try:
        url = f"{ARIA_BASE_URL}{endpoint}"
        response = requests.request(method, url, timeout=ARIA_TIMEOUT, **kwargs)
        return response
    except requests.RequestException as e:
        raise HTTPException(
            status_code=503, detail=f"Impossible de contacter ARIA: {str(e)}"
        ) from e


@router.get("/status")
async def aria_integration_status() -> dict[str, Any]:
    """Statut de l'intégration ARIA"""
    aria_connected = _check_aria_connection()

    return {
        "module": "aria_integration",
        "status": "healthy" if aria_connected else "aria_unavailable",
        "timestamp": datetime.now().isoformat(),
        "aria_connected": aria_connected,
        "aria_url": ARIA_BASE_URL,
        "features": [
            "quick_pain_entry",
            "detailed_pain_entry",
            "pain_history",
            "export_to_psy",
            "pattern_analysis",
            "prediction_engine",
        ],
    }


@router.post("/quick-pain-entry", response_model=PainEntryOut)
async def quick_pain_entry(entry: QuickEntry) -> PainEntryOut:
    """Saisie ultra-rapide de douleur via ARIA"""
    if not _check_aria_connection():
        raise HTTPException(
            status_code=503,
            detail="ARIA non disponible. Vérifiez que le service ARIA est démarré.",
        )

    response = _make_aria_request(
        "POST", "/api/pain/quick-entry", json=entry.model_dump()
    )

    if response.status_code == 200:
        return PainEntryOut(**response.json())
    else:
        raise HTTPException(
            status_code=response.status_code, detail=f"Erreur ARIA: {response.text}"
        )


@router.post("/pain-entry", response_model=PainEntryOut)
async def create_pain_entry(entry: PainEntryIn) -> PainEntryOut:
    """Création d'une entrée détaillée via ARIA"""
    if not _check_aria_connection():
        raise HTTPException(status_code=503, detail="ARIA non disponible")

    response = _make_aria_request("POST", "/api/pain/entry", json=entry.model_dump())

    if response.status_code == 200:
        return PainEntryOut(**response.json())
    else:
        raise HTTPException(
            status_code=response.status_code, detail=f"Erreur ARIA: {response.text}"
        )


@router.get("/pain-entries", response_model=list[PainEntryOut])
async def get_pain_entries() -> list[PainEntryOut]:
    """Récupère toutes les entrées de douleur depuis ARIA"""
    if not _check_aria_connection():
        raise HTTPException(status_code=503, detail="ARIA non disponible")

    response = _make_aria_request("GET", "/api/pain/entries")

    if response.status_code == 200:
        return [PainEntryOut(**entry) for entry in response.json()]
    else:
        raise HTTPException(
            status_code=response.status_code, detail=f"Erreur ARIA: {response.text}"
        )


@router.get("/pain-entries/recent", response_model=list[PainEntryOut])
async def get_recent_pain_entries(limit: int = 20) -> list[PainEntryOut]:
    """Récupère les entrées récentes de douleur depuis ARIA"""
    if not _check_aria_connection():
        raise HTTPException(status_code=503, detail="ARIA non disponible")

    response = _make_aria_request(
        "GET", "/api/pain/entries/recent", params={"limit": limit}
    )

    if response.status_code == 200:
        return [PainEntryOut(**entry) for entry in response.json()]
    else:
        raise HTTPException(
            status_code=response.status_code, detail=f"Erreur ARIA: {response.text}"
        )


@router.get("/export/csv")
async def export_csv() -> dict[str, Any]:
    """Export CSV pour professionnels de santé via ARIA"""
    if not _check_aria_connection():
        raise HTTPException(status_code=503, detail="ARIA non disponible")

    response = _make_aria_request("GET", "/api/pain/export/csv")

    if response.status_code == 200:
        return cast(dict[str, Any], response.json())
    else:
        raise HTTPException(
            status_code=response.status_code, detail=f"Erreur ARIA: {response.text}"
        )


@router.get("/patterns/recent")
async def get_recent_patterns() -> dict[str, Any]:
    """Récupère les patterns récents depuis ARIA"""
    if not _check_aria_connection():
        raise HTTPException(status_code=503, detail="ARIA non disponible")

    response = _make_aria_request("GET", "/api/patterns/recent")

    if response.status_code == 200:
        return cast(dict[str, Any], response.json())
    else:
        raise HTTPException(
            status_code=response.status_code, detail=f"Erreur ARIA: {response.text}"
        )


@router.get("/predictions/current")
async def get_current_predictions() -> dict[str, Any]:
    """Récupère les prédictions actuelles depuis ARIA"""
    if not _check_aria_connection():
        raise HTTPException(status_code=503, detail="ARIA non disponible")

    response = _make_aria_request("GET", "/api/predictions/current")

    if response.status_code == 200:
        return cast(dict[str, Any], response.json())
    else:
        raise HTTPException(
            status_code=response.status_code, detail=f"Erreur ARIA: {response.text}"
        )
