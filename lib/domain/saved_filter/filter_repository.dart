import 'package:ntodotxt/domain/saved_filter/filter_model.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart' show Priorities;
import 'package:ntodotxt/main.dart' show log;
import 'package:ntodotxt/presentation/todo/states/todo_list_state.dart'
    show TodoGroupBy, TodoOrder;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class FilterRepository {
  final FilterController controller;

  FilterRepository(this.controller);

  Future<List<Filter>> list() => controller.list();

  Future<int> insert(Filter model) => controller.insert(model);

  Future<int> update(Filter model) => controller.update(model);

  Future<int> delete(Filter model) => controller.delete(model);
}

class DataBaseController {
  static Database? _database;

  static Future<Database> instance(String path) async {
    if (_database != null) {
      return _database!;
    } else {
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      _database = await _open(path);
      return _database!;
    }
  }

  static Future close() async {
    if (_database != null) {
      return _database!.close();
    }
  }

  static Future<Database> _open(String path) async {
    // Change the default factory. On iOS/Android, if not using `sqlite_flutter_lib`
    // you can forget this step, it will use the sqlite version available on the system.
    databaseFactoryOrNull = databaseFactoryFfi;
    return openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) {
        log.info('Create database $path');
        return db.execute(Filter.tableRepr);
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) {
        if (newVersion > oldVersion) {
          log.info('Database upgrade is needed');
        }
      },
      onOpen: (Database db) {
        log.info('Open database $path');
      },
      singleInstance: true,
    );
  }
}

class FilterController extends DataBaseController {
  final String dbPath;

  FilterController(this.dbPath);

  Future<Database> get database async =>
      await DataBaseController.instance(dbPath);

  Future<List<Filter>> list() async {
    final Database db = await database;

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('saved_filters');

    return List.generate(maps.length, (i) {
      return Filter(
        id: maps[i]['id'] as int,
        name: maps[i]['name'] as String,
        priorities: {
          for (var p in maps[i]['priorities'].split(',')..sort())
            if (p != null && p.isNotEmpty) Priorities.byName(p)
        },
        projects: {
          for (var p in maps[i]['projects'].split(',')..sort())
            if (p != null && p.isNotEmpty) p,
        },
        contexts: {
          for (var c in maps[i]['contexts'].split(',')..sort())
            if (c != null && c.isNotEmpty) c,
        },
        order: TodoOrder.byName(maps[i]['order']),
        groupBy: TodoGroupBy.byName(maps[i]['groupBy']),
      );
    });
  }

  Future<int> insert(Filter model) async {
    final Database db = await database;

    Map<String, dynamic> modelMap = model.toMap();
    modelMap['id'] = null; // Ignore id in insert mode.
    return await db.insert(
      'saved_filters',
      modelMap,
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<int> update(Filter model) async {
    final Database db = await database;

    return await db.update(
      'saved_filters',
      model.toMap(),
      // Ensure that the model has a matching id.
      where: 'id = ?',
      // Pass the models id as a whereArg to prevent SQL injection.
      whereArgs: [model.id],
    );
  }

  Future<int> delete(Filter model) async {
    final Database db = await database;

    // Remove the Dog from the database.
    return await db.delete(
      'saved_filters',
      // Ensure that the model has a matching id.
      where: 'id = ?',
      // Pass the models id as a whereArg to prevent SQL injection.
      whereArgs: [model.id],
    );
  }
}
