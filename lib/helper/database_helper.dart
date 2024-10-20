import 'dart:async';
import 'dart:io';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  // Singleton Pattern
  DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Inisialisasi Database
  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'history.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Membuat tabel di SQLite
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        time INTEGER
      )
    ''');
  }

  // Insert data ke tabel history
  Future<int> insertHistory(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('history', row);
  }

  // Ambil semua data dari tabel history
  Future<List<Map<String, dynamic>>> queryAllHistory() async {
    Database db = await database;
    return await db.query('history');
  }

  // Update data di tabel history
  Future<int> updateHistory(Map<String, dynamic> row) async {
    Database db = await database;
    int id = row['id'];
    return await db.update('history', row, where: 'id = ?', whereArgs: [id]);
  }

  // Delete data dari tabel history
  Future<int> deleteHistory(int id) async {
    Database db = await database;
    return await db.delete('history', where: 'id = ?', whereArgs: [id]);
  }
}