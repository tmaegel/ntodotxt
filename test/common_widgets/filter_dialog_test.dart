import 'dart:io';

import 'package:file/memory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/common_widgets/filter_dialog.dart';
import 'package:ntodotxt/data/todo/todo_list_api.dart';
import 'package:ntodotxt/domain/todo/todo_list_repository.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_bloc.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_event.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_state.dart';
import 'package:ntodotxt/presentation/todo/widgets/todo_list_widget.dart';
import 'package:ntodotxt/presentation/todo/widgets/todo_tile_widget.dart';

final scaffoldKey = GlobalKey<ScaffoldState>();
const appBarKey = Key("appBar");
const buttonKey = Key("button");
const filterDialogKey = Key("FilterTodoListBottomSheet");
const radioButtonKeyAll = Key('allBottomSheetRadioButton');
const radioButtonKeyCompletedOnly = Key('completedOnlyBottomSheetRadioButton');
const radioButtonKeyIncompletedOnly =
    Key('incompletedOnlyBottomSheetRadioButton');

Future<void> pumpFilterDialog(
  WidgetTester tester,
  TodoListRepository todoListRepository,
) async {
  await tester.pumpWidget(
    BlocProvider(
      create: (BuildContext context) => TodoListBloc(
        todoListRepository: todoListRepository,
      )..add(
          const TodoListSubscriptionRequested(),
        ),
      child: MaterialApp(
        home: Scaffold(
          key: scaffoldKey,
          appBar: AppBar(
            key: appBarKey,
            title: const Text("Test App"),
            actions: <Widget>[
              Builder(
                builder: (context) {
                  return TextButton(
                    key: buttonKey,
                    child: const Text("Show dialog"),
                    onPressed: () async {
                      context.read<TodoListBloc>().add(
                            TodoListFilterChanged(
                              filter:
                                  await showModalBottomSheet<TodoListFilter?>(
                                context: context,
                                builder: (BuildContext context) =>
                                    const FilterTodoListBottomSheet(),
                              ),
                            ),
                          );
                      // await showModalBottomSheet<TodoListFilter?>(
                      //   context: context,
                      //   builder: (BuildContext context) =>
                      //       const FilterTodoListBottomSheet(),
                      // );
                    },
                  );
                },
              ),
            ],
          ),
          body: const SafeArea(
            child: TodoList(),
          ),
        ),
      ),
    ),
  );
}

void main() async {
  List<Todo> todoList = [
    Todo(
      id: 0,
      completion: false,
      creationDate: DateTime.now(),
      description: 'Todo A',
    ),
    Todo(
      id: 1,
      completion: true,
      creationDate: DateTime.now(),
      completionDate: DateTime.now(),
      description: 'Todo B',
    ),
  ];
  MemoryFileSystem fs = MemoryFileSystem();
  File file = fs.file('todo.test');
  await file.create();
  await file.writeAsString(
    todoList.join(Platform.lineTerminator),
    flush: true,
  ); // Initial todos.
  final LocalTodoListApi todoListApi = LocalTodoListApi();
  final TodoListRepository todoListRepository =
      TodoListRepository(todoListApi: todoListApi);
  await todoListRepository.init(file: file);

  testWidgets('Open and close the filter dialog', (tester) async {
    await pumpFilterDialog(tester, todoListRepository);

    expect(find.byKey(filterDialogKey), findsNothing);

    final button = find.byKey(buttonKey);
    await tester.runAsync(() async {
      await tester.tap(button);
    });
    await tester.pumpAndSettle();

    expect(find.byKey(filterDialogKey), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Completed only'), findsOneWidget);
    expect(find.text('Incompleted only'), findsOneWidget);

    Navigator.pop(scaffoldKey.currentContext!);
    await tester.pumpAndSettle();
    expect(find.byKey(filterDialogKey), findsNothing);
  });

  testWidgets('Filter the list by "all"', (tester) async {
    await pumpFilterDialog(tester, todoListRepository);

    final button = find.byKey(buttonKey);
    await tester.runAsync(() async {
      await tester.tap(button);
    });
    await tester.pumpAndSettle();

    final filterDialogButton = find.byKey(filterDialogKey);
    await tester.runAsync(() async {
      await tester.tap(filterDialogButton);
    });
    await tester.pumpAndSettle();

    final radioButton = find.byKey(radioButtonKeyAll);
    expect(radioButton, findsOneWidget);
    await tester.runAsync(() async {
      await tester.tap(radioButton);
    });
    // Close modal manually  because 'all' is already selected.
    Navigator.pop(scaffoldKey.currentContext!);
    await tester.pumpAndSettle();

    expect(find.byType(TodoTile), findsNWidgets(2));
    expect(find.text('Todo A'), findsOneWidget);
    expect(find.text('Todo B'), findsOneWidget);
    expect(find.byKey(filterDialogKey), findsNothing);
  });

  testWidgets('Filter the list by "completed only"', (tester) async {
    await pumpFilterDialog(tester, todoListRepository);

    final button = find.byKey(buttonKey);
    await tester.runAsync(() async {
      await tester.tap(button);
    });
    await tester.pumpAndSettle();

    final filterDialogButton = find.byKey(filterDialogKey);
    await tester.runAsync(() async {
      await tester.tap(filterDialogButton);
    });
    await tester.pumpAndSettle();

    final radioButton = find.byKey(radioButtonKeyCompletedOnly);
    expect(radioButton, findsOneWidget);
    await tester.runAsync(() async {
      await tester.tap(radioButton);
    });
    await tester.pumpAndSettle();

    expect(find.byType(TodoTile), findsNWidgets(1));
    expect(find.text('Todo A'), findsNothing);
    expect(find.text('Todo B'), findsOneWidget);
    expect(find.byKey(filterDialogKey), findsNothing);
  });

  testWidgets('Filter the list by "incompleted only"', (tester) async {
    await pumpFilterDialog(tester, todoListRepository);

    final button = find.byKey(buttonKey);
    await tester.runAsync(() async {
      await tester.tap(button);
    });
    await tester.pumpAndSettle();

    final filterDialogButton = find.byKey(filterDialogKey);
    await tester.runAsync(() async {
      await tester.tap(filterDialogButton);
    });
    await tester.pumpAndSettle();

    final radioButton = find.byKey(radioButtonKeyIncompletedOnly);
    expect(radioButton, findsOneWidget);
    await tester.runAsync(() async {
      await tester.tap(radioButton);
    });
    await tester.pumpAndSettle();

    expect(find.byType(TodoTile), findsNWidgets(1));
    expect(find.text('Todo A'), findsOneWidget);
    expect(find.text('Todo B'), findsNothing);
    expect(find.byKey(filterDialogKey), findsNothing);
  });
}
