class ConnectionManager {
  Timer? _reconnectTimer;
  
  void startAutoReconnect(BluetoothDevice device) {
    _reconnectTimer = Timer.periodic(Duration(seconds: 5), (_) async {
      if (!_isConnected) {
        try {
          await connectToDevice(device);
        } catch (e) {
          // Log reconnection attempt failure
        }
      }
    });
  }
  
  void stopAutoReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }
} 