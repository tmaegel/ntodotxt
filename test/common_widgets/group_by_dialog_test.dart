import 'dart:io';

import 'package:file/memory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/common_widgets/group_by_dialog.dart';
import 'package:ntodotxt/data/todo/todo_list_api.dart';
import 'package:ntodotxt/domain/todo/todo_list_repository.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_bloc.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_event.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_state.dart';
import 'package:ntodotxt/presentation/todo/widgets/todo_list_widget.dart';

final scaffoldKey = GlobalKey<ScaffoldState>();
const appBarKey = Key("appBar");
const buttonKey = Key("button");
const groupbyDialogKey = Key("GroupByTodoListBottomSheet");
const radioButtonKeyUpcoming = Key('upcomingBottomSheetRadioButton');
const radioButtonKeyPriority = Key('priorityBottomSheetRadioButton');
const radioButtonKeyProject = Key('projectBottomSheetRadioButton');
const radioButtonKeyContext = Key('contextBottomSheetRadioButton');

Future<void> pumpGroupByBottomSheet(
  WidgetTester tester,
  TodoListRepository repository,
) async {
  await tester.pumpWidget(
    BlocProvider(
      create: (BuildContext context) => TodoListBloc(
        repository: repository,
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
                            TodoListGroupByChanged(
                              group:
                                  await showModalBottomSheet<TodoListGroupBy?>(
                                context: context,
                                builder: (BuildContext context) =>
                                    const GroupByTodoListBottomSheet(),
                              ),
                            ),
                          );
                      // await showModalBottomSheet<TodoListGroupBy?>(
                      //   context: context,
                      //   builder: (BuildContext context) =>
                      //       const GroupByTodoListBottomSheet(),
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
      creationDate: DateTime.now(),
      description: 'Todo without priority',
    ),
    Todo(
      priority: 'A',
      creationDate: DateTime.now(),
      description: 'Todo with priority',
    ),
    Todo(
      creationDate: DateTime.now(),
      description: 'Todo with project',
      projects: const {'projecttag'},
    ),
    Todo(
      creationDate: DateTime.now(),
      description: 'Todo with context',
      contexts: const {'contexttag'},
    ),
    Todo(
      completion: true,
      creationDate: DateTime.now(),
      completionDate: DateTime.now(),
      description: 'Todo (completed)',
    ),
  ];
  final MemoryFileSystem fs = MemoryFileSystem();
  File file = fs.file('todo.test');
  await file.create();
  await file.writeAsString(
    todoList.join(Platform.lineTerminator),
    flush: true,
  ); // Initial todos.
  final LocalTodoListApi api = LocalTodoListApi(todoFile: file);
  final TodoListRepository repository = TodoListRepository(api: api);

  testWidgets('Open and close the group by dialog (default)', (tester) async {
    await pumpGroupByBottomSheet(tester, repository);

    expect(find.byKey(groupbyDialogKey), findsNothing);

    final button = find.byKey(buttonKey);
    await tester.runAsync(() async {
      await tester.tap(button);
    });
    await tester.pumpAndSettle();

    expect(find.byKey(groupbyDialogKey), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(GroupByTodoListBottomSheet),
        matching: find.text('Upcoming'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(GroupByTodoListBottomSheet),
        matching: find.text('Priority'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(GroupByTodoListBottomSheet),
        matching: find.text('Project'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(GroupByTodoListBottomSheet),
        matching: find.text('Context'),
      ),
      findsOneWidget,
    );

    Navigator.pop(scaffoldKey.currentContext!);
    await tester.pumpAndSettle();

    expect(find.byKey(groupbyDialogKey), findsNothing);

    expect(
      find.byWidgetPredicate(
        (Widget widget) =>
            widget is TodoListSection && widget.title == 'Deadline passed',
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (Widget widget) => widget is TodoListSection && widget.title == 'Today',
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (Widget widget) =>
            widget is TodoListSection && widget.title == 'Upcoming',
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (Widget widget) => widget is TodoListSection && widget.title == 'Done',
      ),
      findsOneWidget,
    );
  });

  testWidgets('Group by the list by "priority"', (tester) async {
    await pumpGroupByBottomSheet(tester, repository);

    final button = find.byKey(buttonKey);
    await tester.runAsync(() async {
      await tester.tap(button);
    });
    await tester.pumpAndSettle();

    final groupbyDialogButton = find.byKey(groupbyDialogKey);
    await tester.runAsync(() async {
      await tester.tap(groupbyDialogButton);
    });
    await tester.pumpAndSettle();

    final radioButton = find.byKey(radioButtonKeyPriority);
    expect(radioButton, findsOneWidget);
    await tester.runAsync(() async {
      await tester.tap(radioButton);
    });
    await tester.pumpAndSettle();

    expect(find.byKey(groupbyDialogKey), findsNothing);

    expect(
      find.byWidgetPredicate(
        (Widget widget) => widget is TodoListSection && widget.title == 'A',
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (Widget widget) =>
            widget is TodoListSection && widget.title == 'No priority',
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (Widget widget) => widget is TodoListSection && widget.title == 'Done',
      ),
      findsOneWidget,
    );
  });

  testWidgets('Group by the list by "project"', (tester) async {
    await pumpGroupByBottomSheet(tester, repository);

    final button = find.byKey(buttonKey);
    await tester.runAsync(() async {
      await tester.tap(button);
    });
    await tester.pumpAndSettle();

    final groupbyDialogButton = find.byKey(groupbyDialogKey);
    await tester.runAsync(() async {
      await tester.tap(groupbyDialogButton);
    });
    await tester.pumpAndSettle();

    final radioButton = find.byKey(radioButtonKeyProject);
    expect(radioButton, findsOneWidget);
    await tester.runAsync(() async {
      await tester.tap(radioButton);
    });
    await tester.pumpAndSettle();

    expect(find.byKey(groupbyDialogKey), findsNothing);

    expect(
      find.byWidgetPredicate(
        (Widget widget) =>
            widget is TodoListSection && widget.title == 'projecttag',
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (Widget widget) =>
            widget is TodoListSection && widget.title == 'No project',
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (Widget widget) => widget is TodoListSection && widget.title == 'Done',
      ),
      findsOneWidget,
    );
  });

  testWidgets('Group by the list by "context"', (tester) async {
    await pumpGroupByBottomSheet(tester, repository);

    final button = find.byKey(buttonKey);
    await tester.runAsync(() async {
      await tester.tap(button);
    });
    await tester.pumpAndSettle();

    final groupbyDialogButton = find.byKey(groupbyDialogKey);
    await tester.runAsync(() async {
      await tester.tap(groupbyDialogButton);
    });
    await tester.pumpAndSettle();

    final radioButton = find.byKey(radioButtonKeyContext);
    expect(radioButton, findsOneWidget);
    await tester.runAsync(() async {
      await tester.tap(radioButton);
    });
    await tester.pumpAndSettle();

    expect(find.byKey(groupbyDialogKey), findsNothing);

    expect(
      find.byWidgetPredicate(
        (Widget widget) =>
            widget is TodoListSection && widget.title == 'contexttag',
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (Widget widget) =>
            widget is TodoListSection && widget.title == 'No context',
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (Widget widget) => widget is TodoListSection && widget.title == 'Done',
      ),
      findsOneWidget,
    );
  });
}
