import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast_web/sembast_web.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseService {
  static Database? _db;
  static final _eventStore = intMapStoreFactory.store('events');
  static final _checkInStore = intMapStoreFactory.store('checkins');

  static Future<Database> get db async {
    if (_db == null) {
      await _initDatabase();
    }
    return _db!;
  }

  static Future<void> _initDatabase() async {
    if (kIsWeb) {
      _db = await databaseFactoryWeb.openDatabase('app_database.db');
    } else {
      final dir = await getApplicationDocumentsDirectory();
      await dir.create(recursive: true);
      final dbPath = join(dir.path, 'app_database.db');
      _db = await databaseFactoryIo.openDatabase(dbPath);
    }
  }
}