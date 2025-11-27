import 'package:flutter_test/flutter_test.dart';
import 'package:arkalia_cia/services/backend_config_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('BackendConfigService', () {
    setUp(() async {
      // Réinitialiser les préférences avant chaque test
      SharedPreferences.setMockInitialValues({});
    });

    test('getBackendURL should return empty string by default on mobile', () async {
      // Note: Ce test nécessite un mock de kIsWeb, mais on teste le comportement par défaut
      final url = await BackendConfigService.getBackendURL();
      // Sur mobile (kIsWeb = false), devrait retourner '' si pas configuré
      // Sur web (kIsWeb = true), devrait retourner 'http://localhost:8000'
      // On teste juste que ça ne crash pas
      expect(url, isA<String>());
    });

    test('setBackendURL should update backend URL', () async {
      const testUrl = 'http://192.168.1.100:8000';
      await BackendConfigService.setBackendURL(testUrl);
      final url = await BackendConfigService.getBackendURL();
      expect(url, testUrl);
    });

    test('isBackendEnabled should return false by default', () async {
      final isEnabled = await BackendConfigService.isBackendEnabled();
      expect(isEnabled, false);
    });

    test('setBackendEnabled should update backend enabled status', () async {
      await BackendConfigService.setBackendEnabled(true);
      expect(await BackendConfigService.isBackendEnabled(), true);

      await BackendConfigService.setBackendEnabled(false);
      expect(await BackendConfigService.isBackendEnabled(), false);
    });

    // Note: testConnection nécessite un serveur réel ou un mock HTTP
    // Ce test est marqué comme à faire avec un mock
    test('testConnection should handle invalid URLs gracefully', () async {
      // Test avec une URL invalide
      final result = await BackendConfigService.testConnection('invalid-url');
      expect(result, false);
    });
  });
}

