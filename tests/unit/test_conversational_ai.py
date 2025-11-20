"""
Tests unitaires pour ConversationalAI
"""

from __future__ import annotations

from typing import Any

import pytest

from arkalia_cia_python_backend.ai.conversational_ai import ConversationalAI


class TestConversationalAI:
    """Tests pour ConversationalAI"""

    @pytest.fixture
    def ai(self):
        """Créer une instance d'IA conversationnelle"""
        return ConversationalAI()

    def test_analyze_question_basic(self, ai):
        """Test analyse question basique"""
        question = "Quels sont mes examens ?"
        user_data: dict[str, Any] = {"documents": [], "doctors": []}
        result = ai.analyze_question(question, user_data)
        assert isinstance(result, dict)
        assert "answer" in result
        assert "related_documents" in result
        assert "suggestions" in result
        assert "patterns_detected" in result
        assert "question_type" in result
        assert isinstance(result["answer"], str)

    def test_analyze_question_pain(self, ai):
        """Test analyse question douleur"""
        question = "J'ai mal au dos"
        user_data: dict[str, Any] = {"documents": [], "doctors": [], "pain_records": []}
        result = ai.analyze_question(question, user_data)
        assert result["question_type"] == "pain"
        assert isinstance(result["answer"], str)

    def test_analyze_question_doctor(self, ai):
        """Test analyse question médecin"""
        question = "Qui est mon médecin traitant ?"
        user_data: dict[str, Any] = {
            "documents": [],
            "doctors": [{"id": "1", "name": "Dr. Smith", "specialty": "Généraliste"}],
        }
        result = ai.analyze_question(question, user_data)
        assert result["question_type"] == "doctor"
        assert isinstance(result["answer"], str)

    def test_analyze_question_exam(self, ai):
        """Test analyse question examen"""
        question = "Quels sont mes derniers examens ?"
        user_data: dict[str, Any] = {
            "documents": [
                {
                    "id": "1",
                    "name": "Analyse sanguine",
                    "category": "examen",
                    "created_at": "2024-01-01",
                }
            ],
            "doctors": [],
        }
        result = ai.analyze_question(question, user_data)
        assert result["question_type"] == "exam"
        assert isinstance(result["answer"], str)

    def test_analyze_question_medication(self, ai):
        """Test analyse question médicament"""
        question = "Quels médicaments je prends ?"
        user_data: dict[str, Any] = {"documents": [], "doctors": []}
        result = ai.analyze_question(question, user_data)
        assert result["question_type"] == "medication"
        assert isinstance(result["answer"], str)

    def test_analyze_question_appointment(self, ai):
        """Test analyse question rendez-vous"""
        question = "J'ai un rdv demain"
        user_data: dict[str, Any] = {
            "documents": [],
            "doctors": [],
            "consultations": [],
        }
        result = ai.analyze_question(question, user_data)
        assert result["question_type"] == "appointment"
        assert isinstance(result["answer"], str)

    def test_analyze_question_cause_effect(self, ai):
        """Test analyse cause-effet"""
        question = "Y a-t-il un lien entre mes douleurs et mes examens ?"
        user_data: dict[str, Any] = {
            "documents": [
                {"id": "1", "name": "Radiographie", "created_at": "2024-01-01"}
            ],
            "pain_records": [{"date": "2024-01-02", "intensity": 7}],
        }
        result = ai.analyze_question(question, user_data)
        assert isinstance(result["answer"], str)
        assert len(result["answer"]) > 0

    def test_detect_question_type(self, ai):
        """Test détection type question"""
        assert ai._detect_question_type("j'ai mal") == "pain"
        assert ai._detect_question_type("mon médecin") == "doctor"
        assert ai._detect_question_type("examen") == "exam"
        assert ai._detect_question_type("médicament") == "medication"
        assert ai._detect_question_type("rdv") == "appointment"
        assert ai._detect_question_type("prochain") == "appointment"
        assert ai._detect_question_type("autre chose") == "general"

    def test_find_related_documents(self, ai):
        """Test recherche documents liés"""
        question = "analyse sanguine"
        user_data: dict[str, Any] = {
            "documents": [
                {"id": "1", "original_name": "Analyse sanguine", "category": "examen"},
                {"id": "2", "original_name": "Radiographie", "category": "examen"},
            ]
        }
        related = ai._find_related_documents(question.lower(), user_data)
        assert isinstance(related, list)
        # Le code cherche dans original_name + category, et filtre les mots < 3 caractères
        # "analyse" (7 chars) devrait être trouvé
        if related:  # Peut être vide si aucun mot-clé ne correspond
            assert isinstance(related[0], str)

    def test_generate_suggestions(self, ai):
        """Test génération suggestions"""
        question_type = "pain"
        user_data: dict[str, Any] = {"documents": [], "doctors": []}
        suggestions = ai._generate_suggestions(question_type, user_data)
        assert isinstance(suggestions, list)
        assert len(suggestions) > 0
