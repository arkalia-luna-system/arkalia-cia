import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arkalia_cia/services/pin_auth_service.dart';

void main() {
  group('PinAuthService Tests', () {
    setUp(() async {
      // Nettoyer les préférences avant chaque test
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    });

    // Utiliser forceWeb=true pour tous les tests car on n'est pas sur web
    const forceWeb = true;

    test('isPinConfigured retourne false si aucun PIN configuré', () async {
      final result = await PinAuthService.isPinConfigured(forceWeb: forceWeb);
      expect(result, isFalse);
    });

    test('configurePin configure un PIN valide', () async {
      final result = await PinAuthService.configurePin('1234', forceWeb: forceWeb);
      expect(result, isTrue);
      
      final isConfigured = await PinAuthService.isPinConfigured(forceWeb: forceWeb);
      expect(isConfigured, isTrue);
    });

    test('configurePin rejette un PIN trop court', () async {
      final result = await PinAuthService.configurePin('123', forceWeb: forceWeb);
      expect(result, isFalse);
    });

    test('configurePin rejette un PIN trop long', () async {
      final result = await PinAuthService.configurePin('1234567', forceWeb: forceWeb);
      expect(result, isFalse);
    });

    test('configurePin rejette un PIN avec des lettres', () async {
      final result = await PinAuthService.configurePin('123a', forceWeb: forceWeb);
      expect(result, isFalse);
    });

    test('verifyPin retourne true pour un PIN correct', () async {
      await PinAuthService.configurePin('1234', forceWeb: forceWeb);
      final result = await PinAuthService.verifyPin('1234', forceWeb: forceWeb);
      expect(result, isTrue);
    });

    test('verifyPin retourne false pour un PIN incorrect', () async {
      await PinAuthService.configurePin('1234', forceWeb: forceWeb);
      final result = await PinAuthService.verifyPin('5678', forceWeb: forceWeb);
      expect(result, isFalse);
    });

    test('verifyPin retourne false si aucun PIN configuré', () async {
      final result = await PinAuthService.verifyPin('1234', forceWeb: forceWeb);
      expect(result, isFalse);
    });

    test('resetPin supprime la configuration', () async {
      await PinAuthService.configurePin('1234', forceWeb: forceWeb);
      await PinAuthService.resetPin(forceWeb: forceWeb);
      
      final isConfigured = await PinAuthService.isPinConfigured(forceWeb: forceWeb);
      expect(isConfigured, isFalse);
      
      final verifyResult = await PinAuthService.verifyPin('1234', forceWeb: forceWeb);
      expect(verifyResult, isFalse);
    });

    test('isPinAuthEnabled retourne true par défaut', () async {
      final result = await PinAuthService.isPinAuthEnabled(forceWeb: forceWeb);
      expect(result, isTrue);
    });

    test('setPinAuthEnabled active/désactive l\'authentification PIN', () async {
      await PinAuthService.setPinAuthEnabled(false, forceWeb: forceWeb);
      final result1 = await PinAuthService.isPinAuthEnabled(forceWeb: forceWeb);
      expect(result1, isFalse);
      
      await PinAuthService.setPinAuthEnabled(true, forceWeb: forceWeb);
      final result2 = await PinAuthService.isPinAuthEnabled(forceWeb: forceWeb);
      expect(result2, isTrue);
    });

    test('shouldAuthenticateOnStartup retourne true par défaut', () async {
      final result = await PinAuthService.shouldAuthenticateOnStartup(forceWeb: forceWeb);
      expect(result, isTrue);
    });

    test('setPinAuthOnStartup configure l\'authentification au démarrage', () async {
      await PinAuthService.setPinAuthOnStartup(false, forceWeb: forceWeb);
      final result1 = await PinAuthService.shouldAuthenticateOnStartup(forceWeb: forceWeb);
      expect(result1, isFalse);
      
      await PinAuthService.setPinAuthOnStartup(true, forceWeb: forceWeb);
      final result2 = await PinAuthService.shouldAuthenticateOnStartup(forceWeb: forceWeb);
      expect(result2, isTrue);
    });

    test('PIN de 4 chiffres est valide', () async {
      final result = await PinAuthService.configurePin('1234', forceWeb: forceWeb);
      expect(result, isTrue);
    });

    test('PIN de 5 chiffres est valide', () async {
      final result = await PinAuthService.configurePin('12345', forceWeb: forceWeb);
      expect(result, isTrue);
    });

    test('PIN de 6 chiffres est valide', () async {
      final result = await PinAuthService.configurePin('123456', forceWeb: forceWeb);
      expect(result, isTrue);
    });
  });
}

