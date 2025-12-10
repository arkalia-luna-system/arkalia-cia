// Tests pour RegisterScreen
// Date: 10 décembre 2025

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:arkalia_cia/screens/auth/register_screen.dart';

void main() {
  group('RegisterScreen Tests', () {
    testWidgets('Affiche le formulaire d\'inscription', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RegisterScreen(),
        ),
      );

      expect(find.text('Créer un compte'), findsOneWidget);
      expect(find.text('Nom d\'utilisateur *'), findsOneWidget);
      expect(find.text('Email (recommandé)'), findsOneWidget);
      expect(find.text('Mot de passe *'), findsOneWidget);
      expect(find.text('Confirmer le mot de passe *'), findsOneWidget);
    });

    testWidgets('Valide le nom d\'utilisateur (minimum 3 caractères)', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RegisterScreen(),
        ),
      );

      final usernameField = find.widgetWithText(TextFormField, 'Nom d\'utilisateur *');
      await tester.enterText(usernameField, 'ab');
      await tester.tap(find.text('Créer le compte'));
      await tester.pump();

      expect(find.text('Le nom d\'utilisateur doit contenir au moins 3 caractères'), findsOneWidget);
    });

    testWidgets('Valide le mot de passe (minimum 8 caractères)', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RegisterScreen(),
        ),
      );

      final passwordField = find.widgetWithText(TextFormField, 'Mot de passe *');
      await tester.enterText(passwordField, 'short');
      await tester.tap(find.text('Créer le compte'));
      await tester.pump();

      expect(find.text('Le mot de passe doit contenir au moins 8 caractères'), findsOneWidget);
    });

    testWidgets('Valide la confirmation du mot de passe', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RegisterScreen(),
        ),
      );

      final passwordField = find.widgetWithText(TextFormField, 'Mot de passe *');
      final confirmPasswordField = find.widgetWithText(TextFormField, 'Confirmer le mot de passe *');

      await tester.enterText(passwordField, 'password123');
      await tester.enterText(confirmPasswordField, 'different');
      await tester.tap(find.text('Créer le compte'));
      await tester.pump();

      expect(find.text('Les mots de passe ne correspondent pas'), findsOneWidget);
    });

    testWidgets('Valide le format email si fourni', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RegisterScreen(),
        ),
      );

      // Remplir les champs requis d'abord
      final usernameField = find.widgetWithText(TextFormField, 'Nom d\'utilisateur *');
      final passwordField = find.widgetWithText(TextFormField, 'Mot de passe *');
      final confirmPasswordField = find.widgetWithText(TextFormField, 'Confirmer le mot de passe *');
      final emailField = find.widgetWithText(TextFormField, 'Email (recommandé)');
      
      await tester.enterText(usernameField, 'testuser');
      await tester.enterText(passwordField, 'password123');
      await tester.enterText(confirmPasswordField, 'password123');
      await tester.enterText(emailField, 'invalid-email');
      
      // Sortir du champ email pour déclencher la validation
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      
      await tester.tap(find.text('Créer le compte'));
      await tester.pumpAndSettle();

      // Le message d'erreur peut être dans un Text widget ou dans le helperText
      expect(find.textContaining('Format d\'email invalide'), findsWidgets);
    });

    testWidgets('Affiche le texte d\'aide pour l\'email', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RegisterScreen(),
        ),
      );

      expect(find.text('Permet la récupération de compte si vous oubliez votre mot de passe'), findsOneWidget);
    });

    testWidgets('L\'écran est scrollable', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RegisterScreen(),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}

