// coverage:ignore-file

import 'package:ntodotxt/data/filter/filter_controller.dart'
    show FilterControllerInterface;
import 'package:ntodotxt/domain/filter/filter_model.dart' show Filter;

class FakeFilterController implements FilterControllerInterface {
  static final List<Filter> filters = [];

  FakeFilterController();

  @override
  Future<List<Filter>> list() async => filters;

  @override
  Future<Filter?> get({required dynamic identifier}) async {
    for (Filter s in filters) {
      if (s.id == identifier) {
        return s;
      }
    }
    return null;
  }

  @override
  Future<int> insert(Filter model) async {
    filters.add(model);
    return filters.length;
  }

  @override
  Future<int> update(Filter model) async {
    int index = filters.indexWhere((Filter s) => s.id == model.id);
    if (index != -1) {
      filters[index] = model;
      return index;
    } else {
      return 0;
    }
  }

  @override
  Future<int> delete({required dynamic identifier}) async {
    int index = filters.indexWhere((Filter s) => s.id == identifier);
    if (index != -1) {
      filters.removeAt(index);
      return index;
    } else {
      return 0;
    }
  }
}
