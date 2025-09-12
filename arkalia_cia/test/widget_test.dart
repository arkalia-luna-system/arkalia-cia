// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:arkalia_cia/main.dart';

void main() {
  testWidgets('Arkalia CIA App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ArkaliaCIAApp());

    // Verify that our app loads without crashing
    expect(find.byType(ArkaliaCIAApp), findsOneWidget);
  });

  testWidgets('App initialization test', (WidgetTester tester) async {
    // Test that the app initializes properly
    await tester.pumpWidget(const ArkaliaCIAApp());
    await tester.pumpAndSettle();

    // Verify the app is running
    expect(find.byType(ArkaliaCIAApp), findsOneWidget);
  });
}
