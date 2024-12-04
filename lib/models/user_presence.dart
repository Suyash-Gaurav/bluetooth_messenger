enum PresenceStatus {
  online,
  offline,
  away,
  busy
}

class UserPresence {
  final String deviceAddress;
  final PresenceStatus status;
  final DateTime lastSeen;
  final String? customStatus;

  UserPresence({
    required this.deviceAddress,
    required this.status,
    required this.lastSeen,
    this.customStatus,
  });

  Map<String, dynamic> toJson() => {
        'deviceAddress': deviceAddress,
        'status': status.toString(),
        'lastSeen': lastSeen.toIso8601String(),
        'customStatus': customStatus,
      };

  factory UserPresence.fromJson(Map<String, dynamic> json) => UserPresence(
        deviceAddress: json['deviceAddress'],
        status: PresenceStatus.values.firstWhere(
          (e) => e.toString() == json['status'],
          orElse: () => PresenceStatus.offline,
        ),
        lastSeen: DateTime.parse(json['lastSeen']),
        customStatus: json['customStatus'],
      );
} 