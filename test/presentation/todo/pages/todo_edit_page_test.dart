import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/presentation/todo/pages/todo_edit_page.dart';

class TodoEditPageMaterialApp extends StatelessWidget {
  final Todo todo;

  const TodoEditPageMaterialApp({
    required this.todo,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TodoEditPage(todo: todo),
    );
  }
}

Future safeTapByFinder(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
}

void main() {
  group('Todo edit', () {
    group('completion', () {
      testWidgets('set', (tester) async {
        // Increase size to ensure all elements in list are visible.
        tester.view.physicalSize = const Size(400, 1600);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(TodoEditPageMaterialApp(
          todo: Todo(completion: true, description: 'Code something'),
        ));
        await tester.pump();

        Finder todoAttrTileFinder = find.ancestor(
          of: find.byTooltip('Completion'),
          matching: find.byType(ListTile),
        );
        expect(todoAttrTileFinder, findsOneWidget);
        expect(
          find.descendant(
            of: todoAttrTileFinder,
            matching: find.byWidgetPredicate(
              (Widget widget) => widget is Checkbox && widget.value == true,
            ),
          ),
          findsOneWidget,
        );

        // resets the screen to its original size after the test end
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
      });
      testWidgets('unset', (tester) async {
        // Increase size to ensure all elements in list are visible.
        tester.view.physicalSize = const Size(400, 1600);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(TodoEditPageMaterialApp(
          todo: Todo(completion: false, description: 'Code something'),
        ));
        await tester.pump();

        Finder todoAttrTileFinder = find.ancestor(
          of: find.byTooltip('Completion'),
          matching: find.byType(ListTile),
        );
        expect(todoAttrTileFinder, findsOneWidget);
        expect(
          find.descendant(
            of: todoAttrTileFinder,
            matching: find.byWidgetPredicate(
              (Widget widget) => widget is Checkbox && widget.value == false,
            ),
          ),
          findsOneWidget,
        );

        // resets the screen to its original size after the test end
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
      });
    });

    group('priority', () {
      testWidgets('set', (tester) async {
        // Increase size to ensure all elements in list are visible.
        tester.view.physicalSize = const Size(400, 1600);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(TodoEditPageMaterialApp(
          todo: Todo(priority: 'A', description: 'Code something'),
        ));
        await tester.pump();

        Finder todoAttrTileFinder = find.ancestor(
          of: find.byTooltip('Priority'),
          matching: find.byType(ListTile),
        );
        expect(todoAttrTileFinder, findsOneWidget);
        expect(
          find.descendant(
            of: todoAttrTileFinder,
            matching: find.byWidgetPredicate(
              (Widget widget) =>
                  widget is ChoiceChip &&
                  (widget.label as Text).data == 'A' &&
                  widget.selected == true,
            ),
          ),
          findsOneWidget,
        );

        // resets the screen to its original size after the test end
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
      });
      testWidgets('unset', (tester) async {
        // Increase size to ensure all elements in list are visible.
        tester.view.physicalSize = const Size(400, 1600);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(TodoEditPageMaterialApp(
          todo: Todo(priority: null, description: 'Code something'),
        ));
        await tester.pump();

        Finder todoAttrTileFinder = find.ancestor(
          of: find.byTooltip('Priority'),
          matching: find.byType(ListTile),
        );
        expect(todoAttrTileFinder, findsOneWidget);
        expect(
          find.descendant(
            of: todoAttrTileFinder,
            matching: find.byWidgetPredicate(
              (Widget widget) =>
                  widget is ChoiceChip && widget.selected == true,
            ),
          ),
          findsNothing,
        );

        // resets the screen to its original size after the test end
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
      });
    });

    group('completion date', () {
      testWidgets('set', (tester) async {
        // Increase size to ensure all elements in list are visible.
        tester.view.physicalSize = const Size(400, 1600);
        tester.view.devicePixelRatio = 1.0;

        final DateTime now = DateTime.now();
        final String today =
            '${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
        await tester.pumpWidget(TodoEditPageMaterialApp(
          todo: Todo(completion: true, description: 'Code something'),
        ));
        await tester.pump();

        Finder todoAttrTileFinder = find.ancestor(
          of: find.byTooltip('Completion date'),
          matching: find.byType(ListTile),
        );
        expect(todoAttrTileFinder, findsOneWidget);
        expect(
          find.descendant(
            of: todoAttrTileFinder,
            matching: find.byWidgetPredicate(
              (Widget widget) => widget is Text && widget.data == today,
            ),
          ),
          findsOneWidget,
        );

        // resets the screen to its original size after the test end
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
      });
      testWidgets('unset', (tester) async {
        // Increase size to ensure all elements in list are visible.
        tester.view.physicalSize = const Size(400, 1600);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(TodoEditPageMaterialApp(
          todo: Todo(completion: false, description: 'Code something'),
        ));
        await tester.pump();

        Finder todoAttrTileFinder = find.ancestor(
          of: find.byTooltip('Completion date'),
          matching: find.byType(ListTile),
        );
        expect(todoAttrTileFinder, findsOneWidget);
        expect(
          find.descendant(
            of: todoAttrTileFinder,
            matching: find.byWidgetPredicate(
              (Widget widget) =>
                  widget is Text && widget.data == 'no completion date',
            ),
          ),
          findsOneWidget,
        );

        // resets the screen to its original size after the test end
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
      });
    });

    group('creation date', () {
      testWidgets('set', (tester) async {
        // Increase size to ensure all elements in list are visible.
        tester.view.physicalSize = const Size(400, 1600);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(TodoEditPageMaterialApp(
          todo: Todo(
              creationDate: DateTime(2023, 12, 5),
              description: 'Code something'),
        ));
        await tester.pump();

        Finder todoAttrTileFinder = find.ancestor(
          of: find.byTooltip('Creation date'),
          matching: find.byType(ListTile),
        );
        expect(todoAttrTileFinder, findsOneWidget);
        expect(
          find.descendant(
            of: todoAttrTileFinder,
            matching: find.byWidgetPredicate(
              (Widget widget) => widget is Text && widget.data == '2023-12-05',
            ),
          ),
          findsOneWidget,
        );

        // resets the screen to its original size after the test end
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
      });
    });

    group('due date', () {
      testWidgets('set', (tester) async {
        // Increase size to ensure all elements in list are visible.
        tester.view.physicalSize = const Size(400, 1600);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(TodoEditPageMaterialApp(
          todo: Todo(
            description: 'Code something',
            keyValues: const {'due': '2023-12-31'},
          ),
        ));
        await tester.pump();

        Finder todoAttrTileFinder = find.ancestor(
          of: find.byTooltip('Due date'),
          matching: find.byType(ListTile),
        );
        expect(todoAttrTileFinder, findsOneWidget);
        expect(
          find.descendant(
            of: todoAttrTileFinder,
            matching: find.byWidgetPredicate(
              (Widget widget) => widget is Text && widget.data == '2023-12-31',
            ),
          ),
          findsOneWidget,
        );
        Finder todoKeyValuesTileFinder = find.ancestor(
          of: find.byTooltip('Key values'),
          matching: find.byType(ListTile),
        );
        expect(todoKeyValuesTileFinder, findsOneWidget);
        expect(
          find.descendant(
            of: todoKeyValuesTileFinder,
            matching: find.byWidgetPredicate(
              (Widget widget) =>
                  widget is ChoiceChip &&
                  (widget.label as Text).data == 'due:2023-12-31',
            ),
          ),
          findsOneWidget,
        );

        // resets the screen to its original size after the test end
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
      });
      testWidgets('unset', (tester) async {
        // Increase size to ensure all elements in list are visible.
        tester.view.physicalSize = const Size(400, 1600);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(TodoEditPageMaterialApp(
          todo: Todo(description: 'Code something'),
        ));
        await tester.pump();

        Finder todoAttrTileFinder = find.ancestor(
          of: find.byTooltip('Due date'),
          matching: find.byType(ListTile),
        );
        expect(todoAttrTileFinder, findsOneWidget);
        expect(
          find.descendant(
            of: todoAttrTileFinder,
            matching: find.byWidgetPredicate(
              (Widget widget) => widget is Text && widget.data == 'no due date',
            ),
          ),
          findsOneWidget,
        );
        Finder todoKeyValuesTileFinder = find.ancestor(
          of: find.byTooltip('Key values'),
          matching: find.byType(ListTile),
        );
        expect(todoKeyValuesTileFinder, findsOneWidget);
        expect(
          find.descendant(
            of: todoKeyValuesTileFinder,
            matching: find.byWidgetPredicate(
              (Widget widget) =>
                  widget is ChoiceChip &&
                  (widget.label as Text).data!.startsWith('due'),
            ),
          ),
          findsNothing,
        );

        // resets the screen to its original size after the test end
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
      });
    });

    group('project', () {
      testWidgets('set', (tester) async {
        // Increase size to ensure all elements in list are visible.
        tester.view.physicalSize = const Size(400, 1600);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(TodoEditPageMaterialApp(
          todo: Todo(
            description: 'Code something',
            projects: const {'project1'},
          ),
        ));
        await tester.pump();

        Finder todoProjectsTileFinder = find.ancestor(
          of: find.byTooltip('Projects'),
          matching: find.byType(ListTile),
        );
        expect(todoProjectsTileFinder, findsOneWidget);
        expect(
          find.descendant(
            of: todoProjectsTileFinder,
            matching: find.byWidgetPredicate(
              (Widget widget) =>
                  widget is ChoiceChip &&
                  (widget.label as Text).data == 'project1',
            ),
          ),
          findsOneWidget,
        );

        // resets the screen to its original size after the test end
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
      });
      testWidgets('unset', (tester) async {
        // Increase size to ensure all elements in list are visible.
        tester.view.physicalSize = const Size(400, 1600);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(TodoEditPageMaterialApp(
          todo: Todo(
            description: 'Code something',
          ),
        ));
        await tester.pump();

        Finder todoProjectsTileFinder = find.ancestor(
          of: find.byTooltip('Projects'),
          matching: find.byType(ListTile),
        );
        expect(todoProjectsTileFinder, findsOneWidget);
        expect(
          find.descendant(
            of: todoProjectsTileFinder,
            matching:
                find.byWidgetPredicate((Widget widget) => widget is ChoiceChip),
          ),
          findsNothing,
        );

        // resets the screen to its original size after the test end
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
      });
    });
    testWidgets('add', (tester) async {
      // Increase size to ensure all elements in list are visible.
      tester.view.physicalSize = const Size(400, 1600);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(TodoEditPageMaterialApp(
        todo: Todo(description: 'Code something'),
      ));
      await tester.pump();

      Finder todoProjectsTileFinder = find.ancestor(
        of: find.byTooltip('Projects'),
        matching: find.byType(ListTile),
      );
      expect(todoProjectsTileFinder, findsOneWidget);

      Finder addProjectTagFinder = find.descendant(
        of: todoProjectsTileFinder,
        matching: find.byTooltip('Add project tag'),
      );
      expect(addProjectTagFinder, findsOneWidget);
      await tester.tap(addProjectTagFinder); // Add project tag button.
      await tester.pump();

      Finder addProjectTagDialogFinder =
          find.byKey(const Key('addProjectTagDialog'));
      expect(addProjectTagDialogFinder, findsOneWidget);
      await tester.enterText(
        find.descendant(
          of: addProjectTagDialogFinder,
          matching: find.byType(TextFormField),
        ),
        "project1",
      );
      await safeTapByFinder(
        tester,
        find.descendant(
          of: addProjectTagDialogFinder,
          matching: find.byTooltip('Add project tags'),
        ),
      );
      await tester.pump();

      expect(
        find.descendant(
          of: todoProjectsTileFinder,
          matching: find.byWidgetPredicate(
            (Widget widget) =>
                widget is ChoiceChip &&
                (widget.label as Text).data == 'project1',
          ),
        ),
        findsOneWidget,
      );

      // resets the screen to its original size after the test end
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });
    testWidgets('remove', (tester) async {
      // Increase size to ensure all elements in list are visible.
      tester.view.physicalSize = const Size(400, 1600);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(TodoEditPageMaterialApp(
        todo: Todo(
          description: 'Code something',
          projects: const {'project1'},
        ),
      ));
      await tester.pump();

      Finder todoProjectsTileFinder = find.ancestor(
        of: find.byTooltip('Projects'),
        matching: find.byType(ListTile),
      );
      expect(todoProjectsTileFinder, findsOneWidget);

      // Remove project (tag) by tap on chip.
      await tester.tap(
        find.descendant(
          of: todoProjectsTileFinder,
          matching: find.byWidgetPredicate(
            (Widget widget) =>
                widget is ChoiceChip &&
                (widget.label as Text).data == 'project1',
          ),
        ),
      );
      await tester.pump();

      expect(
        find.descendant(
          of: todoProjectsTileFinder,
          matching:
              find.byWidgetPredicate((Widget widget) => widget is ChoiceChip),
        ),
        findsNothing,
      );

      // resets the screen to its original size after the test end
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });
  });

  group('context', () {
    testWidgets('set', (tester) async {
      // Increase size to ensure all elements in list are visible.
      tester.view.physicalSize = const Size(400, 1600);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(TodoEditPageMaterialApp(
        todo: Todo(
          description: 'Code something',
          contexts: const {'context1'},
        ),
      ));
      await tester.pump();

      Finder todoProjectsTileFinder = find.ancestor(
        of: find.byTooltip('Contexts'),
        matching: find.byType(ListTile),
      );
      expect(todoProjectsTileFinder, findsOneWidget);
      expect(
        find.descendant(
          of: todoProjectsTileFinder,
          matching: find.byWidgetPredicate(
            (Widget widget) =>
                widget is ChoiceChip &&
                (widget.label as Text).data == 'context1',
          ),
        ),
        findsOneWidget,
      );

      // resets the screen to its original size after the test end
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });
    testWidgets('unset', (tester) async {
      // Increase size to ensure all elements in list are visible.
      tester.view.physicalSize = const Size(400, 1600);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(TodoEditPageMaterialApp(
        todo: Todo(
          description: 'Code something',
        ),
      ));
      await tester.pump();

      Finder todoProjectsTileFinder = find.ancestor(
        of: find.byTooltip('Contexts'),
        matching: find.byType(ListTile),
      );
      expect(todoProjectsTileFinder, findsOneWidget);
      expect(
        find.descendant(
          of: todoProjectsTileFinder,
          matching:
              find.byWidgetPredicate((Widget widget) => widget is ChoiceChip),
        ),
        findsNothing,
      );

      // resets the screen to its original size after the test end
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });
    testWidgets('add', (tester) async {
      // Increase size to ensure all elements in list are visible.
      tester.view.physicalSize = const Size(400, 1600);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(TodoEditPageMaterialApp(
        todo: Todo(description: 'Code something'),
      ));
      await tester.pump();

      Finder todoContextsTileFinder = find.ancestor(
        of: find.byTooltip('Contexts'),
        matching: find.byType(ListTile),
      );
      expect(todoContextsTileFinder, findsOneWidget);

      Finder addContextTagFinder = find.descendant(
        of: todoContextsTileFinder,
        matching: find.byTooltip('Add context tag'),
      );
      expect(addContextTagFinder, findsOneWidget);
      await tester.tap(addContextTagFinder); // Add context tag button.
      await tester.pump();

      Finder addContextTagDialogFinder =
          find.byKey(const Key('addContextTagDialog'));
      expect(addContextTagDialogFinder, findsOneWidget);
      await tester.enterText(
        find.descendant(
          of: addContextTagDialogFinder,
          matching: find.byType(TextFormField),
        ),
        "context1",
      );
      await safeTapByFinder(
        tester,
        find.descendant(
          of: addContextTagDialogFinder,
          matching: find.byTooltip('Add context tags'),
        ),
      );
      await tester.pump();

      expect(
        find.descendant(
          of: todoContextsTileFinder,
          matching: find.byWidgetPredicate(
            (Widget widget) =>
                widget is ChoiceChip &&
                (widget.label as Text).data == 'context1',
          ),
        ),
        findsOneWidget,
      );

      // resets the screen to its original size after the test end
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });
    testWidgets('remove', (tester) async {
      // Increase size to ensure all elements in list are visible.
      tester.view.physicalSize = const Size(400, 1600);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(TodoEditPageMaterialApp(
        todo: Todo(
          description: 'Code something',
          contexts: const {'context1'},
        ),
      ));
      await tester.pump();

      Finder todoContextsTileFinder = find.ancestor(
        of: find.byTooltip('Contexts'),
        matching: find.byType(ListTile),
      );
      expect(todoContextsTileFinder, findsOneWidget);

      // Remove project (tag) by tap on chip.
      await tester.tap(
        find.descendant(
          of: todoContextsTileFinder,
          matching: find.byWidgetPredicate(
            (Widget widget) =>
                widget is ChoiceChip &&
                (widget.label as Text).data == 'context1',
          ),
        ),
      );
      await tester.pump();

      expect(
        find.descendant(
          of: todoContextsTileFinder,
          matching:
              find.byWidgetPredicate((Widget widget) => widget is ChoiceChip),
        ),
        findsNothing,
      );

      // resets the screen to its original size after the test end
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });
  });

  group('key-value', () {
    testWidgets('set', (tester) async {
      // Increase size to ensure all elements in list are visible.
      tester.view.physicalSize = const Size(400, 1600);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(TodoEditPageMaterialApp(
        todo: Todo(
          description: 'Code something',
          keyValues: const {'foo': 'bar'},
        ),
      ));
      await tester.pump();

      Finder todoProjectsTileFinder = find.ancestor(
        of: find.byTooltip('Key values'),
        matching: find.byType(ListTile),
      );
      expect(todoProjectsTileFinder, findsOneWidget);
      expect(
        find.descendant(
          of: todoProjectsTileFinder,
          matching: find.byWidgetPredicate(
            (Widget widget) =>
                widget is ChoiceChip &&
                (widget.label as Text).data == 'foo:bar',
          ),
        ),
        findsOneWidget,
      );

      // resets the screen to its original size after the test end
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });
    testWidgets('unset', (tester) async {
      // Increase size to ensure all elements in list are visible.
      tester.view.physicalSize = const Size(400, 1600);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(TodoEditPageMaterialApp(
        todo: Todo(
          description: 'Code something',
        ),
      ));
      await tester.pump();

      Finder todoProjectsTileFinder = find.ancestor(
        of: find.byTooltip('Key values'),
        matching: find.byType(ListTile),
      );
      expect(todoProjectsTileFinder, findsOneWidget);
      expect(
        find.descendant(
          of: todoProjectsTileFinder,
          matching:
              find.byWidgetPredicate((Widget widget) => widget is ChoiceChip),
        ),
        findsNothing,
      );

      // resets the screen to its original size after the test end
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });
    testWidgets('add', (tester) async {
      // Increase size to ensure all elements in list are visible.
      tester.view.physicalSize = const Size(400, 1600);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(TodoEditPageMaterialApp(
        todo: Todo(description: 'Code something'),
      ));
      await tester.pump();

      Finder todoKeyValuesTileFinder = find.ancestor(
        of: find.byTooltip('Key values'),
        matching: find.byType(ListTile),
      );
      expect(todoKeyValuesTileFinder, findsOneWidget);

      Finder addKeyValueTagFinder = find.descendant(
        of: todoKeyValuesTileFinder,
        matching: find.byTooltip('Add key:value tag'),
      );
      expect(addKeyValueTagFinder, findsOneWidget);
      await tester.tap(addKeyValueTagFinder); // Add key value tag button.
      await tester.pump();

      Finder addKeyValueTagDialogFinder =
          find.byKey(const Key('addKeyValueTagDialog'));
      expect(addKeyValueTagDialogFinder, findsOneWidget);
      await tester.enterText(
        find.descendant(
          of: addKeyValueTagDialogFinder,
          matching: find.byType(TextFormField),
        ),
        "foo:bar",
      );
      await safeTapByFinder(
        tester,
        find.descendant(
          of: addKeyValueTagDialogFinder,
          matching: find.byTooltip('Add key:value tags'),
        ),
      );
      await tester.pump();

      expect(
        find.descendant(
          of: todoKeyValuesTileFinder,
          matching: find.byWidgetPredicate(
            (Widget widget) =>
                widget is ChoiceChip &&
                (widget.label as Text).data == 'foo:bar',
          ),
        ),
        findsOneWidget,
      );

      // resets the screen to its original size after the test end
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });
    testWidgets('remove', (tester) async {
      // Increase size to ensure all elements in list are visible.
      tester.view.physicalSize = const Size(400, 1600);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(TodoEditPageMaterialApp(
        todo: Todo(
          description: 'Code something',
          keyValues: const {'foo': 'bar'},
        ),
      ));
      await tester.pump();

      Finder todoKeyValuesTileFinder = find.ancestor(
        of: find.byTooltip('Key values'),
        matching: find.byType(ListTile),
      );
      expect(todoKeyValuesTileFinder, findsOneWidget);

      // Remove project (tag) by tap on chip.
      await tester.tap(
        find.descendant(
          of: todoKeyValuesTileFinder,
          matching: find.byWidgetPredicate(
            (Widget widget) =>
                widget is ChoiceChip &&
                (widget.label as Text).data == 'foo:bar',
          ),
        ),
      );
      await tester.pump();

      expect(
        find.descendant(
          of: todoKeyValuesTileFinder,
          matching:
              find.byWidgetPredicate((Widget widget) => widget is ChoiceChip),
        ),
        findsNothing,
      );

      // resets the screen to its original size after the test end
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });
  });
}
