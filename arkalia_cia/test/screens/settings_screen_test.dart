import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:arkalia_cia/screens/settings_screen.dart';

void main() {
  group('SettingsScreen - Statistiques', () {
    testWidgets('affiche section Statistiques dans les paramètres', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );

      // Attendre que l'écran soit chargé
      await tester.pumpAndSettle();

      // Vérifier que la section Statistiques est présente
      expect(find.text('Statistiques'), findsOneWidget);
      expect(find.text('Statistiques détaillées'), findsOneWidget);
      expect(find.text('Voir graphiques et analyses complètes'), findsOneWidget);
    });

    testWidgets('affiche icône bar_chart pour section Statistiques', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );

      // Attendre que l'écran soit chargé
      await tester.pumpAndSettle();

      // Vérifier que l'icône est présente
      expect(find.byIcon(Icons.bar_chart), findsWidgets);
    });

    testWidgets('ListTile Statistiques détaillées est cliquable', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );

      // Attendre que l'écran soit chargé
      await tester.pumpAndSettle();

      // Trouver le ListTile des statistiques
      final statsTile = find.text('Statistiques détaillées');
      expect(statsTile, findsOneWidget);

      // Vérifier qu'il y a un trailing chevron (indique navigation)
      expect(find.byIcon(Icons.chevron_right), findsWidgets);
    });
  });
}

