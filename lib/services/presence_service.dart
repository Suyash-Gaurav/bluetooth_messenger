import 'dart:async';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import '../models/user_presence.dart';
import 'bluetooth_service.dart';

class PresenceService {
  static final PresenceService _instance = PresenceService._internal();
  factory PresenceService() => _instance;
  PresenceService._internal();

  final BluetoothService _bluetoothService = BluetoothService();
  final Map<String, UserPresence> _connectedDevices = {};
  final _presenceController = StreamController<Map<String, UserPresence>>.broadcast();
  Timer? _presenceUpdateTimer;

  Stream<Map<String, UserPresence>> get presenceStream => _presenceController.stream;
  PresenceStatus _currentStatus = PresenceStatus.online;
  String? _customStatus;

  void initialize() {
    _startPresenceUpdates();
    _listenToPresenceUpdates();
  }

  void _startPresenceUpdates() {
    _presenceUpdateTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _broadcastPresence();
    });
  }

  void _listenToPresenceUpdates() {
    _bluetoothService.receiveMessages().listen((message) {
      if (message.startsWith('PRESENCE:')) {
        final presenceData = message.substring(9);
        final presence = UserPresence.fromJson(
          Map<String, dynamic>.from(json.decode(presenceData))
        );
        _updateDevicePresence(presence);
      }
    });
  }

  void _updateDevicePresence(UserPresence presence) {
    _connectedDevices[presence.deviceAddress] = presence;
    _presenceController.add(_connectedDevices);
  }

  Future<void> updateStatus(PresenceStatus status, {String? customStatus}) async {
    _currentStatus = status;
    _customStatus = customStatus;
    await _broadcastPresence();
  }

  Future<void> _broadcastPresence() async {
    if (!_bluetoothService.isConnected) return;

    final presence = UserPresence(
      deviceAddress: await FlutterBluetoothSerial.instance.address,
      status: _currentStatus,
      lastSeen: DateTime.now(),
      customStatus: _customStatus,
    );

    final message = 'PRESENCE:${json.encode(presence.toJson())}';
    await _bluetoothService.broadcastToGroup(message, _connectedDevices.keys.toList());
  }

  UserPresence? getDevicePresence(String deviceAddress) {
    return _connectedDevices[deviceAddress];
  }

  void markDeviceOffline(String deviceAddress) {
    final presence = _connectedDevices[deviceAddress];
    if (presence != null) {
      _connectedDevices[deviceAddress] = UserPresence(
        deviceAddress: deviceAddress,
        status: PresenceStatus.offline,
        lastSeen: DateTime.now(),
        customStatus: presence.customStatus,
      );
      _presenceController.add(_connectedDevices);
    }
  }

  void dispose() {
    _presenceUpdateTimer?.cancel();
    _presenceController.close();
  }
} 