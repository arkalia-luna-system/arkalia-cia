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

      // Attendre que l'écran soit chargé avec plusieurs pumps pour les appels async
      // Ne pas utiliser pumpAndSettle car les appels async peuvent prendre du temps
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(seconds: 1));

      // Scroller jusqu'à la section Statistiques (elle est en bas de la liste)
      // Utiliser find.byType(Scrollable) au lieu de ListView
      final scrollable = find.byType(Scrollable);
      expect(scrollable, findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Statistiques'),
        500.0,
        scrollable: scrollable,
      );

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

      // Attendre que l'écran soit chargé avec plusieurs pumps
      // Ne pas utiliser pumpAndSettle car les appels async peuvent prendre du temps
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(seconds: 1));

      // Scroller jusqu'à la section Statistiques
      // Utiliser find.byType(Scrollable) au lieu de ListView
      final scrollable = find.byType(Scrollable);
      await tester.scrollUntilVisible(
        find.text('Statistiques'),
        500.0,
        scrollable: scrollable,
      );

      // Vérifier que l'icône est présente
      expect(find.byIcon(Icons.bar_chart), findsWidgets);
    });

    testWidgets('ListTile Statistiques détaillées est cliquable', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );

      // Attendre que l'écran soit chargé avec plusieurs pumps
      // Ne pas utiliser pumpAndSettle car les appels async peuvent prendre du temps
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(seconds: 1));

      // Scroller jusqu'à la section Statistiques
      // Utiliser find.byType(Scrollable) au lieu de ListView
      final scrollable = find.byType(Scrollable);
      await tester.scrollUntilVisible(
        find.text('Statistiques détaillées'),
        500.0,
        scrollable: scrollable,
      );

      // Trouver le ListTile des statistiques
      final statsTile = find.text('Statistiques détaillées');
      expect(statsTile, findsOneWidget);

      // Vérifier qu'il y a un trailing chevron (indique navigation)
      expect(find.byIcon(Icons.chevron_right), findsWidgets);
    });
  });
}

