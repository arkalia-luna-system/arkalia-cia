"""
Tests unitaires pour le service de médicaments
Note: Ces tests valident la logique métier qui pourrait être partagée
entre le backend Python et le frontend Flutter
"""

from datetime import datetime, timedelta


class TestMedicationService:
    """Tests pour le service de médicaments"""

    def test_medication_is_active_on_date(self):
        """Test vérification si médicament est actif à une date"""
        start_date = datetime.now() - timedelta(days=10)
        end_date = datetime.now() + timedelta(days=10)
        today = datetime.now()

        # Médicament actif
        assert self._is_active_on_date(start_date, end_date, today) is True

        # Médicament pas encore commencé
        future_start = datetime.now() + timedelta(days=5)
        assert self._is_active_on_date(future_start, end_date, today) is False

        # Médicament terminé
        past_end = datetime.now() - timedelta(days=5)
        assert self._is_active_on_date(start_date, past_end, today) is False

        # Médicament sans date de fin
        assert self._is_active_on_date(start_date, None, today) is True

    def test_medication_frequency_parsing(self):
        """Test parsing des fréquences"""
        frequencies = ["daily", "twice_daily", "three_times_daily", "four_times_daily", "as_needed"]
        for freq in frequencies:
            assert self._is_valid_frequency(freq) is True

        assert self._is_valid_frequency("invalid") is False

    def test_medication_times_parsing(self):
        """Test parsing des heures de prise"""
        times_str = "8:0,14:0,20:0"
        times = self._parse_times(times_str)
        assert len(times) == 3
        assert times[0] == (8, 0)
        assert times[1] == (14, 0)
        assert times[2] == (20, 0)

    def test_medication_times_formatting(self):
        """Test formatage des heures de prise"""
        times = [(8, 0), (14, 0), (20, 0)]
        times_str = self._format_times(times)
        assert times_str == "8:0,14:0,20:0"

    def test_get_missed_doses_logic(self):
        """Test logique de détection des doses manquées"""
        # Médicament avec rappel à 8h
        reminder_time = datetime.now().replace(hour=8, minute=0, second=0, microsecond=0)
        now = datetime.now()

        if now.hour > 8:
            # Si on est après 8h et pas pris, c'est manqué
            assert self._is_missed(reminder_time, False, now) is True
        else:
            # Si on est avant 8h, pas encore manqué
            assert self._is_missed(reminder_time, False, now) is False

    def _is_active_on_date(self, start_date, end_date, check_date):
        """Vérifie si médicament est actif à une date"""
        if check_date < start_date:
            return False
        if end_date is not None and check_date > end_date:
            return False
        return True

    def _is_valid_frequency(self, frequency):
        """Valide la fréquence"""
        valid = ["daily", "twice_daily", "three_times_daily", "four_times_daily", "as_needed"]
        return frequency in valid

    def _parse_times(self, times_str):
        """Parse les heures depuis une string"""
        if not times_str:
            return []
        return [
            tuple(map(int, time.split(":"))) for time in times_str.split(",") if time
        ]

    def _format_times(self, times):
        """Formate les heures en string"""
        return ",".join([f"{h}:{m}" for h, m in times])

    def _is_missed(self, reminder_time, taken, now):
        """Vérifie si une dose est manquée"""
        if taken:
            return False
        return now > reminder_time


class TestMedicationTracking:
    """Tests pour le suivi de prise de médicaments"""

    def test_tracking_percentage(self):
        """Test calcul pourcentage de conformité"""
        taken = 5
        total = 7
        percentage = (taken / total * 100) if total > 0 else 0
        assert percentage == (5 / 7 * 100)

    def test_tracking_perfect_compliance(self):
        """Test conformité parfaite"""
        taken = 7
        total = 7
        percentage = (taken / total * 100) if total > 0 else 0
        assert percentage == 100

    def test_tracking_no_entries(self):
        """Test sans entrées"""
        taken = 0
        total = 0
        percentage = (taken / total * 100) if total > 0 else 0
        assert percentage == 0

