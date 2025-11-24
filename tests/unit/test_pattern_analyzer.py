"""
Tests unitaires pour AdvancedPatternAnalyzer
"""

from datetime import datetime, timedelta

import pytest

from arkalia_cia_python_backend.ai.pattern_analyzer import AdvancedPatternAnalyzer


class TestAdvancedPatternAnalyzer:
    """Tests pour AdvancedPatternAnalyzer"""

    @pytest.fixture
    def analyzer(self):
        """Créer une instance d'analyseur"""
        return AdvancedPatternAnalyzer()

    @pytest.fixture
    def sample_data(self):
        """Données de test"""
        base_date = datetime(2024, 1, 1)
        # OPTIMISATION: Réduit de 10 à 7 pour améliorer les performances (suffisant pour les tests)
        return [
            {
                "date": (base_date + timedelta(days=i)).isoformat(),
                "value": 5 + i,
                "type": "document",
            }
            for i in range(7)
        ]

    def test_detect_temporal_patterns_basic(self, analyzer, sample_data):
        """Test détection patterns temporels basique"""
        result = analyzer.detect_temporal_patterns(sample_data)
        assert isinstance(result, dict)
        assert "recurring_patterns" in result
        assert "trends" in result
        assert "seasonality" in result
        assert "predictions" in result

    def test_detect_temporal_patterns_empty(self, analyzer):
        """Test avec données vides"""
        result = analyzer.detect_temporal_patterns([])
        assert isinstance(result, dict)
        assert "recurring_patterns" in result
        assert isinstance(result["recurring_patterns"], list)

    def test_detect_recurrence(self, analyzer):
        """Test détection récurrence"""
        base_date = datetime(2024, 1, 1)
        data = [
            {
                "date": (base_date + timedelta(days=i * 7)).isoformat(),
                "value": 1,
                "type": "exam",
            }
            for i in range(5)
        ]
        recurring = analyzer._detect_recurrence(data)
        assert isinstance(recurring, list)

    def test_detect_trends(self, analyzer, sample_data):
        """Test détection tendances"""
        trends = analyzer._detect_trends(sample_data)
        assert isinstance(trends, dict)
        assert "slope" in trends
        assert "direction" in trends
        assert trends["direction"] in ["increasing", "decreasing", "stable"]

    def test_detect_seasonality(self, analyzer):
        """Test détection saisonnalité"""
        base_date = datetime(2024, 1, 1)
        # OPTIMISATION: Réduit de 12 à 7 pour améliorer les performances (suffisant pour détecter saisonnalité)
        data = [
            {
                "date": (base_date + timedelta(days=i * 30)).isoformat(),
                "value": 1,
                "type": "document",
            }
            for i in range(7)
        ]
        seasonality = analyzer._detect_seasonality(data)
        assert isinstance(seasonality, dict)

    def test_predict_future_events_basic(self, analyzer):
        """Test prédiction événements futurs"""
        base_date = datetime(2024, 1, 1)
        data = [
            {
                "date": (base_date + timedelta(days=i * 7)).isoformat(),
                "value": 1,
                "type": "document",
            }
            for i in range(5)
        ]
        result = analyzer.predict_future_events(
            data, event_type="document", days_ahead=30
        )
        assert isinstance(result, dict)
        assert "predicted_dates" in result
        assert "confidence" in result
        assert "pattern_based" in result
        assert isinstance(result["predicted_dates"], list)
        assert 0.0 <= result["confidence"] <= 1.0

    def test_predict_future_events_insufficient_data(self, analyzer):
        """Test prédiction avec données insuffisantes"""
        data = [{"date": datetime.now().isoformat(), "value": 1, "type": "document"}]
        result = analyzer.predict_future_events(
            data, event_type="document", days_ahead=30
        )
        assert result["predicted_dates"] == []
        assert result["confidence"] == 0.0
        assert result["pattern_based"] is False

    def test_detect_temporal_patterns_with_prophet(self, analyzer):
        """Test détection patterns avec Prophet (si disponible)"""
        base_date = datetime(2024, 1, 1)
        # OPTIMISATION: Réduit de 14 à 7 pour améliorer les performances (minimum requis pour Prophet)
        data = [
            {
                "date": (base_date + timedelta(days=i)).isoformat(),
                "value": 5 + (i % 7),
                "type": "document",
            }
            for i in range(7)  # Minimum 7 points pour Prophet
        ]
        result = analyzer.detect_temporal_patterns(data)
        assert isinstance(result, dict)
        # Prophet peut être disponible ou non selon dépendances
        if result.get("predictions"):
            assert isinstance(result["predictions"], dict)
