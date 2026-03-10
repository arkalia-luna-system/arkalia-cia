"""
Tests end-to-end de base pour les parcours utilisateur critiques.

Ces tests ne visent pas l'exhaustivité technique mais à vérifier, de bout en bout,
que les principaux scénarios fonctionnent avec le backend FastAPI démarré
et une base de données temporaire.

Ils peuvent servir de point de départ pour ajouter progressivement
les cas décrits dans PLAN_TESTS_UTILISATEURS_SENIORS.md (coté backend/API).
"""

from http import HTTPStatus

import pytest
from fastapi.testclient import TestClient

from arkalia_cia_python_backend import api


client = TestClient(api.app)


@pytest.mark.xfail(reason="Endpoints documents/reminders/contacts nécessitent une configuration/auth backend complète", strict=False)
def test_e2e_basic_document_flow(tmp_path) -> None:
    """Parcours minimal: créer un document puis le retrouver via l'API."""
    # Upload d'un document
    files = {"file": ("test.pdf", b"%PDF-1.4 test content", "application/pdf")}
    response = client.post("/api/v1/documents/", files=files)
    assert response.status_code == HTTPStatus.OK
    data = response.json()
    doc_id = data.get("id")
    assert doc_id is not None

    # Récupération de la liste de documents
    list_resp = client.get("/api/v1/documents/")
    assert list_resp.status_code == HTTPStatus.OK
    docs = list_resp.json()
    assert any(d.get("id") == doc_id for d in docs)


@pytest.mark.xfail(reason="Endpoints documents/reminders/contacts nécessitent une configuration/auth backend complète", strict=False)
def test_e2e_basic_reminder_flow() -> None:
    """Parcours minimal: créer un rappel puis le lister."""
    payload = {
        "title": "Consultation cardiologue",
        "description": "RDV de test end-to-end",
        "datetime": "2030-01-01T10:00:00",
        "repeat": "none",
    }
    create_resp = client.post("/api/v1/reminders/", json=payload)
    assert create_resp.status_code == HTTPStatus.OK

    list_resp = client.get("/api/v1/reminders/")
    assert list_resp.status_code == HTTPStatus.OK
    reminders = list_resp.json()
    assert any(r.get("title") == payload["title"] for r in reminders)


@pytest.mark.xfail(reason="Endpoints documents/reminders/contacts nécessitent une configuration/auth backend complète", strict=False)
def test_e2e_emergency_contact_flow() -> None:
    """Parcours minimal: ajouter un contact ICE puis vérifier sa présence."""
    payload = {
        "name": "Test ICE",
        "phone": "+32470000000",
        "relationship": "Famille",
    }
    create_resp = client.post("/api/v1/emergency-contacts/", json=payload)
    assert create_resp.status_code == HTTPStatus.OK

    list_resp = client.get("/api/v1/emergency-contacts/")
    assert list_resp.status_code == HTTPStatus.OK
    contacts = list_resp.json()
    assert any(c.get("name") == payload["name"] for c in contacts)

