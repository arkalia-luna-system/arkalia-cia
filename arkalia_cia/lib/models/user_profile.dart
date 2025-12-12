import 'device.dart';

/// Modèle représentant le profil utilisateur avec synchronisation multi-appareil
class UserProfile {
  final String userId; // UUID unique
  final String email; // Identifiant principal
  final String? displayName;
  final List<Device> devices;
  final DateTime createdAt;
  final DateTime? lastSync;
  final Map<String, dynamic>? preferences; // Préférences utilisateur

  UserProfile({
    required this.userId,
    required this.email,
    this.displayName,
    List<Device>? devices,
    DateTime? createdAt,
    this.lastSync,
    this.preferences,
  })  : devices = devices ?? [],
        createdAt = createdAt ?? DateTime.now();

  /// Crée un UserProfile depuis un Map (depuis JSON/SharedPreferences)
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      userId: map['userId'] as String,
      email: map['email'] as String,
      displayName: map['displayName'] as String?,
      devices: (map['devices'] as List<dynamic>?)
              ?.map((d) => Device.fromMap(d as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : null,
      lastSync: map['lastSync'] != null
          ? DateTime.parse(map['lastSync'] as String)
          : null,
      preferences: map['preferences'] as Map<String, dynamic>?,
    );
  }

  /// Convertit un UserProfile en Map (pour JSON/SharedPreferences)
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'email': email,
      'displayName': displayName,
      'devices': devices.map((d) => d.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'lastSync': lastSync?.toIso8601String(),
      'preferences': preferences,
    };
  }

  /// Crée une copie avec des champs modifiés
  UserProfile copyWith({
    String? userId,
    String? email,
    String? displayName,
    List<Device>? devices,
    DateTime? createdAt,
    DateTime? lastSync,
    Map<String, dynamic>? preferences,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      devices: devices ?? this.devices,
      createdAt: createdAt ?? this.createdAt,
      lastSync: lastSync ?? this.lastSync,
      preferences: preferences ?? this.preferences,
    );
  }

  /// Retourne le device actuel (celui sur lequel l'app tourne)
  Device? getCurrentDevice(String currentDeviceId) {
    try {
      return devices.firstWhere((d) => d.deviceId == currentDeviceId);
    } catch (e) {
      return null;
    }
  }

  /// Retourne les devices actifs
  List<Device> getActiveDevices() {
    return devices.where((d) => d.isActive).toList();
  }

  @override
  String toString() {
    return 'UserProfile(userId: $userId, email: $email, devices: ${devices.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;
}

