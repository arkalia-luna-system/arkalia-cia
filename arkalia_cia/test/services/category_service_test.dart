import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arkalia_cia/services/category_service.dart';

void main() {
  group('CategoryService', () {
    setUp(() async {
      // Initialiser SharedPreferences pour les tests
      SharedPreferences.setMockInitialValues({});
    });

    test('getCategories should return default categories initially', () async {
      final categories = await CategoryService.getCategories();
      expect(categories.length, 3);
      expect(categories, contains('Médical'));
      expect(categories, contains('Administratif'));
      expect(categories, contains('Autre'));
    });

    test('addCategory should add a custom category', () async {
      final success = await CategoryService.addCategory('Test Category');
      expect(success, true);

      final categories = await CategoryService.getCategories();
      expect(categories.length, 4);
      expect(categories, contains('Test Category'));
    });

    test('addCategory should not add empty category', () async {
      final success = await CategoryService.addCategory('');
      expect(success, false);

      final categories = await CategoryService.getCategories();
      expect(categories.length, 3); // Seulement les défaut
    });

    test('addCategory should not add default category', () async {
      final success = await CategoryService.addCategory('Médical');
      expect(success, false);

      final categories = await CategoryService.getCategories();
      expect(categories.length, 3); // Pas de doublon
    });

    test('addCategory should not add duplicate category', () async {
      await CategoryService.addCategory('Test Category');
      final success = await CategoryService.addCategory('Test Category');
      expect(success, false);

      final categories = await CategoryService.getCategories();
      expect(categories.where((c) => c == 'Test Category').length, 1);
    });

    test('deleteCategory should remove custom category', () async {
      await CategoryService.addCategory('Test Category');
      final success = await CategoryService.deleteCategory('Test Category');
      expect(success, true);

      final categories = await CategoryService.getCategories();
      expect(categories, isNot(contains('Test Category')));
    });

    test('deleteCategory should not remove default category', () async {
      final success = await CategoryService.deleteCategory('Médical');
      expect(success, false);

      final categories = await CategoryService.getCategories();
      expect(categories, contains('Médical'));
    });

    test('deleteCategory should return false for non-existent category', () async {
      final success = await CategoryService.deleteCategory('Non Existent');
      expect(success, false);
    });
  });
}

