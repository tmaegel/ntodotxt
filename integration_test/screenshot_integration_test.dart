import 'dart:io';

import 'package:file/memory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/data/filter/filter_controller.dart'
    show FilterController;
import 'package:ntodotxt/domain/filter/filter_model.dart'
    show Filter, ListFilter, ListGroup, ListOrder;
import 'package:ntodotxt/domain/todo/todo_model.dart' show Priority, Todo;
import 'package:ntodotxt/main.dart';
import 'package:ntodotxt/presentation/login/states/login_state.dart'
    show LoginOffline;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:integration_test/integration_test.dart';

class AppTester extends StatelessWidget {
  final String databasePath;
  final File todoFile;
  final ThemeMode? themeMode;

  const AppTester({
    required this.todoFile,
    required this.databasePath,
    this.themeMode,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return App(
      filter: const Filter(),
      loginState: const LoginOffline(),
      databasePath: databasePath,
      todoFile: todoFile,
      themeMode: themeMode,
    );
  }
}

void main() async {
  final IntegrationTestWidgetsFlutterBinding binding =
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final DateTime today = DateTime.now();

  const String databasePath = inMemoryDatabasePath;
  final FilterController controller = FilterController(databasePath);

  final MemoryFileSystem fs = MemoryFileSystem();
  final File todoFile = fs.file('todo.txt');
  final List<Todo> todoList = [
    Todo(
      creationDate: today.subtract(const Duration(days: 7)),
      priority: Priority.A,
      description: 'Automate the generation of app screenshots',
      projects: const {'app', 'learnflutter'},
      contexts: const {'development', 'automation', 'productivity'},
      keyValues: {'due': Todo.date2Str(today.add(const Duration(days: 3)))!},
    ),
    Todo(
      creationDate: today.subtract(const Duration(days: 14)),
      priority: Priority.B,
      description: 'Puplish this app',
      projects: const {'app', 'learnflutter'},
      contexts: const {'development'},
      keyValues: {'due': Todo.date2Str(today.add(const Duration(days: 7)))!},
    ),
    Todo(
      creationDate: today.subtract(const Duration(days: 2)),
      description: 'Increase test coverage',
      projects: const {'app', 'learnflutter'},
      contexts: const {'development', 'testing', 'productivity'},
    ),
    Todo(
      creationDate: today.subtract(const Duration(days: 2)),
      completion: true,
      completionDate: today.subtract(const Duration(days: 1)),
      description: 'Write some tests',
      projects: const {'app', 'learnflutter'},
      contexts: const {'development', 'testing', 'productivity'},
    ),
    Todo(
      creationDate: today.subtract(const Duration(days: 21)),
      priority: Priority.C,
      description: 'Setup a good project management tool',
      contexts: const {'development', 'productivity'},
    ),
  ];

  setUp(() async {
    // Setup todos.
    await todoFile.create();
    await todoFile.writeAsString(
      todoList.join(Platform.lineTerminator),
      flush: true,
    );
    // Setup filters.
    await (await controller.database).delete('filters'); // Clear
    await controller.insert(
      const Filter(
        id: 1,
        name: 'Agenda',
        order: ListOrder.ascending,
        filter: ListFilter.incompletedOnly,
        group: ListGroup.upcoming,
      ),
    );
    await controller.insert(
      const Filter(
        id: 2,
        name: 'Highly prioritized',
        order: ListOrder.ascending,
        filter: ListFilter.incompletedOnly,
        group: ListGroup.project,
        priorities: {Priority.A},
      ),
    );
    await controller.insert(
      const Filter(
        id: 3,
        name: 'Projectideas',
        order: ListOrder.ascending,
        filter: ListFilter.completedOnly,
        group: ListGroup.none,
        projects: {'projectideas'},
      ),
    );
    await controller.insert(
      const Filter(
        id: 4,
        name: 'Completed only',
        order: ListOrder.ascending,
        filter: ListFilter.completedOnly,
        group: ListGroup.none,
      ),
    );
  });

  group('dark mode', () {
    group('take screenshots', () {
      testWidgets('of todo list (default)', (tester) async {
        await tester.pumpWidget(
          AppTester(
            todoFile: todoFile,
            databasePath: databasePath,
            themeMode: ThemeMode.dark,
          ),
        );
        await tester.pumpAndSettle();

        await binding.convertFlutterSurfaceToImage();
        await tester.pumpAndSettle();
        await binding.takeScreenshot('phone/1');
      });
      testWidgets('of todo list (with open drawer)', (tester) async {
        await tester.pumpWidget(
          AppTester(
            todoFile: todoFile,
            databasePath: databasePath,
            themeMode: ThemeMode.dark,
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byTooltip('Open drawer'));
        await tester.pumpAndSettle();

        await tester.drag(
            find.byType(DraggableScrollableSheet), const Offset(0, -500));
        await tester.pumpAndSettle();

        await binding.convertFlutterSurfaceToImage();
        await tester.pumpAndSettle();
        await binding.takeScreenshot('phone/2');
      });
      testWidgets('of todo edit page', (tester) async {
        await tester.pumpWidget(
          AppTester(
            todoFile: todoFile,
            databasePath: databasePath,
            themeMode: ThemeMode.dark,
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Puplish this app'));
        await tester.pumpAndSettle();

        await binding.convertFlutterSurfaceToImage();
        await tester.pumpAndSettle();
        await binding.takeScreenshot('phone/3');
      });
      testWidgets('of filter list (default)', (tester) async {
        await tester.pumpWidget(
          AppTester(
            todoFile: todoFile,
            databasePath: databasePath,
            themeMode: ThemeMode.dark,
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byTooltip('Open drawer'));
        await tester.pumpAndSettle();

        await tester.drag(
            find.byType(DraggableScrollableSheet), const Offset(0, -500));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Filters'));
        await tester.pumpAndSettle();

        await binding.convertFlutterSurfaceToImage();
        await tester.pumpAndSettle();
        await binding.takeScreenshot('phone/4');
      });
      testWidgets('of filter edit page', (tester) async {
        await tester.pumpWidget(
          AppTester(
            todoFile: todoFile,
            databasePath: databasePath,
            themeMode: ThemeMode.dark,
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byTooltip('Open drawer'));
        await tester.pumpAndSettle();

        await tester.drag(
            find.byType(DraggableScrollableSheet), const Offset(0, -500));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Filters'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Projectideas'));
        await tester.pumpAndSettle();

        await binding.convertFlutterSurfaceToImage();
        await tester.pumpAndSettle();
        await binding.takeScreenshot('phone/5');
      });
    });
  });
}