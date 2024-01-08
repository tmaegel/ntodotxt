import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/data/filter/filter_controller.dart';
import 'package:ntodotxt/domain/filter/filter_model.dart' show Filter;
import 'package:ntodotxt/domain/filter/filter_repository.dart';
import 'package:ntodotxt/presentation/filter/pages/filter_list_page.dart';
import 'package:ntodotxt/presentation/filter/states/filter_list_bloc.dart';
import 'package:ntodotxt/presentation/filter/states/filter_list_event.dart';

class FakeController extends Fake implements FilterController {
  List<Filter> items = [
    const Filter(id: 1, name: 'Filter 01'),
    const Filter(id: 2, name: 'Filter 02'),
    const Filter(id: 3, name: 'Filter 03'),
  ];

  @override
  Future<List<Filter>> list() async {
    return Future.value(items);
  }
}

class FilterListPageMaterialApp extends StatelessWidget {
  final FilterController controller;

  const FilterListPageMaterialApp({
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<FilterRepository>(
          create: (BuildContext context) => FilterRepository(controller),
        ),
      ],
      child: Builder(
        builder: (BuildContext context) {
          return MultiBlocProvider(
            providers: [
              BlocProvider<FilterListBloc>(
                create: (BuildContext context) {
                  return FilterListBloc(
                    repository: context.read<FilterRepository>(),
                  )
                    ..add(const FilterListSubscriped())
                    ..add(const FilterListSynchronizationRequested());
                },
              ),
            ],
            child: const MaterialApp(
              home: FilterListPage(),
            ),
          );
        },
      ),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('List', () {
    testWidgets('narrow view', (tester) async {
      // Increase size to ensure all elements in list are visible.
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(FilterListPageMaterialApp(
        controller: FakeController(),
      ));
      await tester.pump();

      expect(find.byType(FilterListTile), findsNWidgets(3));
      Iterable<FilterListTile> filterTiles =
          tester.widgetList<FilterListTile>(find.byType(FilterListTile));
      expect(filterTiles.elementAt(0).filter.name, 'Filter 01');
      expect(filterTiles.elementAt(1).filter.name, 'Filter 02');
      expect(filterTiles.elementAt(2).filter.name, 'Filter 03');

      // resets the screen to its original size after the test end
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });
    testWidgets('wide view', (tester) async {
      // Increase size to ensure all elements in list are visible.
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(FilterListPageMaterialApp(
        controller: FakeController(),
      ));
      await tester.pump();

      expect(find.byType(FilterListTile), findsNWidgets(3));
      Iterable<FilterListTile> filterTiles =
          tester.widgetList<FilterListTile>(find.byType(FilterListTile));
      expect(filterTiles.elementAt(0).filter.name, 'Filter 01');
      expect(filterTiles.elementAt(1).filter.name, 'Filter 02');
      expect(filterTiles.elementAt(2).filter.name, 'Filter 03');

      // resets the screen to its original size after the test end
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });
  });
}
