import 'package:ntodotxt/data/database.dart';
import 'package:ntodotxt/domain/settings/setting_model.dart' show Setting;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

abstract class SettingControllerInterface
    implements ModelControllerInterface<Setting> {
  Future<Setting> getOrInsert(
      {required dynamic identifier, required String defaultValue});

  Future<int> updateOrInsert(Setting model);
}

class SettingController implements SettingControllerInterface {
  final DatabaseController controller;

  SettingController(this.controller);

  @override
  Future<List<Setting>> list() async {
    final Database db = await controller.database;
    final List<Map<String, dynamic>> maps = await db.query('settings');

    return List.generate(maps.length, (i) {
      return Setting.fromMap(maps[i]);
    });
  }

  @override
  Future<Setting?> get(dynamic identifier) async {
    Setting? model;
    final Database db = await controller.database;
    final List<Map> maps = await db.query(
      'settings',
      columns: ['key', 'value'],
      where: 'key = ?',
      whereArgs: [identifier as String],
    );

    if (maps.isNotEmpty) {
      model = Setting.fromMap(maps.first);
    }

    return model;
  }

  @override
  Future<int> insert(Setting model) async {
    final Database db = await controller.database;
    final int id = await db.insert(
      'settings',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );

    return id;
  }

  @override
  Future<Setting> getOrInsert(
      {required dynamic identifier, required String defaultValue}) async {
    Setting? result = await get(identifier);
    if (result == null) {
      Setting fallback = Setting(key: identifier, value: defaultValue);
      await insert(fallback);
      return fallback;
    } else {
      return result;
    }
  }

  @override
  Future<int> update(Setting model) async {
    final Database db = await controller.database;
    final int id = await db.update(
      'settings',
      model.toMap(),
      // Ensure that the model has a matching id.
      where: 'key = ?',
      // Pass the models id as a whereArg to prevent SQL injection.
      whereArgs: [model.key],
    );

    return id;
  }

  @override
  Future<int> updateOrInsert(Setting model) async {
    int id = await update(model);
    if (id == 0) {
      id = await insert(model);
    }
    return id;
  }

  @override
  Future<int> delete(dynamic identifier) async {
    final Database db = await controller.database;
    final int id = await db.delete(
      'settings',
      // Ensure that the model has a matching id.
      where: 'key = ?',
      // Pass the models id as a whereArg to prevent SQL injection.
      whereArgs: [identifier],
    );

    return id;
  }
}
