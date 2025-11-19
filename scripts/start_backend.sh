#!/bin/bash

# Script de démarrage pour Arkalia CIA Backend
echo "🚀 Démarrage d'Arkalia CIA Backend..."

# Aller dans le dossier backend
cd /Volumes/T7/arkalia-cia/arkalia_cia_python_backend

# Activer l'environnement virtuel
source ../arkalia_cia_venv/bin/activate

# Démarrer l'API
echo "📡 Démarrage de l'API FastAPI sur http://localhost:8000"
python api.py
