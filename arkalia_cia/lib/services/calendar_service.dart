import 'package:device_calendar/device_calendar.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/doctor.dart';
import 'doctor_service.dart';

/// Service de gestion du calendrier natif pour Arkalia CIA
/// Intègre le calendrier système et les notifications
class CalendarService {
  static final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Initialise le service calendrier
  static Future<void> init() async {
    // Sur le web, device_calendar et notifications ne sont pas disponibles
    if (kIsWeb) {
      return;
    }
    
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
    String? recurrence, // 'daily', 'weekly', 'monthly', ou null
    int? doctorId, // ID du médecin pour couleur
  }) async {
    // Sur le web, device_calendar n'est pas disponible
    if (kIsWeb) {
      return false;
    }
    try {
      // Récupérer les calendriers disponibles
      final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
      if (!calendarsResult.isSuccess || calendarsResult.data!.isEmpty) {
        return false;
      }

      // Utiliser le premier calendrier disponible
      final calendar = calendarsResult.data!.first;

      // Récupérer la couleur du médecin si disponible
      Color? doctorColor;
      if (doctorId != null) {
        try {
          final doctorService = DoctorService();
          final doctor = await doctorService.getDoctorById(doctorId);
          if (doctor != null) {
            doctorColor = Doctor.getColorForSpecialty(doctor.specialty);
          }
        } catch (e) {
          // Ignorer erreur, utiliser couleur par défaut
        }
      }

      // Créer le premier événement
      final event = Event(
        calendar.id,
        title: '[Santé] $title',
        description: description,
        start: TZDateTime.fromMillisecondsSinceEpoch(tz.local, reminderDate.millisecondsSinceEpoch),
        end: TZDateTime.fromMillisecondsSinceEpoch(tz.local, reminderDate.add(const Duration(hours: 1)).millisecondsSinceEpoch),
        allDay: false,
        // Note: device_calendar ne supporte pas directement les couleurs
        // On stocke la couleur dans la description pour récupération ultérieure
        // Format: [COLOR:#RRGGBB] en début de description si couleur disponible
      );
      
      // Ajouter info couleur dans description si disponible
      if (doctorColor != null) {
        // Format: #RRGGBB (sans alpha)
        // Les accesseurs .red, .green, .blue retournent des valeurs entre 0.0 et 1.0
        final r = (doctorColor.red * 255).round();
        final g = (doctorColor.green * 255).round();
        final b = (doctorColor.blue * 255).round();
        final colorHex = '#${r.toRadixString(16).padLeft(2, '0').toUpperCase()}'
            '${g.toRadixString(16).padLeft(2, '0').toUpperCase()}'
            '${b.toRadixString(16).padLeft(2, '0').toUpperCase()}';
        event.description = '[COLOR:$colorHex] $description';
      }

      // Ajouter l'événement au calendrier
      var result = await _deviceCalendarPlugin.createOrUpdateEvent(event);

      // Programmer une notification pour le premier événement
      await _scheduleNotification(
        title: title,
        description: description,
        date: reminderDate,
      );

      // Si récurrence demandée, créer plusieurs événements
      if (recurrence != null && result?.isSuccess == true) {
        DateTime nextDate = reminderDate;
        final endDate = reminderDate.add(const Duration(days: 365)); // 1 an
        
        for (int i = 0; i < 52 && nextDate.isBefore(endDate); i++) {
          switch (recurrence) {
            case 'daily':
              nextDate = nextDate.add(const Duration(days: 1));
              break;
            case 'weekly':
              nextDate = nextDate.add(const Duration(days: 7));
              break;
            case 'monthly':
              nextDate = DateTime(nextDate.year, nextDate.month + 1, nextDate.day);
              break;
          }
          
          if (nextDate.isBefore(endDate)) {
            final recurringEvent = Event(
              calendar.id,
              title: '[Santé] $title',
              description: description,
              start: TZDateTime.fromMillisecondsSinceEpoch(tz.local, nextDate.millisecondsSinceEpoch),
              end: TZDateTime.fromMillisecondsSinceEpoch(tz.local, nextDate.add(const Duration(hours: 1)).millisecondsSinceEpoch),
              allDay: false,
            );
            
            await _deviceCalendarPlugin.createOrUpdateEvent(recurringEvent);
            
            // Programmer une notification pour chaque occurrence
            await _scheduleNotification(
              title: title,
              description: description,
              date: nextDate,
            );
          }
        }
      }

      return result?.isSuccess ?? false;
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout du rappel: $e');
    }
  }

  /// Récupère les rappels à venir depuis le calendrier
  static Future<List<Map<String, dynamic>>> getUpcomingReminders() async {
    // Sur le web, device_calendar n'est pas disponible
    if (kIsWeb) {
      return [];
    }
    try {
      final events = await getUpcomingEvents();
      final now = DateTime.now();
      
      return events
          .where((event) => event.start != null && event.start!.isAfter(now))
          .map((event) => {
                'id': event.eventId,
                'title': event.title?.replaceAll('[Santé] ', '') ?? 'Rappel',
                'description': event.description ?? '',
                'reminder_date': event.start?.toIso8601String() ?? '',
                'is_completed': false,
                'created_at': event.start?.toIso8601String() ?? '',
              })
          .toList();
    } catch (e) {
      // Retourner liste vide plutôt que de planter
      return [];
    }
  }

  /// Récupère les événements à venir
  static Future<List<Event>> getUpcomingEvents() async {
    // Sur le web, device_calendar n'est pas disponible
    if (kIsWeb) {
      return [];
    }
    try {
      final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
      if (!calendarsResult.isSuccess || calendarsResult.data!.isEmpty) {
        return [];
      }

      final now = DateTime.now();
      final endDate = now.add(const Duration(days: 30)); // 30 jours à venir

      final events = <Event>[];
      for (final calendar in calendarsResult.data!) {
        final calendarEventsResult = await _deviceCalendarPlugin.retrieveEvents(
          calendar.id,
          RetrieveEventsParams(
            startDate: now,
            endDate: endDate,
          ),
        );
        if (calendarEventsResult.isSuccess) {
          events.addAll(calendarEventsResult.data!);
        }
      }

      return events;
    } catch (e) {
      throw Exception('Erreur lors de la récupération des événements: $e');
    }
  }

  /// Supprime un événement
  static Future<bool> deleteEvent(String eventId) async {
    try {
      final result = await _deviceCalendarPlugin.deleteEvent(eventId, '');
      return result.isSuccess;
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
        TZDateTime.fromMillisecondsSinceEpoch(tz.local, date.millisecondsSinceEpoch),
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
      final permissionsResult = await _deviceCalendarPlugin.hasPermissions();
      return permissionsResult.isSuccess && (permissionsResult.data ?? false);
    } catch (e) {
      return false;
    }
  }

  /// Demande les permissions du calendrier
  static Future<bool> requestCalendarPermission() async {
    try {
      final result = await _deviceCalendarPlugin.requestPermissions();
      return result.isSuccess && (result.data ?? false);
    } catch (e) {
      return false;
    }
  }

  /// Ajoute un rappel adaptatif pour médicament non pris (30min après)
  static Future<void> scheduleAdaptiveMedicationReminder({
    required String medicationName,
    required String dosage,
    required DateTime originalTime,
  }) async {
    final reminderTime = originalTime.add(const Duration(minutes: 30));
    
    // Ne programmer que si l'heure n'est pas encore passée
    if (reminderTime.isAfter(DateTime.now())) {
      await scheduleNotification(
        title: '💊 Rappel: $medicationName',
        description: 'Vous n\'avez pas encore pris $medicationName. '
            'Dosage: $dosage',
        date: reminderTime,
      );
    }
  }

  /// Récupère les événements avec distinction par type
  static Future<List<Map<String, dynamic>>> getEventsByType({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final events = await getUpcomingEvents();
      final now = startDate ?? DateTime.now();
      final end = endDate ?? now.add(const Duration(days: 30));

      return events
          .where((event) {
            if (event.start == null) return false;
            return event.start!.isAfter(now) && event.start!.isBefore(end);
          })
          .map((event) {
            final title = event.title ?? '';
            final description = event.description ?? '';
            
            // Détecter le type d'événement
            String type = 'other';
            String icon = '📅';
            
            if (title.contains('💊') || description.contains('médicament')) {
              type = 'medication';
              icon = '💊';
            } else if (title.contains('💧') || description.contains('hydratation') || description.contains('eau')) {
              type = 'hydration';
              icon = '💧';
            } else if (title.contains('[Santé]')) {
              type = 'appointment';
              icon = '🏥';
            }

            return {
              'id': event.eventId,
              'title': title.replaceAll('[Santé] ', ''),
              'description': description,
              'date': event.start?.toIso8601String() ?? '',
              'type': type,
              'icon': icon,
              'is_completed': false,
            };
          })
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des événements: $e');
    }
  }
}
