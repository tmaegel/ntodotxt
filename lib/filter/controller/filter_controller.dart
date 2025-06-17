import 'package:ntodotxt/database/controller/database.dart';
import 'package:ntodotxt/filter/model/filter_model.dart' show Filter;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

abstract class FilterControllerInterface
    implements ModelControllerInterface<Filter> {}

class FilterController implements FilterControllerInterface {
  final DatabaseController controller;

  FilterController(this.controller);

  @override
  Future<List<Filter>> list() async {
    final Database db = await controller.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'filters',
      orderBy: 'name',
    );

    return List.generate(maps.length, (i) {
      return Filter.fromMap(maps[i]);
    });
  }

  @override
  Future<Filter?> get(dynamic identifier) async {
    Filter? model;
    final Database db = await controller.database;
    final List<Map> maps = await db.query(
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

    return model;
  }

  @override
  Future<int> insert(Filter model) async {
    final Database db = await controller.database;
    Map<String, dynamic> modelMap = model.toMap();
    modelMap['id'] = null; // Ignore id in insert mode.
    final int id = await db.insert(
      'filters',
      modelMap,
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );

    return id;
  }

  @override
  Future<int> update(Filter model) async {
    final Database db = await controller.database;
    // @todo
    // if (model.id == null) {
    //   throw SqfliteDatabaseException('Missing id attribute in Filter model');
    // }
    final int id = await db.update(
      'filters',
      model.toMap(),
      // Ensure that the model has a matching id.
      where: 'id = ?',
      // Pass the models id as a whereArg to prevent SQL injection.
      whereArgs: [model.id],
    );

    return id;
  }

  @override
  Future<int> delete(dynamic identifier) async {
    final Database db = await controller.database;
    final int id = await db.delete(
      'filters',
      // Ensure that the model has a matching id.
      where: 'id = ?',
      // Pass the models id as a whereArg to prevent SQL injection.
      whereArgs: [identifier],
    );

    return id;
  }
}
