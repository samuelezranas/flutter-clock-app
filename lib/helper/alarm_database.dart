import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AlarmDatabaseHelper {
  static final AlarmDatabaseHelper instance = AlarmDatabaseHelper._init();
  static Database? _database;

  AlarmDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('alarms.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE alarms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        time TEXT,
        description TEXT
      )
    ''');
  }

  Future<void> insertAlarm(Map<String, dynamic> alarm) async {
    final db = await instance.database;
    await db.insert('alarms', alarm);
  }

  Future<List<Map<String, dynamic>>> getAlarms() async {
    final db = await instance.database;
    return await db.query('alarms');
  }

  Future<void> deleteAlarm(int id) async {
    final db = await instance.database;
    await db.delete('alarms', where: 'id = ?', whereArgs: [id]);
  }
}
