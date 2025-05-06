import 'package:mudepocflutter/models/checkin_model.dart';
import 'package:mudepocflutter/db/database_service.dart';
import 'package:sembast/sembast.dart';

class CheckInDatabase {

  static Future<void> insertCheckIn(CheckInModel checkin) async {
    final db = await DatabaseService.db;
    await DatabaseService.checkInStore.add(db, checkin.toMap());
  }

  static Future<List<CheckInModel>> getCheckInsForEvent(int eventId) async {
    final db = await DatabaseService.db;
    final records = await DatabaseService.checkInStore.find(db,
        finder: Finder(filter: Filter.equals('event_id', eventId)));

    return records.map((record) {
      return CheckInModel.fromMap(record.value, record.key);
    }).toList();
  }

}