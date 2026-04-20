import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // ===============================
  // GET DATABASE
  // ===============================
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('fsm.db');
    await insertDefaultAdmin();

    return _database!;
  }

  // ===============================
  // INIT DATABASE
  // ===============================
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  // ===============================
  // CREATE TABLES
  // ===============================
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT UNIQUE,
        password TEXT,
        role TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE jobs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        customer TEXT,
        location TEXT,
        technician TEXT,
        priority TEXT,
        status TEXT,
        lat REAL,
        lng REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE technicians(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT UNIQUE,
        phone TEXT,
        role TEXT,
        jobs INTEGER DEFAULT 0,
        online INTEGER DEFAULT 0
      )
    ''');
  }

  // ===============================
  // DATABASE UPGRADE
  // ===============================
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS users(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          email TEXT UNIQUE,
          password TEXT,
          role TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS jobs(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          customer TEXT,
          location TEXT,
          technician TEXT,
          priority TEXT,
          status TEXT,
          lat REAL,
          lng REAL
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS technicians(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          email TEXT UNIQUE,
          phone TEXT,
          role TEXT,
          jobs INTEGER DEFAULT 0,
          online INTEGER DEFAULT 0
        )
      ''');
    }
  }

  // ===============================
  // DEFAULT ADMIN
  // ===============================
  Future<void> insertDefaultAdmin() async {
    final db = _database ?? await database;

    const adminEmail = 'divyabharathi@catalystack.com';
    const adminPassword = 'Rdivya@0108';

    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [adminEmail],
      limit: 1,
    );

    if (result.isEmpty) {
      await db.insert('users', {
        'name': 'Divya',
        'email': adminEmail,
        'password': adminPassword,
        'role': 'admin',
      });
    }
  }

  // ===============================
  // LOGIN USER
  // ===============================
  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final db = await database;

    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email.trim(), password.trim()],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
  }

  // ===============================
  // USERS
  // ===============================
  Future<int> insertUser(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('users', data);
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return await db.query('users', orderBy: 'id DESC');
  }

  Future<int> updateUserPassword(String email, String newPassword) async {
    final db = await database;

    return await db.update(
      'users',
      {'password': newPassword},
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  // ===============================
  // JOBS
  // ===============================
  Future<int> insertJob(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('jobs', data);
  }

  Future<List<Map<String, dynamic>>> getJobs() async {
    final db = await database;
    return await db.query('jobs', orderBy: 'id DESC');
  }

  Future<int> deleteJob(int id) async {
    final db = await database;
    return await db.delete('jobs', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateJob(Map<String, dynamic> data, int id) async {
    final db = await database;

    return await db.update('jobs', data, where: 'id = ?', whereArgs: [id]);
  }

  // ===============================
  // TECHNICIANS
  // ===============================
  Future<int> insertTechnician(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('technicians', row);
  }

  Future<List<Map<String, dynamic>>> getTechnicians() async {
    final db = await database;
    return await db.query('technicians', orderBy: 'id DESC');
  }

  Future<int> deleteTechnician(int id) async {
    final db = await database;

    return await db.delete('technicians', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateTechnician(Map<String, dynamic> data, int id) async {
    final db = await database;

    return await db.update(
      'technicians',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ===============================
  // JOB COUNT UPDATE
  // ===============================
  Future<int> updateJobsCount(int id, int jobs) async {
    final db = await database;

    return await db.update(
      'technicians',
      {'jobs': jobs},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ===============================
  // FIND TECH BY NAME
  // ===============================
  Future<List<Map<String, dynamic>>> getTechnicianByName(String name) async {
    final db = await database;

    return await db.query('technicians', where: 'name = ?', whereArgs: [name]);
  }

  // ===============================
  // INCREASE JOB COUNT
  // ===============================
  Future<void> increaseTechnicianJobs(String name) async {
    final db = await database;

    final result = await db.query(
      'technicians',
      where: 'name = ?',
      whereArgs: [name],
    );

    if (result.isNotEmpty) {
      final tech = result.first;

      final id = tech['id'] as int;
      final currentJobs = tech['jobs'] as int? ?? 0;

      await db.update(
        'technicians',
        {'jobs': currentJobs + 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  Future<int> updateJobStatus(int id, String status) async {
    final db = await database;

    return await db.update(
      'jobs',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ===============================
  // CLOSE DB
  // ===============================
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
