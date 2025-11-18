#!/usr/bin/env python3
"""
Dashboard de sécurité web pour Athalia
Interface moderne pour visualiser les rapports de sécurité en temps réel
"""

import gc
import logging
import platform
import subprocess  # nosec B404
import time
import urllib.parse
import webbrowser
from datetime import datetime
from pathlib import Path
from typing import Any

# Import des composants Athalia réels (optionnels)
# Ces imports sont dans un try/except car les modules peuvent ne pas être disponibles
try:
    from athalia_core.core.cache_manager import (  # type: ignore[import-untyped]
        CacheManager,  # noqa: F401
    )
    from athalia_core.metrics.collector import (  # type: ignore[import-untyped]
        MetricsCollector,  # noqa: F401
    )
    from athalia_core.quality.code_linter import (  # type: ignore[import-untyped]
        CodeLinter,  # noqa: F401
    )
    from athalia_core.validation.security_validator import (  # type: ignore[import-untyped]
        CommandSecurityValidator,  # noqa: F401
    )

    ATHALIA_AVAILABLE = True
except ImportError as e:
    logging.warning(f"Composants Athalia non disponibles: {e}")
    ATHALIA_AVAILABLE = False
    # Définir des types vides pour éviter les erreurs de type
    CacheManager = None
    MetricsCollector = None
    CodeLinter = None
    CommandSecurityValidator = None

logger = logging.getLogger(__name__)


def force_memory_cleanup():
    """Force un nettoyage complet de la mémoire"""
    gc.collect()
    gc.collect()  # Double collect pour forcer le nettoyage complet


