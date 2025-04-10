import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:mudepocflutter/models/checkin_model.dart';

class CheckInDatabase {
  static Future<Database> _getDB() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'checkins.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE checkins(id INTEGER PRIMARY KEY, latitude REAL, longitude REAL, timestamp TEXT)',
        );
      },
      version: 1,
    );
  }

  static Future<void> insertCheckIn(CheckInModel checkin) async {
    final db = await _getDB();
    await db.insert('checkins', checkin.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<CheckInModel>> getCheckIns() async {
    final db = await _getDB();
    final List<Map<String, dynamic>> maps = await db.query('checkins');

    return List.generate(maps.length, (i) {
      return CheckInModel(
        id: maps[i]['id'],
        latitude: maps[i]['latitude'],
        longitude: maps[i]['longitude'],
        timestamp: maps[i]['timestamp'],
      );
    });
  }
}