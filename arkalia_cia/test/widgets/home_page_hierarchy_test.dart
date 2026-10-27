import 'package:arkalia_cia/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Home expose Accès rapide et section Plus', (tester) async {
    // Surface haute pour scroller jusqu'à « Plus » sans hit-test hors écran.
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: HomePage()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Accès rapide'), findsOneWidget);
    expect(find.text('Documents'), findsWidgets);
    expect(find.text('Urgence'), findsOneWidget);
    expect(find.text('Plus'), findsOneWidget);

    await tester.ensureVisible(find.text('Plus'));
    await tester.tap(find.text('Plus'));
    // Éviter pumpAndSettle : HomePage a des timers / reloads stats.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Hydratation'), findsOneWidget);
    expect(find.text('Médecins'), findsOneWidget);
    expect(find.text('Pathologies'), findsOneWidget);
  });
}
