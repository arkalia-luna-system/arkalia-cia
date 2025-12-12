import 'package:flutter_test/flutter_test.dart';
import 'package:arkalia_cia/models/device.dart';

void main() {
  group('Device', () {
    test('fromMap crée un Device depuis un Map', () {
      final map = {
        'deviceId': 'test-device-id',
        'deviceName': 'iPhone',
        'platform': 'iOS',
        'lastSeen': '2024-01-01T00:00:00.000Z',
        'isActive': true,
        'fcmToken': 'test-token',
      };

      final device = Device.fromMap(map);

      expect(device.deviceId, 'test-device-id');
      expect(device.deviceName, 'iPhone');
      expect(device.platform, 'iOS');
      expect(device.isActive, isTrue);
      expect(device.fcmToken, 'test-token');
    });

    test('toMap convertit un Device en Map', () {
      final device = Device(
        deviceId: 'test-device-id',
        deviceName: 'iPhone',
        platform: 'iOS',
        lastSeen: DateTime(2024, 1, 1),
        isActive: true,
        fcmToken: 'test-token',
      );

      final map = device.toMap();

      expect(map['deviceId'], 'test-device-id');
      expect(map['deviceName'], 'iPhone');
      expect(map['platform'], 'iOS');
      expect(map['isActive'], isTrue);
      expect(map['fcmToken'], 'test-token');
    });

    test('copyWith crée une copie avec modifications', () {
      final device = Device(
        deviceId: 'test-device-id',
        deviceName: 'iPhone',
        platform: 'iOS',
        lastSeen: DateTime(2024, 1, 1),
        isActive: true,
      );

      final updated = device.copyWith(
        deviceName: 'Updated Name',
        isActive: false,
      );

      expect(updated.deviceId, 'test-device-id');
      expect(updated.deviceName, 'Updated Name');
      expect(updated.isActive, isFalse);
    });

    test('equality compare par deviceId', () {
      final device1 = Device(
        deviceId: 'same-id',
        deviceName: 'Device 1',
        platform: 'iOS',
        lastSeen: DateTime.now(),
      );
      final device2 = Device(
        deviceId: 'same-id',
        deviceName: 'Device 2',
        platform: 'Android',
        lastSeen: DateTime.now(),
      );

      expect(device1 == device2, isTrue);
      expect(device1.hashCode, device2.hashCode);
    });
  });
}

