import 'package:flutter_test/flutter_test.dart';
import 'package:arkalia_cia/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AuthService', () {
    setUp(() async {
      // Réinitialiser les préférences avant chaque test
      SharedPreferences.setMockInitialValues({});
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
      // Par défaut, l'authentification est activée
      final shouldAuth = await AuthService.shouldAuthenticateOnStartup();
      expect(shouldAuth, true);

      // Désactiver l'authentification
      await AuthService.setAuthEnabled(false);
      final shouldAuthAfterDisable = await AuthService.shouldAuthenticateOnStartup();
      expect(shouldAuthAfterDisable, false);
    });

    // Note: Les tests pour isBiometricAvailable, getAvailableBiometrics et authenticate
    // nécessitent des mocks plus complexes car ils utilisent LocalAuthentication
    // qui nécessite une plateforme réelle. Ces tests sont marqués comme à faire.
  });
}

