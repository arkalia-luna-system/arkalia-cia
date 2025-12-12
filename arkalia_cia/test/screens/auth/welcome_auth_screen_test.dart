// Tests pour WelcomeAuthScreen
// Date: 12 décembre 2025

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:arkalia_cia/screens/auth/welcome_auth_screen.dart';
import 'package:arkalia_cia/screens/auth/login_screen.dart';
import 'package:arkalia_cia/screens/auth/register_screen.dart';

void main() {
  group('WelcomeAuthScreen Tests', () {
    testWidgets('Affiche le titre et le sous-titre', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WelcomeAuthScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Arkalia CIA'), findsOneWidget);
      expect(find.text('Votre Carnet de Santé'), findsOneWidget);
    });

    testWidgets('Affiche les deux boutons principaux', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WelcomeAuthScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('SE CONNECTER'), findsOneWidget);
      expect(find.text('CRÉER UN COMPTE'), findsOneWidget);
    });

    testWidgets('Bouton SE CONNECTER navigue vers LoginScreen', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WelcomeAuthScreen(),
        ),
      );

      await tester.pumpAndSettle();

      final loginButton = find.text('SE CONNECTER');
      expect(loginButton, findsOneWidget);

      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('Bouton CRÉER UN COMPTE navigue vers RegisterScreen', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WelcomeAuthScreen(),
        ),
      );

      await tester.pumpAndSettle();

      final registerButton = find.text('CRÉER UN COMPTE');
      expect(registerButton, findsOneWidget);

      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      expect(find.byType(RegisterScreen), findsOneWidget);
    });

    testWidgets('Affiche l\'icône de santé', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WelcomeAuthScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.health_and_safety), findsOneWidget);
    });

    testWidgets('L\'écran est scrollable', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WelcomeAuthScreen(),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}

