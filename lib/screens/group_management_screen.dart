import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import '../services/group_service.dart';
import '../models/chat_group.dart';

class GroupManagementScreen extends StatefulWidget {
  final BluetoothDevice currentDevice;

  const GroupManagementScreen({
    Key? key,
    required this.currentDevice,
  }) : super(key: key);

  @override
  State<GroupManagementScreen> createState() => _GroupManagementScreenState();
}

class _GroupManagementScreenState extends State<GroupManagementScreen> {
  final GroupService _groupService = GroupService();
  final TextEditingController _groupNameController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Management'),
      ),
      body: StreamBuilder<ChatGroup?>(
        stream: _groupService.groupStream,
        builder: (context, snapshot) {
          final group = snapshot.data;
          
          if (group == null) {
            return _buildCreateGroupSection();
          }
          
          return _buildGroupManagementSection(group);
        },
      ),
    );
  }
  
  Widget _buildCreateGroupSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _groupNameController,
            decoration: const InputDecoration(
              labelText: 'Group Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              if (_groupNameController.text.isEmpty) return;
              
              try {
                await _groupService.createGroup(
                  _groupNameController.text,
                  widget.currentDevice,
                );
                _groupNameController.clear();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString())),
                );
              }
            },
            child: const Text('Create Group'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGroupManagementSection(ChatGroup group) {
    final isHost = group.isHost(widget.currentDevice);
    
    return Column(
      children: [
        ListTile(
          title: Text('Group: ${group.name}'),
          subtitle: Text(isHost ? 'You are the host' : 'Host: ${group.host.name}'),
        ),
        const Divider(),
        Expanded(
          child: ListView.builder(
            itemCount: group.members.length,
            itemBuilder: (context, index) {
              final member = group.members[index];
              return ListTile(
                title: Text(member.name ?? 'Unknown Device'),
                subtitle: Text(member.address),
                trailing: isHost ? IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () => _groupService.removeMember(member),
                ) : null,
              );
            },
          ),
        ),
        if (isHost) Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () => _groupService.dissolveGroup(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Dissolve Group'),
          ),
        ) else Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () => _groupService.leaveGroup(),
            child: const Text('Leave Group'),
          ),
        ),
      ],
    );
  }
  
  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }
} 