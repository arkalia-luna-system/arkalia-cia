import 'package:arkalia_cia/widgets/emergency_contacts_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('EmergencyContactsEmptyState copy vouvoyé et thème', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: EmergencyContactsEmptyState())),
    );

    expect(find.text('Aucun contact d\'urgence'), findsOneWidget);
    expect(
      find.textContaining('Ajoutez ici 1 ou 2 personnes de confiance'),
      findsOneWidget,
    );
    expect(find.textContaining('Ajoute ici'), findsNothing);
    expect(find.textContaining('tu peux'), findsNothing);
    expect(find.byIcon(Icons.contact_phone_outlined), findsOneWidget);
  });
}
