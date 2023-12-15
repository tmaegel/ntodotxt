import 'package:ntodotxt/data/database.dart' show ModelController;
import 'package:ntodotxt/domain/settings/setting_model.dart' show Setting;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class SettingController extends ModelController<Setting> {
  SettingController(super.path);

  @override
  Future<List<Setting>> list() async {
    late final List<Map<String, dynamic>> maps;
    try {
      final Database db = await database;
      // Query the table for all The Dogs.
      maps = await db.query('settings');
    } on Exception {
      rethrow;
    } finally {
      await close();
    }

    return List.generate(maps.length, (i) {
      return Setting.fromMap(maps[i]);
    });
  }

  @override
  Future<Setting?> get({required dynamic identifier}) async {
    Setting? model;
    try {
      final Database db = await database;
      List<Map> maps = await db.query(
        'settings',
        columns: ['key', 'value'],
        where: 'key = ?',
        whereArgs: [identifier as String],
      );
      if (maps.isNotEmpty) {
        model = Setting.fromMap(maps.first);
      }
    } on Exception {
      rethrow;
    } finally {
      await close();
    }

    return model;
  }

  @override
  Future<int> insert(Setting model) async {
    late final int id;
    try {
      final Database db = await database;
      id = await db.insert(
        'settings',
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    } on Exception {
      rethrow;
    } finally {
      await close();
    }

    return id;
  }

  @override
  Future<int> update(Setting model) async {
    late final int id;
    try {
      final Database db = await database;
      id = await db.update(
        'settings',
        model.toMap(),
        // Ensure that the model has a matching id.
        where: 'key = ?',
        // Pass the models id as a whereArg to prevent SQL injection.
        whereArgs: [model.key],
      );
    } on Exception {
      rethrow;
    } finally {
      await close();
    }

    return id;
  }

  @override
  Future<int> delete({required dynamic identifier}) async {
    late final int id;
    try {
      final Database db = await database;
      // Remove the Dog from the database.
      id = await db.delete(
        'settings',
        // Ensure that the model has a matching id.
        where: 'key = ?',
        // Pass the models id as a whereArg to prevent SQL injection.
        whereArgs: [identifier],
      );
    } on Exception {
      rethrow;
    } finally {
      await close();
    }

    return id;
  }

  Future<int> updateOrInsert(Setting model) async {
    int id = await update(model);
    if (id == 0) {
      id = await insert(model);
    }
    return id;
  }
}
