import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();

  DatabaseHelper._internal();
  factory DatabaseHelper() {
    return instance;
  }
  Database? _database;
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'chat_app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
            CREATE TABLE messages (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            chat_id TEXT NOT NULL,
            role TEXT NOT NULL,
            message TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
          ''');
        await db.execute('''
            CREATE TABLE IF NOT EXISTS settings (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
          )
          ''');
      },
      onOpen: (db) async {
        await db.execute('''
            CREATE TABLE IF NOT EXISTS settings (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
          )
          ''');
      },
    );
  }

  Future<int> insertMessage({
    required String chatId,
    required String role,
    required String message,
  }) async {
    final db = await database;
    return await db.insert('messages', {
      'chat_id': chatId,
      'role': role,
      'message': message,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getMessage(String chatId) async {
    final db = await database;
    return await db.query(
      'messages',
      where: 'chat_id = ?',
      whereArgs: [chatId],
      orderBy: 'created_at ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getRecentChats() async {
    final db = await database;
    try {
      return await db.rawQuery('''
        SELECT m.chat_id, m.message, m.role, m.created_at
        FROM messages m
        INNER JOIN (
          SELECT chat_id, MAX(id) as max_id
          FROM messages
          GROUP BY chat_id
        ) latest ON m.id = latest.max_id
        ORDER BY m.created_at DESC
      ''');
    } catch (_) {
      return [];
    }
  }

  Future<int> deleteChat(String chatId) async {
    final db = await database;
    return await db.delete(
      'messages',
      where: 'chat_id = ?',
      whereArgs: [chatId],
    );
  }

  Future<int> clearAllMessages() async {
    final db = await database;
    return await db.delete('messages');
  }

  Future<int> getTotalChatsCount() async {
    final db = await database;
    try {
      final res = await db.rawQuery('SELECT COUNT(DISTINCT chat_id) as count FROM messages');
      if (res.isNotEmpty && res.first['count'] != null) {
        return (res.first['count'] as num).toInt();
      }
    } catch (_) {}
    return 0;
  }

  Future<int> getTotalMessagesCount() async {
    final db = await database;
    try {
      final res = await db.rawQuery('SELECT COUNT(*) as count FROM messages');
      if (res.isNotEmpty && res.first['count'] != null) {
        return (res.first['count'] as num).toInt();
      }
    } catch (_) {}
    return 0;
  }

  Future<String?> getSetting(String key, {String? defaultValue}) async {
    final db = await database;
    try {
      final res = await db.query(
        'settings',
        where: 'key = ?',
        whereArgs: [key],
        limit: 1,
      );
      if (res.isNotEmpty && res.first['value'] != null) {
        return res.first['value'].toString();
      }
    } catch (_) {}
    return defaultValue;
  }

  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
