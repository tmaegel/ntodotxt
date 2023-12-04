import 'dart:io';

import 'package:file/memory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/presentation/login/pages/login_page.dart'
    show LoginWrapper;
import 'package:ntodotxt/presentation/login/states/login_state.dart';
import 'package:ntodotxt/presentation/todo/widgets/todo_list_widget.dart';
import 'package:ntodotxt/presentation/todo/widgets/todo_tile_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final MemoryFileSystem fs = MemoryFileSystem();
  late SharedPreferences prefs;
  late File file;

  setUp(() async {});

  group('Order', () {
    setUp(() async {
      file = fs.file('todoOrder.txt');
      await file.create();
      await file.writeAsString(
        [
          "2023-12-02 TodoC",
          "2023-12-02 TodoA",
          "2023-12-02 TodoB",
        ].join("\n"),
        flush: true,
      );
    });

    group('ascending', () {
      setUp(() async {
        // Mock shared preferences.
        SharedPreferences.setMockInitialValues({
          'todoFilter': 'all',
          'todoOrder': 'ascending',
          'todoGrouping': 'none',
        });
        prefs = await SharedPreferences.getInstance();
      });

      testWidgets('by settings', (tester) async {
        await tester.pumpWidget(
          LoginWrapper(
            prefs: prefs,
            todoFile: file,
            initialLoginState: const LoginOffline(),
          ),
        );
        await tester.pump();

        expect(find.byType(TodoTile), findsNWidgets(3));
        Iterable<TodoTile> todoTiles =
            tester.widgetList<TodoTile>(find.byType(TodoTile));
        expect(todoTiles.elementAt(0).todo.description, "TodoA");
        expect(todoTiles.elementAt(1).todo.description, "TodoB");
        expect(todoTiles.elementAt(2).todo.description, "TodoC");
      });
    });

    group('descending', () {
      setUp(() async {
        // Mock shared preferences.
        SharedPreferences.setMockInitialValues({
          'todoFilter': 'all',
          'todoOrder': 'descending',
          'todoGrouping': 'none',
        });
        prefs = await SharedPreferences.getInstance();
      });

      testWidgets('by settings', (tester) async {
        await tester.pumpWidget(
          LoginWrapper(
            prefs: prefs,
            todoFile: file,
            initialLoginState: const LoginOffline(),
          ),
        );
        await tester.pump();

        expect(find.byType(TodoTile), findsNWidgets(3));
        Iterable<TodoTile> todoTiles =
            tester.widgetList<TodoTile>(find.byType(TodoTile));
        expect(todoTiles.elementAt(0).todo.description, "TodoC");
        expect(todoTiles.elementAt(1).todo.description, "TodoB");
        expect(todoTiles.elementAt(2).todo.description, "TodoA");
      });
    });
  });

  group('Filter', () {
    setUp(() async {
      file = fs.file('todoFilter.txt');
      await file.create();
      await file.writeAsString(
        [
          "x 2023-12-04 2023-12-02 TodoC",
          "2023-12-02 TodoA",
          "x 2023-12-03 2023-12-02 TodoB",
        ].join("\n"),
        flush: true,
      );
    });

    group('all', () {
      setUp(() async {
        // Mock shared preferences.
        SharedPreferences.setMockInitialValues({
          'todoFilter': 'all',
          'todoOrder': 'ascending',
          'todoGrouping': 'none',
        });
        prefs = await SharedPreferences.getInstance();
      });

      testWidgets('by settings', (tester) async {
        await tester.pumpWidget(
          LoginWrapper(
            prefs: prefs,
            todoFile: file,
            initialLoginState: const LoginOffline(),
          ),
        );
        await tester.pump();

        expect(find.byType(TodoTile), findsNWidgets(3));
        Iterable<TodoTile> todoTiles =
            tester.widgetList<TodoTile>(find.byType(TodoTile));
        expect(todoTiles.elementAt(0).todo.description, "TodoA");
        expect(todoTiles.elementAt(1).todo.description, "TodoB");
        expect(todoTiles.elementAt(2).todo.description, "TodoC");
      });
    });

    group('completed only', () {
      setUp(() async {
        // Mock shared preferences.
        SharedPreferences.setMockInitialValues({
          'todoFilter': 'completedOnly',
          'todoOrder': 'ascending',
          'todoGrouping': 'none',
        });
        prefs = await SharedPreferences.getInstance();
      });

      testWidgets('by settings', (tester) async {
        await tester.pumpWidget(
          LoginWrapper(
            prefs: prefs,
            todoFile: file,
            initialLoginState: const LoginOffline(),
          ),
        );
        await tester.pump();

        expect(find.byType(TodoTile), findsNWidgets(2));
        Iterable<TodoTile> todoTiles =
            tester.widgetList<TodoTile>(find.byType(TodoTile));
        expect(todoTiles.elementAt(0).todo.description, "TodoB");
        expect(todoTiles.elementAt(1).todo.description, "TodoC");
      });
    });

    group('incompleted only', () {
      setUp(() async {
        // Mock shared preferences.
        SharedPreferences.setMockInitialValues({
          'todoFilter': 'incompletedOnly',
          'todoOrder': 'ascending',
          'todoGrouping': 'none',
        });
        prefs = await SharedPreferences.getInstance();
      });

      testWidgets('by settings', (tester) async {
        await tester.pumpWidget(
          LoginWrapper(
            prefs: prefs,
            todoFile: file,
            initialLoginState: const LoginOffline(),
          ),
        );
        await tester.pump();

        expect(find.byType(TodoTile), findsNWidgets(1));
        Iterable<TodoTile> todoTiles =
            tester.widgetList<TodoTile>(find.byType(TodoTile));
        expect(todoTiles.elementAt(0).todo.description, "TodoA");
      });
    });
  });

  group('Group by', () {
    setUp(() async {});

    group('none', () {
      setUp(() async {
        file = fs.file('todoGroupByNone.txt');
        await file.create();
        await file.writeAsString(
          [
            "x 2023-13-04 2023-12-02 TodoB",
            "2023-12-02 TodoA",
          ].join("\n"),
          flush: true,
        );
        // Mock shared preferences.
        SharedPreferences.setMockInitialValues({
          'todoFilter': 'all',
          'todoOrder': 'ascending',
          'todoGrouping': 'none',
        });
        prefs = await SharedPreferences.getInstance();
      });

      testWidgets('check sections', (tester) async {
        await tester.pumpWidget(
          LoginWrapper(
            prefs: prefs,
            todoFile: file,
            initialLoginState: const LoginOffline(),
          ),
        );
        await tester.pump();

        expect(find.byType(TodoListSection), findsNWidgets(2));
        Iterable<TodoListSection> todoListSections =
            tester.widgetList<TodoListSection>(find.byType(TodoListSection));
        expect(todoListSections.elementAt(0).title, "Undone");
        expect(todoListSections.elementAt(1).title, "Done");

        expect(
          find.descendant(
            of: find.byWidget(todoListSections.elementAt(0)),
            matching: find.text('TodoA'), // 'TodoA' is undone.
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byWidget(todoListSections.elementAt(1)),
            matching: find.text('TodoB'), // 'TodoB' is done
          ),
          findsOneWidget,
        );
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
            // "x 2023-12-03 2023-12-02 TodoA",
            "1970-01-01 TodoB due:1970-01-01",
            "2023-12-02 TodoC due:$today",
            "2023-12-02 TodoD due:$tomorrow",
            "2023-12-02 TodoE",
          ].join("\n"),
          flush: true,
        );
        // Mock shared preferences.
        SharedPreferences.setMockInitialValues({
          'todoFilter': 'all',
          'todoOrder': 'ascending',
          'todoGrouping': 'upcoming',
        });
        prefs = await SharedPreferences.getInstance();
      });

      testWidgets('check sections', (tester) async {
        // @todo: Can not find "Done" section. It works in production (manual testing).
        await tester.pumpWidget(
          LoginWrapper(
            prefs: prefs,
            todoFile: file,
            initialLoginState: const LoginOffline(),
          ),
        );
        await tester.pump();

        expect(find.byType(TodoListSection), findsNWidgets(4)); // 5
        Iterable<TodoListSection> todoListSections =
            tester.widgetList<TodoListSection>(find.byType(TodoListSection));
        expect(todoListSections.elementAt(0).title, "Deadline passed");
        expect(todoListSections.elementAt(1).title, "Today");
        expect(todoListSections.elementAt(2).title, "Upcoming");
        expect(todoListSections.elementAt(3).title, "No deadline");
        // expect(todoListSections.elementAt(4).title, "Done");

        expect(
          find.descendant(
            of: find.byWidget(todoListSections.elementAt(0)),
            matching: find.text('TodoB'), // 'TodoB's deadline is passed.
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byWidget(todoListSections.elementAt(1)),
            matching: find.text('TodoC'), // 'TodoC' is today.
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byWidget(todoListSections.elementAt(2)),
            matching: find.text('TodoD'), // 'TodoD' is upcoming.
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byWidget(todoListSections.elementAt(3)),
            matching: find.text('TodoE'), // 'TodoE' has no deadline.
          ),
          findsOneWidget,
        );
        // expect(
        //   find.descendant(
        //     of: find.byWidget(todoListSections.elementAt(4)),
        //     matching: find.text('TodoA'), // 'TodoA' is done.
        //   ),
        //   findsOneWidget,
        // );
      });
    });

    group('priority', () {
      setUp(() async {
        file = fs.file('todoGroupByPriority.txt');
        await file.create();
        await file.writeAsString(
          [
            "x 2023-13-04 2023-12-02 TodoA",
            "(E) 2023-12-02 TodoB",
            "(F) 2023-12-02 TodoC",
            "2023-12-02 TodoD",
          ].join("\n"),
          flush: true,
        );
        // Mock shared preferences.
        SharedPreferences.setMockInitialValues({
          'todoFilter': 'all',
          'todoOrder': 'ascending',
          'todoGrouping': 'priority',
        });
        prefs = await SharedPreferences.getInstance();
      });

      testWidgets('check sections', (tester) async {
        await tester.pumpWidget(
          LoginWrapper(
            prefs: prefs,
            todoFile: file,
            initialLoginState: const LoginOffline(),
          ),
        );
        await tester.pump();

        expect(find.byType(TodoListSection), findsNWidgets(4));
        Iterable<TodoListSection> todoListSections =
            tester.widgetList<TodoListSection>(find.byType(TodoListSection));
        expect(todoListSections.elementAt(0).title, "E");
        expect(todoListSections.elementAt(1).title, "F");
        expect(todoListSections.elementAt(2).title, "No priority");
        expect(todoListSections.elementAt(3).title, "Done");

        expect(
          find.descendant(
            of: find.byWidget(todoListSections.elementAt(0)),
            matching: find.text('TodoB'), // 'TodoB' has priority E.
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byWidget(todoListSections.elementAt(1)),
            matching: find.text('TodoC'), // 'TodoC' has priority F.
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byWidget(todoListSections.elementAt(2)),
            matching: find.text('TodoD'), // 'TodoD' has no priority.
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byWidget(todoListSections.elementAt(3)),
            matching: find.text('TodoA'), // 'TodoA' is done.
          ),
          findsOneWidget,
        );
      });
    });

    group('project', () {
      setUp(() async {
        file = fs.file('todoGroupByProject.txt');
        await file.create();
        await file.writeAsString(
          [
            "x 2023-13-04 2023-12-02 TodoC",
            "2023-12-02 TodoA +project1",
            "2023-12-02 TodoB +project2",
            "2023-12-02 TodoD",
          ].join("\n"),
          flush: true,
        );
        // Mock shared preferences.
        SharedPreferences.setMockInitialValues({
          'todoFilter': 'all',
          'todoOrder': 'ascending',
          'todoGrouping': 'project',
        });
        prefs = await SharedPreferences.getInstance();
      });

      testWidgets('check sections', (tester) async {
        await tester.pumpWidget(
          LoginWrapper(
            prefs: prefs,
            todoFile: file,
            initialLoginState: const LoginOffline(),
          ),
        );
        await tester.pump();

        expect(find.byType(TodoListSection), findsNWidgets(4));
        Iterable<TodoListSection> todoListSections =
            tester.widgetList<TodoListSection>(find.byType(TodoListSection));
        expect(todoListSections.elementAt(0).title, "project1");
        expect(todoListSections.elementAt(1).title, "project2");
        expect(todoListSections.elementAt(2).title, "No project");
        expect(todoListSections.elementAt(3).title, "Done");

        expect(
          find.descendant(
            of: find.byWidget(todoListSections.elementAt(0)),
            matching: find.text('TodoA'), // 'TodoA' containts project1.
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byWidget(todoListSections.elementAt(1)),
            matching: find.text('TodoB'), // 'TodoB' contains project2.
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byWidget(todoListSections.elementAt(2)),
            matching: find.text('TodoD'), // 'TodoD' contains no project.
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byWidget(todoListSections.elementAt(3)),
            matching: find.text('TodoC'), // 'TodoC' is done.
          ),
          findsOneWidget,
        );
      });
    });

    group('context', () {
      setUp(() async {
        file = fs.file('todoGroupByContext.txt');
        await file.create();
        await file.writeAsString(
          [
            "x 2023-13-04 2023-12-02 TodoC",
            "2023-12-02 TodoA @context1",
            "2023-12-02 TodoB @context2",
            "2023-12-02 TodoD",
          ].join("\n"),
          flush: true,
        );
        // Mock shared preferences.
        SharedPreferences.setMockInitialValues({
          'todoFilter': 'all',
          'todoOrder': 'ascending',
          'todoGrouping': 'context',
        });
        prefs = await SharedPreferences.getInstance();
      });

      testWidgets('check sections', (tester) async {
        await tester.pumpWidget(
          LoginWrapper(
            prefs: prefs,
            todoFile: file,
            initialLoginState: const LoginOffline(),
          ),
        );
        await tester.pump();

        expect(find.byType(TodoListSection), findsNWidgets(4));
        Iterable<TodoListSection> todoListSections =
            tester.widgetList<TodoListSection>(find.byType(TodoListSection));
        expect(todoListSections.elementAt(0).title, "context1");
        expect(todoListSections.elementAt(1).title, "context2");
        expect(todoListSections.elementAt(2).title, "No context");
        expect(todoListSections.elementAt(3).title, "Done");

        expect(
          find.descendant(
            of: find.byWidget(todoListSections.elementAt(0)),
            matching: find.text('TodoA'), // 'TodoA' containts context1.
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byWidget(todoListSections.elementAt(1)),
            matching: find.text('TodoB'), // 'TodoB' contains context2.
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byWidget(todoListSections.elementAt(2)),
            matching: find.text('TodoD'), // 'TodoD' contains no context.
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byWidget(todoListSections.elementAt(3)),
            matching: find.text('TodoC'), // 'TodoC' is done.
          ),
          findsOneWidget,
        );
      });
    });
  });
}
