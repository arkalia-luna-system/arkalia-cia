"""Tests pour suggestions IA Phase 4"""

from arkalia_cia_python_backend.ai.conversational_ai import ConversationalAI


class TestAISuggestions:
    """Tests suggestions intelligentes Phase 4"""

    def test_suggest_exam_type(self):
        """Test suggestion type d'examen"""
        ai = ConversationalAI()

        # Test scanner
        text1 = "Résultat du scanner CT"
        result = ai.suggest_exam_type(text1)
        assert result["type"] == "scanner"
        assert result["confidence"] > 0.5
        assert isinstance(result["alternatives"], list)

        # Test IRM
        text2 = "IRM du genou"
        result = ai.suggest_exam_type(text2)
        assert result["type"] == "irm"
        assert result["confidence"] > 0.5

    def test_suggest_doctor_completion(self):
        """Test suggestion complétion médecin"""
        ai = ConversationalAI()

        # Médecin partiel (sans adresse)
        partial_doctor = {
            "first_name": "Jean",
            "last_name": "Dupont",
            "specialty": "Cardiologue",
        }

        result = ai.suggest_doctor_completion(partial_doctor)
        assert "suggestions" in result
        assert "missing_fields" in result
        assert "address" in result["missing_fields"]
        assert len(result["suggestions"]) > 0

        # Médecin complet
        complete_doctor = {
            "first_name": "Jean",
            "last_name": "Dupont",
            "specialty": "Cardiologue",
            "address": "Rue de la Paix 12",
            "phone": "+32 470 12 34 56",
            "email": "jean.dupont@example.com",
        }

        result = ai.suggest_doctor_completion(complete_doctor)
        assert len(result["missing_fields"]) == 0

    def test_detect_duplicates(self):
        """Test détection doublons médecins"""
        ai = ConversationalAI()

        doctors = [
            {
                "first_name": "Jean",
                "last_name": "Dupont",
                "specialty": "Cardiologue",
            },
            {
                "first_name": "Jean",
                "last_name": "Dupont",
                "specialty": "Cardiologue",
            },
            {
                "first_name": "Marie",
                "last_name": "Martin",
                "specialty": "Dermatologue",
            },
        ]

        duplicates = ai.detect_duplicates(doctors)
        assert len(duplicates) > 0
        assert duplicates[0]["similarity_score"] > 0.8
        assert "doctor1" in duplicates[0]
        assert "doctor2" in duplicates[0]

    def test_detect_duplicates_no_duplicates(self):
        """Test détection doublons - aucun doublon"""
        ai = ConversationalAI()

        doctors = [
            {
                "first_name": "Jean",
                "last_name": "Dupont",
                "specialty": "Cardiologue",
            },
            {
                "first_name": "Marie",
                "last_name": "Martin",
                "specialty": "Dermatologue",
            },
        ]

        duplicates = ai.detect_duplicates(doctors)
        assert len(duplicates) == 0
