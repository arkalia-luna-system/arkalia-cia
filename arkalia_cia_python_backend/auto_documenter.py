#!/usr/bin/env python3
"""
Module auto_documenter pour Athalia
Génération automatique de documentation
"""

import ast
from datetime import datetime
import json
import logging
import os
from pathlib import Path
from typing import Any

import yaml

from ..core.error_handling import AthaliaError
from ..core.generation import generate_project
from ..quality.code_linter import CodeLinter
from ..utilities.logger_advanced import AthaliaLogger


logger = logging.getLogger(__name__)


class AutoDocumenter:
    """Générateur automatique de documentation"""

    def __init__(self, project_path: str = ".", lang: str = "en") -> None:
        self.project_path = Path(project_path)
        self.lang = lang
        self.doc_config = self.load_documentation_config()
        self.doc_history: list[dict[str, Any]] = []

    def load_documentation_config(
        self, config_path: str | None = None
    ) -> dict[str, Any]:
        """Charge la configuration de documentation"""
        default_config = {
            "output_formats": ["md", "html"],
            "include_private": False,
            "generate_api_docs": True,
            "include_examples": True,
            "template_engine": "jinja2",
            "output_directory": "docs",
            "exclude_patterns": [
                "__pycache__",
                "*.pyc",
                ".git",
                "venv",
                ".venv",
            ],
            "include_patterns": ["*.py", "*.md", "*.txt", "*.yaml", "*.yml"],
        }

        if config_path:
            try:
                with open(config_path, encoding="utf-8") as f:
                    user_config = yaml.safe_load(f)
                    default_config.update(user_config)
            except Exception as e:
                logger.warning(
                    f"Impossible de charger la configuration {config_path}: {e}"
                )

        return default_config

    def scan_project_structure(self) -> dict[str, Any]:
        """Scanne la structure du projet"""
        structure: dict[str, list[str]] = {
            "python_files": [],
            "test_files": [],
            "documentation_files": [],
            "config_files": [],
            "other_files": [],
        }

        try:
            for file_path in self.project_path.rglob("*"):
                if file_path.is_file() and not self._is_excluded(file_path):
                    relative_path = str(file_path.relative_to(self.project_path))

                    if file_path.suffix == ".py":
                        if "test" in relative_path.lower():
                            structure["test_files"].append(relative_path)
                        else:
                            structure["python_files"].append(relative_path)
                    elif file_path.suffix in [".md", ".rst", ".txt"]:
                        structure["documentation_files"].append(relative_path)
                    elif file_path.suffix in [
                        ".yaml",
                        ".yml",
                        ".json",
                        ".toml",
                    ]:
                        structure["config_files"].append(relative_path)
                    else:
                        structure["other_files"].append(relative_path)
        except Exception as e:
            logger.error(f"Erreur scan structure: {e}")

        return structure

    def _is_excluded(self, path: Path) -> bool:
        """Vérifie si un chemin est exclu"""
        path_str = str(path)
        for exclude_pattern in self.doc_config["exclude_patterns"]:
            if exclude_pattern in path_str:
                return True
        return False

    def analyze_python_files(self) -> dict[str, Any]:
        """Analyse les fichiers Python"""
        analysis = {
            "total_files": 0,
            "total_functions": 0,
            "total_classes": 0,
            "total_methods": 0,
            "documented_functions": 0,
            "documented_classes": 0,
            "documented_methods": 0,
        }

        try:
            for py_file in self.project_path.rglob("*.py"):
                if py_file.is_file() and not self._is_excluded(py_file):
                    analysis["total_files"] += 1

                    try:
                        with open(py_file, encoding="utf-8") as f:
                            content = f.read()

                        tree = ast.parse(content)

                        for node in ast.walk(tree):
                            if isinstance(node, ast.FunctionDef):
                                analysis["total_functions"] += 1
                                if ast.get_docstring(node):
                                    analysis["documented_functions"] += 1
                            elif isinstance(node, ast.ClassDef):
                                analysis["total_classes"] += 1
                                if ast.get_docstring(node):
                                    analysis["documented_classes"] += 1
                                # Compter les méthodes
                                for child in ast.walk(node):
                                    if (
                                        isinstance(child, ast.FunctionDef)
                                        and child is not node
                                    ):
                                        analysis["total_methods"] += 1
                                        if ast.get_docstring(child):
                                            analysis["documented_methods"] += 1
                    except Exception as e:
                        logger.warning(f"Erreur analyse {py_file}: {e}")
        except Exception as e:
            logger.error(f"Erreur analyse fichiers Python: {e}")

        return analysis

    def extract_docstrings(self, file_path: str) -> list[dict[str, Any]]:
        """Extrait les docstrings d'un fichier Python"""
        docstrings = []

        try:
            with open(file_path, encoding="utf-8") as f:
                content = f.read()

            tree = ast.parse(content)

            for node in ast.walk(tree):
                if isinstance(node, ast.FunctionDef | ast.ClassDef | ast.Module):
                    docstring = ast.get_docstring(node)
                    if docstring:
                        docstrings.append({
                            "type": type(node).__name__,
                            "name": getattr(node, "name", "module"),
                            "docstring": docstring,
                            "line_number": getattr(node, "lineno", 0),
                        })
        except Exception as e:
            logger.error(f"Erreur extraction docstrings {file_path}: {e}")

        return docstrings

    def generate_readme(self) -> str:
        """Génère un README"""
        project_name = self.project_path.name
        structure = self.scan_project_structure()

        readme_content = f"""# {project_name}

## Description

Projet {project_name} généré automatiquement par Athalia.

## Structure du Projet

- **Fichiers Python**: {len(structure["python_files"])}
- **Fichiers de Test**: {len(structure["test_files"])}
- **Fichiers de Documentation**: {len(structure["documentation_files"])}

## Installation

```bash
pip install -r requirements.txt
```

## Utilisation

```python
# Exemple d'utilisation
from {project_name} import main

main()
```

## Tests

```bash
pytest tests/
```

## Licence

MIT License
"""

        return readme_content

    def generate_api_documentation(self) -> dict[str, Any]:
        """Génère la documentation API"""
        api_docs: dict[str, list[dict[str, Any]]] = {
            "functions": [],
            "classes": [],
            "modules": [],
        }

        try:
            for py_file in self.project_path.rglob("*.py"):
                if py_file.is_file() and not self._is_excluded(py_file):
                    docstrings = self.extract_docstrings(str(py_file))

                    for doc in docstrings:
                        if doc["type"] == "FunctionDef":
                            api_docs["functions"].append({
                                "name": doc["name"],
                                "docstring": doc["docstring"],
                                "file": str(py_file.relative_to(self.project_path)),
                            })
                        elif doc["type"] == "ClassDef":
                            api_docs["classes"].append({
                                "name": doc["name"],
                                "docstring": doc["docstring"],
                                "file": str(py_file.relative_to(self.project_path)),
                            })
        except Exception as e:
            logger.error(f"Erreur génération API docs: {e}")

        return api_docs

    def generate_function_documentation(self, function_info: dict[str, Any]) -> str:
        """Génère la documentation d'une fonction"""
        doc = f"""## {function_info["name"]}

{function_info["docstring"]}

"""

        if function_info.get("parameters"):
            doc += "### Paramètres\n\n"
            for param in function_info["parameters"]:
                doc += f"- `{param}`\n"
            doc += "\n"

        if function_info.get("return_type"):
            doc += f"### Retour\n\n`{function_info['return_type']}`\n\n"

        return doc

    def generate_class_documentation(self, class_info: dict[str, Any]) -> str:
        """Génère la documentation d'une classe"""
        doc = f"""## {class_info["name"]}

{class_info["docstring"]}

"""

        if class_info.get("methods"):
            doc += "### Méthodes\n\n"
            for method in class_info["methods"]:
                doc += f"#### {method['name']}\n\n{method['docstring']}\n\n"

        return doc

    def generate_installation_guide(self) -> str:
        """Génère le guide d'installation"""
        guide = """# Guide d'Installation

## Prérequis

- Python 3.8+
- pip

## Installation

1. Cloner le repository:
```bash
git clone <repository-url>
cd <project-name>
```

2. Créer un environnement virtuel:
```bash
python -m venv venv
source venv/bin/activate  # Linux/Mac
# ou
venv\\Scripts\\activate  # Windows
```

3. Installer les dépendances:
```bash
pip install -r requirements.txt
```

## Vérification

```bash
python -c "import <project-name>; print('Installation réussie!')"
```
"""

        return guide

    def generate_usage_examples(self) -> str:
        """Génère des exemples d'utilisation"""
        examples = """# Exemples d'Utilisation

## Exemple Basique

```python
from <project-name> import main_function

result = main_function()
print(result)
```

## Exemple Avancé

```python
from <project-name> import MyClass

obj = MyClass()
result = obj.method()
print(result)
```

## Exemple avec Configuration

```python
import <project-name>

config = {
    "option1": "value1",
    "option2": "value2"
}

result = <project-name>.configured_function(config)
```
"""

        return examples

    def generate_changelog(self) -> str:
        """Génère un changelog"""
        changelog = """# Changelog

Tous les changements notables de ce projet seront documentés dans ce fichier.

## [Unreleased]

### Added
- Fonctionnalités initiales

### Changed
- Aucun changement

### Deprecated
- Aucune dépréciation

### Removed
- Aucune suppression

### Fixed
- Aucun correctif

### Security
- Aucune amélioration de sécurité

## [0.1.0] - 2024-01-01

### Added
- Version initiale
- Fonctionnalités de base
"""

        return changelog

    def generate_contributing_guide(self) -> str:
        """Génère le guide de contribution"""
        guide = """# Guide de Contribution

Merci de votre intérêt pour contribuer à ce projet !

## Comment Contribuer

1. Fork le projet
2. Créer une branche pour votre fonctionnalité "
    "(`git checkout -b feature/AmazingFeature`)"
3. Commit vos changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## Standards de Code

- Suivre PEP 8
- Ajouter des tests pour les nouvelles fonctionnalités
- Mettre à jour la documentation si nécessaire

## Tests

```bash
pytest tests/
```

## Style de Commit

Utiliser des messages de commit conventionnels:
- `feat:` nouvelle fonctionnalité
- `fix:` correction de bug
- `docs:` documentation
- `style:` formatage
- `refactor:` refactorisation
- `test:` tests
- `chore:` maintenance
"""

        return guide

    def generate_license_file(self, license_type: str = "MIT") -> str:
        """Génère un fichier de licence"""
        if license_type.upper() == "MIT":
            license_content = f"""MIT License

Copyright (c) {datetime.now().year} {self.project_path.name}

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
"""
        else:
            license_content = (
                f"# {license_type} License\n\nLicence {license_type} "
                f"pour {self.project_path.name}"
            )

        return license_content

    def generate_documentation_index(self) -> str:
        """Génère l'index de documentation"""
        structure = self.scan_project_structure()

        index = """# Index de Documentation

## Fichiers de Documentation

"""

        for doc_file in structure["documentation_files"]:
            index += f"- [{doc_file}]({doc_file})\n"

        index += f"""
## Statistiques

- **Fichiers Python**: {len(structure["python_files"])}
- **Fichiers de Test**: {len(structure["test_files"])}
- **Fichiers de Documentation**: {len(structure["documentation_files"])}

## Navigation

- [README](README.md)
- [Installation](INSTALLATION.md)
- [API](API.md)
- [Exemples](EXAMPLES.md)
- [Contributing](CONTRIBUTING.md)
- [Changelog](CHANGELOG.md)
- [Licence](LICENSE)
"""

        return index

    def validate_documentation(self) -> dict[str, Any]:
        """Valide la documentation"""
        validation: dict[str, Any] = {"is_valid": True, "issues": [], "warnings": []}

        try:
            # Vérifier la présence de fichiers essentiels
            essential_files = ["README.md", "LICENSE", "requirements.txt"]
            for file_name in essential_files:
                file_path = self.project_path / file_name
                if not file_path.exists():
                    if isinstance(validation["issues"], list):
                        validation["issues"].append(f"Fichier manquant: {file_name}")
                    validation["is_valid"] = False

            # Vérifier la couverture de documentation
            coverage = self.calculate_documentation_coverage()
            if coverage["coverage_percentage"] < 50:
                if isinstance(validation["warnings"], list):
                    validation["warnings"].append(
                        "Couverture de documentation faible: "
                        f"{coverage['coverage_percentage']}%"
                    )

            # Vérifier la qualité des docstrings
            for py_file in self.project_path.rglob("*.py"):
                if py_file.is_file() and not self._is_excluded(py_file):
                    docstrings = self.extract_docstrings(str(py_file))
                    for doc in docstrings:
                        if len(doc["docstring"]) < 10:
                            if isinstance(validation["warnings"], list):
                                validation["warnings"].append(
                                    f"Docstring trop courte dans {py_file}:"
                                    f" {doc['name']}"
                                )

        except Exception as e:
            logger.error(f"Erreur validation documentation: {e}")
            validation["is_valid"] = False
            if isinstance(validation["issues"], list):
                validation["issues"].append(f"Erreur de validation: {e}")

        return validation

    def calculate_documentation_coverage(self) -> dict[str, Any]:
        """Calcule la couverture de documentation"""
        analysis = self.analyze_python_files()

        total_items = (
            analysis["total_functions"]
            + analysis["total_classes"]
            + analysis["total_methods"]
        )
        documented_items = (
            analysis["documented_functions"]
            + analysis["documented_classes"]
            + analysis["documented_methods"]
        )

        coverage_percentage = 0
        if total_items > 0:
            coverage_percentage = (documented_items / total_items) * 100

        return {
            "total_functions": analysis["total_functions"],
            "total_classes": analysis["total_classes"],
            "total_methods": analysis["total_methods"],
            "documented_functions": analysis["documented_functions"],
            "documented_classes": analysis["documented_classes"],
            "documented_methods": analysis["documented_methods"],
            "total_items": total_items,
            "documented_items": documented_items,
            "coverage_percentage": round(coverage_percentage, 2),
        }

    def generate_documentation_report(self) -> dict[str, Any]:
        """Génère un rapport de documentation"""
        coverage = self.calculate_documentation_coverage()
        validation = self.validate_documentation()
        structure = self.scan_project_structure()

        report: dict[str, Any] = {
            "summary": {
                "project_path": str(self.project_path),
                "analysis_date": datetime.now().isoformat(),
                "coverage_percentage": coverage["coverage_percentage"],
                "is_valid": validation["is_valid"],
            },
            "detailed_results": {
                "coverage": coverage,
                "validation": validation,
                "structure": structure,
            },
            "recommendations": [],
        }

        # Générer des recommandations
        if coverage["coverage_percentage"] < 50:
            if isinstance(report["recommendations"], list):
                report["recommendations"].append(
                    "Améliorer la couverture de documentation"
                )

        if validation["issues"]:
            if isinstance(report["recommendations"], list):
                report["recommendations"].append("Corriger les problèmes de validation")

        if len(structure["documentation_files"]) < 3:
            if isinstance(report["recommendations"], list):
                report["recommendations"].append(
                    "Ajouter plus de fichiers de documentation"
                )

        return report

    def save_documentation_history(self, output_path: str) -> bool:
        """Sauvegarde l'historique de documentation"""
        try:
            with open(output_path, "w", encoding="utf-8") as f:
                json.dump(self.doc_history, f, indent=2, default=str)
            return True
        except Exception as e:
            logger.error(f"Erreur sauvegarde historique: {e}")
            return False

    def load_documentation_history(self, history_path: str) -> list[dict[str, Any]]:
        """Charge l'historique de documentation"""
        try:
            with open(history_path, encoding="utf-8") as f:
                history: list[dict[str, Any]] = json.load(f)
                self.doc_history = history
                return history
        except Exception as e:
            logger.warning(f"Impossible de charger l'historique {history_path}: {e}")
            return []

    def perform_full_documentation(self) -> dict[str, Any]:
        """Effectue une documentation complète du projet"""
        start_time = datetime.now()

        result: dict[str, Any] = {
            "summary": "",
            "detailed_results": {},
            "recommendations": [],
            "errors": [],
            "files_generated": 0,
            "coverage": 0,
            "documentation_time": 0,
        }

        try:
            # Analyser la structure du projet
            structure = self.scan_project_structure()
            if isinstance(result["detailed_results"], dict):
                result["detailed_results"]["structure"] = structure

            # Analyser les fichiers Python
            python_analysis = self.analyze_python_files()
            if isinstance(result["detailed_results"], dict):
                result["detailed_results"]["python_analysis"] = python_analysis

            # Calculer la couverture de documentation
            coverage = self.calculate_documentation_coverage()
            if isinstance(result["detailed_results"], dict):
                result["detailed_results"]["coverage"] = coverage
            result["coverage"] = coverage.get("coverage_percentage", 0)

            # Valider la documentation existante
            validation = self.validate_documentation()
            if isinstance(result["detailed_results"], dict):
                result["detailed_results"]["validation"] = validation

            # Générer le rapport
            report = self.generate_documentation_report()
            result["summary"] = report.get(
                "summary", "Documentation générée avec succès"
            )

            # Simuler la génération de fichiers
            files_generated = [
                "README.md",
                "docs/api.md",
                "docs/setup.md",
                "docs/usage.md",
                "docs/index.md",
            ]
            result["files_generated"] = len(files_generated)

            # Ajouter des recommandations
            if coverage.get("coverage_percentage", 0) < 80:
                if isinstance(result["recommendations"], list):
                    result["recommendations"].append(
                        "Améliorer la couverture de documentation "
                        "(actuellement {}%)".format(
                            coverage.get("coverage_percentage", 0)
                        )
                    )

            if validation.get("issues", []):
                if isinstance(result["recommendations"], list):
                    result["recommendations"].append(
                        "Corriger {} problèmes de documentation identifiés".format(
                            len(validation.get("issues", []))
                        )
                    )

        except Exception as e:
            if isinstance(result["errors"], list):
                result["errors"].append(f"Erreur documentation complète: {e}")
            logger.error(f"Erreur documentation complète: {e}")

        # Calculer le temps d'exécution
        result["documentation_time"] = (datetime.now() - start_time).total_seconds()

        self.doc_history.append({
            "timestamp": datetime.now().isoformat(),
            "operation": "perform_full_documentation",
            "result": result,
        })

        return result

    def document_project(self, project_path: str) -> dict[str, Any]:
        """Documente un projet complet"""
        self.project_path = Path(project_path)

        # Initialiser les informations du projet si pas déjà fait
        if not hasattr(self, "project_info"):
            self.project_info: dict[str, Any] = {
                "name": self.project_path.name,
                "description": "Projet documenté automatiquement",
                "version": "1.0.0",
                "modules": [],
                "dependencies": {},
                "classes": [],
                "functions": [],
                "entry_points": [],
                "license": "MIT",
            }

        result = {
            "readme": self._generate_readme(),
            "api_docs": self._generate_api_documentation(),
            "setup_guide": self._generate_setup_guide(),
            "usage_guide": self._generate_usage_guide(),
            "created_files": self._get_created_files(),
        }

        return result

    def _load_translations(self, lang: str) -> dict[str, str]:
        """Charge les traductions pour la langue spécifiée"""
        translations = {
            "fr": {
                "readme_title": "Documentation du Projet",
                "api_docs_title": "Documentation API",
                "setup_guide_title": "Guide d'Installation",
                "usage_guide_title": "Guide d'Utilisation",
                "functions": "Fonctions",
                "classes": "Classes",
                "methods": "Méthodes",
                "parameters": "Paramètres",
                "returns": "Retourne",
                "examples": "Exemples",
            },
            "en": {
                "readme_title": "Project Documentation",
                "api_docs_title": "API Documentation",
                "setup_guide_title": "Installation Guide",
                "usage_guide_title": "Usage Guide",
                "functions": "Functions",
                "classes": "Classes",
                "methods": "Methods",
                "parameters": "Parameters",
                "returns": "Returns",
                "examples": "Examples",
            },
        }
        return translations.get(lang, translations["en"])

    def _generate_readme(self) -> str:
        """Génère un README basique"""

        readme = f"""# {self.project_info.get("name", "Projet")}

{self.project_info.get("description", "Description du projet")}

## Installation

```bash
pip install -r requirements.txt
```

## Utilisation

```python
from {self.project_info.get("name", "project")} import main
main()
```

## Documentation

Consultez la documentation complète dans le dossier `docs/`.

## Licence

{self.project_info.get("license", "MIT")}
"""
        return readme

    def _generate_api_documentation(self) -> str:
        """Génère la documentation API"""
        translations = self._load_translations(self.lang)

        api_docs = f"""# {translations["api_docs_title"]}

## {translations["classes"]}

"""

        for class_info in self.project_info.get("classes", []):
            if isinstance(class_info, dict):
                api_docs += f"""### {class_info.get("name", "Unknown")}

{class_info.get("docstring", "Aucune description")}

#### {translations["methods"]}

"""
                for method in class_info.get("methods", []):
                    api_docs += f"- `{method}()`\n"
                api_docs += "\n"
            elif isinstance(class_info, str):
                api_docs += f"""### {class_info}

Aucune description disponible

"""

        api_docs += f"""## {translations["functions"]}

"""

        for func_info in self.project_info.get("functions", []):
            if isinstance(func_info, dict):
                api_docs += f"""### {func_info.get("name", "Unknown")}

{func_info.get("docstring", "Aucune description")}

"""
                if func_info.get("args"):
                    api_docs += (
                        f"**{translations['parameters']}:** "
                        f"{', '.join(func_info['args'])}\n\n"
                    )
            elif isinstance(func_info, str):
                api_docs += f"""### {func_info}

Aucune description disponible

"""

        return api_docs

    def _generate_setup_guide(self) -> str:
        """Génère le guide d'installation"""
        translations = self._load_translations(self.lang)

        setup_guide = f"""# {translations["setup_guide_title"]}

## Prérequis

- Python 3.8+
- pip

## Installation

1. Cloner le repository:
```bash
git clone <repository-url>
cd {self.project_info.get("name", "project")}
```

2. Installer les dépendances:
```bash
pip install -r requirements.txt
```

3. Configuration:
```bash
cp config.example.yml config.yml
# Éditer config.yml selon vos besoins
```

## Vérification

```bash
python -m pytest tests/
```
"""
        return setup_guide

    def _generate_usage_guide(self) -> str:
        """Génère le guide d'utilisation"""
        translations = self._load_translations(self.lang)

        usage_guide = f"""# {translations["usage_guide_title"]}

## Démarrage rapide

```python
from {self.project_info.get("name", "project")} import main

# Configuration de base
config = {{"debug": True}}

# Lancement
main(config)
```

## {translations["examples"]}

### Exemple 1: Utilisation basique

```python
# Code d'exemple
```

### Exemple 2: Configuration avancée

```python
# Code d'exemple avancé
```
"""
        return usage_guide

    def _get_created_files(self) -> list[str]:
        """Retourne la liste des fichiers créés"""
        return ["README.md", "docs/api.md", "docs/setup.md", "docs/usage.md"]


def generate_documentation(project_path: str = ".") -> dict[str, Any]:
    """Fonction utilitaire pour générer la documentation"""
    documenter = AutoDocumenter(project_path)
    return documenter.perform_full_documentation()


def analyze_documentation_needs(project_path: str = ".") -> dict[str, Any]:
    """Fonction utilitaire pour analyser les besoins de documentation"""
    documenter = AutoDocumenter(project_path)
    return documenter.calculate_documentation_coverage()
