import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AlarmDatabaseHelper {
  static final AlarmDatabaseHelper _instance = AlarmDatabaseHelper._internal();

  // This is the getter for accessing the singleton instance.
  static AlarmDatabaseHelper get instance => _instance;

  static Database? _database;

  // Private constructor for singleton
  AlarmDatabaseHelper._internal();

  // Initialize the database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'alarms.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Create table
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE alarms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        time TEXT,
        description TEXT
      )
    ''');
  }

  // Insert an alarm into the database
  Future<int> insertAlarm(Map<String, dynamic> alarm) async {
    Database db = await instance.database;
    return await db.insert('alarms', alarm);
  }

  // Get all alarms
  Future<List<Map<String, dynamic>>> getAlarms() async {
    Database db = await instance.database;
    return await db.query('alarms');
  }

  // Delete an alarm
  Future<int> deleteAlarm(int id) async {
    Database db = await instance.database;
    return await db.delete('alarms', where: 'id = ?', whereArgs: [id]);
  }

  // Update the status of an existing alarm
  Future<void> updateAlarmStatus(int id, int isActive) async {
    final db = await database;
    await db.update(
      'alarms',
      {'isActive': isActive},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
