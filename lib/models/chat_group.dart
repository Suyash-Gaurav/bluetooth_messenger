import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

enum GroupRole {
  host,
  member
}

class ChatGroup {
  final String groupId;
  final String name;
  final BluetoothDevice host;
  final List<BluetoothDevice> members;
  final DateTime createdAt;
  
  ChatGroup({
    required this.groupId,
    required this.name,
    required this.host,
    List<BluetoothDevice>? members,
    DateTime? createdAt,
  }) : 
    this.members = members ?? [],
    this.createdAt = createdAt ?? DateTime.now();

  bool isHost(BluetoothDevice device) => device.address == host.address;
  
  bool isMember(BluetoothDevice device) {
    return members.any((member) => member.address == device.address);
  }
} 