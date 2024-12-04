import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:bluetooth_chat/models/chat_message.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'chat_messages.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE messages(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            deviceAddress TEXT,
            message TEXT,
            isFromMe INTEGER,
            timestamp INTEGER,
            contentType TEXT,
            content TEXT
          )
        ''');
      },
    );
  }

  Future<void> saveMessage(String deviceAddress, ChatMessage message) async {
    final db = await database;
    await db.insert(
      'messages',
      {
        'deviceAddress': deviceAddress,
        'message': message.message,
        'isFromMe': message.isFromMe ? 1 : 0,
        'timestamp': message.timestamp.millisecondsSinceEpoch,
        'contentType': message.contentType,
        'content': message.content,
      },
    );
  }

  Future<List<ChatMessage>> getMessages(String deviceAddress) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'messages',
      where: 'deviceAddress = ?',
      whereArgs: [deviceAddress],
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return ChatMessage(
        message: maps[i]['message'],
        isFromMe: maps[i]['isFromMe'] == 1,
        timestamp: DateTime.fromMillisecondsSinceEpoch(maps[i]['timestamp']),
        contentType: maps[i]['contentType'],
        content: maps[i]['content'],
      );
    });
  }

  Future<List<ChatMessage>> searchMessages(String query) async {
    final db = await database;
    return await db.query(
      'messages',
      where: 'message LIKE ?',
      whereArgs: ['%$query%'],
    );
  }

  Future<List<ChatMessage>> filterByDate(DateTime start, DateTime end) async {
    final db = await database;
    return await db.query(
      'messages',
      where: 'timestamp BETWEEN ? AND ?',
      whereArgs: [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
    );
  }
} 