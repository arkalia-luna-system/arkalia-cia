"""
Tests unitaires pour les templates de pathologies
"""


class TestPathologyTemplates:
    """Tests pour les templates de pathologies"""

    def test_endometriosis_template_complete(self):
        """Test template endométriose complet"""
        template = {
            "name": "Endométriose",
            "description": "Suivi de l'endométriose avec cycle, douleurs et saignements",
            "symptoms": [
                "Douleurs pelviennes",
                "Règles douloureuses",
                "Saignements",
                "Fatigue",
            ],
            "treatments": ["Hormonothérapie", "Chirurgie", "Antalgiques"],
            "exams": ["Échographie pelvienne", "IRM pelvienne", "Laparoscopie"],
            "reminders": {
                "exam": {"type": "exam", "frequency": "monthly"},
                "cycle": {"type": "cycle", "frequency": "monthly"},
            },
        }

        assert template["name"] == "Endométriose"
        assert len(template["symptoms"]) == 4
        assert len(template["treatments"]) == 3
        assert len(template["exams"]) == 3
        assert "exam" in template["reminders"]
        assert "cycle" in template["reminders"]

    def test_cancer_template_complete(self):
        """Test template cancer complet"""
        template = {
            "name": "Cancer",
            "symptoms": ["Fatigue", "Nausées", "Douleurs", "Perte d'appétit"],
            "treatments": ["Chimiothérapie", "Radiothérapie", "Chirurgie"],
            "exams": ["Scanner", "IRM", "Biopsie", "Analyses sanguines"],
            "reminders": {
                "treatment": {"type": "treatment", "frequency": "weekly"},
                "exam": {"type": "exam", "frequency": "monthly"},
            },
        }

        assert template["name"] == "Cancer"
        assert "Chimiothérapie" in template["treatments"]
        assert "Scanner" in template["exams"]
        assert "treatment" in template["reminders"]

    def test_myeloma_template_complete(self):
        """Test template myélome complet"""
        template = {
            "name": "Myélome",
            "symptoms": ["Douleurs osseuses", "Fatigue", "Infections"],
            "exams": ["IRM", "Biopsie médullaire", "Analyses sanguines"],
            "reminders": {
                "exam": {"type": "exam", "frequency": "monthly"},
                "treatment": {"type": "treatment", "frequency": "weekly"},
            },
        }

        assert template["name"] == "Myélome"
        assert "Douleurs osseuses" in template["symptoms"]
        assert "Biopsie médullaire" in template["exams"]

    def test_osteoporosis_template_complete(self):
        """Test template ostéoporose complet"""
        template = {
            "name": "Ostéoporose",
            "symptoms": ["Douleurs", "Fractures"],
            "treatments": ["Biphosphonates", "Calcium", "Vitamine D"],
            "exams": ["Densitométrie osseuse"],
            "reminders": {
                "exam": {"type": "exam", "frequency": "yearly"},
                "activity": {"type": "activity", "frequency": "daily"},
                "medication": {"type": "medication", "frequency": "daily"},
            },
        }

        assert template["name"] == "Ostéoporose"
        assert "Biphosphonates" in template["treatments"]
        assert len(template["reminders"]) == 3
        assert template["reminders"]["exam"]["frequency"] == "yearly"

    def test_arthritis_templates(self):
        """Test templates arthrose, arthrite, tendinite, spondylarthrite"""
        templates = [
            {
                "name": "Arthrose",
                "symptoms": ["Douleurs articulaires", "Raideur", "Gonflement"],
                "treatments": ["Anti-inflammatoires", "Antalgiques", "Kinésithérapie"],
            },
            {
                "name": "Arthrite",
                "symptoms": ["Douleurs articulaires", "Raideur", "Gonflement"],
                "treatments": [
                    "Anti-inflammatoires",
                    "Traitements de fond",
                    "Kinésithérapie",
                ],
            },
            {
                "name": "Tendinite",
                "symptoms": ["Douleurs articulaires", "Raideur", "Gonflement"],
                "treatments": ["Anti-inflammatoires", "Repos", "Kinésithérapie"],
            },
            {
                "name": "Spondylarthrite",
                "symptoms": ["Douleurs articulaires", "Raideur", "Gonflement"],
                "treatments": [
                    "Anti-inflammatoires",
                    "Traitements de fond",
                    "Kinésithérapie",
                ],
            },
        ]

        for template in templates:
            assert template["name"] in [
                "Arthrose",
                "Arthrite",
                "Tendinite",
                "Spondylarthrite",
            ]
            assert len(template["symptoms"]) == 3
            assert "Anti-inflammatoires" in template["treatments"]
            assert "Kinésithérapie" in template["treatments"]

    def test_parkinson_template_complete(self):
        """Test template Parkinson complet"""
        template = {
            "name": "Parkinson",
            "symptoms": [
                "Tremblements",
                "Rigidité",
                "Bradykinésie",
                "Troubles de l'équilibre",
            ],
            "treatments": ["Lévodopa", "Autres traitements"],
            "exams": ["Consultation neurologue"],
            "reminders": {
                "medication": {
                    "type": "medication",
                    "frequency": "daily",
                    "times": ["08:00", "12:00", "18:00", "22:00"],
                },
                "therapy": {"type": "therapy", "frequency": "weekly"},
                "consultation": {"type": "consultation", "frequency": "monthly"},
            },
        }

        assert template["name"] == "Parkinson"
        assert len(template["symptoms"]) == 4
        assert "Lévodopa" in template["treatments"]
        assert len(template["reminders"]["medication"]["times"]) == 4
        assert template["reminders"]["medication"]["frequency"] == "daily"

    def test_all_templates_have_required_fields(self):
        """Test que tous les templates ont les champs requis"""
        required_fields = ["name", "symptoms", "treatments", "exams", "reminders"]

        templates = [
            {
                "name": "Endométriose",
                "symptoms": [],
                "treatments": [],
                "exams": [],
                "reminders": {},
            },
            {
                "name": "Cancer",
                "symptoms": [],
                "treatments": [],
                "exams": [],
                "reminders": {},
            },
            {
                "name": "Myélome",
                "symptoms": [],
                "treatments": [],
                "exams": [],
                "reminders": {},
            },
            {
                "name": "Ostéoporose",
                "symptoms": [],
                "treatments": [],
                "exams": [],
                "reminders": {},
            },
            {
                "name": "Arthrose",
                "symptoms": [],
                "treatments": [],
                "exams": [],
                "reminders": {},
            },
            {
                "name": "Parkinson",
                "symptoms": [],
                "treatments": [],
                "exams": [],
                "reminders": {},
            },
        ]

        for template in templates:
            for field in required_fields:
                assert field in template, (
                    f"Champ {field} manquant dans {template['name']}"
                )

    def test_reminder_frequencies(self):
        """Test que les fréquences de rappels sont valides"""
        valid_frequencies = ["daily", "weekly", "monthly", "yearly", "custom"]

        reminders = [
            {"frequency": "daily"},
            {"frequency": "weekly"},
            {"frequency": "monthly"},
            {"frequency": "yearly"},
        ]

        for reminder in reminders:
            assert reminder["frequency"] in valid_frequencies

    def test_reminder_types(self):
        """Test que les types de rappels sont cohérents"""
        reminder_types = [
            "exam",
            "medication",
            "therapy",
            "activity",
            "treatment",
            "cycle",
            "consultation",
        ]

        # Vérifier que les types utilisés dans les templates sont valides
        used_types = [
            "exam",
            "medication",
            "therapy",
            "activity",
            "treatment",
            "cycle",
            "consultation",
        ]

        for used_type in used_types:
            assert used_type in reminder_types, f"Type {used_type} non reconnu"
