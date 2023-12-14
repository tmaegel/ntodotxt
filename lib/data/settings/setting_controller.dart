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
      close();
    }

    return List.generate(maps.length, (i) {
      return Setting(
        id: maps[i]['id'] as int,
        key: maps[i]['key'] as String,
        value: maps[i]['value'] as String,
      );
    });
  }

  @override
  Future<int> insert(Setting model) async {
    late final int id;
    try {
      final Database db = await database;
      Map<String, dynamic> modelMap = model.toMap();
      modelMap['id'] = null; // Ignore id in insert mode.
      id = await db.insert(
        'settings',
        modelMap,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    } on Exception {
      rethrow;
    } finally {
      close();
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
        where: 'id = ?',
        // Pass the models id as a whereArg to prevent SQL injection.
        whereArgs: [model.id],
      );
    } on Exception {
      rethrow;
    } finally {
      close();
    }

    return id;
  }

  @override
  Future<int> delete(Setting model) async {
    late final int id;
    try {
      final Database db = await database;
      // Remove the Dog from the database.
      id = await db.delete(
        'settings',
        // Ensure that the model has a matching id.
        where: 'id = ?',
        // Pass the models id as a whereArg to prevent SQL injection.
        whereArgs: [model.id],
      );
    } on Exception {
      rethrow;
    } finally {
      close();
    }

    return id;
  }
}
