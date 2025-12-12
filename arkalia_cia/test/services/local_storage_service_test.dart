import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arkalia_cia/services/local_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocalStorageService', () {
    setUp(() async {
      // Réinitialiser les préférences avant chaque test
      SharedPreferences.setMockInitialValues({});
    });

    test('init should not throw', () async {
      expect(() => LocalStorageService.init(), returnsNormally);
      await LocalStorageService.init();
    });

    group('Documents', () {
      test('should save and retrieve documents', () async {
        final document = {'id': '1', 'name': 'Test Document', 'type': 'pdf'};
        await LocalStorageService.saveDocument(document);

        final documents = await LocalStorageService.getDocuments();
        expect(documents.length, 1);
        expect(documents[0]['name'], 'Test Document');
      });

      test('should update document', () async {
        final document = {'id': '1', 'name': 'Test Document'};
        await LocalStorageService.saveDocument(document);

        final updated = {'id': '1', 'name': 'Updated Document'};
        await LocalStorageService.updateDocument(updated);

        final documents = await LocalStorageService.getDocuments();
        expect(documents[0]['name'], 'Updated Document');
      });

      test('should delete document', () async {
        final document = {'id': '1', 'name': 'Test Document'};
        await LocalStorageService.saveDocument(document);
        await LocalStorageService.deleteDocument('1');

        final documents = await LocalStorageService.getDocuments();
        expect(documents.length, 0);
      });
    });

    group('Reminders', () {
      test('should save and retrieve reminders', () async {
        final reminder = {'id': '1', 'title': 'Test Reminder'};
        await LocalStorageService.saveReminder(reminder);

        final reminders = await LocalStorageService.getReminders();
        expect(reminders.length, 1);
        expect(reminders[0]['title'], 'Test Reminder');
      });

      test('should update reminder', () async {
        final reminder = {'id': '1', 'title': 'Test Reminder'};
        await LocalStorageService.saveReminder(reminder);

        final updated = {'id': '1', 'title': 'Updated Reminder'};
        await LocalStorageService.updateReminder(updated);

        final reminders = await LocalStorageService.getReminders();
        expect(reminders[0]['title'], 'Updated Reminder');
      });

      test('should delete reminder', () async {
        final reminder = {'id': '1', 'title': 'Test Reminder'};
        await LocalStorageService.saveReminder(reminder);
        await LocalStorageService.deleteReminder('1');

        final reminders = await LocalStorageService.getReminders();
        expect(reminders.length, 0);
      });

      test('should mark reminder as complete', () async {
        final reminder = {'id': '1', 'title': 'Test Reminder'};
        await LocalStorageService.saveReminder(reminder);
        await LocalStorageService.markReminderComplete('1');

        final reminders = await LocalStorageService.getReminders();
        expect(reminders[0]['is_completed'], isTrue);
        expect(reminders[0]['completed_at'], isNotNull);
      });
    });

    group('Emergency Contacts', () {
      test('should save and retrieve emergency contacts', () async {
        final contact = {'id': '1', 'name': 'John Doe', 'phone': '0412345678'};
        await LocalStorageService.saveEmergencyContact(contact);

        final contacts = await LocalStorageService.getEmergencyContacts();
        expect(contacts.length, 1);
        expect(contacts[0]['name'], 'John Doe');
      });

      test('should update emergency contact', () async {
        final contact = {'id': '1', 'name': 'John Doe'};
        await LocalStorageService.saveEmergencyContact(contact);

        final updated = {'id': '1', 'name': 'Jane Doe'};
        await LocalStorageService.updateEmergencyContact(updated);

        final contacts = await LocalStorageService.getEmergencyContacts();
        expect(contacts[0]['name'], 'Jane Doe');
      });

      test('should delete emergency contact', () async {
        final contact = {'id': '1', 'name': 'John Doe'};
        await LocalStorageService.saveEmergencyContact(contact);
        await LocalStorageService.deleteEmergencyContact('1');

        final contacts = await LocalStorageService.getEmergencyContacts();
        expect(contacts.length, 0);
      });
    });

    group('Emergency Info', () {
      test('should save and retrieve emergency info', () async {
        final info = {'blood_type': 'O+', 'allergies': 'None'};
        await LocalStorageService.saveEmergencyInfo(info);

        final retrieved = await LocalStorageService.getEmergencyInfo();
        expect(retrieved?['blood_type'], 'O+');
        expect(retrieved?['allergies'], 'None');
      });

      test('should return null when no emergency info', () async {
        final info = await LocalStorageService.getEmergencyInfo();
        expect(info, isNull);
      });
    });

    group('Utilities', () {
      test('should clear all data', () async {
        await LocalStorageService.saveDocument({'id': '1', 'name': 'Test'});
        await LocalStorageService.saveReminder({'id': '1', 'title': 'Test'});
        await LocalStorageService.saveEmergencyContact({'id': '1', 'name': 'Test'});
        await LocalStorageService.saveEmergencyInfo({'info': 'test'});

        await LocalStorageService.clearAllData();

        expect(await LocalStorageService.getDocuments(), isEmpty);
        expect(await LocalStorageService.getReminders(), isEmpty);
        expect(await LocalStorageService.getEmergencyContacts(), isEmpty);
        expect(await LocalStorageService.getEmergencyInfo(), isNull);
      });

      test('should check if has any data', () async {
        expect(await LocalStorageService.hasAnyData(), isFalse);

        await LocalStorageService.saveDocument({'id': '1', 'name': 'Test'});
        expect(await LocalStorageService.hasAnyData(), isTrue);
      });

      test('should export all data', () async {
        await LocalStorageService.saveDocument({'id': '1', 'name': 'Doc'});
        await LocalStorageService.saveReminder({'id': '1', 'title': 'Reminder'});
        await LocalStorageService.saveEmergencyContact({'id': '1', 'name': 'Contact'});
        await LocalStorageService.saveEmergencyInfo({'info': 'test'});

        final exported = await LocalStorageService.exportAllData();

        expect(exported['documents'], isNotEmpty);
        expect(exported['reminders'], isNotEmpty);
        expect(exported['emergency_contacts'], isNotEmpty);
        expect(exported['emergency_info'], isNotNull);
        expect(exported['export_date'], isNotNull);
      });

      test('should import all data', () async {
        final backup = {
          'documents': [{'id': '1', 'name': 'Imported Doc'}],
          'reminders': [{'id': '1', 'title': 'Imported Reminder'}],
          'emergency_contacts': [{'id': '1', 'name': 'Imported Contact'}],
          'emergency_info': {'info': 'imported'},
        };

        await LocalStorageService.importAllData(backup);

        final documents = await LocalStorageService.getDocuments();
        final reminders = await LocalStorageService.getReminders();
        final contacts = await LocalStorageService.getEmergencyContacts();
        final info = await LocalStorageService.getEmergencyInfo();

        expect(documents.length, 1);
        expect(documents[0]['name'], 'Imported Doc');
        expect(reminders.length, 1);
        expect(reminders[0]['title'], 'Imported Reminder');
        expect(contacts.length, 1);
        expect(contacts[0]['name'], 'Imported Contact');
        expect(info?['info'], 'imported');
      });

      test('should handle partial import', () async {
        final backup = {
          'documents': [{'id': '1', 'name': 'Imported Doc'}],
          // Pas de reminders, contacts ou info
        };

        await LocalStorageService.importAllData(backup);

        final documents = await LocalStorageService.getDocuments();
        expect(documents.length, 1);
        expect(await LocalStorageService.getReminders(), isEmpty);
      });
    });
  });
}

