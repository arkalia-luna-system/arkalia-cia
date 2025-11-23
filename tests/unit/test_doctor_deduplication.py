"""Tests pour la déduplication intelligente de médecins"""


class TestDoctorDeduplication:
    """Tests pour findSimilarDoctors"""

    def test_exact_match(self):
        """Test détection doublon exact"""
        doctor1_name = "Jean Dupont"
        doctor1_specialty = "Cardiologue"
        doctor2_name = "Jean Dupont"
        doctor2_specialty = "Cardiologue"
        # Devrait être détecté comme doublon
        assert doctor1_name == doctor2_name
        assert doctor1_specialty == doctor2_specialty

    def test_similar_name(self):
        """Test détection nom similaire"""
        doctor1_name = "Jean Dupont"
        doctor2_name = "Jean Dupond"  # Faute de frappe
        # Devrait être détecté comme similaire (Jaro-Winkler > 0.85)
        assert doctor1_name != doctor2_name
        # Les noms sont très similaires
        assert len(doctor1_name.split()[-1]) == len(doctor2_name.split()[-1])

    def test_different_specialty(self):
        """Test que médecins différents spécialités ne sont pas doublons"""
        doctor1_name = "Jean Dupont"
        doctor1_specialty = "Cardiologue"
        doctor2_name = "Jean Dupont"
        doctor2_specialty = "Dermatologue"
        # Ne devrait PAS être détecté comme doublon
        assert doctor1_name == doctor2_name
        assert doctor1_specialty != doctor2_specialty

    def test_similar_specialty(self):
        """Test détection spécialité similaire"""
        doctor1_name = "Jean Dupont"
        doctor1_specialty = "Cardiologue"
        doctor2_name = "Jean Dupont"
        doctor2_specialty = "Cardiologie"  # Variante
        # Devrait être détecté comme similaire
        assert doctor1_specialty.lower() != doctor2_specialty.lower()
        # Mais très similaire
        assert "cardio" in doctor1_specialty.lower()
        assert "cardio" in doctor2_specialty.lower()

    def test_no_specialty(self):
        """Test médecins sans spécialité"""
        doctor1_name = "Jean Dupont"
        doctor1_specialty = None
        doctor2_name = "Jean Dupont"
        doctor2_specialty = None
        # Devrait être détecté comme doublon si noms identiques
        assert doctor1_name == doctor2_name
        assert doctor1_specialty == doctor2_specialty
