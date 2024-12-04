class MessageQueueService {
  final Queue<ChatMessage> _messageQueue = Queue();
  
  Future<void> queueMessage(ChatMessage message) async {
    _messageQueue.add(message);
    await _saveQueueToStorage();
  }
  
  Future<void> processQueue() async {
    while (_messageQueue.isNotEmpty) {
      final message = _messageQueue.removeFirst();
      try {
        // Attempt to send message
      } catch (e) {
        _messageQueue.addFirst(message);
        break;
      }
    }
  }
} 