class SecurityDashboard:
    """Dashboard de sécurité web moderne avec vraie intégration Athalia"""

    def __init__(self, project_path: str = "."):
        # Résoudre le chemin et vérifier qu'il n'est pas temporaire
        resolved_path = Path(project_path).resolve()
        project_str = str(resolved_path)

        # Détecter et éviter les répertoires temporaires
        # Note: Utilisation de tempfile.gettempdir() serait préférable mais ici
        # on détecte les chemins temporaires pour éviter les scans sur /tmp
        if (
            "/tmp/" in project_str  # nosec B108
            or "/var/folders/" in project_str  # nosec B108
            or ("tmp" in project_str.lower() and "arkalia" not in project_str.lower())
        ):
            # Si c'est un répertoire temporaire, chercher le vrai projet
            script_file = Path(__file__).resolve()
            script_dir = script_file.parent.parent
            if (script_dir / "pyproject.toml").exists() or (
                script_dir / "README.md"
            ).exists():
                resolved_path = script_dir.resolve()
                logger.warning(
                    f"Chemin temporaire détecté ({project_path}), "
                    f"utilisation du répertoire du script: {resolved_path}"
                )

        self.project_path = resolved_path
        self.dashboard_dir = self.project_path / "dashboard" / "security"
        self.dashboard_dir.mkdir(parents=True, exist_ok=True)
        self.reports_dir = self.project_path / ".github" / "workflows" / "artifacts"

        # Initialisation des composants Athalia
        self.athalia_components = self._initialize_athalia_components()

        # Suivi de la dernière ouverture pour éviter les ouvertures multiples
        self._last_open_time = 0.0

    def _initialize_athalia_components(self) -> dict[str, Any]:
        """Initialise les composants Athalia pour le dashboard de sécurité"""
        if not ATHALIA_AVAILABLE:
            return {}

        try:
            components: dict[str, Any] = {}

            # Initialisation sécurisée de chaque composant
            try:
                components["security_validator"] = CommandSecurityValidator()
            except Exception as e:
                logger.warning(
                    f"Impossible d'initialiser CommandSecurityValidator: {e}"
                )

            try:
                components["code_linter"] = CodeLinter(str(self.project_path))
            except Exception as e:
                logger.warning(f"Impossible d'initialiser CodeLinter: {e}")

            try:
                components["cache_manager"] = CacheManager(".athalia_cache")
            except Exception as e:
                logger.warning(f"Impossible d'initialiser CacheManager: {e}")

            try:
                components["metrics_collector"] = MetricsCollector(
                    str(self.project_path)
                )
            except Exception as e:
                logger.warning(f"Impossible d'initialiser MetricsCollector: {e}")

            return components
        except Exception as e:
            logger.error(
                f"Erreur critique d'initialisation des composants Athalia: {e}"
            )
            return {}

    def collect_security_data(self) -> dict[str, Any]:
        """Collecte les vraies données de sécurité depuis les composants Athalia"""
        security_data: dict[str, Any] = {
            "timestamp": datetime.now().isoformat(),
            "project_path": str(self.project_path),
            "athalia_available": ATHALIA_AVAILABLE,
            "security_score": 0,
            "vulnerabilities": {"high": 0, "medium": 0, "low": 0},
            "security_checks": {},
            "linting_results": {},
            "cache_security": {},
            "cache_performance": 0,
            "python_stats": {},
            "test_coverage": {},
            "documentation_quality": {},
            "project_metrics": {},
            "performance_metrics": {},
            "code_quality_metrics": {},
            "recommendations": [],
        }

        if not self.athalia_components:
            security_data["recommendations"].append(
                "Composants Athalia non disponibles"
            )
            return security_data

        try:
            # Collecte des données de sécurité
            if "security_validator" in self.athalia_components:
                security_validator = self.athalia_components["security_validator"]

                # Scan de sécurité complet avec la vraie méthode
                if hasattr(security_validator, "run_comprehensive_scan"):
                    scan_results = security_validator.run_comprehensive_scan(
                        str(self.project_path)
                    )
                    security_data["security_checks"][
                        "comprehensive_scan"
                    ] = scan_results

                    # Calcul du score de sécurité intelligent et contextuel
                    total_vulns = scan_results.get("vulnerabilities_found", 0)
                    if total_vulns > 0:
                        # Limiter la taille des vulnérabilités en mémoire pour éviter la surcharge
                        vulnerabilities_raw = scan_results.get("vulnerabilities", [])
                        # Limiter à 1000 vulnérabilités max pour éviter la surcharge mémoire
                        max_vulns = 1000
                        if len(vulnerabilities_raw) > max_vulns:
                            logger.warning(
                                f"Trop de vulnérabilités ({len(vulnerabilities_raw)}), "
                                f"limitation à {max_vulns} pour optimiser la mémoire"
                            )
                            vulnerabilities = vulnerabilities_raw[:max_vulns]
                        else:
                            vulnerabilities = vulnerabilities_raw
                        # Libérer la référence pour libérer la mémoire immédiatement
                        del vulnerabilities_raw
                        force_memory_cleanup()

                        # Analyse intelligente des fonctions dangereuses (optimisé pour mémoire)
                        # Parcourir une seule fois au lieu de plusieurs list comprehensions
                        dangerous_functions_count = 0
                        xss_count = 0
                        sql_count = 0
                        xss_patterns_set: set[str] = set()
                        sql_patterns_set: set[str] = set()

                        for v in vulnerabilities:
                            vuln_type = v.get("type", "")
                            if vuln_type == "dangerous_function":
                                dangerous_functions_count += 1
                            elif vuln_type == "xss":
                                xss_count += 1
                                pattern = v.get("pattern", "")
                                if pattern:
                                    xss_patterns_set.add(pattern)
                            elif vuln_type == "sql_injection":
                                sql_count += 1
                                pattern = v.get("pattern", "")
                                if pattern:
                                    sql_patterns_set.add(pattern)

                        xss_patterns = len(xss_patterns_set)
                        sql_patterns = len(sql_patterns_set)

                        # Libérer les sets immédiatement après utilisation
                        del xss_patterns_set, sql_patterns_set

                        # Score contextuel intelligent et réaliste
                        base_score = 100  # Score de base parfait

                        # Classification intelligente des vulnérabilités
                        high_vulns = xss_count + sql_count
                        medium_vulns = dangerous_functions_count
                        low_vulns = total_vulns - high_vulns - medium_vulns

                        # Pénalités critiques (XSS et SQL injection sont très graves)
                        xss_penalty = (
                            xss_patterns * 5.0
                        )  # 5 points par pattern XSS unique
                        sql_penalty = (
                            sql_patterns * 10.0
                        )  # 10 points par pattern SQL unique

                        # Pénalités pour fonctions dangereuses (moins graves mais nombreuses)
                        # Réduire la pénalité si beaucoup de vulnérabilités (probablement des faux positifs)
                        if medium_vulns > 50:
                            # Si plus de 50 vulnérabilités moyennes, probablement des faux positifs
                            medium_penalty = min(15.0, medium_vulns * 0.1)
                        else:
                            medium_penalty = medium_vulns * 0.3

                        # Pénalités pour vulnérabilités mineures
                        low_penalty = low_vulns * 0.05

                        # Calcul du score final intelligent
                        total_penalty = (
                            xss_penalty + sql_penalty + medium_penalty + low_penalty
                        )

                        security_data["security_score"] = max(
                            0, min(100, base_score - total_penalty)
                        )

                        # Classification intelligente des vulnérabilités
                        security_data["vulnerabilities"]["high"] = high_vulns
                        security_data["vulnerabilities"]["medium"] = medium_vulns
                        security_data["vulnerabilities"]["low"] = max(0, low_vulns)

                        # Métriques de performance et qualité du code
                        total_files = scan_results.get("total_files_scanned", 0)
                        vulns_count = len(vulnerabilities)
                        security_data["performance_metrics"] = {
                            "scan_speed": total_files / max(1, vulns_count),
                            "vulnerability_density": total_vulns / max(1, total_files),
                            "risk_distribution": {
                                "critical_ratio": (xss_count + sql_count)
                                / max(1, total_vulns),
                                "medium_ratio": dangerous_functions_count
                                / max(1, total_vulns),
                                "safe_ratio": (total_files - total_vulns)
                                / max(1, total_files),
                            },
                        }

                        # Métriques de qualité du code
                        security_data["code_quality_metrics"] = {
                            "security_awareness": max(0, 100 - (total_vulns * 0.1)),
                            "code_complexity": total_files / max(1, vulns_count),
                            "maintenance_index": max(
                                0, 100 - (dangerous_functions_count * 0.05)
                            ),
                        }

                        # Libérer la mémoire des vulnérabilités après traitement
                        del vulnerabilities
                        # Libérer aussi les données intermédiaires
                        if "vulnerabilities" in scan_results:
                            del scan_results["vulnerabilities"]
                        # Forcer le garbage collector pour libérer la mémoire immédiatement
                        force_memory_cleanup()
                    else:
                        security_data["security_score"] = 100
                        security_data["vulnerabilities"] = {
                            "high": 0,
                            "medium": 0,
                            "low": 0,
                        }

            # Collecte des résultats de linting
            if "code_linter" in self.athalia_components:
                code_linter = self.athalia_components["code_linter"]

                if hasattr(code_linter, "run"):
                    try:
                        linting_results = code_linter.run()
                        security_data["linting_results"] = linting_results
                    except Exception as e:
                        logger.warning(f"Erreur lors du linting: {e}")
                        security_data["linting_results"] = {"error": str(e)}

            # Collecte des métriques de cache
            if "cache_manager" in self.athalia_components:
                cache_manager = self.athalia_components["cache_manager"]

                if hasattr(cache_manager, "get_stats"):
                    try:
                        cache_stats = cache_manager.get_stats()
                        security_data["cache_security"] = cache_stats

                        # Calcul du score de performance du cache
                        hit_rate = cache_stats.get("hit_rate", 0)
                        hits = cache_stats.get("hits", 0)
                        misses = cache_stats.get("misses", 0)
                        total_reqs = cache_stats.get("total_requests", 0)

                        # Calculer le hit_rate correctement
                        if isinstance(hit_rate, int | float) and hit_rate > 0:
                            # Vérifier si hit_rate est déjà en pourcentage (> 1) ou décimal (<= 1)
                            if hit_rate > 1:
                                hit_rate_percent = min(100.0, hit_rate)
                            else:
                                hit_rate_percent = hit_rate * 100
                        elif total_reqs > 0:
                            hit_rate_percent = (hits / total_reqs) * 100
                        elif hits + misses > 0:
                            hit_rate_percent = (hits / (hits + misses)) * 100
                        else:
                            hit_rate_percent = 0.0

                        cache_performance = min(100, max(0, int(hit_rate_percent)))
                        security_data["cache_performance"] = cache_performance
                        # Mettre à jour le hit_rate dans cache_stats pour l'affichage
                        cache_stats["hit_rate"] = hit_rate_percent / 100.0
                    except Exception as e:
                        logger.warning(
                            f"Erreur lors de la collecte des stats cache: {e}"
                        )
                        security_data["cache_security"] = {"error": str(e)}

            # Collecte des métriques complètes du projet
            if "metrics_collector" in self.athalia_components:
                metrics_collector = self.athalia_components["metrics_collector"]

                if hasattr(metrics_collector, "collect_all_metrics"):
                    try:
                        project_metrics = metrics_collector.collect_all_metrics()
                        security_data["project_metrics"] = project_metrics

                        # Métriques Python avec les vraies clés du MetricsCollector
                        python_files = project_metrics.get("python_files", {})
                        if isinstance(python_files, dict):
                            security_data["python_stats"] = {
                                "total_files": python_files.get("count", 0),
                                "total_lines": python_files.get("total_lines", 0),
                                "average_lines": python_files.get(
                                    "average_lines_per_file", 0
                                ),
                                "complexity": python_files.get("average_complexity", 0),
                            }

                        # Métriques de tests avec les vraies clés
                        tests = project_metrics.get("tests", {})
                        if isinstance(tests, dict):
                            security_data["test_coverage"] = {
                                "total_tests": tests.get("collected_tests_count", 0),
                                "test_files": tests.get("test_files_count", 0),
                                "coverage_percentage": tests.get(
                                    "coverage_percentage", 0
                                ),
                            }

                        # Métriques de documentation avec les vraies clés
                        docs = project_metrics.get("documentation", {})
                        if isinstance(docs, dict):
                            security_data["documentation_quality"] = {
                                "total_docs": docs.get("total_files", 0),
                                "doc_files": docs.get("document_files", 0),
                                "coverage": docs.get("coverage_percentage", 0),
                            }

                    except Exception as e:
                        logger.warning(f"Erreur lors de la collecte des métriques: {e}")
                        security_data["project_metrics"] = {"error": str(e)}
                        # Libérer la mémoire en cas d'erreur
                        force_memory_cleanup()

            # Génération des recommandations
            security_data["recommendations"] = self._generate_security_recommendations(
                security_data
            )

            # Libérer les données volumineuses après traitement
            if "project_metrics" in security_data:
                # Garder seulement les métriques essentielles
                project_metrics = security_data.get("project_metrics", {})
                if isinstance(project_metrics, dict) and "error" not in project_metrics:
                    # Nettoyer les données volumineuses non utilisées
                    for key in list(project_metrics.keys()):
                        if key not in ["python_files", "tests", "documentation"]:
                            del project_metrics[key]
                    force_memory_cleanup()

        except Exception as e:
            logger.error(f"Erreur lors de la collecte des données de sécurité: {e}")
            security_data["error"] = str(e)
        finally:
            # Forcer le garbage collector pour libérer la mémoire après collecte
            force_memory_cleanup()

        return security_data

    def _generate_security_recommendations(
        self, security_data: dict[str, Any]
    ) -> list[str]:
        """Génère des recommandations de sécurité basées sur les vraies données"""
        recommendations = []

        # Recommandations basées sur le score de sécurité
        security_score = security_data.get("security_score", 0)
        if security_score < 50:
            recommendations.append(
                "🚨 CRITIQUE: Score de sécurité très faible - Audit immédiat requis"
            )
        elif security_score < 70:
            recommendations.append(
                "⚠️ ATTENTION: Score de sécurité faible - Actions correctives"
                " nécessaires"
            )
        elif security_score < 85:
            recommendations.append(
                "🔶 AMÉLIORATION: Score de sécurité acceptable mais peut être amélioré"
            )
        else:
            recommendations.append(
                "✅ EXCELLENT: Score de sécurité élevé - Maintenir les bonnes pratiques"
            )

        # Recommandations basées sur les vulnérabilités
        vulnerabilities = security_data.get("vulnerabilities", {})
        if vulnerabilities.get("high", 0) > 0:
            recommendations.append(
                "🚨 CRITIQUE: Vulnérabilités critiques détectées - Correction immédiate"
                " requise"
            )
        if vulnerabilities.get("medium", 0) > 5:
            recommendations.append(
                "⚠️ ATTENTION: Nombre élevé de vulnérabilités moyennes - Plan de"
                " correction nécessaire"
            )
        if vulnerabilities.get("low", 0) > 10:
            recommendations.append(
                "🔶 AMÉLIORATION: Nombre élevé de vulnérabilités mineures - Nettoyage"
                " recommandé"
            )

        # Recommandations basées sur les composants
        if not security_data.get("athalia_available", False):
            recommendations.append(
                "🔧 TECHNIQUE: Installer/mettre à jour les composants Athalia pour une"
                " sécurité optimale"
            )

        # Recommandations générales
        if not recommendations:
            recommendations.append("✅ SÉCURISÉ: Aucune action immédiate requise")

        recommendations.append(
            "📚 DOCUMENTATION: Consulter le guide de sécurité Athalia pour plus"
            " d'informations"
        )

        return recommendations

    def generate_security_dashboard(self) -> str:
        """Génère le dashboard de sécurité HTML avec vraies données"""
        try:
            # Collecter les vraies données de sécurité
            security_data = self.collect_security_data()

            # Générer le HTML avec les vraies données
            dashboard_html = self._generate_dashboard_html(security_data)

            # Libérer la mémoire des données de sécurité après génération HTML
            del security_data
            force_memory_cleanup()

            # Créer le fichier dashboard
            dashboard_file = self.dashboard_dir / "security_dashboard.html"
            with open(dashboard_file, "w", encoding="utf-8") as f:
                f.write(dashboard_html)

            # Libérer la mémoire du HTML après écriture
            del dashboard_html
            force_memory_cleanup()

            logger.info(
                f"Dashboard de sécurité généré avec vraies données: {dashboard_file}"
            )
            return str(dashboard_file)
        finally:
            # Nettoyage final de la mémoire
            force_memory_cleanup()

    def _generate_dashboard_html(self, security_data: dict[str, Any]) -> str:
        """Génère le HTML du dashboard avec les vraies données de sécurité"""

        # Extraction des données pour le template
        security_score = security_data.get("security_score", 0)
        vulnerabilities = security_data.get(
            "vulnerabilities", {"high": 0, "medium": 0, "low": 0}
        )
        recommendations = security_data.get("recommendations", [])
        timestamp = security_data.get("timestamp", "")
        project_path = security_data.get("project_path", "")

        # Types de vulnérabilités supportés
        # (pour affichage futur et extensibilité)

        # Calculer les métriques de vulnérabilités
        total_vulnerabilities = (
            vulnerabilities.get("high", 0)
            + vulnerabilities.get("medium", 0)
            + vulnerabilities.get("low", 0)
        )
        high_vulns = vulnerabilities.get("high", 0)
        medium_vulns = vulnerabilities.get("medium", 0)
        low_vulns = vulnerabilities.get("low", 0)

        # Couleurs et statuts
        score_color = (
            "#28a745"
            if security_score >= 85
            else "#ffc107" if security_score >= 70 else "#dc3545"
        )
        score_status = (
            "Sécurisé"
            if security_score >= 85
            else "Attention" if security_score >= 70 else "Critique"
        )

        html_template = f"""<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard Sécurité - Athalia</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        * {{
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }}

        body {{
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            color: #333;
        }}

        .container {{
            max-width: 1400px;
            margin: 0 auto;
            padding: 20px;
        }}

        .header {{
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            padding: 30px;
            margin-bottom: 30px;
            text-align: center;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
        }}

        .header h1 {{
            font-size: 3em;
            color: #667eea;
            margin-bottom: 10px;
            font-weight: 300;
        }}

        .header p {{
            font-size: 1.2em;
            color: #666;
        }}

        .security-overview {{
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            padding: 30px;
            margin-bottom: 30px;
            text-align: center;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
        }}

        .security-score {{
            font-size: 4em;
            font-weight: 700;
            color: {score_color};
            margin: 20px 0;
        }}

        .security-status {{
            font-size: 1.5em;
            color: {score_color};
            margin-bottom: 20px;
        }}

        .vulnerabilities-grid {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin: 30px 0;
        }}

        .vuln-card {{
            background: #f8f9fa;
            border-radius: 15px;
            padding: 20px;
            text-align: center;
            border-left: 4px solid;
            position: relative;
            overflow: hidden;
        }}

        .vuln-high {{
            border-left-color: #dc3545;
            background: #f8d7da;
        }}

        .vuln-medium {{
            border-left-color: #ffc107;
            background: #fff3cd;
        }}

        .vuln-low {{
            border-left-color: #28a745;
            background: #d4edda;
        }}

        .vuln-number {{
            font-size: 2.5em;
            font-weight: 700;
            margin-bottom: 10px;
        }}

        .vuln-high .vuln-number {{
            color: #dc3545;
        }}

        .vuln-medium .vuln-number {{
            color: #ffc107;
        }}

        .vuln-low .vuln-number {{
            color: #28a745;
        }}

        .security-grid {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
            gap: 30px;
            margin-bottom: 30px;
        }}

        .security-card {{
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            padding: 25px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
        }}

        .security-card h3 {{
            color: #667eea;
            margin-bottom: 20px;
            font-size: 1.5em;
        }}

        .recommendations {{
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            padding: 30px;
            margin-bottom: 30px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
        }}

        .recommendation-item {{
            background: #f8f9fa;
            border-radius: 10px;
            padding: 15px;
            margin: 10px 0;
            border-left: 4px solid #667eea;
            display: flex;
            align-items: center;
            gap: 10px;
        }}

        .recommendation-critical {{
            border-left-color: #dc3545;
            background: #fff5f5;
        }}

        .recommendation-warning {{
            border-left-color: #ffc107;
            background: #fffbf0;
        }}

        .recommendation-improvement {{
            border-left-color: #fd7e14;
            background: #fff8f0;
        }}

        .recommendation-excellent {{
            border-left-color: #28a745;
            background: #f0fff4;
        }}

        .recommendation-info {{
            border-left-color: #17a2b8;
            background: #f0f9ff;
        }}

        .rec-icon {{
            font-size: 1.2em;
            min-width: 30px;
        }}

        .rec-text {{
            flex: 1;
        }}

        .risk-high {{
            color: #dc3545;
            font-weight: bold;
        }}

        .risk-medium {{
            color: #ffc107;
            font-weight: bold;
        }}

        .score-75 {{
            color: #ffc107;
            font-weight: bold;
        }}

        .score-60 {{
            color: #fd7e14;
            font-weight: bold;
        }}

        .score-100 {{
            color: #28a745;
            font-weight: bold;
        }}

        .chart-container {{
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            padding: 30px;
            margin-bottom: 30px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
        }}

        .footer {{
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            padding: 20px;
            text-align: center;
            color: #666;
        }}

        .refresh-btn {{
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            border: none;
            padding: 15px 30px;
            border-radius: 25px;
            font-size: 1.1em;
            cursor: pointer;
            margin: 20px 0;
            transition: all 0.3s ease;
        }}

        .refresh-btn:hover {{
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(102, 126, 234, 0.3);
        }}

        .metric-row {{
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin: 10px 0;
            padding: 12px 15px;
            background: #f8f9fa;
            border-radius: 8px;
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }}

        .metric-row:hover {{
            background: #e9ecef;
            transform: translateX(5px);
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }}

        .metric-label {{
            font-weight: bold;
            display: flex;
            align-items: center;
            gap: 8px;
        }}

        .metric-value {{
            color: #666;
            font-weight: 600;
            font-size: 1.05em;
        }}

        /* Barres de progression pour les métriques */
        .progress-bar-container {{
            width: 100%;
            height: 8px;
            background: #e9ecef;
            border-radius: 10px;
            overflow: hidden;
            margin-top: 8px;
        }}

        .progress-bar {{
            height: 100%;
            background: linear-gradient(90deg, #667eea, #764ba2);
            border-radius: 10px;
            transition: width 1s ease-in-out;
            animation: progressAnimation 1.5s ease-out;
        }}

        @keyframes progressAnimation {{
            from {{
                width: 0%;
            }}
        }}

        /* Animations pour les cartes */
        .vuln-card, .security-card {{
            animation: fadeInUp 0.6s ease-out;
            animation-fill-mode: both;
        }}

        .vuln-card:nth-child(1) {{ animation-delay: 0.1s; }}
        .vuln-card:nth-child(2) {{ animation-delay: 0.2s; }}
        .vuln-card:nth-child(3) {{ animation-delay: 0.3s; }}
        .vuln-card:nth-child(4) {{ animation-delay: 0.4s; }}

        .security-card:nth-child(1) {{ animation-delay: 0.2s; }}
        .security-card:nth-child(2) {{ animation-delay: 0.3s; }}
        .security-card:nth-child(3) {{ animation-delay: 0.4s; }}
        .security-card:nth-child(4) {{ animation-delay: 0.5s; }}

        @keyframes fadeInUp {{
            from {{
                opacity: 0;
                transform: translateY(30px);
            }}
            to {{
                opacity: 1;
                transform: translateY(0);
            }}
        }}

        /* Animation pour le score de sécurité */
        .security-score {{
            animation: scorePulse 2s ease-in-out infinite;
            text-shadow: 0 0 20px rgba(102, 126, 234, 0.3);
        }}

        @keyframes scorePulse {{
            0%, 100% {{
                transform: scale(1);
            }}
            50% {{
                transform: scale(1.05);
            }}
        }}

        /* Effet de brillance sur les cartes */
        .vuln-card::before {{
            content: '';
            position: absolute;
            top: -50%;
            left: -50%;
            width: 200%;
            height: 200%;
            background: linear-gradient(45deg, transparent, rgba(255,255,255,0.1), transparent);
            transform: rotate(45deg);
            transition: all 0.5s;
            opacity: 0;
        }}

        .vuln-card:hover::before {{
            animation: shine 0.5s ease-in-out;
        }}

        @keyframes shine {{
            0% {{
                opacity: 0;
                left: -50%;
            }}
            50% {{
                opacity: 1;
            }}
            100% {{
                opacity: 0;
                left: 150%;
            }}
        }}

        /* Indicateur de chargement */
        .loading-indicator {{
            display: inline-block;
            width: 20px;
            height: 20px;
            border: 3px solid #f3f3f3;
            border-top: 3px solid #667eea;
            border-radius: 50%;
            animation: spin 1s linear infinite;
            margin-left: 10px;
        }}

        @keyframes spin {{
            0% {{ transform: rotate(0deg); }}
            100% {{ transform: rotate(360deg); }}
        }}

        /* Badge pour les scores */
        .score-badge {{
            display: inline-block;
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 0.85em;
            font-weight: bold;
            margin-left: 10px;
        }}

        .score-badge.excellent {{
            background: #d4edda;
            color: #155724;
        }}

        .score-badge.good {{
            background: #fff3cd;
            color: #856404;
        }}

        .score-badge.poor {{
            background: #f8d7da;
            color: #721c24;
        }}

        /* Amélioration du bouton refresh */
        .refresh-btn:active {{
            transform: translateY(0);
        }}

        .refresh-btn.loading {{
            opacity: 0.7;
            cursor: not-allowed;
        }}
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🛡️ Dashboard Sécurité Athalia</h1>
            <p>Surveillance en temps réel de la sécurité du projet</p>
        </div>

        <div class="security-overview">
            <h2>Vue d'ensemble de la sécurité</h2>
            <div class="security-score">{security_score}/100</div>
            <div class="security-status">{score_status}</div>
            <p>Projet: {project_path}</p>
            <p>Dernière mise à jour: {timestamp}</p>
            <button class="refresh-btn" onclick="location.reload()">🔄 Actualiser</button>
        </div>

        <div class="vulnerabilities-grid">
            <div class="vuln-card vuln-high">
                <div class="vuln-number">{high_vulns}</div>
                <div>Vulnérabilités Critiques</div>
            </div>
            <div class="vuln-card vuln-medium">
                <div class="vuln-number">{medium_vulns}</div>
                <div>Vulnérabilités Moyennes</div>
            </div>
            <div class="vuln-card vuln-low">
                <div class="vuln-number">{low_vulns}</div>
                <div>Vulnérabilités Mineures</div>
            </div>
            <div class="vuln-card">
                <div class="vuln-number">{total_vulnerabilities}</div>
                <div>Total Vulnérabilités</div>
            </div>
        </div>

        <div class="security-grid">
            <div class="security-card">
                <h3>🔍 Validation des Commandes</h3>
                <div id="commandValidationDetails">
                    {self._generate_command_validation_html(security_data)}
                </div>
            </div>

            <div class="security-card">
                <h3>📝 Analyse de Code</h3>
                <div id="codeAnalysisDetails">
                    {self._generate_code_analysis_html(security_data)}
                </div>
            </div>

            <div class="security-card">
                <h3>💾 Cache et Performance</h3>
                <div id="cacheSecurityDetails">
                    {self._generate_cache_security_html(security_data)}
                </div>
            </div>

            <div class="security-card">
                <h3>📊 Métriques de Sécurité</h3>
                <div id="securityMetricsDetails">
                    {self._generate_security_metrics_html(security_data)}
                </div>
            </div>
        </div>

        <div class="chart-container">
            <h3>📈 Graphiques de Sécurité</h3>
            <canvas id="securityChart" width="400" height="200"></canvas>
        </div>

        <div class="recommendations">
            <h3>💡 Recommandations de Sécurité</h3>
            {self._generate_recommendations_html(recommendations)}
        </div>

        <div class="footer">
            <p>🕒 Dernière mise à jour: {timestamp}</p>
            <p>🛡️ Dashboard de sécurité généré automatiquement par Athalia v12.0.0</p>
        </div>
    </div>

    <script>
        // Animation au chargement de la page
        document.addEventListener('DOMContentLoaded', function() {{
            // Animation des nombres
            animateNumbers();

            // Ajouter des barres de progression aux métriques
            addProgressBars();
        }});

        // Fonction pour animer les nombres
        function animateNumbers() {{
            const numberElements = document.querySelectorAll('.vuln-number, .security-score');
            numberElements.forEach(element => {{
                const finalValue = parseInt(element.textContent.replace(/[^0-9]/g, ''));
                if (finalValue > 0) {{
                    let currentValue = 0;
                    const increment = finalValue / 30;
                    const timer = setInterval(() => {{
                        currentValue += increment;
                        if (currentValue >= finalValue) {{
                            element.textContent = element.textContent.replace(/[0-9]+/, finalValue);
                            clearInterval(timer);
                        }} else {{
                            const displayValue = Math.floor(currentValue);
                            element.textContent = element.textContent.replace(/[0-9]+/, displayValue);
                        }}
                    }}, 30);
                }}
            }});
        }}

        // Fonction pour ajouter des barres de progression
        function addProgressBars() {{
            const metricRows = document.querySelectorAll('.metric-row');
            metricRows.forEach(row => {{
                const valueElement = row.querySelector('.metric-value');
                if (valueElement) {{
                    const text = valueElement.textContent.trim();
                    // Extraire les nombres (pourcentage, score, etc.)
                    const match = text.match(/([0-9]+)/);
                    if (match) {{
                        let percentage = parseInt(match[1]);
                        // Si c'est un score sur 100, utiliser directement
                        if (text.includes('/100')) {{
                            // Déjà en pourcentage
                        }} else if (text.includes('%')) {{
                            // Déjà en pourcentage
                        }} else if (percentage > 100) {{
                            // Normaliser si > 100
                            percentage = Math.min(100, percentage / 10);
                        }}

                        // Créer la barre de progression
                        const progressContainer = document.createElement('div');
                        progressContainer.className = 'progress-bar-container';
                        const progressBar = document.createElement('div');
                        progressBar.className = 'progress-bar';
                        progressBar.style.width = percentage + '%';
                        progressContainer.appendChild(progressBar);
                        row.appendChild(progressContainer);
                    }}
                }}
            }});
        }}

        // Graphique des vulnérabilités avec animation
        const ctx = document.getElementById('securityChart').getContext('2d');
        const chartData = {{
            labels: ['Critiques', 'Moyennes', 'Mineures', 'Sécurisé'],
            datasets: [{{
                data: [{high_vulns}, {medium_vulns}, {low_vulns}, {max(0, 1000 - total_vulnerabilities)}],
                backgroundColor: [
                    '#dc3545',
                    '#ffc107',
                    '#28a745',
                    '#6c757d'
                ],
                borderWidth: 3,
                borderColor: '#fff',
                hoverOffset: 10
            }}]
        }};

        const chart = new Chart(ctx, {{
            type: 'doughnut',
            data: chartData,
            options: {{
                responsive: true,
                animation: {{
                    animateRotate: true,
                    animateScale: true,
                    duration: 2000
                }},
                plugins: {{
                    title: {{
                        display: true,
                        text: 'Répartition des Vulnérabilités',
                        font: {{
                            size: 18,
                            weight: 'bold'
                        }}
                    }},
                    legend: {{
                        position: 'bottom',
                        labels: {{
                            padding: 15,
                            font: {{
                                size: 12
                            }}
                        }}
                    }},
                    tooltip: {{
                        callbacks: {{
                            label: function(context) {{
                                const label = context.label || '';
                                const value = context.parsed || 0;
                                const total = context.dataset.data.reduce((a, b) => a + b, 0);
                                const percentage = total > 0 ? ((value / total) * 100).toFixed(1) : 0;
                                return label + ': ' + value + ' (' + percentage + '%)';
                            }}
                        }}
                    }}
                }}
            }}
        }});

        // Amélioration du bouton de rafraîchissement
        const refreshBtn = document.querySelector('.refresh-btn');
        if (refreshBtn) {{
            refreshBtn.addEventListener('click', function() {{
                this.classList.add('loading');
                this.innerHTML = '🔄 Actualisation...';
                setTimeout(() => {{
                    location.reload();
                }}, 500);
            }});
        }}

        // Actualisation automatique intelligente (vérifie les changements avant de recharger)
        let lastUpdateTime = '{timestamp}';
        setInterval(function() {{
            // Vérifier si le timestamp a changé en comparant avec le footer
            const footerElement = document.querySelector('.footer p');
            if (footerElement) {{
                const footerTimeMatch = footerElement.textContent.match(/(\\d{{4}}-\\d{{2}}-\\d{{2}}T[\\d:]+)/);
                if (footerTimeMatch && footerTimeMatch[1] !== lastUpdateTime) {{
                    lastUpdateTime = footerTimeMatch[1];
                    location.reload();
                }}
            }}
        }}, 60000); // Vérifier toutes les minutes

        // Ajouter des badges de score dynamiques
        const scoreElement = document.querySelector('.security-score');
        if (scoreElement) {{
            const score = parseInt(scoreElement.textContent.replace(/[^0-9]/g, ''));
            const badge = document.createElement('span');
            badge.className = 'score-badge';
            if (score >= 85) {{
                badge.className += ' excellent';
                badge.textContent = 'Excellent';
            }} else if (score >= 70) {{
                badge.className += ' good';
                badge.textContent = 'Bon';
            }} else {{
                badge.className += ' poor';
                badge.textContent = 'À améliorer';
            }}
            scoreElement.parentElement.appendChild(badge);
        }}
    </script>
</body>
</html>"""

        return html_template

    def _generate_command_validation_html(self, security_data: dict[str, Any]) -> str:
        """Génère le HTML pour la validation des commandes avec vraies données"""
        scan_results = security_data.get("security_checks", {}).get(
            "comprehensive_scan", {}
        )

        if not scan_results:
            return "<p>Scan de sécurité en cours...</p>"

        total_files = scan_results.get("total_files_scanned", 0)
        total_vulns = scan_results.get("vulnerabilities_found", 0)
        risk_level = scan_results.get("risk_level", "unknown")

        html = f"""
        <div class="metric-row">
            <span class="metric-label">📁 Fichiers Scannés</span>
            <span class="metric-value">{total_files:,}</span>
        </div>
        <div class="metric-row">
            <span class="metric-label">🔍 Vulnérabilités Détectées</span>
            <span class="metric-value">{total_vulns:,}</span>
        </div>
        <div class="metric-row">
            <span class="metric-label">⚠️ Niveau de Risque</span>
            <span class="metric-value risk-{risk_level}">{risk_level.upper()}</span>
        </div>
        <div class="metric-row">
            <span class="metric-label">📊 Ratio Vuln/Fichier</span>
            <span class="metric-value">{(total_vulns / max(total_files, 1) * 1000):.1f}‰</span>
        </div>
        """

        return html

    def _generate_code_analysis_html(self, security_data: dict[str, Any]) -> str:
        """Génère le HTML pour l'analyse de code avec vraies données"""
        python_stats = security_data.get("python_stats", {})
        test_coverage = security_data.get("test_coverage", {})
        doc_quality = security_data.get("documentation_quality", {})

        html = f"""
        <div class="metric-row">
            <span class="metric-label">🐍 Fichiers Python</span>
            <span class="metric-value">{python_stats.get("total_files", 0):,}</span>
        </div>
        <div class="metric-row">
            <span class="metric-label">📝 Lignes de Code</span>
            <span class="metric-value">{python_stats.get("total_lines", 0):,}</span>
        </div>
        <div class="metric-row">
            <span class="metric-label">🧪 Tests Collectés</span>
            <span class="metric-value">{test_coverage.get("total_tests", 0):,}</span>
        </div>
        <div class="metric-row">
            <span class="metric-label">📚 Documentation</span>
            <span class="metric-value">{doc_quality.get("total_docs", 0):,} fichiers</span>
        </div>
        """

        return html

    def _generate_cache_security_html(self, security_data: dict[str, Any]) -> str:
        """Génère le HTML pour la sécurité du cache avec tes vraies données"""
        cache_security = security_data.get("cache_security", {})

        if not cache_security:
            return "<p>Métriques de cache en cours de collecte...</p>"

        hits = cache_security.get("hits", 0)
        misses = cache_security.get("misses", 0)
        total_requests = cache_security.get("total_requests", 0)
        hit_rate_raw = cache_security.get("hit_rate", 0.0)
        cache_size = cache_security.get("cache_size", 0)

        # Calculer le hit_rate correctement
        # Si total_requests est disponible, calculer depuis hits/misses
        if total_requests > 0:
            calculated_hit_rate = (hits / total_requests) * 100
        elif hits + misses > 0:
            calculated_hit_rate = (hits / (hits + misses)) * 100
        else:
            calculated_hit_rate = 0.0

        # Si hit_rate_raw est fourni, vérifier s'il est déjà en pourcentage (> 1) ou décimal (<= 1)
        if hit_rate_raw > 0:
            if hit_rate_raw > 1:
                # Déjà en pourcentage (ex: 93.3)
                hit_rate_percent = min(100.0, hit_rate_raw)
            else:
                # En décimal (ex: 0.933)
                hit_rate_percent = hit_rate_raw * 100
            # Utiliser le calcul depuis hits/misses si disponible, sinon utiliser hit_rate_raw
            if total_requests > 0 or (hits + misses > 0):
                hit_rate_percent = calculated_hit_rate
        else:
            hit_rate_percent = calculated_hit_rate

        # S'assurer que le hit_rate est entre 0 et 100%
        hit_rate_percent = max(0.0, min(100.0, hit_rate_percent))

        html = f"""
        <div class="metric-row">
            <span class="metric-label">🎯 Hits</span>
            <span class="metric-value">{hits:,}</span>
        </div>
        <div class="metric-row">
            <span class="metric-label">❌ Misses</span>
            <span class="metric-value">{misses:,}</span>
        </div>
        <div class="metric-row">
            <span class="metric-label">📊 Total Requests</span>
            <span class="metric-value">{total_requests if total_requests > 0 else hits + misses:,}</span>
        </div>
        <div class="metric-row">
            <span class="metric-label">⚡ Hit Rate</span>
            <span class="metric-value">{hit_rate_percent:.1f}%</span>
        </div>
        <div class="metric-row">
            <span class="metric-label">💾 Cache Size</span>
            <span class="metric-value">{cache_size:,} bytes</span>
        </div>
        """

        return html

    def _generate_security_metrics_html(self, security_data: dict[str, Any]) -> str:
        """Génère le HTML pour les métriques de sécurité avec tes vraies données"""
        vulnerabilities = security_data.get("vulnerabilities", {})

        total_vulns = sum(vulnerabilities.values())
        high_vulns = vulnerabilities.get("high", 0)
        medium_vulns = vulnerabilities.get("medium", 0)

        html = f"""
        <div class="metric-row">
            <span class="metric-label">🛡️ Score Global</span>
            <span class="metric-value score-{security_data.get("security_score", 0)}">{security_data.get("security_score", 0)}/100</span>
        </div>
        <div class="metric-row">
            <span class="metric-label">🚨 Vulnérabilités Critiques</span>
            <span class="metric-value risk-high">{high_vulns:,}</span>
        </div>
        <div class="metric-row">
            <span class="metric-label">⚠️ Vulnérabilités Moyennes</span>
            <span class="metric-value risk-medium">{medium_vulns:,}</span>
        </div>
        <div class="metric-row">
            <span class="metric-label">📊 Total Vulnérabilités</span>
            <span class="metric-value">{total_vulns:,}</span>
        </div>
        <div class="metric-row">
            <span class="metric-label">⚡ Athalia Components</span>
            <span class="metric-value">{"✅ Disponibles" if security_data.get("athalia_available") else "❌ Non disponibles"}</span>
        </div>
        """

        return html

    def _generate_recommendations_html(self, recommendations: list[str]) -> str:
        """Génère le HTML pour les recommandations avec tes vraies données"""
        if not recommendations:
            return "<p>Aucune recommandation disponible</p>"

        html = ""
        for recommendation in recommendations:
            # Déterminer l'icône et la classe CSS basée sur le contenu
            if "CRITIQUE" in recommendation or "🚨" in recommendation:
                icon = "🚨"
                css_class = "recommendation-critical"
            elif "ATTENTION" in recommendation or "⚠️" in recommendation:
                icon = "⚠️"
                css_class = "recommendation-warning"
            elif "AMÉLIORATION" in recommendation or "🔶" in recommendation:
                icon = "🔶"
                css_class = "recommendation-improvement"
            elif "EXCELLENT" in recommendation or "✅" in recommendation:
                icon = "✅"
                css_class = "recommendation-excellent"
            else:
                icon = "💡"
                css_class = "recommendation-info"

            html += (
                f'<div class="recommendation-item {css_class}"><span'
                f' class="rec-icon">{icon}</span><span'
                f' class="rec-text">{recommendation}</span></div>'
            )

        return html

    def open_dashboard(self, dashboard_file: str | None = None):
        """Ouvre le dashboard de sécurité dans le navigateur ou actualise s'il est déjà ouvert"""
        try:
            # Éviter les ouvertures multiples trop rapides (moins de 1 seconde entre deux ouvertures)
            current_time = time.time()
            if current_time - self._last_open_time < 1.0:
                logger.debug(
                    "Ouverture du dashboard ignorée (trop récente, réutilisation de l'onglet existant)"
                )
                return

            # Générer le dashboard si non fourni
            if dashboard_file is None:
                dashboard_file = self.generate_security_dashboard()

            dashboard_path = Path(dashboard_file)
            if not dashboard_path.exists():
                logger.error(f"❌ Le fichier dashboard n'existe pas: {dashboard_path}")
                return

            # Obtenir le chemin absolu
            absolute_path = dashboard_path.resolve()

            # Encoder correctement pour file:// URL
            path_str = str(absolute_path)
            encoded_path = urllib.parse.quote(path_str, safe="/")
            file_url = f"file://{encoded_path}"

            # Utiliser webbrowser.open avec new=0 pour réutiliser l'onglet existant si possible
            # new=0 : réutilise l'onglet existant si disponible
            # new=1 : ouvre un nouvel onglet
            # new=2 : ouvre une nouvelle fenêtre
            try:
                # Essayer d'abord de réutiliser l'onglet existant
                webbrowser.open(file_url, new=0, autoraise=True)
                self._last_open_time = current_time
                logger.info(
                    f"🔄 Dashboard de sécurité ouvert/actualisé dans le navigateur: {absolute_path}"
                )
            except Exception as webbrowser_error:
                logger.warning(f"Erreur avec webbrowser.open: {webbrowser_error}")
                # Fallback: utiliser la méthode native du système
                system = platform.system()
                if system == "Darwin":  # macOS
                    # Utiliser 'open' avec -g pour ne pas amener la fenêtre au premier plan
                    # et -a pour spécifier le navigateur par défaut
                    subprocess.run(
                        ["open", "-g", str(absolute_path)], check=False
                    )  # nosec B607, B603
                    self._last_open_time = current_time
                    logger.info(
                        f"🌐 Dashboard de sécurité ouvert via 'open': {absolute_path}"
                    )
                elif system == "Windows":
                    # Windows utilise start (sans shell=True pour sécurité)
                    subprocess.run(  # nosec B607, B603
                        ["cmd", "/c", "start", "", str(absolute_path)],
                        check=False,
                    )
                    self._last_open_time = current_time
                    logger.info(
                        f"🌐 Dashboard de sécurité ouvert via 'start': {absolute_path}"
                    )
                else:
                    # Linux et autres: réessayer avec webbrowser
                    webbrowser.open(file_url, new=0)
                    self._last_open_time = current_time
                    logger.info(
                        f"🌐 Dashboard de sécurité ouvert dans le navigateur: {file_url}"
                    )
        except Exception as e:
            logger.error(f"Erreur lors de l'ouverture du dashboard: {e}")
            # Fallback final: essayer avec webbrowser.open directement
            try:
                dashboard_path = (
                    Path(dashboard_file)
                    if dashboard_file
                    else Path(self.dashboard_dir / "security_dashboard.html")
                )
                if dashboard_path.exists():
                    absolute_path = dashboard_path.resolve()
                    file_url = (
                        f"file://{urllib.parse.quote(str(absolute_path), safe='/')}"
                    )
                    webbrowser.open(file_url, new=0)
                    self._last_open_time = time.time()
                    logger.info(f"🌐 Ouverture via fallback: {file_url}")
            except Exception as fallback_error:
                logger.error(f"Erreur lors de l'ouverture fallback: {fallback_error}")
        finally:
            # Nettoyage mémoire après ouverture du dashboard
            force_memory_cleanup()


