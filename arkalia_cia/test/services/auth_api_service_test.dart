// Tests pour AuthApiService
// Date: 12 décembre 2025
// Tests pour vérifier la gestion de session après création de compte

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:arkalia_cia/services/auth_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // Initialiser le binding Flutter pour les tests
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('AuthApiService - Gestion Session', () {
    setUp(() async {
      // Réinitialiser les préférences avant chaque test
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      // Note: On force le mode web pour utiliser SharedPreferences
      // au lieu de flutter_secure_storage qui nécessite une plateforme réelle
      // En production, kIsWeb est détecté automatiquement
    });

    test('isLoggedIn should return false when no token', () async {
      // Forcer le mode web pour ce test
      // En mode web, AuthApiService utilise SharedPreferences
      final isLoggedIn = await AuthApiService.isLoggedIn();
      expect(isLoggedIn, false);
    });

    test('logout should clear all tokens (web mode)', () async {
      // Simuler un token stocké (via SharedPreferences pour web)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_access_token', 'test_token');
      await prefs.setString('jwt_refresh_token', 'test_refresh');
      await prefs.setString('username', 'testuser');

      // Vérifier que les tokens sont présents (en mode web)
      final tokenBefore = prefs.getString('jwt_access_token');
      expect(tokenBefore, isNotNull);

      // Déconnecter
      await AuthApiService.logout();

      // Vérifier que les tokens sont supprimés (en mode web)
      final tokenAfter = prefs.getString('jwt_access_token');
      expect(tokenAfter, isNull);

      final isLoggedIn = await AuthApiService.isLoggedIn();
      expect(isLoggedIn, false);
    });

    test('getUsername should return null when not logged in', () async {
      final username = await AuthApiService.getUsername();
      expect(username, isNull);
    });

    // Note: Les tests pour login, register et refreshToken nécessitent
    // un backend réel ou des mocks HTTP complexes.
    // Ces tests sont à faire avec des mocks appropriés.
  });
}

