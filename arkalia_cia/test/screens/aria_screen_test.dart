import 'package:arkalia_cia/screens/aria_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('ARIA AppBar utilise colorScheme et CTA a Semantics', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ARIAScreen()));
    await tester.pump();

    expect(find.text('ARKALIA ARIA'), findsOneWidget);

    final context = tester.element(find.byType(AppBar));
    final scheme = Theme.of(context).colorScheme;
    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    expect(appBar.backgroundColor, scheme.primary);
    expect(appBar.foregroundColor, scheme.onPrimary);

    expect(find.bySemanticsLabel('ARIA non disponible'), findsOneWidget);
  });
}
