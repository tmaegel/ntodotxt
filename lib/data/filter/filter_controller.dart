import 'package:ntodotxt/data/database.dart' show ModelController;
import 'package:ntodotxt/domain/filter/filter_model.dart'
    show Filter, Filters, Groups, Order;
import 'package:ntodotxt/domain/todo/todo_model.dart' show Priorities;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class FilterController extends ModelController<Filter> {
  FilterController(super.path);

  @override
  Future<List<Filter>> list() async {
    late final List<Map<String, dynamic>> maps;
    try {
      final Database db = await database;
      // Query the table for all The Dogs.
      maps = await db.query('filters');
    } on Exception {
      rethrow;
    } finally {
      close();
    }

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
        order: Order.byName(maps[i]['order']),
        filter: Filters.byName(maps[i]['filter']),
        group: Groups.byName(maps[i]['group']),
      );
    });
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
      rethrow;
    } finally {
      close();
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
      rethrow;
    } finally {
      close();
    }

    return id;
  }

  @override
  Future<int> delete(Filter model) async {
    late final int id;
    try {
      final Database db = await database;
      // Remove the Dog from the database.
      id = await db.delete(
        'filters',
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
