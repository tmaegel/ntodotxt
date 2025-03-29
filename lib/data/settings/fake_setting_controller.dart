// coverage:ignore-file

import 'package:ntodotxt/data/settings/setting_controller.dart'
    show SettingControllerInterface;
import 'package:ntodotxt/domain/settings/setting_model.dart' show Setting;

class FakeSettingController implements SettingControllerInterface {
  static final List<Setting> settings = [];

  FakeSettingController();

  @override
  Future<List<Setting>> list() async => settings;

  @override
  Future<Setting?> get({required dynamic identifier}) async {
    for (Setting s in settings) {
      if (s.key == identifier) {
        return s;
      }
    }
    return null;
  }

  @override
  Future<int> insert(Setting model) async {
    settings.add(model);
    return settings.length;
  }

  @override
  Future<Setting> getOrInsert(
      {required dynamic identifier, required String defaultValue}) async {
    Setting? result = await get(identifier: identifier);
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
    int index = settings.indexWhere((Setting s) => s.key == model.key);
    if (index != -1) {
      settings[index] = model;
      return index;
    } else {
      return 0;
    }
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
  Future<int> delete({required dynamic identifier}) async {
    int index = settings.indexWhere((Setting s) => s.key == identifier);
    if (index != -1) {
      settings.removeAt(index);
      return index;
    } else {
      return 0;
    }
  }
}
