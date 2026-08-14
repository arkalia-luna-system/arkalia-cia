"""
ARIA Integration API - Pont vers ARIA depuis CIA
Interface optimisée pour accéder aux fonctionnalités ARIA depuis CIA
"""

import sqlite3
from csv import DictWriter
from datetime import datetime
from io import StringIO
from typing import Annotated, Any, cast

import requests
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field

from arkalia_cia_python_backend.config import get_settings
from arkalia_cia_python_backend.database import CIADatabase
from arkalia_cia_python_backend.utils.retry import retry_with_backoff

router = APIRouter()

# Configuration ARIA (depuis config.py, configurable via variable d'environnement ARIA_BASE_URL)
_settings = get_settings()
ARIA_ENABLED = _settings.aria_enabled
ARIA_BASE_URL = _settings.aria_base_url
ARIA_TIMEOUT = _settings.aria_timeout
_db = CIADatabase()


def _safe_upstream_error_message(status_code: int) -> str:
    """Retourne un message générique sans exposer les détails internes ARIA."""
    if status_code >= 500:
        return "Service ARIA indisponible temporairement."
    if status_code >= 400:
        return "Requête ARIA invalide ou refusée."
    return "Erreur de communication avec ARIA."


def _ensure_local_pain_table() -> None:
    """Crée la table locale CIA pour les entrées douleur si nécessaire."""
    with sqlite3.connect(_db.db_path) as conn:
        cursor = conn.cursor()
        cursor.execute(
            """
            CREATE TABLE IF NOT EXISTS pain_entries (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                intensity INTEGER NOT NULL,
                physical_trigger TEXT,
                mental_trigger TEXT,
                activity TEXT,
                location TEXT,
                action_taken TEXT,
                effectiveness INTEGER,
                notes TEXT,
                who_present TEXT,
                interactions TEXT,
                emotions TEXT,
                thoughts TEXT,
                physical_symptoms TEXT,
                timestamp TEXT NOT NULL,
                created_at TEXT NOT NULL
            )
            """
        )
        conn.commit()


def _normalize_entry_payload(payload: dict[str, Any]) -> dict[str, Any]:
    now_iso = datetime.now().isoformat()
    timestamp = str(payload.get("timestamp") or now_iso)
    return {
        "intensity": int(payload["intensity"]),
        "physical_trigger": payload.get("physical_trigger"),
        "mental_trigger": payload.get("mental_trigger"),
        "activity": payload.get("activity"),
        "location": payload.get("location"),
        "action_taken": payload.get("action_taken"),
        "effectiveness": payload.get("effectiveness"),
        "notes": payload.get("notes"),
        "who_present": payload.get("who_present"),
        "interactions": payload.get("interactions"),
        "emotions": payload.get("emotions"),
        "thoughts": payload.get("thoughts"),
        "physical_symptoms": payload.get("physical_symptoms"),
        "timestamp": timestamp,
        "created_at": now_iso,
    }


