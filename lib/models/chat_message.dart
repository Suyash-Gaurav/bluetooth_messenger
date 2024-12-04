enum MessageContentType {
  text,
  image,
  file,
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed
}

class ChatMessage {
  final String message;
  final bool isFromMe;
  final DateTime timestamp;
  final String contentType;
  final String? content;
  final String? status;
  final MessageStatus status;
  final String? errorMessage;

  ChatMessage({
    required this.message,
    required this.isFromMe,
    required this.timestamp,
    this.contentType = 'text',
    this.content,
    this.status = 'sent',
    this.status = MessageStatus.sending,
    this.errorMessage,
  });

  Map<String, dynamic> toJson() => {
        'message': message,
        'isFromMe': isFromMe,
        'timestamp': timestamp.toIso8601String(),
        'contentType': contentType,
        'content': content,
        'status': status,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        message: json['message'],
        isFromMe: json['isFromMe'],
        timestamp: DateTime.parse(json['timestamp']),
        contentType: json['contentType'],
        content: json['content'],
        status: json['status'],
        status = MessageStatus.values[json['status']],
        errorMessage: json['errorMessage'],
      );
} 