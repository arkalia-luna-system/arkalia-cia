import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../lib/services/user_profile_service.dart';
import '../../lib/models/user_profile.dart';
import '../../lib/models/device.dart';

void main() {
  group('UserProfileService', () {
    setUp(() async {
      // Nettoyer SharedPreferences avant chaque test
      SharedPreferences.setMockInitialValues({});
    });

    test('createProfile crée un profil avec email et device', () async {
      final profile = await UserProfileService.createProfile(
        email: 'test@example.com',
        displayName: 'Test User',
      );

      expect(profile.email, 'test@example.com');
      expect(profile.displayName, 'Test User');
      expect(profile.userId, isNotEmpty);
      expect(profile.devices.length, 1);
      expect(profile.devices.first.deviceName, isNotEmpty);
    });

    test('getProfile retourne null si aucun profil', () async {
      final profile = await UserProfileService.getProfile();
      expect(profile, isNull);
    });

    test('getProfile retourne le profil sauvegardé', () async {
      final created = await UserProfileService.createProfile(
        email: 'test@example.com',
      );
      final retrieved = await UserProfileService.getProfile();

      expect(retrieved, isNotNull);
      expect(retrieved!.email, created.email);
      expect(retrieved.userId, created.userId);
    });

    test('saveProfile sauvegarde le profil', () async {
      final profile = UserProfile(
        userId: 'test-user-id',
        email: 'test@example.com',
        displayName: 'Test',
      );

      await UserProfileService.saveProfile(profile);
      final retrieved = await UserProfileService.getProfile();

      expect(retrieved, isNotNull);
      expect(retrieved!.email, 'test@example.com');
    });

    test('addDevice ajoute un device au profil', () async {
      final profile = await UserProfileService.createProfile(
        email: 'test@example.com',
      );
      expect(profile.devices.length, 1);

      final newDevice = Device(
        deviceId: 'device-2',
        deviceName: 'iPad',
        platform: 'iOS',
        lastSeen: DateTime.now(),
      );

      await UserProfileService.addDevice(newDevice);
      final updated = await UserProfileService.getProfile();

      expect(updated, isNotNull);
      expect(updated!.devices.length, 2);
      expect(updated.devices.any((d) => d.deviceId == 'device-2'), isTrue);
    });

    test('addDevice met à jour un device existant', () async {
      final profile = await UserProfileService.createProfile(
        email: 'test@example.com',
      );
      final existingDevice = profile.devices.first;

      final updatedDevice = existingDevice.copyWith(
        deviceName: 'Updated Device Name',
      );

      await UserProfileService.addDevice(updatedDevice);
      final updated = await UserProfileService.getProfile();

      expect(updated, isNotNull);
      expect(updated!.devices.length, 1);
      expect(updated.devices.first.deviceName, 'Updated Device Name');
    });

    test('removeDevice supprime un device', () async {
      final profile = await UserProfileService.createProfile(
        email: 'test@example.com',
      );
      final deviceToRemove = profile.devices.first;

      await UserProfileService.removeDevice(deviceToRemove.deviceId);
      final updated = await UserProfileService.getProfile();

      expect(updated, isNotNull);
      expect(updated!.devices.length, 0);
    });

    test('deactivateDevice désactive un device', () async {
      final profile = await UserProfileService.createProfile(
        email: 'test@example.com',
      );
      final deviceToDeactivate = profile.devices.first;

      await UserProfileService.deactivateDevice(deviceToDeactivate.deviceId);
      final updated = await UserProfileService.getProfile();

      expect(updated, isNotNull);
      final device = updated!.devices.firstWhere(
        (d) => d.deviceId == deviceToDeactivate.deviceId,
      );
      expect(device.isActive, isFalse);
    });

    test('hasProfile retourne false si aucun profil', () async {
      final hasProfile = await UserProfileService.hasProfile();
      expect(hasProfile, isFalse);
    });

    test('hasProfile retourne true si profil existe', () async {
      await UserProfileService.createProfile(email: 'test@example.com');
      final hasProfile = await UserProfileService.hasProfile();
      expect(hasProfile, isTrue);
    });

    test('deleteProfile supprime le profil', () async {
      await UserProfileService.createProfile(email: 'test@example.com');
      await UserProfileService.deleteProfile();
      final hasProfile = await UserProfileService.hasProfile();
      expect(hasProfile, isFalse);
    });

    test('getCurrentDeviceId retourne toujours le même ID', () async {
      final id1 = await UserProfileService.getCurrentDeviceId();
      final id2 = await UserProfileService.getCurrentDeviceId();
      expect(id1, id2);
    });
  });
}

