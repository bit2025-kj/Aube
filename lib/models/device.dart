class UserDevice {
  final String deviceId;
  final String userId;
  final String deviceName;
  final String osType;
  final String? fcmToken;
  final bool isPrimary;
  final DateTime lastUsed;
  final DateTime createdAt;

  UserDevice({
    required this.deviceId,
    required this.userId,
    required this.deviceName,
    required this.osType,
    this.fcmToken,
    required this.isPrimary,
    required this.lastUsed,
    required this.createdAt,
  });

  factory UserDevice.fromJson(Map<String, dynamic> json) {
    return UserDevice(
      deviceId: json['device_id'],
      userId: json['user_id'],
      deviceName: json['device_name'],
      osType: json['os_type'],
      fcmToken: json['fcm_token'],
      isPrimary: json['is_primary'] ?? false,
      lastUsed: DateTime.parse(json['last_used']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}



