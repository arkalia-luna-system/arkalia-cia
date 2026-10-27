import 'package:arkalia_cia/widgets/exam_type_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'texte de confiance a fontSize >= 14 quand showConfidence est activé',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ExamTypeBadge(
              examType: 'analyse',
              confidence: 0.8,
              showConfidence: true,
            ),
          ),
        ),
      );

      final confidenceText = find.text('(80%)');
      expect(confidenceText, findsOneWidget);

      final textWidget = tester.widget<Text>(confidenceText);
      final fontSize = textWidget.style?.fontSize;
      expect(fontSize, isNotNull);
      expect(fontSize!, greaterThanOrEqualTo(14));
    },
  );

  testWidgets(
    'texte de confiance absent quand showConfidence est false',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ExamTypeBadge(
              examType: 'analyse',
              confidence: 0.8,
              showConfidence: false,
            ),
          ),
        ),
      );

      expect(find.text('(80%)'), findsNothing);
      expect(find.text('Analyse'), findsOneWidget);
    },
  );
}
