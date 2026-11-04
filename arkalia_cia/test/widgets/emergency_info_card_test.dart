import 'package:arkalia_cia/widgets/emergency_info_card.dart';
import 'package:arkalia_cia/widgets/senior_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('EmergencyInfoCard empty → SeniorEmptyState + CTA', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EmergencyInfoCard(
            emergencyInfo: const {},
            onEdit: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.byType(SeniorEmptyState), findsOneWidget);
    expect(find.text('Aucune information médicale'), findsOneWidget);
    expect(find.text('Ajouter des informations'), findsOneWidget);

    await tester.tap(find.text('Ajouter des informations'));
    await tester.pump();
    expect(tapped, isTrue);
  });

  testWidgets('EmergencyInfoCard filled → colorScheme chrome', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EmergencyInfoCard(
            emergencyInfo: const {
              'blood_type': 'A+',
              'allergies': 'Pénicilline',
            },
          ),
        ),
      ),
    );

    expect(find.text('Informations médicales'), findsOneWidget);
    expect(find.text('Groupe sanguin'), findsOneWidget);
    expect(find.text('A+'), findsOneWidget);
    expect(find.text('Allergies'), findsOneWidget);
    expect(find.text('Pénicilline'), findsOneWidget);
    expect(find.byType(SeniorEmptyState), findsNothing);
  });
}
