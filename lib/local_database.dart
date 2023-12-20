import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalDatabase {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    // If _database is null, initialize it
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    // Get the document directory
    var documentsDirectory = await getDatabasesPath();
    var path = join(documentsDirectory, "local_database.db");

    // Open the database
    return await openDatabase(path, version: 1, onCreate: _createTable);
  }

  Future<void> _createTable(Database db, int version) async {
    // Create your table(s) here
    await db.execute('''
      CREATE TABLE IF NOT EXISTS driver (
        id TEXT PRIMARY KEY,
        email TEXT,
        firstName TEXT,
        phone TEXT
      )
    ''');
  }

  Future<void> insertDriver(Map<String, dynamic> driver) async {
    final Database db = await database;
    await db.insert('driver', driver,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>> getDriver() async {
    final Database db = await database;
    List<Map<String, dynamic>> result = await db.query('driver');
    if (result.isNotEmpty) {
      return result.first;
    }
    return {};
  }
}
