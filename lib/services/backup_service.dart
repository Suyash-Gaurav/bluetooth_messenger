class BackupService {
  Future<void> exportChat(String deviceAddress) async {
    final messages = await DatabaseService().getMessages(deviceAddress);
    final json = jsonEncode(messages);
    // Save to file or cloud
  }
  
  Future<void> importChat(File backupFile) async {
    final json = await backupFile.readAsString();
    final messages = jsonDecode(json);
    // Restore messages to database
  }
} 