import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arkalia_cia/services/health_portal_favorites_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('HealthPortalFavoritesService', () {
    test('getFavoriteUrls retourne un Set vide initialement', () async {
      final favorites = await HealthPortalFavoritesService.getFavoriteUrls();
      expect(favorites, isEmpty);
    });

    test('addFavorite ajoute un portail aux favoris', () async {
      const url = 'https://example.com/portal';
      final success = await HealthPortalFavoritesService.addFavorite(url);
      expect(success, isTrue);
      
      final favorites = await HealthPortalFavoritesService.getFavoriteUrls();
      expect(favorites, contains(url));
    });

    test('removeFavorite retire un portail des favoris', () async {
      const url = 'https://example.com/portal';
      await HealthPortalFavoritesService.addFavorite(url);
      
      final success = await HealthPortalFavoritesService.removeFavorite(url);
      expect(success, isTrue);
      
      final favorites = await HealthPortalFavoritesService.getFavoriteUrls();
      expect(favorites, isNot(contains(url)));
    });

    test('isFavorite retourne true si le portail est favori', () async {
      const url = 'https://example.com/portal';
      await HealthPortalFavoritesService.addFavorite(url);
      
      final isFav = await HealthPortalFavoritesService.isFavorite(url);
      expect(isFav, isTrue);
    });

    test('isFavorite retourne false si le portail n\'est pas favori', () async {
      const url = 'https://example.com/portal';
      
      final isFav = await HealthPortalFavoritesService.isFavorite(url);
      expect(isFav, isFalse);
    });

    test('toggleFavorite ajoute si pas favori, retire si favori', () async {
      const url = 'https://example.com/portal';
      
      // Ajouter
      final success1 = await HealthPortalFavoritesService.toggleFavorite(url);
      expect(success1, isTrue);
      expect(await HealthPortalFavoritesService.isFavorite(url), isTrue);
      
      // Retirer
      final success2 = await HealthPortalFavoritesService.toggleFavorite(url);
      expect(success2, isTrue);
      expect(await HealthPortalFavoritesService.isFavorite(url), isFalse);
    });

    test('getFavoriteUrls retourne plusieurs favoris', () async {
      const url1 = 'https://example.com/portal1';
      const url2 = 'https://example.com/portal2';
      
      await HealthPortalFavoritesService.addFavorite(url1);
      await HealthPortalFavoritesService.addFavorite(url2);
      
      final favorites = await HealthPortalFavoritesService.getFavoriteUrls();
      expect(favorites.length, 2);
      expect(favorites, containsAll([url1, url2]));
    });
  });
}

