class PresenceService {
  String _status = 'online';
  DateTime? _lastSeen;
  
  void updateStatus(String newStatus) {
    _status = newStatus;
    _broadcastStatus();
  }
  
  void _broadcastStatus() {
    // Send status update to connected devices
  }
} 