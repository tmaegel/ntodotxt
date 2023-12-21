import 'package:ntodotxt/data/database.dart' show ModelController;
import 'package:ntodotxt/domain/filter/filter_model.dart' show Filter;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class FilterController extends ModelController<Filter> {
  FilterController(super.path);

  @override
  Future<List<Filter>> list() async {
    late final List<Map<String, dynamic>> maps;
    try {
      final Database db = await database;
      maps = await db.query('filters');
    } on Exception {
      rethrow;
    } finally {
      await close();
    }

    return List.generate(maps.length, (i) {
      return Filter.fromMap(maps[i]);
    });
  }

  @override
  Future<Filter?> get({required dynamic identifier}) async {
    Filter? model;
    try {
      final Database db = await database;
      List<Map> maps = await db.query(
        'filters',
        columns: [
          'id',
          'name',
          'priorities',
          'projects',
          'contexts',
          'order',
          'filter',
          'group',
        ],
        where: 'id = ?',
        whereArgs: [identifier as int],
      );
      if (maps.isNotEmpty) {
        model = Filter.fromMap(maps.first);
      }
    } on Exception {
      rethrow;
    } finally {
      await close();
    }

    return model;
  }

  @override
  Future<int> insert(Filter model) async {
    late final int id;
    try {
      final Database db = await database;
      Map<String, dynamic> modelMap = model.toMap();
      modelMap['id'] = null; // Ignore id in insert mode.
      id = await db.insert(
        'filters',
        modelMap,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    } on Exception {
      await close();
      rethrow;
    } finally {
      // Database will be closed in repository layer after refreshing the stream.
    }

    return id;
  }

  @override
  Future<int> update(Filter model) async {
    late final int id;
    try {
      final Database db = await database;
      id = await db.update(
        'filters',
        model.toMap(),
        // Ensure that the model has a matching id.
        where: 'id = ?',
        // Pass the models id as a whereArg to prevent SQL injection.
        whereArgs: [model.id],
      );
    } on Exception {
      await close();
      rethrow;
    } finally {
      // Database will be closed in repository layer after refreshing the stream.
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
        'filters',
        // Ensure that the model has a matching id.
        where: 'id = ?',
        // Pass the models id as a whereArg to prevent SQL injection.
        whereArgs: [identifier],
      );
    } on Exception {
      await close();
      rethrow;
    } finally {
      // Database will be closed in repository layer after refreshing the stream.
    }

    return id;
  }
}
