import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/common/widget/priorities_dialog.dart';
import 'package:ntodotxt/database/controller/database.dart';
import 'package:ntodotxt/filter/controller/filter_controller.dart';
import 'package:ntodotxt/filter/model/filter_model.dart' show Filter;
import 'package:ntodotxt/filter/repository/filter_repository.dart';
import 'package:ntodotxt/filter/state/filter_cubit.dart';
import 'package:ntodotxt/filter/state/filter_state.dart';
import 'package:ntodotxt/setting/controller/setting_controller.dart';
import 'package:ntodotxt/setting/repository/setting_repository.dart';
import 'package:ntodotxt/todo/model/todo_model.dart' show Priority, Todo;
import 'package:ntodotxt/todo/state/todo_cubit.dart';
import 'package:ntodotxt/todo/state/todo_state.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class MaterialAppFilterPriorityTagDialog extends StatelessWidget {
  final DatabaseController dbController;

  const MaterialAppFilterPriorityTagDialog({
    this.dbController = const DatabaseController(inMemoryDatabasePath),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SettingRepository>(
          create: (BuildContext context) => SettingRepository(
            SettingController(dbController),
          ),
        ),
        RepositoryProvider<FilterRepository>(
          create: (BuildContext context) => FilterRepository(
            FilterController(dbController),
          ),
        ),
      ],
      child: BlocProvider(
        create: (BuildContext context) => FilterCubit(
          settingRepository: context.read<SettingRepository>(),
          filterRepository: context.read<FilterRepository>(),
          filter: const Filter(),
        ),
        child: Builder(
          builder: (BuildContext context) {
            return MaterialApp(
              home: Scaffold(
                body: BlocBuilder<FilterCubit, FilterState>(
                  builder: (BuildContext context, FilterState state) {
                    return Column(
                      children: [
                        Text(
                          'result: ${state.filter.priorities.toString()}',
                        ),
                        Builder(
                          builder: (BuildContext context) {
                            return TextButton(
                              child: const Text('Open dialog'),
                              onPressed: () async {
                                await FilterPriorityTagDialog.dialog(
                                  context: context,
                                  cubit: BlocProvider.of<FilterCubit>(context),
                                  availableTags: {
                                    Priority.A,
                                    Priority.B,
                                    Priority.C
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
      ),
    );
  }
}

class MaterialAppTodoPriorityTagDialog extends StatelessWidget {
  final DatabaseController dbController;

  const MaterialAppTodoPriorityTagDialog({
    this.dbController = const DatabaseController(inMemoryDatabasePath),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SettingRepository>(
          create: (BuildContext context) => SettingRepository(
            SettingController(dbController),
          ),
        ),
        RepositoryProvider<FilterRepository>(
          create: (BuildContext context) => FilterRepository(
            FilterController(dbController),
          ),
        ),
      ],
      child: BlocProvider(
        create: (BuildContext context) => TodoCubit(
          todo: Todo(),
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
                          'result: ${state.todo.priority.toString()}',
                        ),
                        Builder(
                          builder: (BuildContext context) {
                            return TextButton(
                              child: const Text('Open dialog'),
                              onPressed: () async {
                                await TodoPriorityTagDialog.dialog(
                                  context: context,
                                  cubit: BlocProvider.of<TodoCubit>(context),
                                  availableTags: {
                                    Priority.A,
                                    Priority.B,
                                    Priority.C
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

  group('FilterPriorityTagDialog', () {
    testWidgets('set & unset', (tester) async {
      await tester.pumpWidget(const MaterialAppFilterPriorityTagDialog());
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (Widget widget) => widget is Text && widget.data == 'result: {}',
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Open dialog'));
      await tester.pumpAndSettle();

      await safeTapByFinder(
        tester,
        find.descendant(
          of: find.byKey(const Key('FilterPriorityTagDialog')),
          matching: find.text('A'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.drag(find.byType(DraggableScrollableSheet),
          const Offset(0, 500)); // Dismiss dialog.
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is Text && widget.data == 'result: {Priority.A}',
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Open dialog'));
      await tester.pumpAndSettle();

      await safeTapByFinder(
        tester,
        find.descendant(
          of: find.byKey(const Key('FilterPriorityTagDialog')),
          matching: find.text('A'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.drag(find.byType(DraggableScrollableSheet),
          const Offset(0, 500)); // Dismiss dialog.
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (Widget widget) => widget is Text && widget.data == 'result: {}',
        ),
        findsOneWidget,
      );
    });
  });

  group('TodoPriorityTagDialog', () {
    testWidgets('set & unset', (tester) async {
      await tester.pumpWidget(const MaterialAppTodoPriorityTagDialog());
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is Text && widget.data == 'result: Priority.none',
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Open dialog'));
      await tester.pumpAndSettle();

      await safeTapByFinder(
        tester,
        find.descendant(
          of: find.byKey(const Key('TodoPriorityTagDialog')),
          matching: find.text('A'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.drag(find.byType(DraggableScrollableSheet),
          const Offset(0, 500)); // Dismiss dialog.
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is Text && widget.data == 'result: Priority.A',
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Open dialog'));
      await tester.pumpAndSettle();

      await safeTapByFinder(
        tester,
        find.descendant(
          of: find.byKey(const Key('TodoPriorityTagDialog')),
          matching: find.text('A'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.drag(find.byType(DraggableScrollableSheet),
          const Offset(0, 500)); // Dismiss dialog.
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is Text && widget.data == 'result: Priority.none',
        ),
        findsOneWidget,
      );
    });
  });
}
