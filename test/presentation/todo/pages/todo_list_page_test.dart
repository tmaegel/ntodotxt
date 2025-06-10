import 'dart:io';

import 'package:file/memory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/data/database.dart';
import 'package:ntodotxt/data/filter/filter_controller.dart';
import 'package:ntodotxt/data/settings/setting_controller.dart'
    show SettingController;
import 'package:ntodotxt/data/todo/todo_list_api.dart';
import 'package:ntodotxt/domain/filter/filter_model.dart'
    show Filter, ListFilter, ListGroup, ListOrder;
import 'package:ntodotxt/domain/filter/filter_repository.dart';
import 'package:ntodotxt/domain/settings/setting_repository.dart'
    show SettingRepository;
import 'package:ntodotxt/domain/todo/todo_list_repository.dart';
import 'package:ntodotxt/presentation/filter/states/filter_cubit.dart';
import 'package:ntodotxt/presentation/filter/states/filter_list_bloc.dart';
import 'package:ntodotxt/presentation/filter/states/filter_list_event.dart';
import 'package:ntodotxt/presentation/todo/pages/todo_list_page.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_bloc.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_event.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class TodoListPageMaterialApp extends StatelessWidget {
  final DatabaseController dbController =
      const DatabaseController(inMemoryDatabasePath);
  final File localFile;
  final Filter? filter;

  const TodoListPageMaterialApp({
    required this.localFile,
    this.filter,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SettingRepository>(
          create: (BuildContext context) =>
              SettingRepository(SettingController(dbController)),
        ),
        RepositoryProvider<TodoListRepository>(
          create: (BuildContext context) {
            return TodoListRepository(
                LocalTodoListApi.fromFile(localFile: localFile));
          },
        ),
        RepositoryProvider<FilterRepository>(
          create: (BuildContext context) => FilterRepository(
            FilterController(dbController),
          ),
        ),
      ],
      child: Builder(
        builder: (BuildContext context) {
          return MultiBlocProvider(
            providers: [
              BlocProvider<FilterCubit>(
                create: (BuildContext context) => FilterCubit(
                  settingRepository: context.read<SettingRepository>(),
                  filterRepository: context.read<FilterRepository>(),
                  filter: filter ?? const Filter(),
                ),
              ),
              BlocProvider(
                create: (BuildContext context) => TodoListBloc(
                  repository: context.read<TodoListRepository>(),
                )
                  ..add(const TodoListSubscriptionRequested())
                  ..add(const TodoListSynchronizationRequested()),
              ),
              BlocProvider<FilterListBloc>(
                create: (BuildContext context) {
                  return FilterListBloc(
                    repository: context.read<FilterRepository>(),
                  )..add(const FilterListSubscriped());
                },
              ),
            ],
            child: MaterialApp(
              home: TodoListPage(filter: filter ?? const Filter()),
            ),
          );
        },
      ),
    );
  }
}

