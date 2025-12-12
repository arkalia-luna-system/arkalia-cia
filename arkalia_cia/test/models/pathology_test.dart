import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:arkalia_cia/models/pathology.dart';

void main() {
  group('Pathology - Catégories', () {
    test('Pathology avec catégorie et sous-catégorie', () {
      final pathology = Pathology(
        name: 'Test Pathologie',
        category: 'Cardiologie',
        subcategory: 'Pathologies cardiovasculaires',
        color: Colors.red,
      );

      expect(pathology.category, 'Cardiologie');
      expect(pathology.subcategory, 'Pathologies cardiovasculaires');
    });

    test('Pathology sans catégorie (nullable)', () {
      final pathology = Pathology(
        name: 'Test Pathologie',
        color: Colors.blue,
      );

      expect(pathology.category, isNull);
      expect(pathology.subcategory, isNull);
    });

    test('Pathology.toMap inclut category et subcategory', () {
      final pathology = Pathology(
        name: 'Test Pathologie',
        category: 'Neurologie',
        subcategory: 'Maladies neurodégénératives',
        color: Colors.indigo,
      );

      final map = pathology.toMap();
      expect(map['category'], 'Neurologie');
      expect(map['subcategory'], 'Maladies neurodégénératives');
    });

    test('Pathology.fromMap parse category et subcategory', () {
      final map = {
        'id': 1,
        'name': 'Test Pathologie',
        'description': 'Description test',
        'symptoms': '',
        'treatments': '',
        'exams': '',
        'reminders': '{}',
        'color': Colors.blue.toARGB32(),
        'category': 'Rhumatologie',
        'subcategory': 'Arthrites',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final pathology = Pathology.fromMap(map);
      expect(pathology.category, 'Rhumatologie');
      expect(pathology.subcategory, 'Arthrites');
    });

    test('Pathology.copyWith préserve category et subcategory', () {
      final original = Pathology(
        name: 'Test Pathologie',
        category: 'Dermatologie',
        subcategory: 'Dermatites',
        color: Colors.orange,
      );

      final copied = original.copyWith(name: 'Nouveau nom');
      expect(copied.category, 'Dermatologie');
      expect(copied.subcategory, 'Dermatites');
      expect(copied.name, 'Nouveau nom');
    });

    test('Pathology.copyWith peut modifier category et subcategory', () {
      final original = Pathology(
        name: 'Test Pathologie',
        category: 'Ancienne catégorie',
        subcategory: 'Ancienne sous-catégorie',
        color: Colors.blue,
      );

      final copied = original.copyWith(
        category: 'Nouvelle catégorie',
        subcategory: 'Nouvelle sous-catégorie',
      );
      expect(copied.category, 'Nouvelle catégorie');
      expect(copied.subcategory, 'Nouvelle sous-catégorie');
    });
  });
}

