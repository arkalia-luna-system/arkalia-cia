import 'package:flutter_test/flutter_test.dart';
import 'package:arkalia_cia/services/pathology_category_service.dart';

void main() {
  group('PathologyCategoryService', () {
    test('getCategoryForPathology retourne la catégorie correcte', () {
      expect(
        PathologyCategoryService.getCategoryForPathology('Endométriose'),
        'Gynécologie',
      );
      expect(
        PathologyCategoryService.getCategoryForPathology('Hypertension'),
        'Cardiologie',
      );
      expect(
        PathologyCategoryService.getCategoryForPathology('Parkinson'),
        'Neurologie',
      );
    });

    test('getCategoryForPathology retourne null pour pathologie inconnue', () {
      expect(
        PathologyCategoryService.getCategoryForPathology('Pathologie inconnue'),
        isNull,
      );
    });

    test('getSubcategoryForPathology retourne la sous-catégorie correcte', () {
      expect(
        PathologyCategoryService.getSubcategoryForPathology('Endométriose'),
        'Pathologies gynécologiques',
      );
      expect(
        PathologyCategoryService.getSubcategoryForPathology('Parkinson'),
        'Maladies neurodégénératives',
      );
      expect(
        PathologyCategoryService.getSubcategoryForPathology('Arthrite'),
        'Arthrites',
      );
    });

    test('getSubcategoryForPathology retourne null pour pathologie inconnue', () {
      expect(
        PathologyCategoryService.getSubcategoryForPathology('Pathologie inconnue'),
        isNull,
      );
    });

    test('getCategoryAndSubcategory retourne les deux valeurs', () {
      final result = PathologyCategoryService.getCategoryAndSubcategory('Diabète');
      expect(result['category'], 'Endocrinologie');
      expect(result['subcategory'], 'Troubles métaboliques');
      
      // Test avec une autre pathologie
      final result2 = PathologyCategoryService.getCategoryAndSubcategory('Endométriose');
      expect(result2['category'], 'Gynécologie');
      expect(result2['subcategory'], 'Pathologies gynécologiques');
    });

    test('hasCategoryMapping retourne true pour pathologie mappée', () {
      expect(
        PathologyCategoryService.hasCategoryMapping('Asthme'),
        isTrue,
      );
      expect(
        PathologyCategoryService.hasCategoryMapping('Dépression'),
        isTrue,
      );
    });

    test('hasCategoryMapping retourne false pour pathologie non mappée', () {
      expect(
        PathologyCategoryService.hasCategoryMapping('Pathologie inconnue'),
        isFalse,
      );
    });

    test('getAllCategories retourne toutes les catégories', () {
      final categories = PathologyCategoryService.getAllCategories();
      expect(categories, isNotEmpty);
      expect(categories, contains('Cardiologie'));
      expect(categories, contains('Neurologie'));
      expect(categories, contains('Rhumatologie'));
    });

    test('getSubcategoriesForCategory retourne les sous-catégories', () {
      final subcategories = PathologyCategoryService.getSubcategoriesForCategory('Neurologie');
      expect(subcategories, isNotEmpty);
      expect(subcategories, contains('Maladies neurodégénératives'));
      expect(subcategories, contains('Céphalées'));
    });

    test('getPathologiesForCategory retourne les pathologies de la catégorie', () {
      final pathologies = PathologyCategoryService.getPathologiesForCategory('Rhumatologie');
      expect(pathologies, isNotEmpty);
      expect(pathologies, contains('Arthrite'));
      expect(pathologies, contains('Ostéoporose'));
    });

    test('getPathologiesForSubcategory retourne les pathologies de la sous-catégorie', () {
      final pathologies = PathologyCategoryService.getPathologiesForSubcategory('Arthrites');
      expect(pathologies, isNotEmpty);
      expect(pathologies, contains('Arthrite'));
      expect(pathologies, contains('Arthrite rhumatoïde'));
    });
  });
}

