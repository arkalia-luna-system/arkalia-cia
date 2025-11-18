"""
Tests unitaires pour le module auto_documenter
"""

import tempfile
from pathlib import Path

from arkalia_cia_python_backend.auto_documenter import AutoDocumenter


class TestAutoDocumenter:
    """Tests pour AutoDocumenter"""

    def setup_method(self):
        """Configuration avant chaque test"""
        self.temp_dir = tempfile.mkdtemp()
        self.documenter = AutoDocumenter(project_path=self.temp_dir)

    def teardown_method(self):
        """Nettoyage après chaque test"""
        import shutil

        if Path(self.temp_dir).exists():
            shutil.rmtree(self.temp_dir)

    def test_initialization(self):
        """Test d'initialisation"""
        assert self.documenter is not None
        assert self.documenter.project_path == Path(self.temp_dir)
        assert self.documenter.lang == "en"

    def test_load_documentation_config_default(self):
        """Test de chargement de la configuration par défaut"""
        config = self.documenter.load_documentation_config()
        assert config is not None
        assert "output_formats" in config
        assert "include_private" in config
        assert "generate_api_docs" in config

    def test_load_documentation_config_with_file(self):
        """Test de chargement de configuration depuis un fichier"""
        import yaml

        config_file = Path(self.temp_dir) / "doc_config.yaml"
        config_data = {"output_formats": ["html"], "include_private": True}
        with open(config_file, "w", encoding="utf-8") as f:
            yaml.dump(config_data, f)

        config = self.documenter.load_documentation_config(str(config_file))
        assert config["include_private"] is True

    def test_is_excluded(self):
        """Test de vérification d'exclusion"""
        excluded_path = Path(self.temp_dir) / "__pycache__" / "test.pyc"
        excluded_path.parent.mkdir(exist_ok=True)
        excluded_path.touch()

        assert self.documenter._is_excluded(excluded_path) is True

        normal_path = Path(self.temp_dir) / "test.py"
        normal_path.touch()
        assert self.documenter._is_excluded(normal_path) is False

    def test_scan_project_structure(self):
        """Test de scan de structure de projet"""
        # Créer quelques fichiers de test
        (Path(self.temp_dir) / "test.py").touch()
        (Path(self.temp_dir) / "test_test.py").touch()
        (Path(self.temp_dir) / "README.md").touch()
        (Path(self.temp_dir) / "config.yaml").touch()

        structure = self.documenter.scan_project_structure()
        assert "python_files" in structure
        assert "test_files" in structure
        assert "documentation_files" in structure
        assert "config_files" in structure

    def test_extract_docstrings(self):
        """Test d'extraction de docstrings"""
        test_file = Path(self.temp_dir) / "test_module.py"
        test_file.write_text(
            '''"""
Module docstring
"""

def test_function():
    """Function docstring"""
    pass

class TestClass:
    """Class docstring"""
    pass
'''
        )

        docstrings = self.documenter.extract_docstrings(str(test_file))
        assert len(docstrings) >= 3  # Module, function, class

    def test_generate_readme(self):
        """Test de génération de README"""
        readme = self.documenter.generate_readme()
        assert readme is not None
        assert isinstance(readme, str)
        assert "#" in readme  # Contient un titre

    def test_generate_api_documentation(self):
        """Test de génération de documentation API"""
        test_file = Path(self.temp_dir) / "test_module.py"
        test_file.write_text(
            '''"""
Module docstring
"""

def test_function():
    """Function docstring"""
    pass
'''
        )

        api_docs = self.documenter.generate_api_documentation()
        assert "functions" in api_docs
        assert "classes" in api_docs
        assert "modules" in api_docs

    def test_analyze_python_files(self):
        """Test d'analyse de fichiers Python"""
        test_file = Path(self.temp_dir) / "test_module.py"
        test_file.write_text(
            '''"""
Module docstring
"""

def test_function():
    """Function docstring"""
    pass

class TestClass:
    """Class docstring"""
    def method(self):
        """Method docstring"""
        pass
'''
        )

        analysis = self.documenter.analyze_python_files()
        assert "total_files" in analysis
        assert "total_functions" in analysis
        assert "total_classes" in analysis

    def test_calculate_documentation_coverage(self):
        """Test de calcul de couverture de documentation"""
        test_file = Path(self.temp_dir) / "test_module.py"
        test_file.write_text(
            '''"""
Module docstring
"""

def documented_function():
    """Function docstring"""
    pass

def undocumented_function():
    pass
'''
        )

        coverage = self.documenter.calculate_documentation_coverage()
        assert "coverage_percentage" in coverage
        assert "total_functions" in coverage
        assert "documented_functions" in coverage

    def test_validate_documentation(self):
        """Test de validation de documentation"""
        validation = self.documenter.validate_documentation()
        assert "is_valid" in validation
        assert "issues" in validation
        assert "warnings" in validation

    def test_generate_documentation_report(self):
        """Test de génération de rapport de documentation"""
        report = self.documenter.generate_documentation_report()
        assert "summary" in report
        assert "detailed_results" in report
        assert "recommendations" in report

    def test_generate_installation_guide(self):
        """Test de génération de guide d'installation"""
        guide = self.documenter.generate_installation_guide()
        assert guide is not None
        assert isinstance(guide, str)
        assert "Installation" in guide

    def test_generate_usage_examples(self):
        """Test de génération d'exemples d'utilisation"""
        examples = self.documenter.generate_usage_examples()
        assert examples is not None
        assert isinstance(examples, str)

    def test_generate_changelog(self):
        """Test de génération de changelog"""
        changelog = self.documenter.generate_changelog()
        assert changelog is not None
        assert isinstance(changelog, str)
        assert "Changelog" in changelog

    def test_generate_contributing_guide(self):
        """Test de génération de guide de contribution"""
        guide = self.documenter.generate_contributing_guide()
        assert guide is not None
        assert isinstance(guide, str)
        assert "Contribution" in guide

    def test_generate_license_file(self):
        """Test de génération de fichier de licence"""
        license_content = self.documenter.generate_license_file("MIT")
        assert license_content is not None
        assert isinstance(license_content, str)
        assert "MIT" in license_content

    def test_generate_documentation_index(self):
        """Test de génération d'index de documentation"""
        (Path(self.temp_dir) / "README.md").touch()
        index = self.documenter.generate_documentation_index()
        assert index is not None
        assert isinstance(index, str)

    def test_perform_full_documentation(self):
        """Test de documentation complète"""
        result = self.documenter.perform_full_documentation()
        assert "summary" in result
        assert "coverage" in result
        assert "files_generated" in result

    def test_generate_function_documentation(self):
        """Test de génération de documentation de fonction"""
        function_info = {
            "name": "test_function",
            "docstring": "Test function",
            "parameters": ["param1", "param2"],
            "return_type": "str",
        }
        doc = self.documenter.generate_function_documentation(function_info)
        assert "test_function" in doc
        assert "param1" in doc

    def test_generate_class_documentation(self):
        """Test de génération de documentation de classe"""
        class_info = {
            "name": "TestClass",
            "docstring": "Test class",
            "methods": [
                {"name": "method1", "docstring": "Method 1"},
                {"name": "method2", "docstring": "Method 2"},
            ],
        }
        doc = self.documenter.generate_class_documentation(class_info)
        assert "TestClass" in doc
        assert "method1" in doc

    def test_save_and_load_documentation_history(self):
        """Test de sauvegarde et chargement de l'historique"""
        history_path = Path(self.temp_dir) / "history.json"
        result = self.documenter.save_documentation_history(str(history_path))
        assert result is True
        assert history_path.exists()

        history = self.documenter.load_documentation_history(str(history_path))
        assert isinstance(history, list)

    def test_document_project(self):
        """Test de documentation d'un projet complet"""
        result = self.documenter.document_project(self.temp_dir)
        assert "readme" in result
        assert "api_docs" in result
        assert "setup_guide" in result

    def test_load_translations(self):
        """Test de chargement des traductions"""
        translations_fr = self.documenter._load_translations("fr")
        assert "readme_title" in translations_fr

        translations_en = self.documenter._load_translations("en")
        assert "readme_title" in translations_en

        translations_default = self.documenter._load_translations("unknown")
        assert "readme_title" in translations_default
