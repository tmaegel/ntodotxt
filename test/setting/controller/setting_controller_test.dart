import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/database/controller/database.dart';
import 'package:ntodotxt/setting/controller/setting_controller.dart'
    show SettingController;
import 'package:ntodotxt/setting/model/setting_model.dart' show Setting;
import 'package:ntodotxt/setting/repository/setting_repository.dart'
    show SettingRepository;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Init ffi loader if needed.
  sqfliteFfiInit();

  late DatabaseController controller;
  late SettingRepository repository;

  setUp(() async {
    controller = DatabaseController(inMemoryDatabasePath);
    repository = SettingRepository(SettingController(controller));
    await (await controller.database).delete('settings'); // Clear
  });

  group('list()', () {
    test('empty', () async {
      expect(await repository.list(), isEmpty);
    });
    test('filled', () async {
      Setting model = const Setting(
        key: 'key1',
        value: 'value1',
      );
      await (await controller.database).insert('settings', model.toMap());
      expect(await repository.list(), [model]);
    });
  });

  group('get()', () {
    test('empty', () async {
      expect(await repository.get(key: 'key1'), null);
    });
    test('filled', () async {
      Setting model = const Setting(
        key: 'key1',
        value: 'value1',
      );
      await (await controller.database).insert('settings', model.toMap());
      expect(await repository.get(key: 'key1'), model);
    });
  });

  group('insert()', () {
    test('empty', () async {
      Setting model = const Setting(
        key: 'key1',
        value: 'value1',
      );
      expect(await repository.insert(model) > 0, isTrue);
    });
    test('filled', () async {
      Setting model = const Setting(
        key: 'key1',
        value: 'value1',
      );
      await (await controller.database).insert('settings', model.toMap());
      expect(await repository.insert(model), 0);
    });
  });

  group('update()', () {
    test('empty', () async {
      Setting model = const Setting(
        key: 'key1',
        value: 'value1',
      );
      expect(await repository.update(model), 0);
    });
    test('filled', () async {
      Setting model1 = const Setting(
        key: 'key1',
        value: 'value1',
      );
      Setting model2 = model1.copyWith(value: 'value2');
      await (await controller.database).insert('settings', model1.toMap());
      expect(await repository.update(model2) > 0, isTrue);
    });
  });

  group('updateOrInsert()', () {
    test('empty', () async {
      Setting model = const Setting(
        key: 'key1',
        value: 'value1',
      );
      expect(await repository.updateOrInsert(model) > 0, isTrue);
    });
    test('filled', () async {
      Setting model1 = const Setting(
        key: 'key1',
        value: 'value1',
      );
      Setting model2 = model1.copyWith(value: 'value2');
      await (await controller.database).insert('settings', model1.toMap());
      expect(await repository.updateOrInsert(model2) > 0, isTrue);
    });
  });

  group('delete()', () {
    test('empty', () async {
      Setting model = const Setting(
        key: 'key1',
        value: 'value1',
      );
      expect(await repository.delete(key: model.key), 0);
    });
    test('filled', () async {
      Setting model = const Setting(
        key: 'key1',
        value: 'value1',
      );
      await (await controller.database).insert('settings', model.toMap());
      expect(await repository.delete(key: model.key) > 0, isTrue);
    });
  });
}
