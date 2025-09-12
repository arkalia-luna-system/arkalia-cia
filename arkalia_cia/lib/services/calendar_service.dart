import 'package:device_calendar/device_calendar.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

/// Service de gestion du calendrier natif pour Arkalia CIA
/// Intègre le calendrier système et les notifications
class CalendarService {
  static final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Initialise le service calendrier
  static Future<void> init() async {
    // Configuration des notifications locales
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  /// Ajoute un rappel au calendrier
  static Future<bool> addReminder({
    required String title,
    required String description,
    required DateTime reminderDate,
  }) async {
    try {
      // Récupérer les calendriers disponibles
      final calendars = await _deviceCalendarPlugin.retrieveCalendars();
      if (calendars.isEmpty) {
        return false;
      }

      // Utiliser le premier calendrier disponible
      final calendar = calendars.first;

      // Créer l'événement
      final event = Event(
        calendarId: calendar.id,
        title: '[Santé] $title',
        description: description,
        start: TZDateTime.from(reminderDate, tz.local),
        end: TZDateTime.from(reminderDate.add(const Duration(hours: 1)), tz.local),
        allDay: false,
      );

      // Ajouter l'événement au calendrier
      final result = await _deviceCalendarPlugin.createEvent(event);

      // Programmer une notification
      await _scheduleNotification(
        title: title,
        description: description,
        date: reminderDate,
      );

      return result;
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout du rappel: $e');
    }
  }

  /// Récupère les rappels à venir
  static Future<List<Map<String, dynamic>>> getUpcomingReminders() async {
    try {
      // Pour l'instant, retourner une liste vide
      // L'implémentation complète nécessiterait l'intégration avec le calendrier
      return [];
    } catch (e) {
      throw Exception('Erreur lors de la récupération des rappels: $e');
    }
  }

  /// Récupère les événements à venir
  static Future<List<Event>> getUpcomingEvents() async {
    try {
      final calendars = await _deviceCalendarPlugin.retrieveCalendars();
      if (calendars.isEmpty) {
        return [];
      }

      final now = DateTime.now();
      final endDate = now.add(const Duration(days: 30)); // 30 jours à venir

      final events = <Event>[];
      for (final calendar in calendars) {
        final calendarEvents = await _deviceCalendarPlugin.retrieveEvents(
          calendar.id,
          RetrieveEventsParams(
            startDate: now,
            endDate: endDate,
          ),
        );
        events.addAll(calendarEvents);
      }

      return events;
    } catch (e) {
      throw Exception('Erreur lors de la récupération des événements: $e');
    }
  }

  /// Supprime un événement
  static Future<bool> deleteEvent(String eventId) async {
    try {
      return await _deviceCalendarPlugin.deleteEvent(eventId);
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'événement: $e');
    }
  }

  /// Programme une notification locale
  static Future<void> _scheduleNotification({
    required String title,
    required String description,
    required DateTime date,
  }) async {
    try {
      await _notificationsPlugin.zonedSchedule(
        0,
        title,
        description,
        tz.TZDateTime.from(date, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'arkalia_cia_reminders',
            'Rappels Arkalia CIA',
            channelDescription: 'Notifications pour les rappels médicaux',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      throw Exception('Erreur lors de la programmation de la notification: $e');
    }
  }

  /// Programme une notification
  static Future<void> scheduleNotification({
    required String title,
    required String description,
    required DateTime date,
  }) async {
    await _scheduleNotification(
      title: title,
      description: description,
      date: date,
    );
  }

  /// Annule toutes les notifications
  static Future<void> cancelAllNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();
    } catch (e) {
      throw Exception('Erreur lors de l\'annulation des notifications: $e');
    }
  }

  /// Vérifie les permissions du calendrier
  static Future<bool> hasCalendarPermission() async {
    try {
      final permissions = await _deviceCalendarPlugin.hasPermissions();
      return permissions ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Demande les permissions du calendrier
  static Future<bool> requestCalendarPermission() async {
    try {
      return await _deviceCalendarPlugin.requestPermissions() ?? false;
    } catch (e) {
      return false;
    }
  }
}
