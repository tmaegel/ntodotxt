import 'package:ntodotxt/filter/controller/filter_controller.dart'
    show FilterController;
import 'package:ntodotxt/filter/model/filter_model.dart' show Filter;
import 'package:rxdart/rxdart.dart';

class FilterRepository {
  final FilterController controller;
  final BehaviorSubject<List<Filter>> _streamController =
      BehaviorSubject<List<Filter>>.seeded(const []);

  FilterRepository(this.controller);

  Stream<List<Filter>> get stream => _streamController.asBroadcastStream();

  Future<void> refresh() async {
    _streamController.sink.add(await controller.list());
  }

  void dispose() {
    _streamController.close();
  }

  Future<List<Filter>> list() async => await controller.list();

  Future<Filter?> get({required int id}) async => await controller.get(id);

  Future<int> insert(Filter model) async {
    final int result = await controller.insert(model);
    await refresh();
    return result;
  }

  Future<int> update(Filter model) async {
    final int result = await controller.update(model);
    await refresh();
    return result;
  }

  Future<int> delete({required int id}) async {
    final int result = await controller.delete(id);
    await refresh();
    return result;
  }
}
