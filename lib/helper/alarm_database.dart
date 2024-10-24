import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AlarmDatabaseHelper {
  static final AlarmDatabaseHelper _instance = AlarmDatabaseHelper._internal();
  static Database? _database;

  factory AlarmDatabaseHelper() {
    return _instance;
  }

  AlarmDatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'alarm.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE alarms (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            time TEXT,
            isActive INTEGER
          )
        ''');
      },
    );
  }

  // Insert new alarm
  Future<int> insertAlarm(Map<String, dynamic> alarm) async {
    final db = await database;
    return await db.insert('alarms', alarm);
  }

  // Get all alarms
  Future<List<Map<String, dynamic>>> getAlarms() async {
    final db = await database;
    return await db.query('alarms');
  }

  // Update alarm status (active/inactive)
  Future<int> updateAlarmStatus(int id, int isActive) async {
    final db = await database;
    return await db.update(
      'alarms',
      {'isActive': isActive},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete alarm
  Future<int> deleteAlarm(int id) async {
    final db = await database;
    return await db.delete(
      'alarms',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
