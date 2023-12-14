import 'package:ntodotxt/domain/filter/filter_model.dart' show Filter;
import 'package:ntodotxt/domain/settings/setting_model.dart' show Setting;
import 'package:ntodotxt/main.dart' show log;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseController {
  static Database? _database;
  final String path;

  DatabaseController(this.path);

  Future<Database> get instance async {
    if (_database != null) {
      return _database!;
    } else {
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      _database = await _open();
      return _database!;
    }
  }

  Future<void> close() async {
    log.info('Close database $path');
    if (_database != null) {
      _database!.close();
    }
    _database = null;
  }

  Future<Database> _open() async {
    // Change the default factory. On iOS/Android, if not using `sqlite_flutter_lib`
    // you can forget this step, it will use the sqlite version available on the system.
    databaseFactoryOrNull = databaseFactoryFfi;
    return openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) {
        log.info('Create database $path');
        db.execute(Setting.tableRepr);
        db.execute(Filter.tableRepr);
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) {
        if (newVersion > oldVersion) {
          log.info('Perform database upgrade');
        }
      },
      onOpen: (Database db) {
        log.info('Open database $path');
      },
      singleInstance: true,
    );
  }
}

abstract class ModelController<T> extends DatabaseController {
  ModelController(super.path);

  Future<Database> get database async => await instance;

  Future<List<T>> list();

  Future<int> insert(T model);

  Future<int> update(T model);

  Future<int> delete(T model);
}
