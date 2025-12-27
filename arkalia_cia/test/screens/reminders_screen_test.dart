// Tests pour RemindersScreen
// Date: 12 décembre 2025

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:arkalia_cia/screens/reminders_screen.dart';
import 'package:arkalia_cia/services/local_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('RemindersScreen Tests', () {
    setUp(() async {
      // Réinitialiser les préférences avant chaque test
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      // Réinitialiser les rappels
      final reminders = await LocalStorageService.getReminders();
      for (final reminder in reminders) {
        if (reminder['id'] != null) {
          await LocalStorageService.deleteReminder(reminder['id'].toString());
        }
      }
    });

    testWidgets('Affiche le titre de l\'écran', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RemindersScreen(),
        ),
      );

      // Attendre le chargement complet avec plusieurs pumps
      // Ne pas utiliser pumpAndSettle car CalendarService peut bloquer en test
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      // Attendre que le timeout de CalendarService (2 secondes) soit passé
      await tester.pump(const Duration(seconds: 2));
      // Un dernier pump pour s'assurer que tout est stable
      await tester.pump();

      expect(find.text('Rappels'), findsOneWidget);
    });

    testWidgets('Affiche un message quand il n\'y a pas de rappels', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RemindersScreen(),
        ),
      );

      // Attendre le chargement complet avec plusieurs pumps
      // Ne pas utiliser pumpAndSettle car CalendarService peut bloquer en test
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      // Attendre que le timeout de CalendarService (2 secondes) soit passé
      await tester.pump(const Duration(seconds: 2));
      // Un dernier pump pour s'assurer que tout est stable
      await tester.pump();

      // L'icône notifications_none est affichée dans l'état vide
      expect(find.byIcon(Icons.notifications_none), findsOneWidget);
    });

    testWidgets('Affiche le bouton d\'ajout de rappel', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RemindersScreen(),
        ),
      );

      // Attendre le chargement complet avec plusieurs pumps
      // Ne pas utiliser pumpAndSettle car CalendarService peut bloquer en test
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      // Attendre que le timeout de CalendarService (2 secondes) soit passé
      await tester.pump(const Duration(seconds: 2));
      // Un dernier pump pour s'assurer que tout est stable
      await tester.pump();

      // Le bouton add est dans le FloatingActionButton (plus spécifique)
      // Il y a aussi un bouton "Créer un rappel" dans l'état vide, donc on cherche le FloatingActionButton
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsWidgets); // Il y en a plusieurs, c'est normal
    });

    testWidgets('Affiche les rappels existants', (WidgetTester tester) async {
      // Créer un rappel de test
      final testReminder = {
        'id': 'test_reminder_1',
        'title': 'Test Rappel',
        'description': 'Description test',
        'reminder_date': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
        'is_completed': false,
        'source': 'local',
        'created_at': DateTime.now().toIso8601String(),
      };

      await LocalStorageService.saveReminder(testReminder);
      
      // Vérifier que le rappel est bien sauvegardé avant de charger l'écran
      final savedReminders = await LocalStorageService.getReminders();
      expect(savedReminders.length, greaterThan(0));
      expect(savedReminders.any((r) => r['id'] == 'test_reminder_1'), isTrue);

      await tester.pumpWidget(
        const MaterialApp(
          home: RemindersScreen(),
        ),
      );

      // Les rappels locaux sont chargés en premier dans _loadReminders, avant CalendarService
      // On attend seulement quelques frames pour que les rappels locaux soient affichés
      // Ne pas attendre CalendarService qui peut bloquer indéfiniment
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump();
      
      // Vérifier directement que le texte est présent
      // Si le texte n'est pas trouvé, attendre encore un peu (max 500ms)
      int attempts = 0;
      const maxAttempts = 10; // 10 * 50ms = 500ms max
      while (find.text('Test Rappel').evaluate().isEmpty && attempts < maxAttempts) {
        await tester.pump(const Duration(milliseconds: 50));
        attempts++;
      }
      
      // Vérifier que le texte est présent (les rappels locaux doivent être chargés)
      expect(find.text('Test Rappel'), findsOneWidget, reason: 'Le titre du rappel doit être affiché');
      expect(find.text('Description test'), findsOneWidget, reason: 'La description du rappel doit être affichée');
    }, timeout: const Timeout(Duration(seconds: 10)));

    testWidgets('Affiche le bouton Modifier sur les rappels non terminés', (WidgetTester tester) async {
      // Créer un rappel de test non terminé
      final testReminder = {
        'id': 'test_reminder_2',
        'title': 'Rappel à modifier',
        'description': 'Description',
        'reminder_date': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
        'is_completed': false,
        'source': 'local',
        'created_at': DateTime.now().toIso8601String(),
      };

      await LocalStorageService.saveReminder(testReminder);

      await tester.pumpWidget(
        const MaterialApp(
          home: RemindersScreen(),
        ),
      );

      // Attendre que les rappels locaux soient chargés (sans attendre CalendarService)
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();
      
      // Attendre que l'icône apparaisse (max 1 seconde)
      int attempts = 0;
      const maxAttempts = 20; // 20 * 50ms = 1 seconde max
      while (find.byIcon(Icons.edit).evaluate().isEmpty && attempts < maxAttempts) {
        await tester.pump(const Duration(milliseconds: 50));
        attempts++;
      }

      // Vérifier que le bouton Modifier (icône edit) est présent
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('Affiche le bouton Terminer sur les rappels non terminés', (WidgetTester tester) async {
      // Créer un rappel de test non terminé
      final testReminder = {
        'id': 'test_reminder_3',
        'title': 'Rappel à terminer',
        'description': 'Description',
        'reminder_date': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
        'is_completed': false,
        'source': 'local',
        'created_at': DateTime.now().toIso8601String(),
      };

      await LocalStorageService.saveReminder(testReminder);

      await tester.pumpWidget(
        const MaterialApp(
          home: RemindersScreen(),
        ),
      );

      // Attendre le chargement complet avec plusieurs pumps
      // Ne pas utiliser pumpAndSettle car CalendarService peut bloquer en test
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(seconds: 1));

      // Vérifier que le bouton Terminer (icône check_circle_outline) est présent
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    testWidgets('N\'affiche pas le bouton Modifier sur les rappels terminés', (WidgetTester tester) async {
      // Créer un rappel de test terminé
      final testReminder = {
        'id': 'test_reminder_4',
        'title': 'Rappel terminé',
        'description': 'Description',
        'reminder_date': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
        'is_completed': true,
        'source': 'local',
        'created_at': DateTime.now().toIso8601String(),
      };

      await LocalStorageService.saveReminder(testReminder);

      await tester.pumpWidget(
        const MaterialApp(
          home: RemindersScreen(),
        ),
      );

      // Attendre le chargement complet avec plusieurs pumps
      // Ne pas utiliser pumpAndSettle car CalendarService peut bloquer en test
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(seconds: 1));

      // Vérifier que le bouton Modifier n'est pas présent
      expect(find.byIcon(Icons.edit), findsNothing);
      // Mais l'icône check (terminé) est présente
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('Affiche la date formatée correctement', (WidgetTester tester) async {
      final testDate = DateTime.now().add(const Duration(days: 1));
      final testReminder = {
        'id': 'test_reminder_5',
        'title': 'Rappel avec date',
        'description': 'Description',
        'reminder_date': testDate.toIso8601String(),
        'is_completed': false,
        'source': 'local',
        'created_at': DateTime.now().toIso8601String(),
      };

      await LocalStorageService.saveReminder(testReminder);

      await tester.pumpWidget(
        const MaterialApp(
          home: RemindersScreen(),
        ),
      );

      // Attendre le chargement complet avec plusieurs pumps
      // Ne pas utiliser pumpAndSettle car CalendarService peut bloquer en test
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(seconds: 1));

      // Vérifier que la date formatée est affichée (format: DD/MM/YYYY à HH:MM)
      expect(find.textContaining('${testDate.day}/${testDate.month}/${testDate.year}'), findsOneWidget);
    });

    testWidgets('L\'écran est scrollable', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RemindersScreen(),
        ),
      );

      // Attendre le chargement complet avec plusieurs pumps
      // Ne pas utiliser pumpAndSettle car CalendarService peut bloquer en test
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('Affiche le bouton de rafraîchissement', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RemindersScreen(),
        ),
      );

      // Attendre le chargement complet avec plusieurs pumps
      // Ne pas utiliser pumpAndSettle car CalendarService peut bloquer en test
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(seconds: 1));

      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });
  });

  group('LocalStorageService - Rappels', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    });

    test('saveReminder sauvegarde un rappel', () async {
      final reminder = {
        'id': 'test_1',
        'title': 'Test',
        'reminder_date': DateTime.now().toIso8601String(),
        'is_completed': false,
      };

      await LocalStorageService.saveReminder(reminder);

      final reminders = await LocalStorageService.getReminders();
      expect(reminders.length, 1);
      expect(reminders.first['id'], 'test_1');
      expect(reminders.first['title'], 'Test');
    });

    test('updateReminder met à jour un rappel existant', () async {
      // Créer un rappel
      final reminder = {
        'id': 'test_2',
        'title': 'Titre original',
        'description': 'Description originale',
        'reminder_date': DateTime.now().toIso8601String(),
        'is_completed': false,
        'source': 'local',
        'created_at': DateTime.now().toIso8601String(),
      };

      await LocalStorageService.saveReminder(reminder);

      // Mettre à jour le rappel
      final updatedReminder = {
        ...reminder,
        'title': 'Titre modifié',
        'description': 'Description modifiée',
        'updated_at': DateTime.now().toIso8601String(),
      };

      await LocalStorageService.updateReminder(updatedReminder);

      // Vérifier la mise à jour
      final reminders = await LocalStorageService.getReminders();
      expect(reminders.length, 1);
      expect(reminders.first['title'], 'Titre modifié');
      expect(reminders.first['description'], 'Description modifiée');
    });

    test('markReminderComplete marque un rappel comme terminé', () async {
      // Créer un rappel
      final reminder = {
        'id': 'test_3',
        'title': 'Test',
        'reminder_date': DateTime.now().toIso8601String(),
        'is_completed': false,
      };

      await LocalStorageService.saveReminder(reminder);

      // Marquer comme terminé
      await LocalStorageService.markReminderComplete('test_3');

      // Vérifier
      final reminders = await LocalStorageService.getReminders();
      expect(reminders.length, 1);
      expect(reminders.first['is_completed'], true);
    });

    test('deleteReminder supprime un rappel', () async {
      // Créer un rappel
      final reminder = {
        'id': 'test_4',
        'title': 'Test',
        'reminder_date': DateTime.now().toIso8601String(),
        'is_completed': false,
      };

      await LocalStorageService.saveReminder(reminder);

      // Supprimer
      await LocalStorageService.deleteReminder('test_4');

      // Vérifier
      final reminders = await LocalStorageService.getReminders();
      expect(reminders.length, 0);
    });
  });
}

