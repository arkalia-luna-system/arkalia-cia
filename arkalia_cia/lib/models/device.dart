/// Modèle représentant un appareil connecté au profil utilisateur
class Device {
  final String deviceId;
  final String deviceName;
  final String platform; // 'iOS', 'Android', 'Web', 'macOS', 'Windows', 'Linux'
  final DateTime lastSeen;
  final bool isActive;
  final String? fcmToken; // Token pour notifications push (optionnel)

  Device({
    required this.deviceId,
    required this.deviceName,
    required this.platform,
    required this.lastSeen,
    this.isActive = true,
    this.fcmToken,
  });

  /// Crée un Device depuis un Map (depuis JSON/SharedPreferences)
  factory Device.fromMap(Map<String, dynamic> map) {
    return Device(
      deviceId: map['deviceId'] as String,
      deviceName: map['deviceName'] as String,
      platform: map['platform'] as String,
      lastSeen: DateTime.parse(map['lastSeen'] as String),
      isActive: map['isActive'] as bool? ?? true,
      fcmToken: map['fcmToken'] as String?,
    );
  }

  /// Convertit un Device en Map (pour JSON/SharedPreferences)
  Map<String, dynamic> toMap() {
    return {
      'deviceId': deviceId,
      'deviceName': deviceName,
      'platform': platform,
      'lastSeen': lastSeen.toIso8601String(),
      'isActive': isActive,
      'fcmToken': fcmToken,
    };
  }

  /// Crée une copie avec des champs modifiés
  Device copyWith({
    String? deviceId,
    String? deviceName,
    String? platform,
    DateTime? lastSeen,
    bool? isActive,
    String? fcmToken,
  }) {
    return Device(
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      platform: platform ?? this.platform,
      lastSeen: lastSeen ?? this.lastSeen,
      isActive: isActive ?? this.isActive,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  @override
  String toString() {
    return 'Device(deviceId: $deviceId, deviceName: $deviceName, platform: $platform, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Device && other.deviceId == deviceId;
  }

  @override
  int get hashCode => deviceId.hashCode;
}

