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

        # Libérer la mémoire avant nettoyage
        if hasattr(self, "documenter"):
            # Nettoyer les données du documenter
            if hasattr(self.documenter, "doc_history"):
                self.documenter.doc_history.clear()
            if hasattr(self.documenter, "project_info"):
                self.documenter.project_info.clear()
            del self.documenter
        # Le GC Python gère automatiquement, pas besoin de forcer systématiquement

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
        # Créer quelques fichiers de test (limité pour éviter consommation mémoire)
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
        # Limiter à un seul fichier pour réduire consommation mémoire
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
        # Limiter à un fichier minimal
        test_file = Path(self.temp_dir) / "test.py"
        test_file.write_text("def test(): pass")

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
        # Créer seulement un fichier minimal pour limiter la consommation mémoire
        test_file = Path(self.temp_dir) / "test.py"
        test_file.write_text("def test(): pass")

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
        # Limiter à un seul fichier pour réduire consommation mémoire
        test_file = Path(self.temp_dir) / "test.py"
        test_file.write_text("def test(): pass")

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

    def test_generate_documentation_function(self):
        """Test de la fonction utilitaire generate_documentation"""
        from arkalia_cia_python_backend.auto_documenter import generate_documentation

        result = generate_documentation(self.temp_dir)
        assert "summary" in result or "coverage" in result

    def test_analyze_documentation_needs_function(self):
        """Test de la fonction utilitaire analyze_documentation_needs"""
        from arkalia_cia_python_backend.auto_documenter import (
            analyze_documentation_needs,
        )

        result = analyze_documentation_needs(self.temp_dir)
        assert "coverage_percentage" in result

    def test_generate_readme_private(self):
        """Test de génération README privée"""
        self.documenter.project_info = {
            "name": "test_project",
            "description": "Test description",
            "license": "MIT",
        }
        readme = self.documenter._generate_readme()
        assert "test_project" in readme
        assert "Test description" in readme

    def test_generate_api_documentation_private(self):
        """Test de génération API documentation privée"""
        self.documenter.project_info = {
            "classes": [
                {
                    "name": "TestClass",
                    "docstring": "Test class",
                    "methods": ["method1", "method2"],
                }
            ],
            "functions": [
                {
                    "name": "test_function",
                    "docstring": "Test function",
                    "args": ["arg1"],
                }
            ],
        }
        api_docs = self.documenter._generate_api_documentation()
        assert "TestClass" in api_docs
        assert "test_function" in api_docs

    def test_generate_setup_guide_private(self):
        """Test de génération setup guide privée"""
        self.documenter.project_info = {"name": "test_project"}
        guide = self.documenter._generate_setup_guide()
        assert "test_project" in guide
        assert "Installation" in guide

    def test_generate_usage_guide_private(self):
        """Test de génération usage guide privée"""
        self.documenter.project_info = {"name": "test_project"}
        guide = self.documenter._generate_usage_guide()
        assert "test_project" in guide
        assert "Utilisation" in guide or "Usage" in guide

    def test_get_created_files(self):
        """Test de récupération des fichiers créés"""
        files = self.documenter._get_created_files()
        assert isinstance(files, list)
        assert len(files) > 0

    def test_generate_api_documentation_with_string_classes(self):
        """Test de génération API avec classes en string"""
        self.documenter.project_info = {
            "classes": ["Class1", "Class2"],
            "functions": ["func1"],
        }
        api_docs = self.documenter._generate_api_documentation()
        assert isinstance(api_docs, str)

    def test_load_documentation_config_with_invalid_file(self):
        """Test de chargement config avec fichier invalide"""
        invalid_path = Path(self.temp_dir) / "nonexistent.yaml"
        config = self.documenter.load_documentation_config(str(invalid_path))
        assert config is not None
        assert "output_formats" in config

    def test_scan_project_structure_with_excluded_files(self):
        """Test de scan avec fichiers exclus"""
        (Path(self.temp_dir) / "__pycache__" / "test.pyc").parent.mkdir(exist_ok=True)
        (Path(self.temp_dir) / "__pycache__" / "test.pyc").touch()
        structure = self.documenter.scan_project_structure()
        assert "__pycache__" not in str(structure)

    def test_extract_docstrings_with_invalid_file(self):
        """Test d'extraction docstrings avec fichier invalide"""
        invalid_file = Path(self.temp_dir) / "invalid.py"
        invalid_file.write_text("invalid python code !!!")
        docstrings = self.documenter.extract_docstrings(str(invalid_file))
        # Devrait gérer l'erreur gracieusement
        assert isinstance(docstrings, list)

    def test_validate_documentation_with_issues(self):
        """Test de validation avec problèmes"""
        # Créer un fichier avec docstring trop courte
        test_file = Path(self.temp_dir) / "short_doc.py"
        test_file.write_text('def test():\n    """x"""\n    pass')
        validation = self.documenter.validate_documentation()
        assert "is_valid" in validation

    def test_generate_documentation_report_with_low_coverage(self):
        """Test de génération rapport avec faible couverture"""
        # Créer un projet avec peu de documentation
        test_file = Path(self.temp_dir) / "undocumented.py"
        test_file.write_text("def test():\n    pass\nclass Test:\n    pass")
        report = self.documenter.generate_documentation_report()
        assert "recommendations" in report

    def test_perform_full_documentation_with_errors(self):
        """Test de documentation complète avec gestion d'erreurs"""
        # Tester avec un chemin invalide
        result = self.documenter.perform_full_documentation()
        assert "errors" in result or "coverage" in result

    def test_document_project_with_classes_and_functions(self):
        """Test de documentation projet avec classes et fonctions"""
        self.documenter.project_info = {
            "name": "test",
            "classes": [{"name": "Class1", "methods": []}],
            "functions": [{"name": "func1"}],
        }
        result = self.documenter.document_project(self.temp_dir)
        assert "readme" in result

    def test_load_documentation_config_with_valid_yaml(self):
        """Test de chargement config avec YAML valide"""
        import yaml

        config_file = Path(self.temp_dir) / "config.yaml"
        config_data = {"output_formats": ["html"], "include_private": True}
        with open(config_file, "w", encoding="utf-8") as f:
            yaml.dump(config_data, f)
        config = self.documenter.load_documentation_config(str(config_file))
        assert config["include_private"] is True

    def test_analyze_python_files_with_parse_error(self):
        """Test d'analyse avec erreur de parsing"""
        # Créer un fichier Python invalide
        invalid_file = Path(self.temp_dir) / "invalid_syntax.py"
        invalid_file.write_text("def test(\n    # Syntax error")
        analysis = self.documenter.analyze_python_files()
        # Devrait gérer l'erreur gracieusement
        assert "total_files" in analysis

    def test_generate_documentation_report_with_validation_issues(self):
        """Test de génération rapport avec problèmes de validation"""
        # Créer un projet sans README
        test_file = Path(self.temp_dir) / "test.py"
        test_file.write_text("def test(): pass")
        report = self.documenter.generate_documentation_report()
        assert "recommendations" in report

    def test_generate_documentation_report_with_few_docs(self):
        """Test de génération rapport avec peu de docs"""
        # Créer un projet avec peu de fichiers de documentation
        test_file = Path(self.temp_dir) / "test.py"
        test_file.write_text("def test(): pass")
        report = self.documenter.generate_documentation_report()
        assert isinstance(report, dict)
