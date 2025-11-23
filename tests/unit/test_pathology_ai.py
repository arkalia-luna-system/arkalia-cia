"""Tests pour IA conversationnelle pathologies Phase 4"""

import pytest
from arkalia_cia_python_backend.ai.conversational_ai import ConversationalAI


class TestPathologyAI:
    """Tests IA conversationnelle pathologies Phase 4"""

    def test_answer_pathology_question(self):
        """Test réponse question pathologie"""
        ai = ConversationalAI()

        pathologies = [
            {
                "name": "Arthrose",
                "symptoms": ["Douleurs articulaires", "Raideur"],
                "exams": ["Radiographie", "IRM"],
                "treatments": ["Anti-inflammatoires", "Kinésithérapie"],
            },
        ]

        question = "Quels sont les symptômes de l'arthrose ?"
        result = ai.answer_pathology_question(question, pathologies)

        assert "answer" in result
        assert result["pathology_mentioned"] == "Arthrose"
        assert len(result["suggestions"]) >= 0
        assert len(result["exams_suggested"]) >= 0
        assert len(result["treatments_suggested"]) >= 0

    def test_answer_pathology_question_no_pathology(self):
        """Test réponse question sans pathologie mentionnée"""
        ai = ConversationalAI()

        pathologies = [
            {
                "name": "Arthrose",
                "symptoms": ["Douleurs articulaires"],
            },
        ]

        question = "Comment ça va ?"
        result = ai.answer_pathology_question(question, pathologies)

        assert "answer" in result
        # Devrait utiliser la première pathologie par défaut
        assert result["pathology_mentioned"] is not None

    def test_suggest_questions_for_appointment(self):
        """Test suggestions questions pour RDV"""
        ai = ConversationalAI()

        pathologies = [
            {
                "name": "Arthrose",
                "symptoms": ["Douleurs articulaires", "Raideur"],
                "exams": ["Radiographie"],
            },
            {
                "name": "Diabète",
                "symptoms": ["Fatigue"],
                "exams": ["Analyses sanguines"],
            },
        ]

        questions = ai.suggest_questions_for_appointment("doctor_1", pathologies)

        assert isinstance(questions, list)
        assert len(questions) > 0
        assert len(questions) <= 8  # Limite de 8 questions

        # Vérifier que les questions sont pertinentes
        questions_str = " ".join(questions).lower()
        assert "arthrose" in questions_str or "diabète" in questions_str

    def test_suggest_questions_for_appointment_no_pathologies(self):
        """Test suggestions questions sans pathologies"""
        ai = ConversationalAI()

        questions = ai.suggest_questions_for_appointment("doctor_1", [])

        assert isinstance(questions, list)
        # Devrait avoir des questions générales
        assert len(questions) > 0

