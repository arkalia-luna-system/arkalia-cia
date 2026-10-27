import 'package:arkalia_cia/widgets/documents/documents_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('DocumentsEmptyState affiche le copy vouvoyé et le CTA', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DocumentsEmptyState(onAdd: () => tapped = true),
        ),
      ),
    );

    expect(find.text('Aucun document médical enregistré'), findsOneWidget);
    expect(
      find.textContaining('Appuyez sur le bouton ci-dessous'),
      findsOneWidget,
    );
    expect(find.textContaining('ton premier'), findsNothing);
    expect(find.text('Ajouter un document médical'), findsOneWidget);

    await tester.tap(find.text('Ajouter un document médical'));
    await tester.pump();
    expect(tapped, isTrue);
  });

  testWidgets('DocumentsFilterEmptyState invite à modifier les critères', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: DocumentsFilterEmptyState()),
      ),
    );

    expect(find.text('Aucun document trouvé'), findsOneWidget);
    expect(
      find.text('Modifiez vos critères de recherche ou de filtre.'),
      findsOneWidget,
    );
  });
}
