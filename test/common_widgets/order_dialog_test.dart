import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/common_widgets/order_dialog.dart';
import 'package:ntodotxt/data/todo/todo_list_api.dart';
import 'package:ntodotxt/domain/todo/todo_list_repository.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_bloc.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_event.dart';
import 'package:ntodotxt/presentation/todo/widgets/todo_list_widget.dart';
import 'package:ntodotxt/presentation/todo/widgets/todo_tile_widget.dart';

final scaffoldKey = GlobalKey<ScaffoldState>();
const appBarKey = Key("appBar");
const buttonKey = Key("button");
const orderDialogKey = Key("orderDialog");
const radioButtonKeyAscending = Key('ascendingRadioButton');
const radioButtonKeyDescending = Key('descendingRadioButton');

Future<void> pumpOrderDialog(
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
                      await showModalBottomSheet<void>(
                        context: context,
                        builder: (BuildContext context) => const OrderDialog(),
                      );
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

void main() {
  final LocalStorageTodoListApi todoListApi = LocalStorageTodoListApi(
    [
      Todo(
        id: 0,
        completion: false,
        creationDate: DateTime.now(),
        description: 'Todo A',
      ),
      Todo(
        id: 1,
        completion: false,
        creationDate: DateTime.now(),
        description: 'Todo B',
      ),
    ],
  );
  final TodoListRepository todoListRepository =
      TodoListRepository(todoListApi: todoListApi);

  testWidgets('Open and close the order dialog', (tester) async {
    await pumpOrderDialog(tester, todoListRepository);

    expect(find.byKey(orderDialogKey), findsNothing);

    final button = find.byKey(buttonKey);
    await tester.runAsync(() async {
      await tester.tap(button);
    });
    await tester.pumpAndSettle();

    expect(find.byKey(orderDialogKey), findsOneWidget);
    expect(find.text('Ascending'), findsOneWidget);
    expect(find.text('Descending'), findsOneWidget);

    Navigator.pop(scaffoldKey.currentContext!);
    await tester.pumpAndSettle();
    expect(find.byKey(orderDialogKey), findsNothing);
  });

  testWidgets('Order the list by "ascending"', (tester) async {
    await pumpOrderDialog(tester, todoListRepository);

    final button = find.byKey(buttonKey);
    await tester.runAsync(() async {
      await tester.tap(button);
    });
    await tester.pumpAndSettle();

    final orderDialogButton = find.byKey(orderDialogKey);
    await tester.runAsync(() async {
      await tester.tap(orderDialogButton);
    });
    await tester.pumpAndSettle();

    final radioButton = find.byKey(radioButtonKeyAscending);
    expect(radioButton, findsOneWidget);
    await tester.runAsync(() async {
      await tester.tap(radioButton);
    });
    // Close modal manually  because 'all' is already selected.
    Navigator.pop(scaffoldKey.currentContext!);
    await tester.pumpAndSettle();

    expect(find.byType(TodoTile), findsNWidgets(2));
    Iterable<TodoTile> todoTiles =
        tester.widgetList<TodoTile>(find.byType(TodoTile));
    expect(todoTiles.elementAt(0).todo.description, "Todo A");
    expect(todoTiles.elementAt(1).todo.description, "Todo B");
    expect(find.byKey(orderDialogKey), findsNothing);
  });

  testWidgets('Order the list by "descending"', (tester) async {
    await pumpOrderDialog(tester, todoListRepository);

    final button = find.byKey(buttonKey);
    await tester.runAsync(() async {
      await tester.tap(button);
    });
    await tester.pumpAndSettle();

    final orderDialogButton = find.byKey(orderDialogKey);
    await tester.runAsync(() async {
      await tester.tap(orderDialogButton);
    });
    await tester.pumpAndSettle();

    final radioButton = find.byKey(radioButtonKeyDescending);
    expect(radioButton, findsOneWidget);
    await tester.runAsync(() async {
      await tester.tap(radioButton);
    });
    await tester.pumpAndSettle();

    expect(find.byType(TodoTile), findsNWidgets(2));
    Iterable<TodoTile> todoTiles =
        tester.widgetList<TodoTile>(find.byType(TodoTile));
    expect(todoTiles.elementAt(0).todo.description, "Todo B");
    expect(todoTiles.elementAt(1).todo.description, "Todo A");
    expect(find.byKey(orderDialogKey), findsNothing);
  });
}
