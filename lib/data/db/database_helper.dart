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
    return _database!;
  }

  // ===============================
  // INIT DATABASE
  // ===============================
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();

    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // ===============================
  // CREATE TABLES
  // ===============================
  Future<void> _createDB(Database db, int version) async {
    // JOBS TABLE
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

    // TECHNICIANS TABLE
    await db.execute('''
      CREATE TABLE technicians(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT,
        phone TEXT,
        role TEXT,
        jobs INTEGER,
        online INTEGER
      )
    ''');
  }

  // =====================================================
  // JOB METHODS
  // =====================================================

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

  // =====================================================
  // TECHNICIAN METHODS
  // =====================================================

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
  // FIND TECHNICIAN BY NAME
  // ===============================
  Future<List<Map<String, dynamic>>> getTechnicianByName(String name) async {
    final db = await database;

    return await db.query('technicians', where: 'name = ?', whereArgs: [name]);
  }

  // ===============================
  // INCREASE JOB COUNT BY NAME
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

      final id = tech["id"] as int;

      final currentJobs = tech["jobs"] as int? ?? 0;

      await db.update(
        'technicians',
        {"jobs": currentJobs + 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  // =====================================================
  // OPTIONAL HELPERS
  // =====================================================

  Future close() async {
    final db = await database;
    db.close();
  }
}
