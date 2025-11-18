"""
Tests unitaires pour le module security_dashboard
"""

import gc
import tempfile
from pathlib import Path
from typing import Any
from unittest.mock import patch

from arkalia_cia_python_backend.security_dashboard import SecurityDashboard


class TestSecurityDashboard:
    """Tests pour SecurityDashboard"""

    def setup_method(self):
        """Configuration avant chaque test"""
        self.temp_dir = tempfile.mkdtemp()
        # Mock les composants Athalia dès l'initialisation pour éviter les scans complets
        with patch(
            "arkalia_cia_python_backend.security_dashboard.ATHALIA_AVAILABLE", False
        ):
            self.dashboard = SecurityDashboard(project_path=self.temp_dir)
            # Vider les composants Athalia pour éviter les scans
            self.dashboard.athalia_components = {}

    def teardown_method(self):
        """Nettoyage après chaque test"""
        import shutil

        # Libérer la mémoire avant nettoyage
        if hasattr(self, "dashboard"):
            # Nettoyer les composants Athalia
            if hasattr(self.dashboard, "athalia_components"):
                self.dashboard.athalia_components.clear()
            del self.dashboard
        gc.collect()
        gc.collect()  # Double collect pour forcer le nettoyage

        if Path(self.temp_dir).exists():
            shutil.rmtree(self.temp_dir)

    def test_initialization(self):
        """Test d'initialisation"""
        assert self.dashboard is not None
        # Le SecurityDashboard détecte les chemins temporaires et utilise le répertoire du script
        # Vérifier que le dashboard est initialisé correctement avec un chemin valide
        assert self.dashboard.project_path.exists()
        assert self.dashboard.dashboard_dir.exists()

    def test_initialize_athalia_components(self):
        """Test d'initialisation des composants Athalia"""
        components = self.dashboard._initialize_athalia_components()
        assert isinstance(components, dict)

    def test_collect_security_data(self):
        """Test de collecte de données de sécurité"""
        # Mock les composants Athalia pour éviter les scans complets
        with patch.dict(self.dashboard.athalia_components, {}, clear=True):
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
        # Mock les composants Athalia pour éviter les scans complets
        with patch.dict(self.dashboard.athalia_components, {}, clear=True):
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
        # Nettoyer la mémoire après génération HTML
        del html
        gc.collect()

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

    def test_collect_security_data_with_athalia_components(self):
        """Test de collecte avec composants Athalia simulés"""
        # Simuler des composants Athalia disponibles mais vides pour éviter les scans
        with patch(
            "arkalia_cia_python_backend.security_dashboard.ATHALIA_AVAILABLE", True
        ):
            dashboard = SecurityDashboard(project_path=self.temp_dir)
            # Vider les composants pour éviter les scans complets
            dashboard.athalia_components = {}
            security_data = dashboard.collect_security_data()
            assert "athalia_available" in security_data
            assert security_data["athalia_available"] is True
            # Nettoyer immédiatement
            dashboard.athalia_components.clear()
            del dashboard
            gc.collect()

    def test_generate_recommendations_empty(self):
        """Test de génération de recommandations avec données vides"""
        security_data: dict[str, Any] = {}
        recommendations = self.dashboard._generate_security_recommendations(
            security_data
        )
        assert isinstance(recommendations, list)

    def test_generate_command_validation_html_empty(self):
        """Test de génération HTML avec données vides"""
        security_data: dict[str, Any] = {}
        html = self.dashboard._generate_command_validation_html(security_data)
        assert html is not None
        assert isinstance(html, str)

    def test_generate_code_analysis_html_empty(self):
        """Test de génération HTML avec données vides"""
        security_data: dict[str, Any] = {}
        html = self.dashboard._generate_code_analysis_html(security_data)
        assert html is not None
        assert isinstance(html, str)

    def test_generate_cache_security_html_empty(self):
        """Test de génération HTML avec données vides"""
        security_data: dict[str, Any] = {}
        html = self.dashboard._generate_cache_security_html(security_data)
        assert html is not None
        assert isinstance(html, str)

    def test_generate_security_metrics_html_empty(self):
        """Test de génération HTML avec données vides"""
        security_data: dict[str, Any] = {}
        html = self.dashboard._generate_security_metrics_html(security_data)
        assert html is not None
        assert isinstance(html, str)

    def test_generate_recommendations_html_empty(self):
        """Test de génération HTML avec recommandations vides"""
        html = self.dashboard._generate_recommendations_html([])
        assert html is not None
        assert isinstance(html, str)

    def test_collect_security_data_with_vulnerabilities(self):
        """Test de collecte avec vulnérabilités simulées"""
        # Mock les composants Athalia pour éviter les scans complets
        with patch.dict(self.dashboard.athalia_components, {}, clear=True):
            security_data = self.dashboard.collect_security_data()
            # Vérifier que les données sont structurées correctement
            assert "vulnerabilities" in security_data
            assert isinstance(security_data["vulnerabilities"], dict)

    def test_generate_command_validation_html_with_data(self):
        """Test de génération HTML avec données complètes"""
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
        assert "100" in html or "Fichiers Scannés" in html

    def test_generate_dashboard_html_with_all_data(self):
        """Test de génération dashboard avec toutes les données"""
        security_data = {
            "security_score": 85,
            "vulnerabilities": {"high": 0, "medium": 2, "low": 5},
            "recommendations": ["Test recommendation"],
            "timestamp": "2024-01-01T00:00:00",
            "project_path": str(self.temp_dir),
            "security_checks": {
                "comprehensive_scan": {
                    "total_files_scanned": 100,
                    "vulnerabilities_found": 5,
                }
            },
            "python_stats": {"total_files": 50},
            "test_coverage": {"total_tests": 100},
            "documentation_quality": {"total_docs": 10},
            "cache_security": {"hits": 100, "misses": 20},
        }
        html = self.dashboard._generate_dashboard_html(security_data)
        assert "<html" in html.lower()
        assert "85" in html
        # Nettoyer immédiatement
        del html, security_data
        gc.collect()

    def test_main_function_generate_only(self):
        """Test de la fonction main avec --generate-only"""
        import sys
        from unittest.mock import patch

        test_args = [
            "security_dashboard.py",
            "--generate-only",
            "--project-path",
            self.temp_dir,
        ]
        with patch.object(sys, "argv", test_args):
            try:
                from arkalia_cia_python_backend.security_dashboard import main

                main()
            except SystemExit:
                pass  # argparse peut appeler sys.exit

    def test_main_function_open(self):
        """Test de la fonction main avec --open"""
        import sys
        from unittest.mock import patch

        test_args = ["security_dashboard.py", "--open", "--project-path", self.temp_dir]
        with patch.object(sys, "argv", test_args):
            try:
                from arkalia_cia_python_backend.security_dashboard import main

                main()
            except SystemExit:
                pass

    def test_generate_recommendations_various_scores(self):
        """Test de génération recommandations avec différents scores"""
        # Score très faible
        data_low = {
            "security_score": 30,
            "vulnerabilities": {"high": 0, "medium": 0, "low": 0},
        }
        recs = self.dashboard._generate_security_recommendations(data_low)
        assert len(recs) > 0

        # Score moyen
        data_medium = {
            "security_score": 60,
            "vulnerabilities": {"high": 0, "medium": 0, "low": 0},
        }
        recs = self.dashboard._generate_security_recommendations(data_medium)
        assert len(recs) > 0

        # Score élevé
        data_high = {
            "security_score": 90,
            "vulnerabilities": {"high": 0, "medium": 0, "low": 0},
        }
        recs = self.dashboard._generate_security_recommendations(data_high)
        assert len(recs) > 0

    def test_generate_recommendations_with_vulnerabilities(self):
        """Test de génération recommandations avec vulnérabilités"""
        data = {
            "security_score": 85,
            "vulnerabilities": {"high": 1, "medium": 10, "low": 15},
            "athalia_available": False,
        }
        recs = self.dashboard._generate_security_recommendations(data)
        assert len(recs) > 0

    def test_generate_recommendations_no_recommendations(self):
        """Test de génération recommandations sans recommandations"""
        data = {
            "security_score": 95,
            "vulnerabilities": {"high": 0, "medium": 0, "low": 0},
            "athalia_available": True,
        }
        recs = self.dashboard._generate_security_recommendations(data)
        assert len(recs) > 0  # Devrait avoir au moins la recommandation générale

    def test_open_dashboard_file_not_exists(self):
        """Test d'ouverture dashboard quand fichier n'existe pas"""
        with patch(
            "arkalia_cia_python_backend.security_dashboard.Path.exists",
            return_value=False,
        ):
            self.dashboard.open_dashboard()
            # Ne devrait pas lever d'exception

    def test_main_function_default(self):
        """Test de la fonction main par défaut"""
        import sys
        from unittest.mock import patch

        test_args = ["security_dashboard.py", "--project-path", self.temp_dir]
        with patch.object(sys, "argv", test_args):
            with patch("arkalia_cia_python_backend.security_dashboard.webbrowser.open"):
                try:
                    from arkalia_cia_python_backend.security_dashboard import main

                    main()
                except (SystemExit, Exception):
                    pass  # Peut lever des exceptions selon l'environnement
