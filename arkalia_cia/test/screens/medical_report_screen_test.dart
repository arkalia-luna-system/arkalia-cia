import 'package:arkalia_cia/screens/medical_report_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('affiche AppBar thématisé et état loading puis erreur backend', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: MedicalReportScreen()));

    expect(find.text('Rapport médical'), findsOneWidget);
    expect(find.text('Préparation de votre rapport…'), findsOneWidget);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Rapport indisponible'), findsOneWidget);
    expect(find.textContaining('Backend'), findsOneWidget);
    expect(find.text('Réessayer'), findsOneWidget);

    final context = tester.element(find.byType(AppBar));
    final scheme = Theme.of(context).colorScheme;
    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    expect(appBar.backgroundColor, scheme.primary);
    expect(appBar.foregroundColor, scheme.onPrimary);
  });
}
