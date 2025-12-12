// Tests pour WelcomeAuthScreen
// Date: 12 décembre 2025

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:arkalia_cia/screens/auth/welcome_auth_screen.dart';
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

    testWidgets('Affiche les boutons principaux (Gmail, Google, Créer un compte)', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WelcomeAuthScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Continuer avec Gmail'), findsOneWidget);
      expect(find.text('Continuer avec Google'), findsOneWidget);
      expect(find.text('CRÉER UN COMPTE'), findsOneWidget);
      expect(find.text('J\'ai déjà un compte'), findsOneWidget);
    });

    testWidgets('Bouton J\'ai déjà un compte existe', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WelcomeAuthScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier que le bouton existe (même s'il est hors écran)
      final loginButton = find.text('J\'ai déjà un compte');
      expect(loginButton, findsOneWidget);
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
