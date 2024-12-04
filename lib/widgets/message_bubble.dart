import 'package:flutter/material.dart';
import 'package:bluetooth_chat/models/chat_message.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isFromMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: message.isFromMe ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.contentType == 'text')
              Text(
                message.message,
                style: TextStyle(
                  color: message.isFromMe ? Colors.white : Colors.black,
                ),
              )
            else if (message.contentType == 'image')
              Column(
                children: [
                  Image.memory(
                    base64Decode(message.content!),
                    width: 200,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Image',
                    style: TextStyle(
                      color: message.isFromMe ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              )
            else if (message.contentType == 'file')
              Row(
                children: [
                  const Icon(Icons.file_present),
                  const SizedBox(width: 8),
                  Text(
                    message.message,
                    style: TextStyle(
                      color: message.isFromMe ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('HH:mm').format(message.timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: message.isFromMe ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  message.status == 'sent' ? Icons.check : Icons.access_time,
                  size: 12,
                  color: message.isFromMe ? Colors.white70 : Colors.black54,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 