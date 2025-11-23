"""
Tests unitaires pour MedicalReportService
"""

from datetime import datetime

import pytest

from arkalia_cia_python_backend.database import CIADatabase
from arkalia_cia_python_backend.services.medical_report_service import (
    MedicalReportService,
)


@pytest.fixture
def temp_db():
    """Base de données temporaire pour tests"""
    db = CIADatabase(":memory:")
    yield db
    # CIADatabase se ferme automatiquement, pas besoin de close()


@pytest.fixture
def report_service(temp_db):
    """Service de rapport médical pour tests"""
    return MedicalReportService(db=temp_db, aria_base_url="http://localhost:9999")


class TestMedicalReportService:
    """Tests pour MedicalReportService"""

    def test_generate_report_basic(self, report_service, temp_db):
        """Test génération rapport basique sans ARIA"""
        # Ajouter quelques documents de test
        # Note: add_document peut avoir une signature différente selon l'implémentation
        # Pour ce test, on vérifie juste que le rapport se génère même sans documents
        # Générer rapport
        report = report_service.generate_pre_consultation_report(
            user_id="test_user",
            days_range=30,
            include_aria=False,
        )

        # Vérifications
        assert "report_date" in report
        assert "generated_at" in report
        assert "sections" in report
        assert "formatted_text" in report
        assert "documents" in report["sections"]

    def test_generate_report_with_aria_unavailable(self, report_service):
        """Test génération rapport avec ARIA non disponible (graceful degradation)"""
        report = report_service.generate_pre_consultation_report(
            user_id="test_user",
            days_range=30,
            include_aria=True,  # Demande ARIA mais non disponible
        )

        # Le rapport doit être généré même sans ARIA
        assert "report_date" in report
        assert "sections" in report
        # Section ARIA peut être absente si non disponible
        assert "formatted_text" in report

    def test_analyze_pain_data_empty(self, report_service):
        """Test analyse données douleur vide"""
        result = report_service._analyze_pain_data([])
        assert result == {}

    def test_analyze_pain_data_with_records(self, report_service):
        """Test analyse données douleur avec enregistrements"""
        pain_records = [
            {
                "intensity": 7,
                "location": "Genou droit",
                "trigger": "Activité physique",
                "timestamp": "2025-11-23T14:30:00Z",
            },
            {
                "intensity": 8,
                "location": "Genou droit",
                "trigger": "Météo froide",
                "timestamp": "2025-11-22T10:00:00Z",
            },
            {
                "intensity": 5,
                "location": "Genou gauche",
                "trigger": "Activité physique",
                "timestamp": "2025-11-21T15:00:00Z",
            },
        ]

        result = report_service._analyze_pain_data(pain_records)

        assert "average_intensity" in result
        assert result["average_intensity"] == pytest.approx(6.67, abs=0.1)
        assert result["max_intensity"] == 8
        assert result["most_common_location"] == "Genou droit"
        assert result["total_entries"] == 3

    def test_format_report_text(self, report_service):
        """Test formatage rapport en texte"""
        report = {
            "report_date": datetime.now().isoformat(),
            "generated_at": datetime.now().isoformat(),
            "days_range": 30,
            "sections": {
                "documents": {
                    "title": "DOCUMENTS MÉDICAUX (CIA)",
                    "items": [
                        {
                            "name": "Test Document",
                            "date": "2025-11-15T00:00:00Z",
                            "type": "Examen",
                        }
                    ],
                    "count": 1,
                }
            },
            "formatted_text": "",
        }

        formatted = report_service._format_report_text(report)

        assert "RAPPORT MÉDICAL" in formatted
        assert "DOCUMENTS MÉDICAUX" in formatted
        assert "Test Document" in formatted

    def test_export_report_to_text(self, report_service):
        """Test export rapport en texte"""
        report = {
            "formatted_text": "Rapport de test\nLigne 2",
        }

        result = report_service.export_report_to_text(report)
        assert result == "Rapport de test\nLigne 2"

    def test_export_report_to_text_empty(self, report_service):
        """Test export rapport vide"""
        report = {}

        result = report_service.export_report_to_text(report)
        assert result == ""
