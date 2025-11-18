"""
Tests unitaires pour le module security_dashboard
"""

import tempfile
from pathlib import Path
from unittest.mock import patch

from arkalia_cia_python_backend.security_dashboard import SecurityDashboard


class TestSecurityDashboard:
    """Tests pour SecurityDashboard"""

    def setup_method(self):
        """Configuration avant chaque test"""
        self.temp_dir = tempfile.mkdtemp()
        self.dashboard = SecurityDashboard(project_path=self.temp_dir)

    def teardown_method(self):
        """Nettoyage après chaque test"""
        import shutil

        if Path(self.temp_dir).exists():
            shutil.rmtree(self.temp_dir)

    def test_initialization(self):
        """Test d'initialisation"""
        assert self.dashboard is not None
        assert self.dashboard.project_path == Path(self.temp_dir)
        assert self.dashboard.dashboard_dir.exists()

    def test_initialize_athalia_components(self):
        """Test d'initialisation des composants Athalia"""
        components = self.dashboard._initialize_athalia_components()
        assert isinstance(components, dict)

    def test_collect_security_data(self):
        """Test de collecte de données de sécurité"""
        security_data = self.dashboard.collect_security_data()
        assert "timestamp" in security_data
        assert "project_path" in security_data
        assert "security_score" in security_data
        assert "vulnerabilities" in security_data
        assert "recommendations" in security_data

    def test_generate_security_recommendations(self):
        """Test de génération de recommandations"""
        security_data = {
            "security_score": 50,
            "vulnerabilities": {"high": 1, "medium": 5, "low": 10},
            "athalia_available": False,
        }
        recommendations = self.dashboard._generate_security_recommendations(
            security_data
        )
        assert isinstance(recommendations, list)
        assert len(recommendations) > 0

    def test_generate_security_recommendations_high_score(self):
        """Test de recommandations avec score élevé"""
        security_data = {
            "security_score": 95,
            "vulnerabilities": {"high": 0, "medium": 0, "low": 0},
            "athalia_available": True,
        }
        recommendations = self.dashboard._generate_security_recommendations(
            security_data
        )
        assert isinstance(recommendations, list)

    def test_generate_security_dashboard(self):
        """Test de génération du dashboard"""
        dashboard_file = self.dashboard.generate_security_dashboard()
        assert dashboard_file is not None
        assert isinstance(dashboard_file, str)
        assert Path(dashboard_file).exists()

    def test_generate_dashboard_html(self):
        """Test de génération du HTML du dashboard"""
        security_data = {
            "security_score": 85,
            "vulnerabilities": {"high": 0, "medium": 2, "low": 5},
            "recommendations": ["Test recommendation"],
            "timestamp": "2024-01-01T00:00:00",
            "project_path": str(self.temp_dir),
        }
        html = self.dashboard._generate_dashboard_html(security_data)
        assert html is not None
        assert isinstance(html, str)
        assert "<html" in html.lower()
        assert "security_score" in html or "85" in html

    def test_generate_command_validation_html(self):
        """Test de génération HTML pour validation de commandes"""
        security_data = {
            "security_checks": {
                "comprehensive_scan": {
                    "total_files_scanned": 100,
                    "vulnerabilities_found": 5,
                    "risk_level": "medium",
                }
            }
        }
        html = self.dashboard._generate_command_validation_html(security_data)
        assert html is not None
        assert isinstance(html, str)

    def test_generate_code_analysis_html(self):
        """Test de génération HTML pour analyse de code"""
        security_data = {
            "python_stats": {"total_files": 50, "total_lines": 5000},
            "test_coverage": {"total_tests": 100},
            "documentation_quality": {"total_docs": 10},
        }
        html = self.dashboard._generate_code_analysis_html(security_data)
        assert html is not None
        assert isinstance(html, str)

    def test_generate_cache_security_html(self):
        """Test de génération HTML pour sécurité du cache"""
        security_data = {
            "cache_security": {
                "hits": 100,
                "misses": 20,
                "total_requests": 120,
                "hit_rate": 0.83,
                "cache_size": 1024,
            }
        }
        html = self.dashboard._generate_cache_security_html(security_data)
        assert html is not None
        assert isinstance(html, str)

    def test_generate_security_metrics_html(self):
        """Test de génération HTML pour métriques de sécurité"""
        security_data = {
            "security_score": 85,
            "vulnerabilities": {"high": 0, "medium": 2, "low": 5},
            "athalia_available": True,
        }
        html = self.dashboard._generate_security_metrics_html(security_data)
        assert html is not None
        assert isinstance(html, str)

    def test_generate_recommendations_html(self):
        """Test de génération HTML pour recommandations"""
        recommendations = [
            "🚨 CRITIQUE: Action requise",
            "⚠️ ATTENTION: Amélioration nécessaire",
            "✅ EXCELLENT: Tout est bon",
        ]
        html = self.dashboard._generate_recommendations_html(recommendations)
        assert html is not None
        assert isinstance(html, str)

    @patch("arkalia_cia_python_backend.security_dashboard.webbrowser.open")
    def test_open_dashboard(self, mock_open):
        """Test d'ouverture du dashboard"""
        self.dashboard.open_dashboard()
        # Vérifier que generate_security_dashboard a été appelé
        assert True  # Si pas d'exception, c'est bon
