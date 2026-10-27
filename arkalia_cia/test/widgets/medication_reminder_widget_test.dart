import 'package:arkalia_cia/models/medication.dart';
import 'package:arkalia_cia/widgets/medication_reminder_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Medication buildMed() => Medication(
    id: 1,
    name: 'Doliprane',
    dosage: '500 mg',
    startDate: DateTime(2024, 1, 1),
  );

  testWidgets('affiche nom, dosage et heure avec couleurs thème', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MedicationReminderWidget(
            medication: buildMed(),
            time: const TimeOfDay(hour: 8, minute: 30),
          ),
        ),
      ),
    );

    expect(find.text('Doliprane'), findsOneWidget);
    expect(find.text('Dosage : 500 mg'), findsOneWidget);
    expect(find.text('08:30'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(find.byTooltip('Marquer comme pris'), findsOneWidget);
    expect(find.byTooltip('Ignorer'), findsOneWidget);
  });

  testWidgets('état pris : barre le nom et masque les actions', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MedicationReminderWidget(
            medication: buildMed(),
            time: const TimeOfDay(hour: 8, minute: 0),
            isTaken: true,
          ),
        ),
      ),
    );

    final name = tester.widget<Text>(find.text('Doliprane'));
    expect(name.style?.decoration, TextDecoration.lineThrough);
    expect(find.byTooltip('Marquer comme pris'), findsNothing);
    expect(find.byTooltip('Ignorer'), findsNothing);
  });
}
