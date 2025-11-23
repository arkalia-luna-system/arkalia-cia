"""
Tests unitaires pour la détection d'interactions médicamenteuses
"""


class TestMedicationInteractions:
    """Tests pour la détection d'interactions médicamenteuses"""

    def test_check_interactions_aspirin_anticoagulant(self):
        """Test détection interaction aspirine/anticoagulant"""
        medications = [
            {"name": "Aspirine", "dosage": "100mg"},
            {"name": "Warfarine", "dosage": "5mg"},
        ]

        interactions = self._check_interactions(medications)
        assert len(interactions) > 0
        assert any("aspirine" in i.lower() or "anticoagulant" in i.lower() for i in interactions)

    def test_check_interactions_ibuprofen_aspirin(self):
        """Test détection interaction ibuprofène/aspirine"""
        medications = [
            {"name": "Ibuprofène", "dosage": "400mg"},
            {"name": "Aspirine", "dosage": "100mg"},
        ]

        interactions = self._check_interactions(medications)
        assert len(interactions) > 0
        assert any("ibuprofène" in i.lower() or "aspirine" in i.lower() for i in interactions)

    def test_check_interactions_no_interaction(self):
        """Test qu'il n'y a pas d'interaction entre médicaments compatibles"""
        medications = [
            {"name": "Paracétamol", "dosage": "500mg"},
            {"name": "Vitamine D", "dosage": "1000 UI"},
        ]

        interactions = self._check_interactions(medications)
        assert len(interactions) == 0

    def test_check_interactions_empty_list(self):
        """Test avec liste vide"""
        medications = []
        interactions = self._check_interactions(medications)
        assert len(interactions) == 0

    def test_check_interactions_single_medication(self):
        """Test avec un seul médicament"""
        medications = [{"name": "Aspirine", "dosage": "100mg"}]
        interactions = self._check_interactions(medications)
        assert len(interactions) == 0

    def _check_interactions(self, medications):
        """
        Méthode de détection d'interactions (basique)
        Simule la logique du MedicationService Dart
        """
        warnings = []
        interaction_map = {
            "aspirine": ["anticoagulant", "ibuprofène"],
            "anticoagulant": ["aspirine", "ibuprofène"],
            "ibuprofène": ["aspirine", "anticoagulant"],
            "warfarine": ["aspirine", "ibuprofène"],
        }

        medication_names = [m["name"].lower() for m in medications]

        for medication in medications:
            name = medication["name"].lower()
            if name in interaction_map:
                conflicting = interaction_map[name]
                for conflict in conflicting:
                    if any(conflict in mn for mn in medication_names if mn != name):
                        warnings.append(
                            f"⚠️ Interaction possible entre {medication['name']} et {conflict}. "
                            "Consultez votre médecin."
                        )

        return warnings


class TestMedicationValidation:
    """Tests pour la validation des données de médicaments"""

    def test_validate_medication_name(self):
        """Test validation nom médicament"""
        assert self._validate_name("Aspirine") is True
        assert self._validate_name("") is False
        assert self._validate_name(None) is False

    def test_validate_medication_dosage(self):
        """Test validation dosage"""
        assert self._validate_dosage("100mg") is True
        assert self._validate_dosage("1 comprimé") is True
        assert self._validate_dosage("") is True  # Optionnel
        assert self._validate_dosage(None) is True  # Optionnel

    def test_validate_medication_frequency(self):
        """Test validation fréquence"""
        valid_frequencies = ["daily", "twice_daily", "three_times_daily", "four_times_daily", "as_needed"]
        for freq in valid_frequencies:
            assert self._validate_frequency(freq) is True
        assert self._validate_frequency("invalid") is False

    def _validate_name(self, name):
        """Valide le nom du médicament"""
        return name is not None and len(name.strip()) > 0

    def _validate_dosage(self, dosage):
        """Valide le dosage (optionnel)"""
        return dosage is None or len(str(dosage).strip()) >= 0

    def _validate_frequency(self, frequency):
        """Valide la fréquence"""
        valid = ["daily", "twice_daily", "three_times_daily", "four_times_daily", "as_needed"]
        return frequency in valid


class TestHydrationValidation:
    """Tests pour la validation des données d'hydratation"""

    def test_validate_hydration_amount(self):
        """Test validation quantité hydratation"""
        assert self._validate_amount(250) is True
        assert self._validate_amount(2000) is True
        assert self._validate_amount(0) is False
        assert self._validate_amount(-100) is False
        assert self._validate_amount(10000) is True  # Limite haute raisonnable

    def test_validate_hydration_goal(self):
        """Test validation objectif hydratation"""
        assert self._validate_goal(2000) is True  # 8 verres
        assert self._validate_goal(1500) is True
        assert self._validate_goal(0) is False
        assert self._validate_goal(-500) is False
        assert self._validate_goal(5000) is True  # Limite haute

    def _validate_amount(self, amount):
        """Valide la quantité d'eau (ml)"""
        return isinstance(amount, int) and 0 < amount <= 10000

    def _validate_goal(self, goal):
        """Valide l'objectif quotidien (ml)"""
        return isinstance(goal, int) and 0 < goal <= 10000

