import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/common/widget/key_values_dialog.dart';
import 'package:ntodotxt/todo/model/todo_model.dart' show Todo;
import 'package:ntodotxt/todo/state/todo_cubit.dart';
import 'package:ntodotxt/todo/state/todo_state.dart';

class MaterialAppTodoKeyValueTagDialog extends StatelessWidget {
  const MaterialAppTodoKeyValueTagDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => TodoCubit(
        todo: Todo(description: 'Test something'),
      ),
      child: Builder(
        builder: (BuildContext context) {
          return MaterialApp(
            home: Scaffold(
              body: BlocBuilder<TodoCubit, TodoState>(
                builder: (BuildContext context, TodoState state) {
                  return Column(
                    children: [
                      Text(
                        'result: ${state.todo.keyValues.toString()}',
                      ),
                      Builder(
                        builder: (BuildContext context) {
                          return TextButton(
                            child: const Text('Open dialog'),
                            onPressed: () async {
                              await TodoKeyValueTagDialog.dialog(
                                context: context,
                                cubit: BlocProvider.of<TodoCubit>(context),
                                availableTags: {
                                  'key1:val1',
                                  'key2:val2',
                                  'key3:val3'
                                },
                              );
                            },
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

Future safeTapByFinder(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TodoKeyValueTagDialog', () {
    testWidgets('enter', (tester) async {
      await tester.pumpWidget(const MaterialAppTodoKeyValueTagDialog());
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (Widget widget) => widget is Text && widget.data == 'result: {}',
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Open dialog'));
      await tester.pumpAndSettle();

      Finder textField = find.descendant(
        of: find.byKey(const Key('TodoKeyValueTagDialog')),
        matching: find.byType(TextFormField),
      );
      await tester.ensureVisible(textField);
      await tester.pumpAndSettle();
      await tester.enterText(textField, 'foo:bar');
      await tester.pumpAndSettle();
      await safeTapByFinder(tester, find.text('Add'));
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byKey(const Key('TodoKeyValueTagDialog')),
          matching: find.text('foo:bar'),
        ),
        findsOneWidget,
      );

      await tester.drag(find.byType(DraggableScrollableSheet),
          const Offset(0, 500)); // Dismiss dialog.
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is Text && widget.data == 'result: {foo:bar}',
        ),
        findsOneWidget,
      );
    });
  });
}
