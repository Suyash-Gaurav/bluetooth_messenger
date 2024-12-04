import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:async';

class BluetoothService {
  static final BluetoothService _instance = BluetoothService._internal();
  factory BluetoothService() => _instance;
  BluetoothService._internal();

  FlutterBluetoothSerial get bluetooth => FlutterBluetoothSerial.instance;
  BluetoothConnection? connection;

  bool _isConnected = false;
  final StreamController<bool> _connectionStatusController = StreamController<bool>.broadcast();
  Stream<bool> get connectionStatus => _connectionStatusController.stream;

  Future<bool> enableBluetooth() async {
    bool? isEnabled = await bluetooth.isEnabled;
    if (!isEnabled!) {
      await bluetooth.requestEnable();
    }
    return await bluetooth.isEnabled ?? false;
  }

  Future<List<BluetoothDevice>> getPairedDevices() async {
    return await bluetooth.getBondedDevices();
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      connection = await BluetoothConnection.toAddress(device.address);
      _isConnected = true;
      _connectionStatusController.add(true);
      
      connection!.input!.listen(
        (data) {
          // Handle incoming data
        },
        onDone: () {
          _isConnected = false;
          _connectionStatusController.add(false);
        },
        onError: (error) {
          _isConnected = false;
          _connectionStatusController.add(false);
        },
      );
    } catch (e) {
      _isConnected = false;
      _connectionStatusController.add(false);
      print('Error connecting to device: $e');
      rethrow;
    }
  }

  Future<void> sendMessage(String message) async {
    if (connection?.isConnected ?? false) {
      connection!.output.add(Uint8List.fromList(utf8.encode(message + "\n")));
      await connection!.output.allSent;
    }
  }

  void disconnect() {
    connection?.dispose();
    connection = null;
  }

  Stream<String> receiveMessages() {
    return connection!.input!.map((Uint8List data) {
      return utf8.decode(data);
    });
  }

  @override
  void dispose() {
    _connectionStatusController.close();
    disconnect();
  }

  Future<void> sendReadReceipt(String messageId) async {
    final receipt = {
      'type': 'read_receipt',
      'messageId': messageId,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await sendMessage(jsonEncode(receipt));
  }

  Future<void> broadcastToGroup(String message, List<BluetoothDevice> recipients) async {
    for (final device in recipients) {
      try {
        final connection = await BluetoothConnection.toAddress(device.address);
        connection.output.add(Uint8List.fromList(utf8.encode(message + "\n")));
        await connection.output.allSent;
        connection.dispose();
      } catch (e) {
        print('Error sending to ${device.name}: $e');
        // Handle failed delivery
      }
    }
  }
} 