import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart'; // Para Android/iOS
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sembast/sembast_io.dart' as sembast_io;
import 'package:sembast_web/sembast_web.dart' as sembast_web;

import '../models/event.dart';

class EventDatabase {
  static final EventDatabase _singleton = EventDatabase._internal();
  EventDatabase._internal();
  factory EventDatabase() => _singleton;

  late Database _db;
  final _store = intMapStoreFactory.store('events');

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    if (kIsWeb) {
      _db = await sembast_web.databaseFactoryWeb.openDatabase('event_db');
    } else {
      final dir = await getApplicationDocumentsDirectory();
      final dbPath = join(dir.path, 'event_db.db');
      _db = await sembast_io.databaseFactoryIo.openDatabase(dbPath);
    }

    _initialized = true;
  }

  Future<int> insertEvent(Event event) async {
    await init(); // Garante que _db está inicializado
    return await _store.add(_db, event.toMap());
  }

  Future<List<Event>> getAllEvents() async {
    await init();
    final records = await _store.find(_db);
    return records.map<Event>((snapshot) {
      return Event.fromMap(snapshot.value, snapshot.key);
    }).toList();
  }

  Future<int> updateEvent(Event event) async {
    await init();
    final finder = Finder(filter: Filter.byKey(event.id));
    return await _store.update(_db, event.toMap(), finder: finder);
  }

  Future<int> deleteEvent(int id) async {
    await init();
    final finder = Finder(filter: Filter.byKey(id));
    return await _store.delete(_db, finder: finder);
  }
}
