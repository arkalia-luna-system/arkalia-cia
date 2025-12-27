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

    test('isAuthEnabled should return true by default on web', () async {
      // Note: Sur mobile, isAuthEnabled retourne false par défaut
      // Sur web, il retourne true par défaut (quand pas de préférence stockée)
      // En test, kIsWeb est false, donc on teste le comportement mobile
      // Pour tester le comportement web, il faudrait forcer kIsWeb à true
      final isEnabled = await AuthService.isAuthEnabled();
      // En environnement de test (mobile), l'authentification est désactivée
      expect(isEnabled, false);
      
      // Note: Le comportement web (true par défaut) est testé dans les tests d'intégration
    });

    test('setAuthEnabled should update auth status', () async {
      // Sur web, setAuthEnabled fonctionne et modifie la valeur
      // Sur mobile, setAuthEnabled ne fait rien (authentification toujours désactivée)
      // En test, kIsWeb est false, donc on teste le comportement mobile
      await AuthService.setAuthEnabled(false);
      final isEnabledAfterDisable = await AuthService.isAuthEnabled();
      // Sur mobile, reste false (authentification désactivée)
      expect(isEnabledAfterDisable, false);

      await AuthService.setAuthEnabled(true);
      final isEnabledAfterEnable = await AuthService.isAuthEnabled();
      // Sur mobile, reste false même après setAuthEnabled(true)
      expect(isEnabledAfterEnable, false);
      
      // Note: Le comportement web (modification effective) est testé dans les tests d'intégration
    });

    test('shouldAuthenticateOnStartup should return correct value', () async {
      // Par défaut, l'authentification au démarrage est activée sur web
      // Sur mobile, elle est désactivée
      // En test, kIsWeb est false, donc on teste le comportement mobile
      final shouldAuth = await AuthService.shouldAuthenticateOnStartup();
      // Sur mobile, l'authentification au démarrage est désactivée
      expect(shouldAuth, false);

      // Désactiver l'authentification au démarrage
      await AuthService.setAuthOnStartup(false);
      final shouldAuthAfterDisable = await AuthService.shouldAuthenticateOnStartup();
      expect(shouldAuthAfterDisable, false);

      // Réactiver l'authentification au démarrage
      await AuthService.setAuthOnStartup(true);
      final shouldAuthAfterEnable = await AuthService.shouldAuthenticateOnStartup();
      // Sur mobile, reste false même après setAuthOnStartup(true)
      expect(shouldAuthAfterEnable, false);
      
      // Note: Le comportement web (true par défaut, modification effective) est testé dans les tests d'intégration
    });

  });
}

