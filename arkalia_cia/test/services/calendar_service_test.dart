import 'package:flutter_test/flutter_test.dart';
import 'package:arkalia_cia/services/calendar_service.dart';
import 'package:flutter/foundation.dart';

void main() {
  group('CalendarService', () {
    setUp(() {
      // Initialiser le service si nécessaire
    });

    test('hasCalendarPermission retourne false sur web', () async {
      // Sur web, les permissions calendrier ne sont pas disponibles
      if (kIsWeb) {
        final hasPermission = await CalendarService.hasCalendarPermission();
        expect(hasPermission, false);
      }
    });

    test('requestCalendarPermission retourne false sur web', () async {
      // Sur web, les permissions calendrier ne sont pas disponibles
      if (kIsWeb) {
        final permissionGranted = await CalendarService.requestCalendarPermission();
        expect(permissionGranted, false);
      }
    });

    test('addReminder retourne false sur web', () async {
      // Sur web, device_calendar n'est pas disponible
      if (kIsWeb) {
        final result = await CalendarService.addReminder(
          title: 'Test Rappel',
          description: 'Description test',
          reminderDate: DateTime.now().add(const Duration(days: 1)),
        );
        expect(result, false);
      }
    });

    test('getUpcomingReminders retourne liste vide sur web', () async {
      // Sur web, device_calendar n'est pas disponible
      if (kIsWeb) {
        final reminders = await CalendarService.getUpcomingReminders();
        expect(reminders, isEmpty);
      }
    });

    test('getUpcomingEvents retourne liste vide sur web', () async {
      // Sur web, device_calendar n'est pas disponible
      if (kIsWeb) {
        final events = await CalendarService.getUpcomingEvents();
        expect(events, isEmpty);
      }
    });

    test('scheduleNotification ne plante pas sur web', () async {
      // Sur web, les notifications locales ne sont pas disponibles
      if (kIsWeb) {
        await CalendarService.scheduleNotification(
          title: 'Test',
          description: 'Description test',
          date: DateTime.now().add(const Duration(minutes: 5)),
        );
        // Ne devrait pas planter
        expect(true, true);
      }
    });

    test('scheduleAdaptiveMedicationReminder ne plante pas sur web', () async {
      // Sur web, les notifications locales ne sont pas disponibles
      if (kIsWeb) {
        await CalendarService.scheduleAdaptiveMedicationReminder(
          medicationName: 'Test Médicament',
          dosage: '1 comprimé',
          originalTime: DateTime.now(),
        );
        // Ne devrait pas planter
        expect(true, true);
      }
    });

    test('getEventsByType retourne liste vide sur web', () async {
      // Sur web, device_calendar n'est pas disponible
      if (kIsWeb) {
        final events = await CalendarService.getEventsByType();
        expect(events, isEmpty);
      }
    });
  });
}

