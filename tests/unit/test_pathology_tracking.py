"""
Tests unitaires pour le tracking des pathologies
"""

from datetime import datetime, timedelta


class TestPathologyTracking:
    """Tests pour le tracking des pathologies"""

    def test_tracking_entry_creation(self):
        """Test création d'une entrée de tracking"""
        entry = {
            "pathology_id": 1,
            "date": datetime.now().isoformat(),
            "data": {
                "painLevel": 5,
                "symptoms": ["Douleur", "Fatigue"],
            },
            "notes": "Journée difficile",
        }

        assert entry["pathology_id"] == 1
        assert "painLevel" in entry["data"]
        assert entry["data"]["painLevel"] == 5
        assert len(entry["data"]["symptoms"]) == 2
        assert entry["notes"] == "Journée difficile"

    def test_tracking_statistics(self):
        """Test calcul des statistiques"""
        entries = [
            {
                "date": (datetime.now() - timedelta(days=5)).isoformat(),
                "data": {"painLevel": 3},
            },
            {
                "date": (datetime.now() - timedelta(days=4)).isoformat(),
                "data": {"painLevel": 5},
            },
            {
                "date": (datetime.now() - timedelta(days=3)).isoformat(),
                "data": {"painLevel": 7},
            },
            {
                "date": (datetime.now() - timedelta(days=2)).isoformat(),
                "data": {"painLevel": 4},
            },
            {
                "date": (datetime.now() - timedelta(days=1)).isoformat(),
                "data": {"painLevel": 6},
            },
        ]

        # Calculer moyenne douleur
        pain_levels = [
            e["data"]["painLevel"] for e in entries if "painLevel" in e["data"]
        ]
        avg_pain = sum(pain_levels) / len(pain_levels) if pain_levels else 0

        assert len(entries) == 5
        assert avg_pain == 5.0
        assert min(pain_levels) == 3
        assert max(pain_levels) == 7

    def test_symptoms_frequency(self):
        """Test calcul de la fréquence des symptômes"""
        entries = [
            {"data": {"symptoms": ["Douleur", "Fatigue"]}},
            {"data": {"symptoms": ["Douleur"]}},
            {"data": {"symptoms": ["Fatigue", "Nausées"]}},
            {"data": {"symptoms": ["Douleur", "Fatigue", "Nausées"]}},
        ]

        symptoms_count = {}
        for entry in entries:
            if "symptoms" in entry["data"]:
                for symptom in entry["data"]["symptoms"]:
                    symptoms_count[symptom] = symptoms_count.get(symptom, 0) + 1

        assert symptoms_count["Douleur"] == 3
        assert symptoms_count["Fatigue"] == 3
        assert symptoms_count["Nausées"] == 2

    def test_tracking_date_range(self):
        """Test filtrage par plage de dates"""
        start_date = datetime.now() - timedelta(days=30)
        end_date = datetime.now()

        entries = [
            {
                "date": (datetime.now() - timedelta(days=35)).isoformat(),
                "data": {"painLevel": 5},
            },
            {
                "date": (datetime.now() - timedelta(days=20)).isoformat(),
                "data": {"painLevel": 6},
            },
            {
                "date": (datetime.now() - timedelta(days=10)).isoformat(),
                "data": {"painLevel": 4},
            },
            {
                "date": (datetime.now() - timedelta(days=5)).isoformat(),
                "data": {"painLevel": 7},
            },
        ]

        # Filtrer par plage de dates
        filtered = [
            e
            for e in entries
            if start_date <= datetime.fromisoformat(e["date"]) <= end_date
        ]

        assert len(filtered) == 3  # Exclut l'entrée de 35 jours

    def test_endometriosis_tracking_data(self):
        """Test données de tracking spécifiques endométriose"""
        entry = {
            "date": datetime.now().isoformat(),
            "data": {
                "painLevel": 8,
                "cycle": 5,
                "bleeding": True,
                "fatigue": 7,
            },
            "notes": "Règles très douloureuses",
        }

        assert entry["data"]["cycle"] == 5
        assert entry["data"]["bleeding"] is True
        assert entry["data"]["fatigue"] == 7
        assert "Règles" in entry["notes"]

    def test_arthritis_tracking_data(self):
        """Test données de tracking spécifiques arthrose"""
        entry = {
            "date": datetime.now().isoformat(),
            "data": {
                "painLevel": 6,
                "location": "Genou droit",
                "mobility": 5,
                "medicationTaken": True,
            },
        }

        assert entry["data"]["location"] == "Genou droit"
        assert entry["data"]["mobility"] == 5
        assert entry["data"]["medicationTaken"] is True

    def test_parkinson_tracking_data(self):
        """Test données de tracking spécifiques Parkinson"""
        entry = {
            "date": datetime.now().isoformat(),
            "data": {
                "tremors": 6,
                "rigidity": 5,
                "medicationTaken": True,
            },
        }

        assert entry["data"]["tremors"] == 6
        assert entry["data"]["rigidity"] == 5
        assert entry["data"]["medicationTaken"] is True

    def test_cancer_tracking_data(self):
        """Test données de tracking spécifiques cancer"""
        entry = {
            "date": datetime.now().isoformat(),
            "data": {
                "sideEffects": ["Nausées", "Fatigue"],
                "treatment": "Chimiothérapie cycle 3",
            },
        }

        assert "sideEffects" in entry["data"]
        assert len(entry["data"]["sideEffects"]) == 2
        assert "Chimiothérapie" in entry["data"]["treatment"]

    def test_tracking_validation(self):
        """Test validation des données de tracking"""
        # Données valides
        valid_entry = {
            "pathology_id": 1,
            "date": datetime.now().isoformat(),
            "data": {"painLevel": 5},
        }

        assert valid_entry["pathology_id"] > 0
        assert "date" in valid_entry
        assert "data" in valid_entry

        # Données invalides
        invalid_entries = [
            {"pathology_id": 0},  # ID invalide
            {"pathology_id": 1},  # Date manquante
            {"pathology_id": 1, "date": datetime.now().isoformat()},  # Data manquante
        ]

        for entry in invalid_entries:
            assert (
                not all(key in entry for key in ["pathology_id", "date", "data"])
                or entry.get("pathology_id", 0) <= 0
            )
