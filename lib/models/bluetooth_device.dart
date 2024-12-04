import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothDeviceModel {
  final BluetoothDevice device;
  bool isConnected;

  BluetoothDeviceModel({
    required this.device,
    this.isConnected = false,
  });
} 