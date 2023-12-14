import 'package:ntodotxt/data/settings/setting_controller.dart'
    show SettingController;
import 'package:ntodotxt/domain/settings/setting_model.dart' show Setting;

class SettingRepository {
  final SettingController controller;

  SettingRepository(this.controller);

  Future<List<Setting>> list() => controller.list();

  Future<int> insert(Setting model) => controller.insert(model);

  Future<int> update(Setting model) => controller.update(model);

  Future<int> delete(Setting model) => controller.delete(model);
}
