# Makefile pour Arkalia-CIA
# Basé sur les standards des autres projets Arkalia

.PHONY: help install install-dev test test-cov lint format security clean build run

# Variables
PYTHON := python3
PIP := pip
VENV := arkalia_cia_venv
PYTHON_VENV := $(VENV)/bin/python
PIP_VENV := $(VENV)/bin/pip

# Couleurs pour les messages
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m # No Color

help: ## Afficher l'aide
	@echo "$(GREEN)Arkalia-CIA - Commandes disponibles:$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-20s$(NC) %s\n", $$1, $$2}'

install: ## Installer les dépendances de base
	@echo "$(GREEN)Installation des dépendances de base...$(NC)"
	$(PIP) install -r requirements.txt
	$(PIP) install -e .

install-dev: ## Installer les dépendances de développement
	@echo "$(GREEN)Installation des dépendances de développement...$(NC)"
	$(PIP) install -r requirements.txt
	$(PIP) install -e ".[dev]"
	$(PIP) install pre-commit
	pre-commit install

test: ## Lancer les tests
	@echo "$(GREEN)Lancement des tests...$(NC)"
	@./scripts/cleanup_all.sh --keep-coverage > /dev/null 2>&1 || true
	@./scripts/run_tests.sh tests/ -v
	@echo "$(GREEN)Nettoyage automatique après les tests...$(NC)"
	@./scripts/cleanup_all.sh --keep-coverage > /dev/null 2>&1 || true

test-cov: ## Lancer les tests avec couverture
	@echo "$(GREEN)Lancement des tests avec couverture...$(NC)"
	@./scripts/cleanup_all.sh --keep-coverage > /dev/null 2>&1 || true
	@./scripts/run_tests.sh tests/ --cov=arkalia_cia_python_backend --cov-report=html --cov-report=term-missing
	@echo "$(GREEN)Nettoyage automatique après les tests...$(NC)"
	@./scripts/cleanup_all.sh --keep-coverage > /dev/null 2>&1 || true

lint: ## Lancer le linting
	@echo "$(GREEN)Lancement du linting...$(NC)"
	ruff check .
	mypy arkalia_cia_python_backend/

format: ## Formater le code
	@echo "$(GREEN)Formatage du code...$(NC)"
	black .
	isort .

security: ## Lancer les vérifications de sécurité
	@echo "$(GREEN)Vérifications de sécurité...$(NC)"
	bandit -r arkalia_cia_python_backend/
	safety check

clean: ## Nettoyer les fichiers temporaires
	@echo "$(GREEN)Nettoyage...$(NC)"
	@./scripts/cleanup_all.sh --keep-coverage || true
	find . -type f -name "*.pyc" -delete
	find . -type d -name "__pycache__" -delete
	find . -type d -name "*.egg-info" -exec rm -rf {} +
	find . -type d -name ".pytest_cache" -exec rm -rf {} +
	find . -type d -name "htmlcov" -exec rm -rf {} +
	find . -type f -name ".coverage" -delete
	find . -type f -name "bandit-report.json" -delete
	find . -type f -name "safety-report.json" -delete
	find . -name "._*" -delete
	find . -name ".!*!._*" -delete
	find . -name ".DS_Store" -delete

build: ## Construire le package
	@echo "$(GREEN)Construction du package...$(NC)"
	$(PYTHON) -m build

run: ## Lancer l'API
	@echo "$(GREEN)Lancement de l'API...$(NC)"
	cd arkalia_cia_python_backend && $(PYTHON) api.py

run-dev: ## Lancer l'API en mode développement
	@echo "$(GREEN)Lancement de l'API en mode développement...$(NC)"
	cd arkalia_cia_python_backend && uvicorn api:app --host 0.0.0.0 --port 8000 --reload

check: lint test security ## Lancer tous les checks (lint, test, security)

ci: clean install-dev check build ## Pipeline CI complet

# Commandes Flutter (si Flutter est installé)
flutter-deps: ## Installer les dépendances Flutter
	@echo "$(GREEN)Installation des dépendances Flutter...$(NC)"
	@if command -v flutter >/dev/null 2>&1; then \
		./scripts/cleanup_all.sh --keep-coverage > /dev/null 2>&1 || true; \
		cd arkalia_cia && flutter pub get; \
	else \
		echo "$(YELLOW)Flutter non installé, skip...$(NC)"; \
	fi

flutter-run: ## Lancer l'application Flutter
	@echo "$(GREEN)Lancement de l'application Flutter...$(NC)"
	@if command -v flutter >/dev/null 2>&1; then \
		cd arkalia_cia && flutter run; \
	else \
		echo "$(YELLOW)Flutter non installé, skip...$(NC)"; \
	fi

flutter-build: ## Construire l'application Flutter
	@echo "$(GREEN)Construction de l'application Flutter...$(NC)"
	@if command -v flutter >/dev/null 2>&1; then \
		cd arkalia_cia && flutter build apk; \
	else \
		echo "$(YELLOW)Flutter non installé, skip...$(NC)"; \
	fi

flutter-test: ## Lancer les tests Flutter
	@echo "$(GREEN)Lancement des tests Flutter...$(NC)"
	@if command -v flutter >/dev/null 2>&1; then \
		./scripts/cleanup_all.sh --keep-coverage > /dev/null 2>&1 || true; \
		cd arkalia_cia && flutter test --coverage; \
		echo "$(GREEN)Nettoyage automatique après les tests Flutter...$(NC)"; \
		cd .. && ./scripts/cleanup_all.sh --keep-coverage > /dev/null 2>&1 || true; \
	else \
		echo "$(YELLOW)Flutter non installé, skip...$(NC)"; \
	fi

# Commandes de développement
dev-setup: install-dev flutter-deps ## Configuration complète pour le développement
	@echo "$(GREEN)Configuration de développement terminée!$(NC)"
	@echo "$(YELLOW)Pour lancer l'API: make run-dev$(NC)"
	@echo "$(YELLOW)Pour lancer Flutter: make flutter-run$(NC)"

# Commandes de déploiement
deploy-test: check build ## Déploiement de test
	@echo "$(GREEN)Déploiement de test...$(NC)"
	@echo "$(YELLOW)Prêt pour le déploiement!$(NC)"

deploy-prod: check build ## Déploiement de production
	@echo "$(GREEN)Déploiement de production...$(NC)"
	@echo "$(YELLOW)Prêt pour le déploiement en production!$(NC)"
