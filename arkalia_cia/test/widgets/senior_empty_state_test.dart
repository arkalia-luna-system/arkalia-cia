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

  testWidgets('SeniorEmptyState portails santé — copy ≥14sp vouvoyée', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SeniorEmptyState(
            icon: Icons.medical_services,
            title: 'Aucun portail santé',
            message: 'Appuyez sur + pour ajouter un portail.',
          ),
        ),
      ),
    );

    expect(find.text('Aucun portail santé'), findsOneWidget);
    expect(find.textContaining('Appuyez sur +'), findsOneWidget);
    expect(find.textContaining('Appuie sur'), findsNothing);
    expect(find.byIcon(Icons.medical_services), findsOneWidget);

    final message = tester.widget<Text>(find.textContaining('Appuyez sur +'));
    expect(message.style?.fontSize, greaterThanOrEqualTo(14));
  });

  testWidgets('SeniorEmptyState médecins — copy ≥14sp vouvoyée', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SeniorEmptyState(
            icon: Icons.people_outline,
            title: 'Aucun médecin trouvé',
            message:
                'Ajoutez un médecin pour retrouver rapidement ses coordonnées.',
            action: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Ajouter un médecin'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Aucun médecin trouvé'), findsOneWidget);
    expect(find.textContaining('Ajoutez un médecin'), findsOneWidget);
    expect(find.textContaining('Ajoute un médecin'), findsNothing);
    expect(find.text('Ajouter un médecin'), findsOneWidget);
    expect(find.byIcon(Icons.people_outline), findsOneWidget);

    final message = tester.widget<Text>(
      find.textContaining('Ajoutez un médecin pour retrouver'),
    );
    expect(message.style?.fontSize, greaterThanOrEqualTo(14));
  });
}
