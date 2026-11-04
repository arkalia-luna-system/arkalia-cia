import 'package:arkalia_cia/widgets/emergency_contact_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('EmergencyContactCard chrome colorScheme + Semantics CTA', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EmergencyContactCard(
            contact: {
              'name': 'Marie Dupont',
              'display_name': 'Maman',
              'phone': '0601020304',
              'relationship': 'Famille',
              'is_primary': true,
              'emoji': '👩',
            },
          ),
        ),
      ),
    );

    expect(find.text('Maman'), findsOneWidget);
    expect(find.text('Marie Dupont'), findsOneWidget);
    expect(find.text('Famille'), findsOneWidget);
    expect(find.text('Appeler'), findsOneWidget);
    expect(find.text('SMS'), findsOneWidget);
    expect(find.text('WhatsApp'), findsOneWidget);
    expect(find.text('Copier'), findsOneWidget);

    expect(find.bySemanticsLabel('Appeler Maman'), findsOneWidget);
    expect(find.bySemanticsLabel('Envoyer un SMS à Maman'), findsOneWidget);
    expect(find.bySemanticsLabel('Ouvrir WhatsApp pour Maman'), findsOneWidget);
    expect(find.bySemanticsLabel('Copier le numéro de Maman'), findsOneWidget);
  });
}