def _save_local_pain_entry(payload: dict[str, Any]) -> dict[str, Any]:
    _ensure_local_pain_table()
    normalized = _normalize_entry_payload(payload)
    with sqlite3.connect(_db.db_path) as conn:
        cursor = conn.cursor()
        cursor.execute(
            """
            INSERT INTO pain_entries (
                intensity, physical_trigger, mental_trigger, activity, location,
                action_taken, effectiveness, notes, who_present, interactions,
                emotions, thoughts, physical_symptoms, timestamp, created_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            (
                normalized["intensity"],
                normalized["physical_trigger"],
                normalized["mental_trigger"],
                normalized["activity"],
                normalized["location"],
                normalized["action_taken"],
                normalized["effectiveness"],
                normalized["notes"],
                normalized["who_present"],
                normalized["interactions"],
                normalized["emotions"],
                normalized["thoughts"],
                normalized["physical_symptoms"],
                normalized["timestamp"],
                normalized["created_at"],
            ),
        )
        raw_entry_id = cursor.lastrowid
        if raw_entry_id is None:
            raise RuntimeError("Insertion locale douleur échouée (id absent).")
        entry_id = int(raw_entry_id)
        conn.commit()
    return {"id": entry_id, **normalized}


def _fetch_local_pain_entries(limit: int | None = None) -> list[dict[str, Any]]:
    _ensure_local_pain_table()
    query = "SELECT * FROM pain_entries ORDER BY timestamp DESC"
    params: tuple[Any, ...] = ()
    if limit is not None:
        query += " LIMIT ?"
        params = (limit,)

    with sqlite3.connect(_db.db_path) as conn:
        conn.row_factory = sqlite3.Row
        cursor = conn.cursor()
        cursor.execute(query, params)
        return [dict(row) for row in cursor.fetchall()]


def _build_local_summary(entries: list[dict[str, Any]], window: int) -> dict[str, Any]:
    if not entries:
        return {
            "window_days": window,
            "stats": {
                "entries_count": 0,
                "average_intensity": 0,
                "max_intensity": 0,
            },
            "top_triggers": [],
            "top_locations": [],
        }

    intensities = [int(e["intensity"]) for e in entries if e.get("intensity") is not None]
    trigger_counts: dict[str, int] = {}
    location_counts: dict[str, int] = {}

    for entry in entries:
        trigger = str(entry.get("physical_trigger") or "").strip()
        location = str(entry.get("location") or "").strip()
        if trigger:
            trigger_counts[trigger] = trigger_counts.get(trigger, 0) + 1
        if location:
            location_counts[location] = location_counts.get(location, 0) + 1

    top_triggers = sorted(
        trigger_counts.items(),
        key=lambda item: item[1],
        reverse=True,
    )[:5]
    top_locations = sorted(
        location_counts.items(),
        key=lambda item: item[1],
        reverse=True,
    )[:5]
    return {
        "window_days": window,
        "stats": {
            "entries_count": len(entries),
            "average_intensity": round(sum(intensities) / len(intensities), 2)
            if intensities
            else 0,
            "max_intensity": max(intensities) if intensities else 0,
        },
        "top_triggers": [{"trigger": key, "count": count} for key, count in top_triggers],
        "top_locations": [
            {"location": key, "count": count} for key, count in top_locations
        ],
    }

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
    who_present: str | None = Field(default=None, max_length=500)
    interactions: str | None = Field(default=None, max_length=1000)
    emotions: str | None = Field(default=None, max_length=1000)
    thoughts: str | None = Field(default=None, max_length=2000)
    physical_symptoms: str | None = Field(default=None, max_length=1000)
    timestamp: str | None = None


class PainEntryOut(PainEntryIn):
    id: int
    timestamp: str
    created_at: str


class QuickEntry(BaseModel):
    """Saisie ultra-rapide - 3 questions seulement"""

    intensity: Intensity
    physical_trigger: ShortText  # Déclencheur en un mot
    action_taken: ShortText  # Action immédiate


@retry_with_backoff(
    max_retries=3,
    backoff_factor=1.5,
    exceptions=(requests.RequestException, requests.Timeout),
)
def _check_aria_connection() -> bool:
    """Vérifie si ARIA est accessible avec retry logic"""
    if not ARIA_ENABLED or not ARIA_BASE_URL:
        return False
    try:
        response = requests.get(f"{ARIA_BASE_URL}/health", timeout=ARIA_TIMEOUT)
        return bool(response.status_code == 200)
    except requests.RequestException:
        return False


@retry_with_backoff(
    max_retries=3,
    backoff_factor=1.5,
    exceptions=(requests.RequestException, requests.Timeout),
)
def _make_aria_request(method: str, endpoint: str, **kwargs) -> requests.Response:
    """Effectue une requête vers ARIA avec retry logic et gestion d'erreurs"""
    if not ARIA_ENABLED or not ARIA_BASE_URL:
        raise HTTPException(
            status_code=503,
            detail="ARIA externe désactivé dans la configuration CIA.",
        )
    try:
        url = f"{ARIA_BASE_URL}{endpoint}"
        response = requests.request(method, url, timeout=ARIA_TIMEOUT, **kwargs)
        return response
    except requests.RequestException:
        raise HTTPException(status_code=503, detail="Impossible de contacter ARIA.") from None


@router.get("/status")
async def aria_integration_status() -> dict[str, Any]:
    """Statut de l'intégration ARIA"""
    aria_connected = _check_aria_connection()
    local_pain_available = True
    try:
        _ensure_local_pain_table()
    except Exception:
        local_pain_available = False

    return {
        "module": "aria_integration",
        "status": (
            "healthy"
            if (aria_connected or local_pain_available)
            else "aria_and_local_unavailable"
        ),
        "timestamp": datetime.now().isoformat(),
        "aria_connected": aria_connected,
        "aria_enabled": ARIA_ENABLED,
        "local_pain_storage": local_pain_available,
        "aria_url": ARIA_BASE_URL,
        "features": [
            "quick_pain_entry",
            "detailed_pain_entry",
            "pain_history",
            "pain_summary",
            "pain_suggestions",
            "export_to_psy",
            "pattern_analysis",
            "prediction_engine",
        ],
    }


@router.post("/quick-pain-entry", response_model=PainEntryOut)
async def quick_pain_entry(entry: QuickEntry) -> PainEntryOut:
    """Saisie ultra-rapide de douleur, locale CIA avec fallback ARIA."""
    payload = entry.model_dump()
    try:
        local_entry = _save_local_pain_entry(payload)
        return PainEntryOut(**local_entry)
    except Exception:
        if not _check_aria_connection():
            raise HTTPException(
                status_code=503,
                detail="CIA douleur locale indisponible et ARIA non disponible.",
            ) from None
        response = _make_aria_request("POST", "/api/pain/quick-entry", json=payload)
        if response.status_code == 200:
            return PainEntryOut(**response.json())
        raise HTTPException(
            status_code=response.status_code,
            detail=_safe_upstream_error_message(response.status_code),
        ) from None


@router.post("/pain-entry", response_model=PainEntryOut)
async def create_pain_entry(entry: PainEntryIn) -> PainEntryOut:
    """Création d'une entrée détaillée, locale CIA avec fallback ARIA."""
    payload = entry.model_dump()
    try:
        local_entry = _save_local_pain_entry(payload)
        return PainEntryOut(**local_entry)
    except Exception:
        if not _check_aria_connection():
            raise HTTPException(status_code=503, detail="CIA/ARIA indisponible") from None
        response = _make_aria_request("POST", "/api/pain/entry", json=payload)
        if response.status_code == 200:
            return PainEntryOut(**response.json())
        raise HTTPException(
            status_code=response.status_code,
            detail=_safe_upstream_error_message(response.status_code),
        ) from None


@router.get("/pain-entries", response_model=list[PainEntryOut])
async def get_pain_entries() -> list[PainEntryOut]:
    """Récupère les entrées douleur depuis CIA local, fallback ARIA."""
    try:
        return [PainEntryOut(**entry) for entry in _fetch_local_pain_entries()]
    except Exception:
        if not _check_aria_connection():
            raise HTTPException(status_code=503, detail="CIA/ARIA indisponible") from None
        response = _make_aria_request("GET", "/api/pain/entries")
        if response.status_code == 200:
            payload = response.json()
            entries = (
                payload.get("entries", payload) if isinstance(payload, dict) else payload
            )
            if not isinstance(entries, list):
                raise HTTPException(
                    status_code=502, detail="Réponse ARIA invalide pour /api/pain/entries"
                ) from None
            return [PainEntryOut(**entry) for entry in entries]
        raise HTTPException(
            status_code=response.status_code,
            detail=_safe_upstream_error_message(response.status_code),
        ) from None


@router.get("/pain-entries/recent", response_model=list[PainEntryOut])
async def get_recent_pain_entries(limit: int = 20) -> list[PainEntryOut]:
    """Récupère les entrées récentes de douleur (local CIA prioritaire)."""
    try:
        return [
            PainEntryOut(**entry) for entry in _fetch_local_pain_entries(limit=limit)
        ]
    except Exception:
        if not _check_aria_connection():
            raise HTTPException(status_code=503, detail="CIA/ARIA indisponible") from None
        response = _make_aria_request(
            "GET", "/api/pain/entries/recent", params={"limit": limit}
        )
        if response.status_code == 200:
            return [PainEntryOut(**entry) for entry in response.json()]
        raise HTTPException(
            status_code=response.status_code,
            detail=_safe_upstream_error_message(response.status_code),
        ) from None


@router.get("/export/csv")
async def export_csv() -> dict[str, Any]:
    """Export CSV local CIA (fallback ARIA si local indisponible)."""
    try:
        entries = _fetch_local_pain_entries()
        output = StringIO()
        fieldnames = [
            "id",
            "timestamp",
            "created_at",
            "intensity",
            "physical_trigger",
            "mental_trigger",
            "activity",
            "location",
            "action_taken",
            "effectiveness",
            "notes",
            "who_present",
            "interactions",
            "emotions",
            "thoughts",
            "physical_symptoms",
        ]
        writer = DictWriter(output, fieldnames=fieldnames)
        writer.writeheader()
        for entry in entries:
            writer.writerow({k: entry.get(k) for k in fieldnames})
        return {
            "source": "cia_local",
            "filename": f"cia_pain_export_{datetime.now().strftime('%Y%m%d_%H%M%S')}.csv",
            "csv_data": output.getvalue(),
            "rows": len(entries),
        }
    except Exception:
        if not _check_aria_connection():
            raise HTTPException(status_code=503, detail="CIA/ARIA indisponible") from None
        response = _make_aria_request("GET", "/api/pain/export/csv")
        if response.status_code == 200:
            return cast(dict[str, Any], response.json())
        raise HTTPException(
            status_code=response.status_code,
            detail=_safe_upstream_error_message(response.status_code),
        ) from None


@router.get("/patterns/recent")
async def get_recent_patterns() -> dict[str, Any]:
    """Récupère des patterns récents depuis CIA local (fallback ARIA)."""
    try:
        entries = _fetch_local_pain_entries(limit=200)
        summary = _build_local_summary(entries, window=30)
        patterns: list[dict[str, Any]] = []
        if summary["top_triggers"]:
            patterns.append(
                {
                    "type": "trigger_frequency",
                    "description": f"Déclencheur dominant: {summary['top_triggers'][0]['trigger']}",
                    "strength": summary["top_triggers"][0]["count"],
                }
            )
        if summary["top_locations"]:
            patterns.append(
                {
                    "type": "location_frequency",
                    "description": f"Localisation dominante: {summary['top_locations'][0]['location']}",
                    "strength": summary["top_locations"][0]["count"],
                }
            )
        return {"source": "cia_local", "patterns": patterns, "stats": summary["stats"]}
    except Exception:
        if not _check_aria_connection():
            raise HTTPException(status_code=503, detail="CIA/ARIA indisponible") from None
        response = _make_aria_request("GET", "/api/patterns/recent")
        if response.status_code == 200:
            return cast(dict[str, Any], response.json())
        raise HTTPException(
            status_code=response.status_code,
            detail=_safe_upstream_error_message(response.status_code),
        ) from None


@router.get("/pain/summary")
async def get_pain_summary(window: int = 30) -> dict[str, Any]:
    """Résumé agrégé local CIA (fallback ARIA si besoin)."""
    try:
        summary = _build_local_summary(_fetch_local_pain_entries(), window=window)
        return summary
    except Exception:
        if not _check_aria_connection():
            raise HTTPException(status_code=503, detail="CIA/ARIA indisponible") from None
        response = _make_aria_request(
            "GET", "/api/pain/summary", params={"window": window}
        )
        if response.status_code == 200:
            return cast(dict[str, Any], response.json())
        raise HTTPException(
            status_code=response.status_code,
            detail=_safe_upstream_error_message(response.status_code),
        ) from None


@router.get("/pain/suggestions")
async def get_pain_suggestions(window: int = 30) -> dict[str, Any]:
    """Suggestions locales CIA basées sur l'historique douleur (fallback ARIA)."""
    try:
        entries = _fetch_local_pain_entries()
        summary = _build_local_summary(entries, window=window)
        suggestions: list[str] = []
        avg_intensity = float(summary["stats"]["average_intensity"])
        if avg_intensity >= 7:
            suggestions.append("Intensité élevée: envisager un avis médical rapidement.")
        if summary["top_triggers"]:
            top_trigger = summary["top_triggers"][0]["trigger"]
            suggestions.append(
                f"Déclencheur fréquent détecté: {top_trigger}. Prévoir une stratégie d'évitement."
            )
        if not suggestions:
            suggestions.append("Aucune alerte majeure: poursuivre le suivi régulier.")
        return {"window_days": window, "suggestions": suggestions, "source": "cia_local"}
    except Exception:
        if not _check_aria_connection():
            raise HTTPException(status_code=503, detail="CIA/ARIA indisponible") from None
        response = _make_aria_request(
            "GET", "/api/pain/suggestions", params={"window": window}
        )
        if response.status_code == 200:
            return cast(dict[str, Any], response.json())
        raise HTTPException(
            status_code=response.status_code,
            detail=_safe_upstream_error_message(response.status_code),
        ) from None


@router.get("/predictions/current")
async def get_current_predictions() -> dict[str, Any]:
    """Prédictions légères locales CIA (fallback ARIA)."""
    try:
        entries = _fetch_local_pain_entries(limit=10)
        intensities = [int(e["intensity"]) for e in entries if e.get("intensity") is not None]
        if len(intensities) < 3:
            return {
                "predictions": [],
                "risk_level": "unknown",
                "source": "cia_local",
                "reason": "données insuffisantes",
            }
        recent_avg = sum(intensities[:3]) / 3
        baseline_avg = sum(intensities) / len(intensities)
        risk_level = "high" if recent_avg - baseline_avg >= 1.5 else "moderate" if recent_avg >= 6 else "low"
        return {
            "predictions": [
                {
                    "type": "pain_risk_next_24h",
                    "risk_level": risk_level,
                    "recent_avg_intensity": round(recent_avg, 2),
                    "baseline_avg_intensity": round(baseline_avg, 2),
                }
            ],
            "risk_level": risk_level,
            "source": "cia_local",
        }
    except Exception:
        if not _check_aria_connection():
            raise HTTPException(status_code=503, detail="CIA/ARIA indisponible") from None
        response = _make_aria_request("GET", "/api/predictions/current")
        if response.status_code == 200:
            return cast(dict[str, Any], response.json())
        raise HTTPException(
            status_code=response.status_code,
            detail=_safe_upstream_error_message(response.status_code),
        ) from None
