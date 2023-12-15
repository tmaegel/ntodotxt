import 'package:ntodotxt/data/filter/filter_controller.dart'
    show FilterController;
import 'package:ntodotxt/domain/filter/filter_model.dart' show Filter;

class FilterRepository {
  final FilterController controller;

  FilterRepository(this.controller);

  Future<List<Filter>> list() async => await controller.list();

  Future<Filter?> get({required int id}) async =>
      await controller.get(identifier: id);

  Future<int> insert(Filter model) async => await controller.insert(model);

  Future<int> update(Filter model) async => await controller.update(model);

  Future<int> delete({required int id}) async =>
      await controller.delete(identifier: id);
}
