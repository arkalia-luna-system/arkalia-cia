import 'package:arkalia_cia/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('HomePage widget tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    Future<void> pumpHome(WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomePage()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 200));
      // Laisse les chargements asynchrones initiaux se stabiliser.
      await tester.pump(const Duration(seconds: 2));
    }

    testWidgets('affiche les elements principaux de l ecran accueil', (
      WidgetTester tester,
    ) async {
      await pumpHome(tester);

      expect(find.text('Arkalia CIA'), findsOneWidget);
      expect(find.text('Assistant Santé Personnel'), findsOneWidget);
      expect(find.text('Documents'), findsWidgets);
      expect(find.text('Rappels'), findsWidgets);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byTooltip('Paramètres'), findsOneWidget);
    });

    testWidgets('affiche la recherche et son acces avance', (
      WidgetTester tester,
    ) async {
      await pumpHome(tester);

      expect(
        find.text('Rechercher dans documents, rappels, contacts...'),
        findsOneWidget,
      );
      expect(find.byTooltip('Recherche avancée'), findsOneWidget);
    });
  });
}
