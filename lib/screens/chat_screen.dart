import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:bluetooth_chat/services/bluetooth_service.dart';
import 'package:bluetooth_chat/models/chat_message.dart';
import 'package:bluetooth_chat/widgets/message_bubble.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:convert/convert.dart';
import 'package:bluetooth_chat/services/database_service.dart';
import '../services/presence_service.dart';
import '../widgets/presence_indicator.dart';

class ChatScreen extends StatefulWidget {
  final BluetoothDevice device;

  const ChatScreen({super.key, required this.device});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final BluetoothService _bluetoothService = BluetoothService();
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final DatabaseService _databaseService = DatabaseService();
  bool _isConnected = false;
  final PresenceService _presenceService = PresenceService();

  @override
  void initState() {
    super.initState();
    _setupMessageListener();
    _loadPreviousMessages();
    _setupConnectionListener();
    _presenceService.initialize();
  }

  void _setupMessageListener() {
    _bluetoothService.receiveMessages().listen((message) {
      setState(() {
        _messages.add(ChatMessage(
          message: message,
          isFromMe: false,
          timestamp: DateTime.now(),
        ));
      });
    });
  }

  void _setupConnectionListener() {
    _bluetoothService.connectionStatus.listen((connected) {
      setState(() {
        _isConnected = connected;
      });
    });
  }

  Future<void> _loadPreviousMessages() async {
    final messages = await _databaseService.getMessages(widget.device.address);
    setState(() {
      _messages.addAll(messages);
    });
  }

  Future<void> _sendMessage(ChatMessage message) async {
    if (_messageController.text.isEmpty) return;

    try {
      await _bluetoothService.sendMessage(_messageController.text);
      setState(() {
        _messages.add(ChatMessage(
          message: _messageController.text,
          isFromMe: true,
          timestamp: DateTime.now(),
        ));
      });
      _messageController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending message: $e')),
      );
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);
      
      final message = ChatMessage(
        message: 'Image',
        isFromMe: true,
        timestamp: DateTime.now(),
        contentType: 'image',
        content: base64Image,
      );
      
      await _sendMessage(message);
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    
    if (result != null) {
      final bytes = await File(result.files.single.path!).readAsBytes();
      final base64File = base64Encode(bytes);
      
      final message = ChatMessage(
        message: result.files.single.name,
        isFromMe: true,
        timestamp: DateTime.now(),
        contentType: 'file',
        content: base64File,
      );
      
      await _sendMessage(message);
    }
  }

  void _showStatusSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const PresenceIndicator(
              presence: UserPresence(
                deviceAddress: '',
                status: PresenceStatus.online,
                lastSeen: null,
              ),
            ),
            title: const Text('Online'),
            onTap: () => _updateStatus(PresenceStatus.online),
          ),
          ListTile(
            leading: const PresenceIndicator(
              presence: UserPresence(
                deviceAddress: '',
                status: PresenceStatus.away,
                lastSeen: null,
              ),
            ),
            title: const Text('Away'),
            onTap: () => _updateStatus(PresenceStatus.away),
          ),
          ListTile(
            leading: const PresenceIndicator(
              presence: UserPresence(
                deviceAddress: '',
                status: PresenceStatus.busy,
                lastSeen: null,
              ),
            ),
            title: const Text('Busy'),
            onTap: () => _updateStatus(PresenceStatus.busy),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(PresenceStatus status) async {
    await _presenceService.updateStatus(status);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _bluetoothService.disconnect();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.device.name ?? 'Chat'),
            Row(
              children: [
                StreamBuilder<Map<String, UserPresence>>(
                  stream: _presenceService.presenceStream,
                  builder: (context, snapshot) {
                    final presence = snapshot.data?[widget.device.address];
                    return Row(
                      children: [
                        PresenceIndicator(presence: presence),
                        const SizedBox(width: 4),
                        Text(
                          presence?.status.toString().split('.').last ?? 'Offline',
                          style: TextStyle(
                            fontSize: 12,
                            color: _isConnected ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: _showStatusSelector,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                return MessageBubble(message: message);
              },
            ),
          ),
          if (!_isConnected)
            Container(
              color: Colors.red[100],
              padding: const EdgeInsets.all(8),
              child: const Text(
                'Disconnected. Trying to reconnect...',
                style: TextStyle(color: Colors.red),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: _pickImage,
                ),
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: _pickFile,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _isConnected ? _sendMessage : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 