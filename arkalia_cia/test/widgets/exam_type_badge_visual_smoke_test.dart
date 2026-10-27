import 'dart:io';
import 'dart:ui' as ui;

import 'package:arkalia_cia/widgets/exam_type_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// Smoke visuel agent : capture PNG du badge avec % (pas un golden CI).
void main() {
  testWidgets('capture visuelle ExamTypeBadge avec confiance', (tester) async {
    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: RepaintBoundary(
              key: key,
              child: const ExamTypeBadge(
                examType: 'analyse',
                confidence: 0.82,
                showConfidence: true,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Analyse'), findsOneWidget);
    expect(find.text('(82%)'), findsOneWidget);

    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;

    late ui.Image image;
    await tester.runAsync(() async {
      image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      expect(byteData, isNotNull);
      final out = File('/tmp/arkalia-cia-smoke/exam_type_badge_confidence.png');
      await out.parent.create(recursive: true);
      await out.writeAsBytes(byteData!.buffer.asUint8List());
      // ignore: avoid_print
      print('SMOKE_PNG=${out.path} size=${out.lengthSync()}');
    });
  });
}
