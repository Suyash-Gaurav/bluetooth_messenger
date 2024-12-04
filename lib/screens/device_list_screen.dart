import 'package:flutter/material.dart';
import 'package:bluetooth_chat/services/bluetooth_service.dart';
import 'package:bluetooth_chat/screens/chat_screen.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:bluetooth_chat/screens/group_management_screen.dart';
import '../services/presence_service.dart';
import '../widgets/presence_indicator.dart';

class DeviceListScreen extends StatefulWidget {
  const DeviceListScreen({super.key});

  @override
  State<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  final BluetoothService _bluetoothService = BluetoothService();
  final PresenceService _presenceService = PresenceService();
  List<BluetoothDevice> devices = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initBluetooth();
    _presenceService.initialize();
  }

  Future<void> _initBluetooth() async {
    await _bluetoothService.enableBluetooth();
    await _loadPairedDevices();
  }

  Future<void> _loadPairedDevices() async {
    setState(() => isLoading = true);
    devices = await _bluetoothService.getPairedDevices();
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Device'),
        actions: [
          IconButton(
            icon: const Icon(Icons.group),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupManagementScreen(
                    currentDevice: _bluetoothService.bluetooth.address,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPairedDevices,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final device = devices[index];
                return ListTile(
                  leading: PresenceIndicator(
                    presence: _presenceService.getDevicePresence(device.address),
                  ),
                  title: Text(device.name ?? 'Unknown Device'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(device.address),
                      StreamBuilder<Map<String, UserPresence>>(
                        stream: _presenceService.presenceStream,
                        builder: (context, snapshot) {
                          final presence = snapshot.data?[device.address];
                          if (presence?.customStatus != null) {
                            return Text(
                              presence!.customStatus!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                  onTap: () async {
                    try {
                      await _bluetoothService.connectToDevice(device);
                      if (mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(device: device),
                          ),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error connecting: $e')),
                      );
                    }
                  },
                );
              },
            ),
    );
  }
} 