# Fonction principale pour exécution directe
def main():
    """Fonction principale pour exécution directe du dashboard de sécurité"""
    import argparse

    parser = argparse.ArgumentParser(description="Dashboard de sécurité Athalia")
    parser.add_argument(
        "--project-path", default=None, help="Chemin du projet à analyser"
    )
    parser.add_argument(
        "--open", action="store_true", help="Ouvrir le dashboard dans le navigateur"
    )
    parser.add_argument(
        "--generate-only",
        action="store_true",
        help="Générer le dashboard sans l'ouvrir",
    )

    args = parser.parse_args()

    # Résoudre automatiquement le chemin du projet si non spécifié
    if args.project_path is None:
        # Chercher le répertoire racine du projet en remontant depuis le script
        script_file = Path(__file__).resolve()
        script_dir = script_file.parent.parent

        # Vérifier si on est dans le projet (présence de pyproject.toml ou README.md)
        project_root = script_dir
        if (project_root / "pyproject.toml").exists() or (
            project_root / "README.md"
        ).exists():
            args.project_path = str(project_root)
        else:
            # Remonter jusqu'à trouver le répertoire racine du projet
            # Chercher pyproject.toml ou README.md en remontant l'arborescence
            current = script_dir
            found = False
            for _ in range(10):  # Limiter à 10 niveaux pour éviter les boucles infinies
                if (current / "pyproject.toml").exists() or (
                    current / "README.md"
                ).exists():
                    args.project_path = str(current)
                    found = True
                    break
                parent = current.parent
                if parent == current:  # On est à la racine du système
                    break
                current = parent

            if not found:
                # Dernier recours: utiliser le répertoire du script comme projet
                # C'est mieux qu'un répertoire temporaire
                args.project_path = str(script_dir)
                logger.warning(
                    f"Impossible de trouver le répertoire racine du projet, "
                    f"utilisation de: {args.project_path}"
                )

    # Convertir en Path absolu pour éviter les problèmes de chemins relatifs
    if args.project_path is None:
        raise ValueError("Le chemin du projet n'a pas pu être déterminé")
    project_path = Path(args.project_path).resolve()

    # Vérifier que le chemin n'est pas un répertoire temporaire
    # Note: Utilisation de tempfile.gettempdir() serait préférable mais ici
    # on détecte les chemins temporaires pour éviter les scans sur /tmp
    project_str = str(project_path)
    if (
        "/tmp/" in project_str  # nosec B108
        or "/var/folders/" in project_str  # nosec B108
        or "tmp" in project_str.lower()
    ):
        # Si c'est un répertoire temporaire, chercher le vrai projet
        script_file = Path(__file__).resolve()
        script_dir = script_file.parent.parent
        if (script_dir / "pyproject.toml").exists() or (
            script_dir / "README.md"
        ).exists():
            project_path = script_dir.resolve()
            logger.warning(
                f"Chemin temporaire détecté, utilisation du répertoire du script: {project_path}"
            )

    # Initialisation du dashboard
    security_dashboard = SecurityDashboard(str(project_path))

    if args.generate_only:
        dashboard_file = security_dashboard.generate_security_dashboard()
        print(f"📊 Dashboard de sécurité généré: {dashboard_file}")
    elif args.open:
        # Ouvrir le dashboard existant ou en générer un nouveau
        dashboard_file_path = (
            security_dashboard.dashboard_dir / "security_dashboard.html"
        )
        if dashboard_file_path.exists():
            security_dashboard.open_dashboard(str(dashboard_file_path))
        else:
            security_dashboard.open_dashboard()
    else:
        # Par défaut, générer et ouvrir
        print("🚀 Génération du dashboard de sécurité...")
        dashboard_file = security_dashboard.generate_security_dashboard()
        print(f"📊 Dashboard généré: {dashboard_file}")

        print("🌐 Ouverture dans le navigateur...")
        # Passer le fichier déjà généré pour éviter de le régénérer
        security_dashboard.open_dashboard(dashboard_file)


if __name__ == "__main__":
    main()
