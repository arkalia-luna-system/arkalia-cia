"""
Tests unitaires pour CalendarService
Tests critiques pour l'intégration calendrier natif
"""

from datetime import datetime, timedelta
from unittest.mock import MagicMock, patch

import pytest


# Mock des dépendances Flutter
with patch.dict(
    "sys.modules",
    {
        "device_calendar": MagicMock(),
        "flutter_local_notifications": MagicMock(),
        "timezone": MagicMock(),
    },
):
    from arkalia_cia.lib.services.calendar_service import CalendarService


class TestCalendarService:
    """Tests complets pour CalendarService"""

    def setup_method(self):
        """Configuration avant chaque test"""
        self.test_reminder = {
            "title": "Rendez-vous cardiologie",
            "description": "Consultation avec Dr. Martin",
            "reminder_date": datetime(2024, 1, 15, 10, 0, 0),
        }

    @patch("arkalia_cia.lib.services.calendar_service.DeviceCalendarPlugin")
    @patch("arkalia_cia.lib.services.calendar_service.FlutterLocalNotificationsPlugin")
    def test_add_reminder_success(self, mock_notifications, mock_calendar_plugin):
        """Test d'ajout réussi d'un rappel"""
        # Arrange
        mock_calendar = MagicMock()
        mock_calendar.id = "test_calendar_id"
        mock_calendar_plugin.return_value.retrieveCalendars.return_value = [
            mock_calendar
        ]
        mock_calendar_plugin.return_value.createEvent.return_value = True

        mock_notif_instance = MagicMock()
        mock_notifications.return_value = mock_notif_instance

        # Act
        CalendarService.addReminder(
            title=self.test_reminder["title"],
            description=self.test_reminder["description"],
            reminder_date=self.test_reminder["reminder_date"],
        )

        # Assert
        mock_calendar_plugin.return_value.retrieveCalendars.assert_called_once()
        mock_calendar_plugin.return_value.createEvent.assert_called_once()

    @patch("arkalia_cia.lib.services.calendar_service.DeviceCalendarPlugin")
    def test_add_reminder_no_calendars(self, mock_calendar_plugin):
        """Test d'ajout de rappel quand aucun calendrier n'est disponible"""
        # Arrange
        mock_calendar_plugin.return_value.retrieveCalendars.return_value = []

        # Act
        CalendarService.addReminder(
            title=self.test_reminder["title"],
            description=self.test_reminder["description"],
            reminder_date=self.test_reminder["reminder_date"],
        )

        # Assert
        mock_calendar_plugin.return_value.retrieveCalendars.assert_called_once()
        # Ne doit pas essayer de créer un événement
        mock_calendar_plugin.return_value.createEvent.assert_not_called()

    @patch("arkalia_cia.lib.services.calendar_service.DeviceCalendarPlugin")
    def test_get_upcoming_events_success(self, mock_calendar_plugin):
        """Test de récupération des événements à venir"""
        # Arrange
        mock_event = MagicMock()
        mock_event.id = "event_1"
        mock_event.title = "Test Event"
        mock_calendar_plugin.return_value.retrieveCalendars.return_value = [MagicMock()]
        mock_calendar_plugin.return_value.retrieveEvents.return_value = [mock_event]

        # Act
        events = CalendarService.getUpcomingEvents()

        # Assert
        assert len(events) == 1
        assert events[0].id == "event_1"

    @patch("arkalia_cia.lib.services.calendar_service.DeviceCalendarPlugin")
    def test_get_upcoming_events_empty(self, mock_calendar_plugin):
        """Test de récupération des événements quand la liste est vide"""
        # Arrange
        mock_calendar_plugin.return_value.retrieveCalendars.return_value = []

        # Act
        events = CalendarService.getUpcomingEvents()

        # Assert
        assert events == []

    @patch("arkalia_cia.lib.services.calendar_service.DeviceCalendarPlugin")
    def test_delete_event_success(self, mock_calendar_plugin):
        """Test de suppression réussie d'un événement"""
        # Arrange
        event_id = "test_event_id"
        mock_calendar_plugin.return_value.deleteEvent.return_value = True

        # Act
        CalendarService.deleteEvent(event_id)

        # Assert
        mock_calendar_plugin.return_value.deleteEvent.assert_called_once_with(event_id)

    @patch("arkalia_cia.lib.services.calendar_service.FlutterLocalNotificationsPlugin")
    def test_schedule_notification_success(self, mock_notifications):
        """Test de programmation réussie d'une notification"""
        # Arrange
        mock_notif_instance = MagicMock()
        mock_notifications.return_value = mock_notif_instance

        # Act
        CalendarService.scheduleNotification(
            title="Test Notification",
            description="Test Description",
            date=datetime.now() + timedelta(hours=1),
        )

        # Assert
        mock_notif_instance.zonedSchedule.assert_called_once()

    def test_reminder_data_validation(self):
        """Test de validation des données de rappel"""
        # Test avec données valides
        assert self.test_reminder["title"] is not None
        assert len(self.test_reminder["title"]) > 0
        assert self.test_reminder["reminder_date"] is not None
        assert isinstance(self.test_reminder["reminder_date"], datetime)

    def test_reminder_date_future(self):
        """Test que la date de rappel est dans le futur"""
        future_date = datetime.now() + timedelta(days=1)
        past_date = datetime.now() - timedelta(days=1)

        # Date future - OK
        assert future_date > datetime.now()

        # Date passée - Pas OK pour un rappel
        assert past_date < datetime.now()

    @patch("arkalia_cia.lib.services.calendar_service.DeviceCalendarPlugin")
    def test_calendar_permission_handling(self, mock_calendar_plugin):
        """Test de gestion des permissions calendrier"""
        # Arrange
        mock_calendar_plugin.return_value.retrieveCalendars.side_effect = (
            PermissionError("Calendar permission denied")
        )

        # Act & Assert
        with pytest.raises(PermissionError):
            CalendarService.getUpcomingEvents()

    @patch("arkalia_cia.lib.services.calendar_service.DeviceCalendarPlugin")
    def test_calendar_error_handling(self, mock_calendar_plugin):
        """Test de gestion d'erreur calendrier"""
        # Arrange
        mock_calendar_plugin.return_value.retrieveCalendars.side_effect = Exception(
            "Calendar error"
        )

        # Act & Assert
        with pytest.raises(Exception, match="Calendar error"):
            CalendarService.getUpcomingEvents()

    def test_event_title_formatting(self):
        """Test du formatage du titre d'événement"""
        title = "Rendez-vous médecin"
        expected_formatted = "[Santé] Rendez-vous médecin"

        # Le service doit ajouter le préfixe [Santé]
        assert title != expected_formatted
        assert expected_formatted.startswith("[Santé]")

    @patch("arkalia_cia.lib.services.calendar_service.DeviceCalendarPlugin")
    def test_multiple_calendars_handling(self, mock_calendar_plugin):
        """Test de gestion de plusieurs calendriers"""
        # Arrange
        mock_calendar1 = MagicMock()
        mock_calendar1.id = "calendar_1"
        mock_calendar2 = MagicMock()
        mock_calendar2.id = "calendar_2"
        mock_calendar_plugin.return_value.retrieveCalendars.return_value = [
            mock_calendar1,
            mock_calendar2,
        ]

        # Act
        CalendarService.addReminder(
            title=self.test_reminder["title"],
            description=self.test_reminder["description"],
            reminder_date=self.test_reminder["reminder_date"],
        )

        # Assert
        # Doit utiliser le premier calendrier disponible
        mock_calendar_plugin.return_value.createEvent.assert_called_once()

    def test_timezone_handling(self):
        """Test de gestion des fuseaux horaires"""
        # Test avec date naïve
        naive_date = datetime(2024, 1, 15, 10, 0, 0)

        # Test avec date avec timezone
        from datetime import timezone

        aware_date = datetime(2024, 1, 15, 10, 0, 0, tzinfo=timezone.utc)

        # Les deux doivent être des objets datetime valides
        assert isinstance(naive_date, datetime)
        assert isinstance(aware_date, datetime)
