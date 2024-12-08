import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/common_widgets/priorities_dialog.dart';
import 'package:ntodotxt/data/filter/filter_controller.dart';
import 'package:ntodotxt/data/settings/setting_controller.dart';
import 'package:ntodotxt/domain/filter/filter_model.dart' show Filter;
import 'package:ntodotxt/domain/filter/filter_repository.dart';
import 'package:ntodotxt/domain/settings/setting_repository.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart' show Priority, Todo;
import 'package:ntodotxt/presentation/filter/states/filter_cubit.dart';
import 'package:ntodotxt/presentation/filter/states/filter_state.dart';
import 'package:ntodotxt/presentation/todo/states/todo_cubit.dart';
import 'package:ntodotxt/presentation/todo/states/todo_state.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class MaterialAppFilterPriorityTagDialog extends StatelessWidget {
  final String databasePath;

  const MaterialAppFilterPriorityTagDialog({
    this.databasePath = inMemoryDatabasePath,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SettingRepository>(
          create: (BuildContext context) => SettingRepository(
            SettingController(databasePath),
          ),
        ),
        RepositoryProvider<FilterRepository>(
          create: (BuildContext context) => FilterRepository(
            FilterController(databasePath),
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
  final String databasePath;

  const MaterialAppTodoPriorityTagDialog({
    this.databasePath = inMemoryDatabasePath,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SettingRepository>(
          create: (BuildContext context) => SettingRepository(
            SettingController(databasePath),
          ),
        ),
        RepositoryProvider<FilterRepository>(
          create: (BuildContext context) => FilterRepository(
            FilterController(databasePath),
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
