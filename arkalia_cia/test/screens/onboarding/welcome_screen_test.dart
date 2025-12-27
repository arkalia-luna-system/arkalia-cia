// Tests pour WelcomeScreen
// Date: 10 décembre 2025

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:arkalia_cia/screens/onboarding/welcome_screen.dart';
import 'package:arkalia_cia/screens/onboarding/import_choice_screen.dart';

void main() {
  group('WelcomeScreen Tests', () {
    testWidgets('Affiche le titre et la description', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WelcomeScreen(),
        ),
      );

      expect(find.text('Bienvenue dans Arkalia CIA'), findsOneWidget);
      expect(find.textContaining('Votre assistant santé personnel'), findsOneWidget);
    });

    testWidgets('Affiche les fonctionnalités', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WelcomeScreen(),
        ),
      );

      expect(find.text('Import automatique'), findsOneWidget);
      expect(find.text('100% sécurisé'), findsOneWidget);
      expect(find.text('Intelligent'), findsOneWidget);
    });

    testWidgets('Bouton Commencer navigue vers ImportChoiceScreen', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WelcomeScreen(),
        ),
      );

      final button = find.text('Commencer');
      expect(button, findsOneWidget);

      await tester.tap(button);
      // Ne pas utiliser pumpAndSettle pour éviter les blocages
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ImportChoiceScreen), findsOneWidget);
    });

    testWidgets('L\'écran est scrollable', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WelcomeScreen(),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}

