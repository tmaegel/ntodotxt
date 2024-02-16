import 'package:ntodotxt/data/settings/setting_controller.dart'
    show SettingController;
import 'package:ntodotxt/domain/settings/setting_model.dart' show Setting;

class SettingRepository {
  final SettingController controller;

  SettingRepository(this.controller);

  Future<List<Setting>> list() async => await controller.list();

  Future<Setting?> get({required String key}) async =>
      await controller.get(identifier: key);

  Future<Setting> getOrInsert(
          {required String key, required String defaultValue}) async =>
      await controller.getOrInsert(identifier: key, defaultValue: defaultValue);

  Future<int> insert(Setting model) async => await controller.insert(model);

  Future<int> update(Setting model) async => await controller.update(model);

  Future<int> delete({required String key}) async =>
      await controller.delete(identifier: key);

  Future<int> updateOrInsert(Setting model) async =>
      await controller.updateOrInsert(model);
}
