import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'user.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'user_profile.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_profile(
        id TEXT PRIMARY KEY,
        firstname TEXT,
        email TEXT,
        phone TEXT
      )
    ''');
  }

  Future<void> insertUserProfile(UserProfile userProfile) async {
    final db = await database;
    await db.insert(
      'user_profile',
      userProfile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserProfile> getUserProfile() async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query('user_profile');
    if (maps.isNotEmpty) {
      return UserProfile.fromMap(maps.first);
    }
    throw Exception('User profile not found in the local database.');
  }
}
