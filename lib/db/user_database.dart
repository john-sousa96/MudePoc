import 'package:sembast/sembast.dart';
import 'package:mudepocflutter/models/user_model.dart';
import 'package:mudepocflutter/db/database_service.dart';

class UserDatabase {
  static final StoreRef<int, Map<String, dynamic>> _userStore =
  intMapStoreFactory.store('users');

  static Future<int> insertUser(User user) async {
    final db = await DatabaseService.db;
    return await _userStore.add(db, user.toMap());
  }

  static Future<User?> getFirstUser() async {
    final db = await DatabaseService.db;
    final record = await _userStore.findFirst(db);

    if (record != null) {
      return User.fromMap(record.value, record.key);
    }
    return null;
  }

  static Future<int> updateUser(User user) async {
    final db = await DatabaseService.db;
    return await _userStore.update(
      db,
      user.toMap(),
      finder: Finder(filter: Filter.byKey(user.id)),
    );
  }

  static Future<int> deleteUser(int id) async {
    final db = await DatabaseService.db;
    return await _userStore.delete(
      db,
      finder: Finder(filter: Filter.byKey(id)),
    );
  }
}