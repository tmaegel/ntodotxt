import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/common_widgets/contexts_dialog.dart';
import 'package:ntodotxt/data/filter/filter_controller.dart';
import 'package:ntodotxt/data/settings/setting_controller.dart';
import 'package:ntodotxt/domain/filter/filter_model.dart' show Filter;
import 'package:ntodotxt/domain/filter/filter_repository.dart';
import 'package:ntodotxt/domain/settings/setting_repository.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart' show Todo;
import 'package:ntodotxt/presentation/filter/states/filter_cubit.dart';
import 'package:ntodotxt/presentation/filter/states/filter_state.dart';
import 'package:ntodotxt/presentation/todo/states/todo_cubit.dart';
import 'package:ntodotxt/presentation/todo/states/todo_state.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class MaterialAppFilterContextTagDialog extends StatelessWidget {
  final String databasePath;

  const MaterialAppFilterContextTagDialog({
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
                          'result: ${state.filter.contexts.toString()}',
                        ),
                        Builder(
                          builder: (BuildContext context) {
                            return TextButton(
                              child: const Text('Open dialog'),
                              onPressed: () async {
                                await FilterContextTagDialog.dialog(
                                  context: context,
                                  cubit: BlocProvider.of<FilterCubit>(context),
                                  availableTags: {
                                    'context1',
                                    'context2',
                                    'context3'
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

class MaterialAppTodoContextTagDialog extends StatelessWidget {
  const MaterialAppTodoContextTagDialog({super.key});

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
                        'result: ${state.todo.contexts.toString()}',
                      ),
                      Builder(
                        builder: (BuildContext context) {
                          return TextButton(
                            child: const Text('Open dialog'),
                            onPressed: () async {
                              await TodoContextTagDialog.dialog(
                                context: context,
                                cubit: BlocProvider.of<TodoCubit>(context),
                                availableTags: {
                                  'context1',
                                  'context2',
                                  'context3'
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

  group('FilterContextTagDialog', () {
    testWidgets('apply', (tester) async {
      await tester.pumpWidget(const MaterialAppFilterContextTagDialog());
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
          of: find.byKey(const Key('FilterContextTagDialog')),
          matching: find.text('context1'),
        ),
      );
      await tester.pumpAndSettle();
      await safeTapByFinder(tester, find.text('Apply'));
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is Text && widget.data == 'result: {context1}',
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Open dialog'));
      await tester.pumpAndSettle();

      await safeTapByFinder(
        tester,
        find.descendant(
          of: find.byKey(const Key('FilterContextTagDialog')),
          matching: find.text('context1'),
        ),
      );
      await tester.pumpAndSettle();
      await safeTapByFinder(tester, find.text('Apply'));
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (Widget widget) => widget is Text && widget.data == 'result: {}',
        ),
        findsOneWidget,
      );
    });
  });

  group('TodoContextTagDialog', () {
    testWidgets('enter', (tester) async {
      await tester.pumpWidget(const MaterialAppTodoContextTagDialog());
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
        of: find.byKey(const Key('TodoContextTagDialog')),
        matching: find.byType(TextFormField),
      );
      await tester.ensureVisible(textField);
      await tester.pumpAndSettle();
      await tester.enterText(textField, 'context99');
      await tester.pumpAndSettle();
      await safeTapByFinder(tester, find.text('Add'));
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byKey(const Key('TodoContextTagDialog')),
          matching: find.text('context99'),
        ),
        findsOneWidget,
      );

      await safeTapByFinder(tester, find.text('Apply'));
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is Text && widget.data == 'result: {context99}',
        ),
        findsOneWidget,
      );
    });
    testWidgets('enter (with leading @)', (tester) async {
      await tester.pumpWidget(const MaterialAppTodoContextTagDialog());
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
        of: find.byKey(const Key('TodoContextTagDialog')),
        matching: find.byType(TextFormField),
      );
      await tester.ensureVisible(textField);
      await tester.pumpAndSettle();
      await tester.enterText(textField, '@context99');
      await tester.pumpAndSettle();
      await safeTapByFinder(tester, find.text('Add'));
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byKey(const Key('TodoContextTagDialog')),
          matching: find.text('context99'),
        ),
        findsOneWidget,
      );

      await safeTapByFinder(tester, find.text('Apply'));
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is Text && widget.data == 'result: {context99}',
        ),
        findsOneWidget,
      );
    });
  });
}
