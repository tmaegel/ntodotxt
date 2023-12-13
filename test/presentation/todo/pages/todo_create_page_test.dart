import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/presentation/todo/pages/todo_create_edit_page.dart';

class TodoCreateEditPageMaterialApp extends StatelessWidget {
  const TodoCreateEditPageMaterialApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: TodoCreateEditPage(),
    );
  }
}

Future safeTapByFinder(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
}

void main() {
  group('Todo create', () {
    group('project', () {
      testWidgets('add & remove', (tester) async {
        // Increase size to ensure all elements in list are visible.
        tester.view.physicalSize = const Size(400, 1600);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(const TodoCreateEditPageMaterialApp());
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
          'project1',
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
  });

  group('context', () {
    testWidgets('add & remove', (tester) async {
      // Increase size to ensure all elements in list are visible.
      tester.view.physicalSize = const Size(400, 1600);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(const TodoCreateEditPageMaterialApp());
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
        'context1',
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
    testWidgets('add', (tester) async {
      // Increase size to ensure all elements in list are visible.
      tester.view.physicalSize = const Size(400, 1600);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(const TodoCreateEditPageMaterialApp());
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
        'foo:bar',
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
