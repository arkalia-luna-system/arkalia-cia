import 'package:arkalia_cia/screens/health_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Health AppBar colorScheme et FAB Semantics', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HealthScreen()));
    await tester.pump();
    // Laisser le chargement async des portails démarrer
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Portails Santé'), findsOneWidget);

    final context = tester.element(find.byType(AppBar));
    final scheme = Theme.of(context).colorScheme;
    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    expect(appBar.backgroundColor, scheme.primary);
    expect(appBar.foregroundColor, scheme.onPrimary);

    expect(find.bySemanticsLabel('Ajouter un portail santé'), findsOneWidget);
  });
}
