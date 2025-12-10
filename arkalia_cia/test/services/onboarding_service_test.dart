import 'package:flutter_test/flutter_test.dart';
import 'package:arkalia_cia/services/onboarding_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('OnboardingService', () {
    setUp(() async {
      // Réinitialiser les préférences avant chaque test
      SharedPreferences.setMockInitialValues({});
      // Réinitialiser l'onboarding avant chaque test
      await OnboardingService.resetOnboarding();
    });

    test('isOnboardingCompleted should return false initially', () async {
      final isCompleted = await OnboardingService.isOnboardingCompleted();
      expect(isCompleted, false);
    });

    test('completeOnboarding should mark onboarding as completed', () async {
      await OnboardingService.completeOnboarding();
      final isCompleted = await OnboardingService.isOnboardingCompleted();
      expect(isCompleted, true);
    });

    test('resetOnboarding should reset onboarding status', () async {
      // Marquer comme complété
      await OnboardingService.completeOnboarding();
      expect(await OnboardingService.isOnboardingCompleted(), true);

      // Réinitialiser
      await OnboardingService.resetOnboarding();
      expect(await OnboardingService.isOnboardingCompleted(), false);
    });
  });
}

