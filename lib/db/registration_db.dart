import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:mudepocflutter/models/registration_model.dart';
import 'package:mudepocflutter/models/checkin_model.dart';

class RegistrationDatabase {
  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'registrations.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE registrations(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            event_id INTEGER UNIQUE,
            is_registered INTEGER,
            has_checked_in INTEGER,
            registration_date TEXT,
            check_in_date TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE checkins(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            event_id INTEGER,
            latitude REAL,
            longitude REAL,
            timestamp TEXT,
            FOREIGN KEY(event_id) REFERENCES registrations(event_id)
          )
        ''');
      },
    );
  }

  static Future<Database> get _db async {
    return await _initDatabase();
  }

  static Future<void> registerForEvent(int eventId) async {
    final db = await _db;
    await db.insert(
      'registrations',
      {
        'event_id': eventId,
        'is_registered': 1,
        'has_checked_in': 0,
        'registration_date': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> checkInForEvent(CheckInModel checkIn) async {
    final db = await _db;

    // Atualiza o registro
    await db.update(
      'registrations',
      {
        'has_checked_in': 1,
        'check_in_date': DateTime.now().toIso8601String(),
      },
      where: 'event_id = ?',
      whereArgs: [checkIn.eventId],
    );

    // Salva os dados do check-in
    await db.insert(
      'checkins',
      checkIn.toMap(),
    );
  }

  static Future<Registration?> getRegistration(int eventId) async {
    final db = await _db;
    final maps = await db.query(
      'registrations',
      where: 'event_id = ?',
      whereArgs: [eventId],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return Registration.fromMap(maps.first);
    }
    return null;
  }

  static Future<List<CheckInModel>> getCheckInsForEvent(int eventId) async {
    final db = await _db;
    final maps = await db.query(
      'checkins',
      where: 'event_id = ?',
      whereArgs: [eventId],
    );

    return maps.map((map) => CheckInModel.fromMap(map)).toList();
  }
}