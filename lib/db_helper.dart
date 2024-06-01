import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models/moment.dart';
import 'models/schedule.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  static Database? _database;

  DBHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'schedule.db');
    return openDatabase(
      path,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE schedules (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT,
            imagePath1 TEXT,
            imagePath2 TEXT,
            imagePath3 TEXT,
            startDate INTEGER,
            endDate INTEGER,
            location TEXT,
            color INTEGER,
            dressCode TEXT,
            allDay INTEGER,
            customFields TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE moments (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT,
            imagePath TEXT,
            date TEXT
          )
        ''');
      },
      version: 1,
    );
  }

  // Methods for Moments
  Future<int> insertMoment(Moment moment) async {
    final db = await database;
    return await db.insert('moments', moment.toMap());
  }

  Future<List<Moment>> getMoments() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('moments');
    return List.generate(maps.length, (i) {
      return Moment(
        id: maps[i]['id'],
        title: maps[i]['title'],
        description: maps[i]['description'],
        imagePath: maps[i]['imagePath'],
        date: DateTime.parse(maps[i]['date']),
      );
    });
  }

  Future<int> deleteMoment(int id) async {
    final db = await database;
    return await db.delete('moments', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateMoment(Moment moment) async {
    final db = await database;
    return await db.update(
      'moments',
      moment.toMap(),
      where: 'id = ?',
      whereArgs: [moment.id],
    );
  }

  // Methods for Schedules
  Future<void> insertSchedule(Schedule schedule) async {
    final db = await database;
    await db.insert(
      'schedules',
      schedule.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateSchedule(Schedule schedule) async {
    final db = await database;
    await db.update(
      'schedules',
      schedule.toMap(),
      where: 'id = ?',
      whereArgs: [schedule.id],
    );
  }

  Future<List<Schedule>> getSchedules() async {
    final db = await database;
    final maps = await db.query('schedules');
    return List.generate(maps.length, (i) {
      return Schedule.fromMap(maps[i]);
    });
  }

  Future<int> deleteSchedule(int id) async {
    final db = await database;
    return await db.delete('schedules', where: 'id = ?', whereArgs: [id]);
  }
}