void main() {
  final MemoryFileSystem fs = MemoryFileSystem();
  late File file;

  setUp(() async {});

  group('Order', () {
    setUp(() async {
      file = fs.file('todoOrder.txt');
      await file.create();
      await file.writeAsString(
        [
          '2023-12-02 TODOC',
          '2023-12-02 todoA',
          '2023-12-02 TodoB',
        ].join('\n'),
        flush: true,
      );
    });
    testWidgets('default', (tester) async {
      final List<String> expectedTiles = [
        'todoA',
        'TodoB',
        'TODOC',
      ];
      await tester.pumpWidget(TodoListPageMaterialApp(
        localFile: file,
      ));
      await tester.pumpAndSettle();

      Iterable<TodoListTile> todoTiles =
          tester.widgetList<TodoListTile>(find.byType(TodoListTile));
      expect(todoTiles.length, expectedTiles.length);

      for (int i = 0; i < expectedTiles.length; i++) {
        Finder element = find.descendant(
          of: find.byWidget(todoTiles.elementAt(i)),
          matching: find.text(expectedTiles[i], findRichText: true),
        );
        await tester.ensureVisible(element);
        expect(element, findsOneWidget);
      }
    });
    testWidgets('ascending', (tester) async {
      final List<String> expectedTiles = [
        'todoA',
        'TodoB',
        'TODOC',
      ];
      await tester.pumpWidget(TodoListPageMaterialApp(
        localFile: file,
        filter: const Filter(
          order: ListOrder.ascending,
          filter: ListFilter.all,
          group: ListGroup.none,
        ),
      ));
      await tester.pumpAndSettle();

      Iterable<TodoListTile> todoTiles =
          tester.widgetList<TodoListTile>(find.byType(TodoListTile));
      expect(todoTiles.length, expectedTiles.length);

      for (int i = 0; i < expectedTiles.length; i++) {
        Finder element = find.descendant(
          of: find.byWidget(todoTiles.elementAt(i)),
          matching: find.text(expectedTiles[i], findRichText: true),
        );
        await tester.ensureVisible(element);
        expect(element, findsOneWidget);
      }
    });
    testWidgets('descending', (tester) async {
      final List<String> expectedTiles = [
        'TODOC',
        'TodoB',
        'todoA',
      ];
      await tester.pumpWidget(TodoListPageMaterialApp(
        localFile: file,
        filter: const Filter(
          order: ListOrder.descending,
          filter: ListFilter.all,
          group: ListGroup.none,
        ),
      ));
      await tester.pumpAndSettle();

      Iterable<TodoListTile> todoTiles =
          tester.widgetList<TodoListTile>(find.byType(TodoListTile));
      expect(todoTiles.length, expectedTiles.length);

      for (int i = 0; i < expectedTiles.length; i++) {
        Finder element = find.descendant(
          of: find.byWidget(todoTiles.elementAt(i)),
          matching: find.text(expectedTiles[i], findRichText: true),
        );
        await tester.ensureVisible(element);
        expect(element, findsOneWidget);
      }
    });
  });

  group('Filter', () {
    setUp(() async {
      file = fs.file('todoFilter.txt');
      await file.create();
      await file.writeAsString(
        [
          'x 2023-12-04 2023-12-02 TodoC',
          '2023-12-02 TodoA',
          'x 2023-12-03 2023-12-02 TodoB',
        ].join('\n'),
        flush: true,
      );
    });
    testWidgets('all', (tester) async {
      final List<String> expectedTiles = [
        'TodoA',
        'TodoB',
        'TodoC',
      ];
      await tester.pumpWidget(TodoListPageMaterialApp(
        localFile: file,
        filter: const Filter(
          order: ListOrder.ascending,
          filter: ListFilter.all,
          group: ListGroup.none,
        ),
      ));
      await tester.pumpAndSettle();

      Iterable<TodoListTile> todoTiles =
          tester.widgetList<TodoListTile>(find.byType(TodoListTile));
      expect(todoTiles.length, expectedTiles.length);

      for (int i = 0; i < expectedTiles.length; i++) {
        Finder element = find.descendant(
          of: find.byWidget(todoTiles.elementAt(i)),
          matching: find.text(expectedTiles[i], findRichText: true),
        );
        await tester.ensureVisible(element);
        expect(element, findsOneWidget);
      }
    });
    testWidgets('completed only', (tester) async {
      final List<String> expectedTiles = [
        'TodoB',
        'TodoC',
      ];
      await tester.pumpWidget(TodoListPageMaterialApp(
        localFile: file,
        filter: const Filter(
          order: ListOrder.ascending,
          filter: ListFilter.completedOnly,
          group: ListGroup.none,
        ),
      ));
      await tester.pumpAndSettle();

      Iterable<TodoListTile> todoTiles =
          tester.widgetList<TodoListTile>(find.byType(TodoListTile));
      expect(todoTiles.length, expectedTiles.length);

      for (int i = 0; i < expectedTiles.length; i++) {
        Finder element = find.descendant(
          of: find.byWidget(todoTiles.elementAt(i)),
          matching: find.text(expectedTiles[i], findRichText: true),
        );
        await tester.ensureVisible(element);
        expect(element, findsOneWidget);
      }
    });
    testWidgets('incompleted only', (tester) async {
      final List<String> expectedTiles = [
        'TodoA',
      ];
      await tester.pumpWidget(TodoListPageMaterialApp(
        localFile: file,
        filter: const Filter(
          order: ListOrder.ascending,
          filter: ListFilter.incompletedOnly,
          group: ListGroup.none,
        ),
      ));
      await tester.pumpAndSettle();

      Iterable<TodoListTile> todoTiles =
          tester.widgetList<TodoListTile>(find.byType(TodoListTile));
      expect(todoTiles.length, expectedTiles.length);

      for (int i = 0; i < expectedTiles.length; i++) {
        Finder element = find.descendant(
          of: find.byWidget(todoTiles.elementAt(i)),
          matching: find.text(expectedTiles[i], findRichText: true),
        );
        await tester.ensureVisible(element);
        expect(element, findsOneWidget);
      }
    });
  });

  group('Group by', () {
    group('none', () {
      setUp(() async {
        file = fs.file('todoGroupByNone.txt');
        await file.create();
        await file.writeAsString(
          [
            'x 2023-13-04 2023-12-02 TodoB',
            '2023-12-02 TodoC',
            '(B) 2023-12-02 TodoA',
          ].join('\n'),
          flush: true,
        );
      });
      testWidgets('ascending', (tester) async {
        final List<String> expectedTiles = [
          'All',
          'TodoA',
          'TodoC',
          'TodoB', // Completed todo come always at last.
        ];
        await tester.pumpWidget(TodoListPageMaterialApp(
          localFile: file,
          filter: const Filter(
            order: ListOrder.ascending,
            filter: ListFilter.all,
            group: ListGroup.none,
          ),
        ));
        await tester.pumpAndSettle();

        Iterable<ListTile> listTiles =
            tester.widgetList<ListTile>(find.byType(ListTile));
        expect(listTiles.length, expectedTiles.length);

        for (int i = 0; i < expectedTiles.length; i++) {
          Finder element = find.descendant(
            of: find.byWidget(listTiles.elementAt(i)),
            matching: find.text(expectedTiles[i], findRichText: true),
          );
          await tester.ensureVisible(element);
          expect(element, findsOneWidget);
        }
      });
      testWidgets('descending', (tester) async {
        final List<String> expectedTiles = [
          'All',
          'TodoC',
          'TodoA',
          'TodoB', // Completed todo come always at last.
        ];
        await tester.pumpWidget(TodoListPageMaterialApp(
          localFile: file,
          filter: const Filter(
            order: ListOrder.descending,
            filter: ListFilter.all,
            group: ListGroup.none,
          ),
        ));
        await tester.pumpAndSettle();

        Iterable<ListTile> listTiles =
            tester.widgetList<ListTile>(find.byType(ListTile));
        expect(listTiles.length, expectedTiles.length);

        for (int i = 0; i < expectedTiles.length; i++) {
          Finder element = find.descendant(
            of: find.byWidget(listTiles.elementAt(i)),
            matching: find.text(expectedTiles[i], findRichText: true),
          );
          await tester.ensureVisible(element);
          expect(element, findsOneWidget);
        }
      });
    });
    group('upcoming', () {
      setUp(() async {
        final DateTime now = DateTime.now();
        final String today =
            '${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
        final String tomorrow =
            '${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${(now.day + 1).toString().padLeft(2, '0')}';

        file = fs.file('todoGroupByUpcoming.txt');
        await file.create();
        await file.writeAsString(
          [
            '2023-12-02 TodoA1',
            'x 2023-12-04 2023-12-02 TodoB2 due:1970-01-01',
            '2023-12-02 TodoB1 due:1970-01-01',
            '2023-12-02 TodoC2 due:$today',
            '2023-12-02 TodoC1 due:$today',
            '2023-12-02 TodoD2 due:$tomorrow',
            '(B) 2023-12-02 TodoD1 due:$tomorrow',
            '2023-12-02 TodoA2',
          ].join('\n'),
          flush: true,
        );
      });
      testWidgets('ascending', (tester) async {
        // Increase size to ensure all elements in list are visible.
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 1.0;

        final List<String> expectedTiles = [
          'Deadline passed',
          'TodoB1',
          'TodoB2', // Completed todo come always at last.
          'Today',
          'TodoC1',
          'TodoC2',
          'Upcoming',
          'TodoD1',
          'TodoD2',
          'No deadline',
          'TodoA1',
          'TodoA2',
        ];
        await tester.pumpWidget(TodoListPageMaterialApp(
          localFile: file,
          filter: const Filter(
            order: ListOrder.ascending,
            filter: ListFilter.all,
            group: ListGroup.upcoming,
          ),
        ));
        await tester.pumpAndSettle();

        Iterable<ListTile> listTiles =
            tester.widgetList<ListTile>(find.byType(ListTile));
        expect(listTiles.length, expectedTiles.length);

        for (int i = 0; i < expectedTiles.length; i++) {
          Finder element = find.descendant(
            of: find.byWidget(listTiles.elementAt(i)),
            matching: find.text(expectedTiles[i], findRichText: true),
          );
          await tester.ensureVisible(element);
          expect(element, findsOneWidget);
        }

        // resets the screen to its original size after the test end
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
      });
      testWidgets('descending', (tester) async {
        // Increase size to ensure all elements in list are visible.
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 1.0;

        final List<String> expectedTiles = [
          'Deadline passed',
          'TodoB1',
          'TodoB2', // Completed todo come always at last.
          'Today',
          'TodoC2',
          'TodoC1',
          'Upcoming',
          'TodoD2',
          'TodoD1',
          'No deadline',
          'TodoA2',
          'TodoA1',
        ];
        await tester.pumpWidget(TodoListPageMaterialApp(
          localFile: file,
          filter: const Filter(
            order: ListOrder.descending,
            filter: ListFilter.all,
            group: ListGroup.upcoming,
          ),
        ));
        await tester.pumpAndSettle();

        Iterable<ListTile> listTiles =
            tester.widgetList<ListTile>(find.byType(ListTile));
        expect(listTiles.length, expectedTiles.length);

        for (int i = 0; i < expectedTiles.length; i++) {
          Finder element = find.descendant(
            of: find.byWidget(listTiles.elementAt(i)),
            matching: find.text(expectedTiles[i], findRichText: true),
          );
          await tester.ensureVisible(element);
          expect(element, findsOneWidget);
        }

        // resets the screen to its original size after the test end
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
      });
    });
    group('priority', () {
      setUp(() async {
        file = fs.file('todoGroupByPriority.txt');
        await file.create();
        await file.writeAsString(
          [
            '2023-12-02 TodoD',
            'x 2023-12-04 (B) 2023-12-02 TodoB2',
            '(B) 2023-12-02 TodoB1',
            'x 2023-12-04 (A) 2023-12-02 TodoA1',
            '(A) 2023-12-02 TodoA2',
            '2023-12-02 TodoC',
          ].join('\n'),
          flush: true,
        );
      });
      testWidgets('ascending', (tester) async {
        final List<String> expectedTiles = [
          'A',
          'TodoA2',
          'TodoA1', // Completed todo come always at last.
          'B',
          'TodoB1',
          'TodoB2', // Completed todo come always at last.
          'No priority',
          'TodoC',
          'TodoD',
        ];
        await tester.pumpWidget(TodoListPageMaterialApp(
          localFile: file,
          filter: const Filter(
            order: ListOrder.ascending,
            filter: ListFilter.all,
            group: ListGroup.priority,
          ),
        ));
        await tester.pumpAndSettle();

        Iterable<ListTile> listTiles =
            tester.widgetList<ListTile>(find.byType(ListTile));
        expect(listTiles.length, expectedTiles.length);

        for (int i = 0; i < expectedTiles.length; i++) {
          Finder element = find.descendant(
            of: find.byWidget(listTiles.elementAt(i)),
            matching: find.text(expectedTiles[i], findRichText: true),
          );
          await tester.ensureVisible(element);
          expect(element, findsOneWidget);
        }
      });
      testWidgets('descending', (tester) async {
        final List<String> expectedTiles = [
          'No priority',
          'TodoD',
          'TodoC',
          'B',
          'TodoB1',
          'TodoB2', // Completed todo come always at last.
          'A',
          'TodoA2',
          'TodoA1', // Completed todo come always at last.
        ];
        await tester.pumpWidget(TodoListPageMaterialApp(
          localFile: file,
          filter: const Filter(
            order: ListOrder.descending,
            filter: ListFilter.all,
            group: ListGroup.priority,
          ),
        ));
        await tester.pumpAndSettle();

        Iterable<ListTile> listTiles =
            tester.widgetList<ListTile>(find.byType(ListTile));
        expect(listTiles.length, expectedTiles.length);

        for (int i = 0; i < expectedTiles.length; i++) {
          Finder element = find.descendant(
            of: find.byWidget(listTiles.elementAt(i)),
            matching: find.text(expectedTiles[i], findRichText: true),
          );
          await tester.ensureVisible(element);
          expect(element, findsOneWidget);
        }
      });
    });
    group('project', () {
      setUp(() async {
        file = fs.file('todoGroupByProject.txt');
        await file.create();
        await file.writeAsString(
          [
            '2023-12-02 TodoD',
            '(B) 2023-12-02 TodoB2 +project2',
            '2023-12-02 TodoB1 +project1',
            'x 2023-13-04 2023-12-02 TodoA1 +project1',
            '2023-12-02 TodoA2 +project2',
            '2023-12-02 TodoC',
          ].join('\n'),
          flush: true,
        );
      });
      testWidgets('ascending', (tester) async {
        final List<String> expectedTiles = [
          'project1',
          'TodoB1 +project1',
          'TodoA1 +project1', // Completed todo come always at last.
          'project2',
          'TodoA2 +project2',
          'TodoB2 +project2',
          'No project',
          'TodoC',
          'TodoD',
        ];
        await tester.pumpWidget(TodoListPageMaterialApp(
          localFile: file,
          filter: const Filter(
            order: ListOrder.ascending,
            filter: ListFilter.all,
            group: ListGroup.project,
          ),
        ));
        await tester.pumpAndSettle();

        Iterable<ListTile> listTiles =
            tester.widgetList<ListTile>(find.byType(ListTile));
        expect(listTiles.length, expectedTiles.length);

        for (int i = 0; i < expectedTiles.length; i++) {
          Finder element = find.descendant(
            of: find.byWidget(listTiles.elementAt(i)),
            matching: find.text(expectedTiles[i], findRichText: true),
          );
          await tester.ensureVisible(element);
          expect(element, findsOneWidget);
        }
      });
      testWidgets('descending', (tester) async {
        final List<String> expectedTiles = [
          'project2',
          'TodoB2 +project2',
          'TodoA2 +project2',
          'project1',
          'TodoB1 +project1',
          'TodoA1 +project1', // Completed todo come always at last.
          'No project',
          'TodoD',
          'TodoC',
        ];
        await tester.pumpWidget(TodoListPageMaterialApp(
          localFile: file,
          filter: const Filter(
            order: ListOrder.descending,
            filter: ListFilter.all,
            group: ListGroup.project,
          ),
        ));
        await tester.pumpAndSettle();

        Iterable<ListTile> listTiles =
            tester.widgetList<ListTile>(find.byType(ListTile));
        expect(listTiles.length, expectedTiles.length);

        for (int i = 0; i < expectedTiles.length; i++) {
          Finder element = find.descendant(
            of: find.byWidget(listTiles.elementAt(i)),
            matching: find.text(expectedTiles[i], findRichText: true),
          );
          await tester.ensureVisible(element);
          expect(element, findsOneWidget);
        }
      });
    });
    group('context', () {
      setUp(() async {
        file = fs.file('todoGroupByContext.txt');
        await file.create();
        await file.writeAsString(
          [
            '2023-12-02 TodoD',
            '(B) 2023-12-02 TodoB2 @context2',
            '2023-12-02 TodoB1 @context1',
            'x 2023-12-04 2023-12-02 TodoA1 @context1',
            '2023-12-02 TodoA2 @context2',
            '2023-12-02 TodoC',
          ].join('\n'),
          flush: true,
        );
      });
      testWidgets('ascending', (tester) async {
        final List<String> expectedTiles = [
          'context1',
          'TodoB1 @context1',
          'TodoA1 @context1', // Completed todo come always at last.
          'context2',
          'TodoA2 @context2',
          'TodoB2 @context2',
          'No context',
          'TodoC',
          'TodoD',
        ];
        await tester.pumpWidget(TodoListPageMaterialApp(
          localFile: file,
          filter: const Filter(
            order: ListOrder.ascending,
            filter: ListFilter.all,
            group: ListGroup.context,
          ),
        ));
        await tester.pumpAndSettle();

        Iterable<ListTile> listTiles =
            tester.widgetList<ListTile>(find.byType(ListTile));
        expect(listTiles.length, expectedTiles.length);

        for (int i = 0; i < expectedTiles.length; i++) {
          Finder element = find.descendant(
            of: find.byWidget(listTiles.elementAt(i)),
            matching: find.text(expectedTiles[i], findRichText: true),
          );
          await tester.ensureVisible(element);
          expect(element, findsOneWidget);
        }
      });
      testWidgets('descending', (tester) async {
        final List<String> expectedTiles = [
          'context2',
          'TodoB2 @context2',
          'TodoA2 @context2',
          'context1',
          'TodoB1 @context1',
          'TodoA1 @context1', // Completed todo come always at last.
          'No context',
          'TodoD',
          'TodoC',
        ];
        await tester.pumpWidget(TodoListPageMaterialApp(
          localFile: file,
          filter: const Filter(
            order: ListOrder.descending,
            filter: ListFilter.all,
            group: ListGroup.context,
          ),
        ));
        await tester.pumpAndSettle();

        Iterable<ListTile> listTiles =
            tester.widgetList<ListTile>(find.byType(ListTile));
        expect(listTiles.length, expectedTiles.length);

        for (int i = 0; i < expectedTiles.length; i++) {
          Finder element = find.descendant(
            of: find.byWidget(listTiles.elementAt(i)),
            matching: find.text(expectedTiles[i], findRichText: true),
          );
          await tester.ensureVisible(element);
          expect(element, findsOneWidget);
        }
      });
    });
  });
}
