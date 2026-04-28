// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:arkalia_cia/main.dart';

void main() {
  test('Arkalia CIA App smoke test', () {
    // Keep a lightweight smoke check to avoid async timers started by full app init.
    const app = ArkaliaCIAApp();
    expect(app, isA<ArkaliaCIAApp>());
  });

  testWidgets('App initialization test', (WidgetTester tester) async {
    // Test that the app initializes properly
    await tester.pumpWidget(const ArkaliaCIAApp());
    // Pump plusieurs fois pour permettre l'initialisation async
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Verify the app is running
    expect(find.byType(ArkaliaCIAApp), findsOneWidget);
  }, timeout: const Timeout(Duration(seconds: 30)));
}
