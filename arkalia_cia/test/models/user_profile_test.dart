import 'package:flutter_test/flutter_test.dart';
import '../../lib/models/user_profile.dart';
import '../../lib/models/device.dart';

void main() {
  group('UserProfile', () {
    test('fromMap crée un UserProfile depuis un Map', () {
      final map = {
        'userId': 'test-id',
        'email': 'test@example.com',
        'displayName': 'Test User',
        'devices': [
          {
            'deviceId': 'device-1',
            'deviceName': 'iPhone',
            'platform': 'iOS',
            'lastSeen': '2024-01-01T00:00:00.000Z',
            'isActive': true,
          }
        ],
        'createdAt': '2024-01-01T00:00:00.000Z',
        'lastSync': '2024-01-02T00:00:00.000Z',
      };

      final profile = UserProfile.fromMap(map);

      expect(profile.userId, 'test-id');
      expect(profile.email, 'test@example.com');
      expect(profile.displayName, 'Test User');
      expect(profile.devices.length, 1);
      expect(profile.devices.first.deviceName, 'iPhone');
      expect(profile.lastSync, isNotNull);
    });

    test('toMap convertit un UserProfile en Map', () {
      final device = Device(
        deviceId: 'device-1',
        deviceName: 'iPhone',
        platform: 'iOS',
        lastSeen: DateTime(2024, 1, 1),
      );

      final profile = UserProfile(
        userId: 'test-id',
        email: 'test@example.com',
        displayName: 'Test User',
        devices: [device],
        createdAt: DateTime(2024, 1, 1),
        lastSync: DateTime(2024, 1, 2),
      );

      final map = profile.toMap();

      expect(map['userId'], 'test-id');
      expect(map['email'], 'test@example.com');
      expect(map['displayName'], 'Test User');
      expect(map['devices'], isA<List>());
      expect((map['devices'] as List).length, 1);
    });

    test('copyWith crée une copie avec modifications', () {
      final profile = UserProfile(
        userId: 'test-id',
        email: 'test@example.com',
      );

      final updated = profile.copyWith(
        displayName: 'Updated Name',
        lastSync: DateTime(2024, 1, 2),
      );

      expect(updated.userId, 'test-id');
      expect(updated.email, 'test@example.com');
      expect(updated.displayName, 'Updated Name');
      expect(updated.lastSync, isNotNull);
    });

    test('getCurrentDevice retourne le device avec le bon ID', () {
      final device1 = Device(
        deviceId: 'device-1',
        deviceName: 'iPhone',
        platform: 'iOS',
        lastSeen: DateTime.now(),
      );
      final device2 = Device(
        deviceId: 'device-2',
        deviceName: 'iPad',
        platform: 'iOS',
        lastSeen: DateTime.now(),
      );

      final profile = UserProfile(
        userId: 'test-id',
        email: 'test@example.com',
        devices: [device1, device2],
      );

      final current = profile.getCurrentDevice('device-1');
      expect(current, isNotNull);
      expect(current!.deviceId, 'device-1');
    });

    test('getCurrentDevice retourne null si device non trouvé', () {
      final profile = UserProfile(
        userId: 'test-id',
        email: 'test@example.com',
      );

      final current = profile.getCurrentDevice('non-existent');
      expect(current, isNull);
    });

    test('getActiveDevices retourne seulement les devices actifs', () {
      final activeDevice = Device(
        deviceId: 'device-1',
        deviceName: 'iPhone',
        platform: 'iOS',
        lastSeen: DateTime.now(),
        isActive: true,
      );
      final inactiveDevice = Device(
        deviceId: 'device-2',
        deviceName: 'iPad',
        platform: 'iOS',
        lastSeen: DateTime.now(),
        isActive: false,
      );

      final profile = UserProfile(
        userId: 'test-id',
        email: 'test@example.com',
        devices: [activeDevice, inactiveDevice],
      );

      final activeDevices = profile.getActiveDevices();
      expect(activeDevices.length, 1);
      expect(activeDevices.first.deviceId, 'device-1');
    });
  });
}

