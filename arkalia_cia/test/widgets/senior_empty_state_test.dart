import 'package:arkalia_cia/widgets/senior_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('SeniorEmptyState copy vouvoyée, ≥14sp et icône', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SeniorEmptyState(
            icon: Icons.event_busy,
            title: 'Aucun événement ce jour',
            message:
                'Appuyez sur un jour avec des petits points colorés pour voir vos rendez-vous et rappels.',
          ),
        ),
      ),
    );

    expect(find.text('Aucun événement ce jour'), findsOneWidget);
    expect(find.textContaining('Appuyez sur un jour'), findsOneWidget);
    expect(find.textContaining('vos rendez-vous'), findsOneWidget);
    expect(find.textContaining('Appuie sur'), findsNothing);
    expect(find.textContaining('tes rendez'), findsNothing);
    expect(find.byIcon(Icons.event_busy), findsOneWidget);

    final message = tester.widget<Text>(
      find.textContaining('Appuyez sur un jour'),
    );
    expect(message.style?.fontSize, greaterThanOrEqualTo(14));
  });
}
