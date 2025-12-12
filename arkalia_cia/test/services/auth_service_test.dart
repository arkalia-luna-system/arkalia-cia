import 'package:flutter_test/flutter_test.dart';
import 'package:arkalia_cia/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // Initialiser le binding Flutter pour les tests
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('AuthService', () {
    setUp(() async {
      // Réinitialiser les préférences avant chaque test
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    });

    test('isAuthEnabled should return true by default', () async {
      final isEnabled = await AuthService.isAuthEnabled();
      expect(isEnabled, true);
    });

    test('setAuthEnabled should update auth status', () async {
      await AuthService.setAuthEnabled(false);
      expect(await AuthService.isAuthEnabled(), false);

      await AuthService.setAuthEnabled(true);
      expect(await AuthService.isAuthEnabled(), true);
    });

    test('shouldAuthenticateOnStartup should return correct value', () async {
      // Par défaut, l'authentification au démarrage est activée
      final shouldAuth = await AuthService.shouldAuthenticateOnStartup();
      expect(shouldAuth, true);

      // Désactiver l'authentification au démarrage
      await AuthService.setAuthOnStartup(false);
      final shouldAuthAfterDisable = await AuthService.shouldAuthenticateOnStartup();
      expect(shouldAuthAfterDisable, false);

      // Réactiver l'authentification au démarrage
      await AuthService.setAuthOnStartup(true);
      final shouldAuthAfterEnable = await AuthService.shouldAuthenticateOnStartup();
      expect(shouldAuthAfterEnable, true);
    });

    test('isBiometricAvailable should handle errors gracefully', () async {
      // Sur web, isBiometricAvailable retourne toujours false
      // Sur mobile, cela nécessite une plateforme réelle
      // Ce test vérifie que la méthode ne crash pas
      final available = await AuthService.isBiometricAvailable();
      expect(available, isA<bool>());
    });

    test('getAvailableBiometrics should return a list', () async {
      // Cette méthode retourne toujours une liste (vide si non disponible)
      final biometrics = await AuthService.getAvailableBiometrics();
      expect(biometrics, isA<List>());
    });

    // Note: Les tests pour authenticate nécessitent des mocks plus complexes
    // car ils utilisent LocalAuthentication qui nécessite une plateforme réelle.
    // Ces tests sont à faire avec des mocks appropriés.
  });
}

