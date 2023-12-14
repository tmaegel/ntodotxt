import 'package:ntodotxt/data/filter/filter_controller.dart'
    show FilterController;
import 'package:ntodotxt/domain/filter/filter_model.dart' show Filter;

class FilterRepository {
  final FilterController controller;

  FilterRepository(this.controller);

  Future<List<Filter>> list() => controller.list();

  Future<int> insert(Filter model) => controller.insert(model);

  Future<int> update(Filter model) => controller.update(model);

  Future<int> delete(Filter model) => controller.delete(model);
}
