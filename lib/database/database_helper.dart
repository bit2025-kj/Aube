import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'mobilemoney_notifications.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        type TEXT NOT NULL,
        sub_type TEXT NOT NULL,
        operator_type TEXT NOT NULL,
        amount REAL,
        commission REAL,
        client_name TEXT,
        client_phone TEXT,
        is_read INTEGER DEFAULT 0,
        is_archived INTEGER DEFAULT 0,
        priority TEXT DEFAULT 'medium',
        created_at TEXT NOT NULL,
        read_at TEXT,
        metadata TEXT DEFAULT '{}'
      )
    ''');

    await db.execute('''
      CREATE TABLE notification_settings (
        id INTEGER PRIMARY KEY,
        transaction_notifications INTEGER DEFAULT 1,
        security_notifications INTEGER DEFAULT 1,
        commission_notifications INTEGER DEFAULT 1,
        daily_summary INTEGER DEFAULT 0,
        daily_summary_time TEXT DEFAULT '20:00',
        silent_notifications INTEGER DEFAULT 0,
        vibration INTEGER DEFAULT 1,
        updated_at TEXT NOT NULL
      )
    ''');

    // Insérer des données de démonstration
    await db.insert('notifications', {
      'title': 'Transaction réussie - Orange Money',
      'description': '25.000 FCFA déposés pour Diallo Ahmed\nTransaction #789012',
      'type': 'transaction',
      'sub_type': 'deposit_success',
      'operator_type': 'orange',
      'amount': 25000,
      'commission': 250,
      'client_name': 'Diallo Ahmed',
      'is_read': 0,
      'is_archived': 0,
      'priority': 'medium',
      'created_at': DateTime.now().subtract(Duration(minutes: 5)).toIso8601String(),
      'metadata': '{}',
    });

    await db.insert('notification_settings', {
      'id': 1,
      'transaction_notifications': 1,
      'security_notifications': 1,
      'commission_notifications': 1,
      'daily_summary': 0,
      'daily_summary_time': '20:00',
      'silent_notifications': 0,
      'vibration': 1,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  // ✅ CORRECTION: Retourne List<Map<String, dynamic>>
  Future<List<Map<String, dynamic>>> getNotifications() async {
    final db = await database;
    return await db.query('notifications',
        where: 'is_archived = 0',
        orderBy: 'created_at DESC',
        limit: 50
    );
  }

  // ✅ CORRECTION: Accepte Map<String, dynamic>
  Future<int> insertNotification(Map<String, dynamic> notification) async {
    final db = await database;
    return await db.insert('notifications', notification);
  }

  Future<int> markAsRead(int id) async {
    final db = await database;
    return await db.update(
      'notifications',
      {'is_read': 1, 'read_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> markAllAsRead() async {
    final db = await database;
    return await db.update(
      'notifications',
      {'is_read': 1, 'read_at': DateTime.now().toIso8601String()},
      where: 'is_read = 0 AND is_archived = 0',
    );
  }

  Future<int> deleteNotification(int id) async {
    final db = await database;
    return await db.delete(
      'notifications',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> countUnreadNotifications() async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM notifications WHERE is_read = 0 AND is_archived = 0'
    );
    return (result.first['count'] ?? 0) as int;
  }

  Future<Map<String, dynamic>> getNotificationSettings() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('notification_settings');

    if (maps.isNotEmpty) {
      return {
        'transactionNotifications': maps.first['transaction_notifications'] == 1,
        'securityNotifications': maps.first['security_notifications'] == 1,
        'commissionNotifications': maps.first['commission_notifications'] == 1,
        'dailySummary': maps.first['daily_summary'] == 1,
        'dailySummaryTime': maps.first['daily_summary_time'],
        'silentNotifications': maps.first['silent_notifications'] == 1,
        'vibration': maps.first['vibration'] == 1,
      };
    }

    return {
      'transactionNotifications': true,
      'securityNotifications': true,
      'commissionNotifications': true,
      'dailySummary': false,
      'dailySummaryTime': '20:00',
      'silentNotifications': false,
      'vibration': true,
    };
  }

  Future<int> updateNotificationSettings(Map<String, dynamic> settings) async {
    final db = await database;

    final map = {
      'transaction_notifications': settings['transactionNotifications'] ? 1 : 0,
      'security_notifications': settings['securityNotifications'] ? 1 : 0,
      'commission_notifications': settings['commissionNotifications'] ? 1 : 0,
      'daily_summary': settings['dailySummary'] ? 1 : 0,
      'daily_summary_time': settings['dailySummaryTime'],
      'silent_notifications': settings['silentNotifications'] ? 1 : 0,
      'vibration': settings['vibration'] ? 1 : 0,
      'updated_at': DateTime.now().toIso8601String(),
    };

    return await db.update(
      'notification_settings',
      map,
      where: 'id = 1',
    );
  }
}


