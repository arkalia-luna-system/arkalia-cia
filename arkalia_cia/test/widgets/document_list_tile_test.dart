import 'package:arkalia_cia/models/document.dart';
import 'package:arkalia_cia/widgets/documents/document_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('DocumentListTile affiche nom, taille et actions', (
    tester,
  ) async {
    var preview = false;
    var share = false;
    var deleted = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DocumentListTile(
            document: const Document(
              id: '1',
              name: 'Ordonnance.pdf',
              createdAt: '2026-01-15',
            ),
            formattedSize: '120 Ko',
            onPreview: () => preview = true,
            onShare: () => share = true,
            onDelete: () => deleted = true,
          ),
        ),
      ),
    );

    expect(find.text('Ordonnance.pdf'), findsOneWidget);
    expect(find.text('Taille: 120 Ko'), findsOneWidget);
    expect(find.textContaining('Ajouté:'), findsOneWidget);

    await tester.tap(find.byTooltip('Prévisualiser'));
    await tester.pump();
    expect(preview, isTrue);

    await tester.tap(find.byTooltip('Partager'));
    await tester.pump();
    expect(share, isTrue);

    await tester.tap(find.byTooltip('Supprimer'));
    await tester.pump();
    expect(deleted, isTrue);
  });
}
