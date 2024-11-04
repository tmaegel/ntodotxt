import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/common_widgets/chip.dart';
import 'package:ntodotxt/common_widgets/contexts_dialog.dart';
import 'package:ntodotxt/common_widgets/key_values_dialog.dart';
import 'package:ntodotxt/common_widgets/priorities_dialog.dart';
import 'package:ntodotxt/common_widgets/projects_dialog.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/presentation/todo/pages/todo_create_edit_page.dart';

class MaterialAppWrapper extends StatelessWidget {
  final Todo? initTodo;
  final Set<String> projects;
  final Set<String> contexts;
  final Set<String> keyValues;

  const MaterialAppWrapper({
    this.initTodo,
    this.projects = const {},
    this.contexts = const {},
    this.keyValues = const {},
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TodoCreateEditPage(
        initTodo: initTodo ?? Todo(),
        newTodo: initTodo == null ? true : false,
        projects: projects,
        contexts: contexts,
        keyValues: keyValues,
      ),
    );
  }
}

void main() {
  group('TodoCreateEditPage', () {
    group('narrow view', () {
      group('create mode', () {
        testWidgets('found no DeleteTodoIconButton', (tester) async {
          // Increase size to ensure all elements in list are visible.
          tester.view.physicalSize = const Size(400, 800);
          tester.view.devicePixelRatio = 1.0;

          await tester.pumpWidget(const MaterialAppWrapper());
          await tester.pumpAndSettle();
          expect(
            find.byType(DeleteTodoIconButton),
            findsNothing,
          );

          // resets the screen to its original size after the test end
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
        });
        testWidgets('found no TodoCompletionDateItem', (tester) async {
          // Increase size to ensure all elements in list are visible.
          tester.view.physicalSize = const Size(400, 800);
          tester.view.devicePixelRatio = 1.0;

          await tester.pumpWidget(const MaterialAppWrapper());
          await tester.pumpAndSettle();
          expect(
            find.byType(TodoCompletionDateItem),
            findsNothing,
          );

          // resets the screen to its original size after the test end
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
        });
      });
      group('edit mode', () {
        testWidgets('found DeleteTodoIconButton', (tester) async {
          // Increase size to ensure all elements in list are visible.
          tester.view.physicalSize = const Size(400, 800);
          tester.view.devicePixelRatio = 1.0;

          await tester.pumpWidget(
            MaterialAppWrapper(
              initTodo:
                  Todo(priority: Priority.A, description: 'Code something'),
            ),
          );
          await tester.pumpAndSettle();
          expect(
            find.byType(DeleteTodoIconButton),
            findsOneWidget,
          );

          // resets the screen to its original size after the test end
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
        });
        testWidgets('found TodoCompletionDateItem', (tester) async {
          // Increase size to ensure all elements in list are visible.
          tester.view.physicalSize = const Size(400, 800);
          tester.view.devicePixelRatio = 1.0;

          await tester.pumpWidget(
            MaterialAppWrapper(
              initTodo:
                  Todo(priority: Priority.A, description: 'Code something'),
            ),
          );
          await tester.pumpAndSettle();
          expect(
            find.byType(TodoCompletionDateItem),
            findsOneWidget,
          );

          // resets the screen to its original size after the test end
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
        });
      });
    });

    group('wide view', () {
      group('create mode', () {
        testWidgets('found no DeleteTodoIconButton', (tester) async {
          // Increase size to ensure all elements in list are visible.
          tester.view.physicalSize = const Size(800, 800);
          tester.view.devicePixelRatio = 1.0;

          await tester.pumpWidget(const MaterialAppWrapper());
          await tester.pumpAndSettle();
          expect(
            find.byType(DeleteTodoIconButton),
            findsNothing,
          );

          // resets the screen to its original size after the test end
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
        });
        testWidgets('found no TodoCompletionDateItem', (tester) async {
          // Increase size to ensure all elements in list are visible.
          tester.view.physicalSize = const Size(800, 800);
          tester.view.devicePixelRatio = 1.0;

          await tester.pumpWidget(const MaterialAppWrapper());
          await tester.pumpAndSettle();
          expect(
            find.byType(TodoCompletionDateItem),
            findsNothing,
          );

          // resets the screen to its original size after the test end
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
        });
      });
      group('edit mode', () {
        testWidgets('found DeleteTodoIconButton', (tester) async {
          // Increase size to ensure all elements in list are visible.
          tester.view.physicalSize = const Size(800, 800);
          tester.view.devicePixelRatio = 1.0;

          await tester.pumpWidget(
            MaterialAppWrapper(
              initTodo:
                  Todo(priority: Priority.A, description: 'Code something'),
            ),
          );
          await tester.pumpAndSettle();
          expect(
            find.byType(DeleteTodoIconButton),
            findsOneWidget,
          );

          // resets the screen to its original size after the test end
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
        });
        testWidgets('found TodoCompletionDateItem', (tester) async {
          // Increase size to ensure all elements in list are visible.
          tester.view.physicalSize = const Size(800, 800);
          tester.view.devicePixelRatio = 1.0;

          await tester.pumpWidget(
            MaterialAppWrapper(
              initTodo:
                  Todo(priority: Priority.A, description: 'Code something'),
            ),
          );
          await tester.pumpAndSettle();
          expect(
            find.byType(TodoCompletionDateItem),
            findsOneWidget,
          );

          // resets the screen to its original size after the test end
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
        });
      });
    });

    group('default values', () {
      testWidgets('TodoPriorityItem', (tester) async {
        await tester.pumpWidget(const MaterialAppWrapper());
        await tester.pumpAndSettle();
        await tester.dragUntilVisible(
          find.byType(TodoPriorityItem),
          find.byType(ListView),
          const Offset(0, -100),
        );
        expect(
          find.descendant(
            of: find.byType(TodoPriorityItem),
            matching: find.text('none'),
          ),
          findsOneWidget,
        );
      });
      testWidgets('TodoProjectTagsItem', (tester) async {
        await tester.pumpWidget(const MaterialAppWrapper());
        await tester.pumpAndSettle();
        await tester.dragUntilVisible(
          find.byType(TodoProjectTagsItem),
          find.byType(ListView),
          const Offset(0, -100),
        );
        expect(
          find.descendant(
            of: find.byType(TodoProjectTagsItem),
            matching: find.text('-'),
          ),
          findsOneWidget,
        );
      });
      testWidgets('TodoContextTagsItem', (tester) async {
        await tester.pumpWidget(const MaterialAppWrapper());
        await tester.pumpAndSettle();
        await tester.dragUntilVisible(
          find.byType(TodoContextTagsItem),
          find.byType(ListView),
          const Offset(0, -100),
        );
        expect(
          find.descendant(
            of: find.byType(TodoContextTagsItem),
            matching: find.text('-'),
          ),
          findsOneWidget,
        );
      });
      testWidgets('TodoKeyValueTagsItem', (tester) async {
        await tester.pumpWidget(const MaterialAppWrapper());
        await tester.pumpAndSettle();
        await tester.dragUntilVisible(
          find.byType(TodoKeyValueTagsItem),
          find.byType(ListView),
          const Offset(0, -100),
        );
        expect(
          find.descendant(
            of: find.byType(TodoKeyValueTagsItem),
            matching: find.text('-'),
          ),
          findsOneWidget,
        );
      });
      testWidgets('TodoCreationDateItem', (tester) async {
        await tester.pumpWidget(const MaterialAppWrapper());
        await tester.pumpAndSettle();
        await tester.dragUntilVisible(
          find.byType(TodoCreationDateItem),
          find.byType(ListView),
          const Offset(0, -100),
        );
        final DateTime now = DateTime.now();
        final String today =
            '${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
        expect(
          find.descendant(
            of: find.byType(TodoCreationDateItem),
            matching: find.text(today),
          ),
          findsOneWidget,
        );
      });
      testWidgets('TodoDueDateItem', (tester) async {
        await tester.pumpWidget(const MaterialAppWrapper());
        await tester.pumpAndSettle();
        await tester.dragUntilVisible(
          find.byType(TodoDueDateItem),
          find.byType(ListView),
          const Offset(0, -100),
        );
        expect(
          find.descendant(
            of: find.byType(TodoDueDateItem),
            matching: find.text('-'),
          ),
          findsOneWidget,
        );
      });
    });

    group('non default values', () {
      testWidgets('TodoPriorityItem', (tester) async {
        await tester.pumpWidget(
          MaterialAppWrapper(
            initTodo: Todo(priority: Priority.A, description: 'Code something'),
          ),
        );
        await tester.pumpAndSettle();
        await tester.dragUntilVisible(
          find.byType(TodoPriorityItem),
          find.byType(ListView),
          const Offset(0, -100),
        );
        expect(
          find.descendant(
            of: find.byType(TodoPriorityItem),
            matching: find.text(Priority.A.name),
          ),
          findsOneWidget,
        );
      });
      testWidgets('TodoProjectTagsItem', (tester) async {
        await tester.pumpWidget(
          MaterialAppWrapper(
            initTodo: Todo(description: 'Code something +project1 +project2'),
          ),
        );
        await tester.pumpAndSettle();
        await tester.dragUntilVisible(
          find.byType(TodoProjectTagsItem),
          find.byType(ListView),
          const Offset(0, -100),
        );
        expect(
          find.descendant(
            of: find.byType(TodoProjectTagsItem),
            matching: find.byWidgetPredicate(
              (Widget widget) =>
                  widget is BasicChip && widget.label == 'project1',
            ),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(TodoProjectTagsItem),
            matching: find.byWidgetPredicate(
              (Widget widget) =>
                  widget is BasicChip && widget.label == 'project2',
            ),
          ),
          findsOneWidget,
        );
      });
      testWidgets('TodoContextTagsItem', (tester) async {
        await tester.pumpWidget(
          MaterialAppWrapper(
            initTodo: Todo(description: 'Code something @context1 @context2'),
          ),
        );
        await tester.pumpAndSettle();
        await tester.dragUntilVisible(
          find.byType(TodoContextTagsItem),
          find.byType(ListView),
          const Offset(0, -100),
        );
        expect(
          find.descendant(
            of: find.byType(TodoContextTagsItem),
            matching: find.byWidgetPredicate(
              (Widget widget) =>
                  widget is BasicChip && widget.label == 'context1',
            ),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(TodoContextTagsItem),
            matching: find.byWidgetPredicate(
              (Widget widget) =>
                  widget is BasicChip && widget.label == 'context2',
            ),
          ),
          findsOneWidget,
        );
      });
      testWidgets('TodoKeyValueTagsItem', (tester) async {
        await tester.pumpWidget(
          MaterialAppWrapper(
            initTodo: Todo(description: 'Code something key1:val1 key2:val2'),
          ),
        );
        await tester.pumpAndSettle();
        await tester.dragUntilVisible(
          find.byType(TodoKeyValueTagsItem),
          find.byType(ListView),
          const Offset(0, -100),
        );
        expect(
          find.descendant(
            of: find.byType(TodoKeyValueTagsItem),
            matching: find.byWidgetPredicate(
              (Widget widget) =>
                  widget is BasicChip && widget.label == 'key1:val1',
            ),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(TodoKeyValueTagsItem),
            matching: find.byWidgetPredicate(
              (Widget widget) =>
                  widget is BasicChip && widget.label == 'key2:val2',
            ),
          ),
          findsOneWidget,
        );
      });
      testWidgets('TodoCompletionDateItem (incompleted)', (tester) async {
        await tester.pumpWidget(
          MaterialAppWrapper(
            initTodo: Todo(description: 'Code something'),
          ),
        );
        await tester.pumpAndSettle();
        await tester.dragUntilVisible(
          find.byType(TodoCompletionDateItem),
          find.byType(ListView),
          const Offset(0, -100),
        );
        expect(
          find.descendant(
            of: find.byType(TodoCompletionDateItem),
            matching: find.text('-'),
          ),
          findsOneWidget,
        );
      });
      testWidgets('TodoCompletionDateItem (completed)', (tester) async {
        await tester.pumpWidget(
          MaterialAppWrapper(
            initTodo: Todo(completion: true, description: 'Code something'),
          ),
        );
        await tester.pumpAndSettle();
        await tester.dragUntilVisible(
          find.byType(TodoCompletionDateItem),
          find.byType(ListView),
          const Offset(0, -100),
        );
        final DateTime now = DateTime.now();
        final String today =
            '${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
        expect(
          find.descendant(
            of: find.byType(TodoCompletionDateItem),
            matching: find.text(today),
          ),
          findsOneWidget,
        );
      });
      testWidgets('TodoCreationDateItem', (tester) async {
        await tester.pumpWidget(
          MaterialAppWrapper(
            initTodo: Todo(description: 'Code something'),
          ),
        );
        await tester.pumpAndSettle();
        await tester.dragUntilVisible(
          find.byType(TodoCreationDateItem),
          find.byType(ListView),
          const Offset(0, -100),
        );
        final DateTime now = DateTime.now();
        final String today =
            '${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
        expect(
          find.descendant(
            of: find.byType(TodoCreationDateItem),
            matching: find.text(today),
          ),
          findsOneWidget,
        );
      });
      testWidgets('TodoDueDateItem', (tester) async {
        await tester.pumpWidget(
          MaterialAppWrapper(
            initTodo: Todo(description: 'Code something due:2024-02-27'),
          ),
        );
        await tester.pumpAndSettle();
        await tester.dragUntilVisible(
          find.byType(TodoDueDateItem),
          find.byType(ListView),
          const Offset(0, -100),
        );
        expect(
          find.descendant(
            of: find.byType(TodoDueDateItem),
            matching: find.text('2024-02-27'),
          ),
          findsOneWidget,
        );
        await tester.dragUntilVisible(
          find.byType(TodoKeyValueTagsItem),
          find.byType(ListView),
          const Offset(0, -100),
        );
        expect(
          find.descendant(
            of: find.byType(TodoKeyValueTagsItem),
            matching: find.byWidgetPredicate(
              (Widget widget) =>
                  widget is BasicChip && widget.label == 'due:2024-02-27',
            ),
          ),
          findsOneWidget,
        );
      });
    });

    group('update values', () {
      testWidgets('TodoDescriptionTextField (project)', (tester) async {
        await tester.pumpWidget(const MaterialAppWrapper());
        await tester.pumpAndSettle();
        await tester.dragUntilVisible(
          find.byType(TodoDescriptionTextField),
          find.byType(ListView),
          const Offset(0, -100),
        );

        await tester.enterText(
          find.descendant(
            of: find.byType(TodoDescriptionTextField),
            matching: find.byType(TextFormField),
          ),
          'Code something +project1',
        );
        await tester.pumpAndSettle();

        await tester.dragUntilVisible(
          find.byType(TodoProjectTagsItem),
          find.byType(ListView),
          const Offset(0, -100),
        );
        expect(
          find.descendant(
            of: find.byType(TodoProjectTagsItem),
            matching: find.byWidgetPredicate(
              (Widget widget) =>
                  widget is BasicChip && widget.label == 'project1',
            ),
          ),
          findsOneWidget,
        );
      });
      testWidgets('TodoDescriptionTextField (context)', (tester) async {
        await tester.pumpWidget(const MaterialAppWrapper());
        await tester.pumpAndSettle();
        await tester.dragUntilVisible(
          find.byType(TodoDescriptionTextField),
          find.byType(ListView),
          const Offset(0, -100),
        );

        await tester.enterText(
          find.descendant(
            of: find.byType(TodoDescriptionTextField),
            matching: find.byType(TextFormField),
          ),
          'Code something @context1',
        );
        await tester.pumpAndSettle();

        await tester.dragUntilVisible(
          find.byType(TodoContextTagsItem),
          find.byType(ListView),
          const Offset(0, -100),
        );
        expect(
          find.descendant(
            of: find.byType(TodoContextTagsItem),
            matching: find.byWidgetPredicate(
              (Widget widget) =>
                  widget is BasicChip && widget.label == 'context1',
            ),
          ),
          findsOneWidget,
        );
      });
      testWidgets('TodoDescriptionTextField (key value)', (tester) async {
        await tester.pumpWidget(const MaterialAppWrapper());
        await tester.pumpAndSettle();
        await tester.dragUntilVisible(
          find.byType(TodoDescriptionTextField),
          find.byType(ListView),
          const Offset(0, -100),
        );

        await tester.enterText(
          find.descendant(
            of: find.byType(TodoDescriptionTextField),
            matching: find.byType(TextFormField),
          ),
          'Code something key1:val1',
        );
        await tester.pumpAndSettle();

        await tester.dragUntilVisible(
          find.byType(TodoKeyValueTagsItem),
          find.byType(ListView),
          const Offset(0, -100),
        );
        expect(
          find.descendant(
            of: find.byType(TodoKeyValueTagsItem),
            matching: find.byWidgetPredicate(
              (Widget widget) =>
                  widget is BasicChip && widget.label == 'key1:val1',
            ),
          ),
          findsOneWidget,
        );
      });
      testWidgets('TodoDescriptionTextField (due date)', (tester) async {
        await tester.pumpWidget(const MaterialAppWrapper());
        await tester.pumpAndSettle();
        await tester.dragUntilVisible(
          find.byType(TodoDescriptionTextField),
          find.byType(ListView),
          const Offset(0, -100),
        );

        await tester.enterText(
          find.descendant(
            of: find.byType(TodoDescriptionTextField),
            matching: find.byType(TextFormField),
          ),
          'Code something due:2024-02-27',
        );
        await tester.pumpAndSettle();

        await tester.dragUntilVisible(
          find.byType(TodoDueDateItem),
          find.byType(ListView),
          const Offset(0, -100),
        );
        expect(
          find.descendant(
            of: find.byType(TodoDueDateItem),
            matching: find.text('2024-02-27'),
          ),
          findsOneWidget,
        );
        await tester.dragUntilVisible(
          find.byType(TodoKeyValueTagsItem),
          find.byType(ListView),
          const Offset(0, -100),
        );
        expect(
          find.descendant(
            of: find.byType(TodoKeyValueTagsItem),
            matching: find.byWidgetPredicate(
              (Widget widget) =>
                  widget is BasicChip && widget.label == 'due:2024-02-27',
            ),
          ),
          findsOneWidget,
        );
      });
      testWidgets('TodoPriorityItem', (tester) async {
        await tester.pumpWidget(const MaterialAppWrapper());
        await tester.pumpAndSettle();
        await tester.dragUntilVisible(
          find.byType(TodoPriorityItem),
          find.byType(ListView),
          const Offset(0, -100),
        );

        await tester.tap(find.byType(TodoPriorityItem));
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.byType(TodoPriorityTagDialog));
        await tester.pumpAndSettle();
        await tester.tap(
          find.descendant(
            of: find.byType(TodoPriorityTagDialog),
            matching: find.text('A'),
          ),
        );
        await tester.drag(find.byType(DraggableScrollableSheet),
            const Offset(0, 500)); // Dismiss dialog.
        await tester.pumpAndSettle();

        expect(
          find.descendant(
            of: find.byType(TodoPriorityItem),
            matching: find.text('A'),
          ),
          findsOneWidget,
        );
      });
      testWidgets('TodoProjectTagsItem by tap chip', (tester) async {
        await tester.pumpWidget(
          const MaterialAppWrapper(
            projects: {'project1', 'project2'},
          ),
        );
        await tester.pumpAndSettle();
        await tester.dragUntilVisible(
          find.byType(TodoProjectTagsItem),
          find.byType(ListView),
          const Offset(0, -100),
        );

        await tester.tap(find.byType(TodoProjectTagsItem));
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.byType(TodoProjectTagDialog));
        await tester.pumpAndSettle();
        await tester.tap(
          find.descendant(
            of: find.byType(TodoProjectTagDialog),
            matching: find.text('project1'),
          ),
        );
        await tester.drag(find.byType(DraggableScrollableSheet),
            const Offset(0, 500)); // Dismiss dialog.
        await tester.pumpAndSettle();

        expect(
          find.descendant(
            of: find.byType(TodoProjectTagsItem),
            matching: find.byWidgetPredicate(
              (Widget widget) =>
                  widget is BasicChip && widget.label == 'project1',
            ),
          ),
          findsOneWidget,
        );
      });
      testWidgets('TodoProjectTagsItem by enter in textfield', (tester) async {
        await tester.pumpWidget(
          const MaterialAppWrapper(
            projects: {'project1', 'project2'},
          ),
        );
        await tester.pumpAndSettle();
        await tester.dragUntilVisible(
          find.byType(TodoProjectTagsItem),
          find.byType(ListView),
          const Offset(0, -100),
        );

        await tester.tap(find.byType(TodoProjectTagsItem));
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.byType(TodoProjectTagDialog));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.descendant(
            of: find.byType(TodoProjectTagDialog),
            matching: find.byType(TextFormField),
          ),
          'project3',
        );
        await tester.tap(
          find.descendant(
            of: find.byType(TodoProjectTagDialog),
            matching: find.text('Add'),
          ),
        );
        await tester.pumpAndSettle();
        await tester.drag(find.byType(DraggableScrollableSheet),
            const Offset(0, 500)); // Dismiss dialog.
        await tester.pumpAndSettle();

        expect(
          find.descendant(
            of: find.byType(TodoProjectTagsItem),
            matching: find.byWidgetPredicate(
              (Widget widget) =>
                  widget is BasicChip && widget.label == 'project3',
            ),
          ),
          findsOneWidget,
        );
      });
      testWidgets('TodoContextTagsItem by tap chip', (tester) async {
        await tester.pumpWidget(
          const MaterialAppWrapper(
            contexts: {'context1', 'context2'},
          ),
        );
        await tester.pumpAndSettle();
        await tester.dragUntilVisible(
          find.byType(TodoContextTagsItem),
          find.byType(ListView),
          const Offset(0, -100),
        );

        await tester.tap(find.byType(TodoContextTagsItem));
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.byType(TodoContextTagDialog));
        await tester.pumpAndSettle();
        await tester.tap(
          find.descendant(
            of: find.byType(TodoContextTagDialog),
            matching: find.text('context1'),
          ),
        );
        await tester.drag(find.byType(DraggableScrollableSheet),
            const Offset(0, 500)); // Dismiss dialog.
        await tester.pumpAndSettle();

        expect(
          find.descendant(
            of: find.byType(TodoContextTagsItem),
            matching: find.byWidgetPredicate(
              (Widget widget) =>
                  widget is BasicChip && widget.label == 'context1',
            ),
          ),
          findsOneWidget,
        );
      });
      testWidgets('TodoContextTagsItem by enter in textfield', (tester) async {
        await tester.pumpWidget(
          const MaterialAppWrapper(
            contexts: {'context1', 'context2'},
          ),
        );
        await tester.pumpAndSettle();
        await tester.dragUntilVisible(
          find.byType(TodoContextTagsItem),
          find.byType(ListView),
          const Offset(0, -100),
        );

        await tester.tap(find.byType(TodoContextTagsItem));
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.byType(TodoContextTagDialog));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.descendant(
            of: find.byType(TodoContextTagDialog),
            matching: find.byType(TextFormField),
          ),
          'context3',
        );
        await tester.tap(
          find.descendant(
            of: find.byType(TodoContextTagDialog),
            matching: find.text('Add'),
          ),
        );
        await tester.pumpAndSettle();
        await tester.drag(find.byType(DraggableScrollableSheet),
            const Offset(0, 500)); // Dismiss dialog.
        await tester.pumpAndSettle();

        expect(
          find.descendant(
            of: find.byType(TodoContextTagsItem),
            matching: find.byWidgetPredicate(
              (Widget widget) =>
                  widget is BasicChip && widget.label == 'context3',
            ),
          ),
          findsOneWidget,
        );
      });
      testWidgets('TodoKeyValueTagsItem by tap chip', (tester) async {
        await tester.pumpWidget(
          const MaterialAppWrapper(
            keyValues: {'key1:val1', 'key2:val2'},
          ),
        );
        await tester.pumpAndSettle();
        await tester.dragUntilVisible(
          find.byType(TodoKeyValueTagsItem),
          find.byType(ListView),
          const Offset(0, -200),
        );

        await tester.tap(find.byType(TodoKeyValueTagsItem));
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.byType(TodoKeyValueTagDialog));
        await tester.pumpAndSettle();
        await tester.tap(
          find.descendant(
            of: find.byType(TodoKeyValueTagDialog),
            matching: find.text('key1:val1'),
          ),
        );
        await tester.drag(find.byType(DraggableScrollableSheet),
            const Offset(0, 500)); // Dismiss dialog.
        await tester.pumpAndSettle();

        expect(
          find.descendant(
            of: find.byType(TodoKeyValueTagsItem),
            matching: find.byWidgetPredicate(
              (Widget widget) =>
                  widget is BasicChip && widget.label == 'key1:val1',
            ),
          ),
          findsOneWidget,
        );
      });
      testWidgets('TodoKeyValueTagsItem by enter in textfield', (tester) async {
        await tester.pumpWidget(
          const MaterialAppWrapper(
            keyValues: {'key1:val1', 'key2:val2'},
          ),
        );
        await tester.pumpAndSettle();
        await tester.dragUntilVisible(
          find.byType(TodoKeyValueTagsItem),
          find.byType(ListView),
          const Offset(0, -200),
        );

        await tester.tap(find.byType(TodoKeyValueTagsItem));
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.byType(TodoKeyValueTagDialog));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.descendant(
            of: find.byType(TodoKeyValueTagDialog),
            matching: find.byType(TextFormField),
          ),
          'key3:val3',
        );
        await tester.tap(
          find.descendant(
            of: find.byType(TodoKeyValueTagDialog),
            matching: find.text('Add'),
          ),
        );
        await tester.pumpAndSettle();
        await tester.drag(find.byType(DraggableScrollableSheet),
            const Offset(0, 500)); // Dismiss dialog.
        await tester.pumpAndSettle();

        expect(
          find.descendant(
            of: find.byType(TodoKeyValueTagsItem),
            matching: find.byWidgetPredicate(
              (Widget widget) =>
                  widget is BasicChip && widget.label == 'key3:val3',
            ),
          ),
          findsOneWidget,
        );
      });
      testWidgets('TodoCompletionDateItem (set)', (tester) async {
        await tester.pumpWidget(
          MaterialAppWrapper(
            initTodo: Todo(completion: false, description: 'Code something'),
          ),
        );
        await tester.pumpAndSettle();
        await tester.dragUntilVisible(
          find.byType(TodoCompletionDateItem),
          find.byType(ListView),
          const Offset(0, -100),
        );

        await tester.tap(find.byType(TodoCompletionDateItem));
        await tester.pumpAndSettle();

        final DateTime now = DateTime.now();
        final String today =
            '${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
        expect(
          find.descendant(
            of: find.byType(TodoCompletionDateItem),
            matching: find.text(today),
          ),
          findsOneWidget,
        );
      });
      testWidgets('TodoCompletionDateItem (unset)', (tester) async {
        await tester.pumpWidget(
          MaterialAppWrapper(
            initTodo: Todo(completion: true, description: 'Code something'),
          ),
        );
        await tester.pumpAndSettle();
        await tester.dragUntilVisible(
          find.byType(TodoCompletionDateItem),
          find.byType(ListView),
          const Offset(0, -100),
        );

        await tester.tap(find.byType(TodoCompletionDateItem));
        await tester.pumpAndSettle();

        expect(
          find.descendant(
            of: find.byType(TodoCompletionDateItem),
            matching: find.text('-'),
          ),
          findsOneWidget,
        );
      });
      testWidgets('TodoDueDateItem (set)', (tester) async {
        await tester.pumpWidget(
          MaterialAppWrapper(
            initTodo: Todo(description: 'Code something'),
          ),
        );
        await tester.pumpAndSettle();
        await tester.dragUntilVisible(
          find.byType(TodoDueDateItem),
          find.byType(ListView),
          const Offset(0, -100),
        );

        await tester.tap(find.byType(TodoDueDateItem));
        await tester.pumpAndSettle();

        await tester.tap(
          find.descendant(
            of: find.byType(DatePickerDialog),
            matching: find.text('OK'),
          ),
        );
        await tester.pumpAndSettle();

        final DateTime now = DateTime.now();
        final String today =
            '${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
        expect(
          find.descendant(
            of: find.byType(TodoDueDateItem),
            matching: find.text(today),
          ),
          findsOneWidget,
        );
      });
      testWidgets('TodoDueDateItem (already set)', (tester) async {
        await tester.pumpWidget(
          MaterialAppWrapper(
            initTodo: Todo(description: 'Code something due:2024-02-27'),
          ),
        );
        await tester.pumpAndSettle();
        await tester.dragUntilVisible(
          find.byType(TodoDueDateItem),
          find.byType(ListView),
          const Offset(0, -100),
        );

        await tester.tap(find.byType(TodoDueDateItem));
        await tester.pumpAndSettle();

        await tester.tap(
          find.descendant(
            of: find.byType(DatePickerDialog),
            matching: find.text('OK'),
          ),
        );
        await tester.pumpAndSettle();

        final DateTime initial = DateTime.parse('2024-02-27');
        final String today =
            '${initial.year.toString()}-${initial.month.toString().padLeft(2, '0')}-${initial.day.toString().padLeft(2, '0')}';
        expect(
          find.descendant(
            of: find.byType(TodoDueDateItem),
            matching: find.text(today),
          ),
          findsOneWidget,
        );
      });
      testWidgets('TodoDueDateItem (unset)', (tester) async {
        await tester.pumpWidget(
          MaterialAppWrapper(
            initTodo: Todo(description: 'Code something due:2024-02-27'),
          ),
        );
        await tester.pumpAndSettle();
        await tester.dragUntilVisible(
          find.byType(TodoDueDateItem),
          find.byType(ListView),
          const Offset(0, -100),
        );

        await tester.tap(
          find.descendant(
            of: find.byType(TodoDueDateItem),
            matching: find.byType(IconButton),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.descendant(
            of: find.byType(TodoDueDateItem),
            matching: find.text('-'),
          ),
          findsOneWidget,
        );
      });
    });
  });
}
