import 'dart:async';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import '../models/chat_group.dart';

class GroupService {
  static final GroupService _instance = GroupService._internal();
  factory GroupService() => _instance;
  GroupService._internal();

  ChatGroup? _currentGroup;
  final _groupController = StreamController<ChatGroup?>.broadcast();
  
  Stream<ChatGroup?> get groupStream => _groupController.stream;
  ChatGroup? get currentGroup => _currentGroup;
  
  Future<ChatGroup> createGroup(String name, BluetoothDevice hostDevice) async {
    if (_currentGroup != null) {
      throw Exception('Already in a group');
    }
    
    final group = ChatGroup(
      groupId: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      host: hostDevice,
    );
    
    _currentGroup = group;
    _groupController.add(group);
    return group;
  }
  
  Future<void> addMember(BluetoothDevice member) async {
    if (_currentGroup == null) {
      throw Exception('No active group');
    }
    
    if (!_currentGroup!.isHost(await FlutterBluetoothSerial.instance.address)) {
      throw Exception('Only host can add members');
    }
    
    if (!_currentGroup!.members.contains(member)) {
      _currentGroup!.members.add(member);
      _groupController.add(_currentGroup);
      
      // Notify all members about the new addition
      await _broadcastGroupUpdate();
    }
  }
  
  Future<void> removeMember(BluetoothDevice member) async {
    if (_currentGroup == null) {
      throw Exception('No active group');
    }
    
    if (!_currentGroup!.isHost(await FlutterBluetoothSerial.instance.address)) {
      throw Exception('Only host can remove members');
    }
    
    _currentGroup!.members.removeWhere(
      (m) => m.address == member.address
    );
    _groupController.add(_currentGroup);
    
    // Notify all members about the removal
    await _broadcastGroupUpdate();
  }
  
  Future<void> joinGroup(ChatGroup group) async {
    if (_currentGroup != null) {
      throw Exception('Already in a group');
    }
    
    _currentGroup = group;
    _groupController.add(group);
  }
  
  Future<void> leaveGroup() async {
    if (_currentGroup == null) return;
    
    final isHost = _currentGroup!.isHost(
      await FlutterBluetoothSerial.instance.address
    );
    
    if (isHost) {
      // If host leaves, dissolve the group
      await dissolveGroup();
    } else {
      // If member leaves, notify host
      await _notifyHostOfDeparture();
    }
    
    _currentGroup = null;
    _groupController.add(null);
  }
  
  Future<void> dissolveGroup() async {
    if (_currentGroup == null) return;
    
    if (!_currentGroup!.isHost(await FlutterBluetoothSerial.instance.address)) {
      throw Exception('Only host can dissolve the group');
    }
    
    // Notify all members that group is dissolved
    await _broadcastGroupDissolution();
    
    _currentGroup = null;
    _groupController.add(null);
  }
  
  Future<void> _broadcastGroupUpdate() async {
    // Implementation to send group updates to all members
  }
  
  Future<void> _broadcastGroupDissolution() async {
    // Implementation to notify all members about group dissolution
  }
  
  Future<void> _notifyHostOfDeparture() async {
    // Implementation to notify host about member departure
  }
  
  void dispose() {
    _groupController.close();
  }
} 