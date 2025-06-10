import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/common_widgets/projects_dialog.dart';
import 'package:ntodotxt/data/database.dart';
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

class MaterialAppFilterProjectTagDialog extends StatelessWidget {
  final DatabaseController dbController;

  const MaterialAppFilterProjectTagDialog({
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
                          'result: ${state.filter.projects.toString()}',
                        ),
                        Builder(
                          builder: (BuildContext context) {
                            return TextButton(
                              child: const Text('Open dialog'),
                              onPressed: () async {
                                await FilterProjectTagDialog.dialog(
                                  context: context,
                                  cubit: BlocProvider.of<FilterCubit>(context),
                                  availableTags: {
                                    'project1',
                                    'project2',
                                    'project3'
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

class MaterialAppTodoProjectTagDialog extends StatelessWidget {
  const MaterialAppTodoProjectTagDialog({super.key});

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
                        'result: ${state.todo.projects.toString()}',
                      ),
                      Builder(
                        builder: (BuildContext context) {
                          return TextButton(
                            child: const Text('Open dialog'),
                            onPressed: () async {
                              await TodoProjectTagDialog.dialog(
                                context: context,
                                cubit: BlocProvider.of<TodoCubit>(context),
                                availableTags: {
                                  'project1',
                                  'project2',
                                  'project3'
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

  group('FilterProjectTagDialog', () {
    testWidgets('apply', (tester) async {
      await tester.pumpWidget(const MaterialAppFilterProjectTagDialog());
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
          of: find.byKey(const Key('FilterProjectTagDialog')),
          matching: find.text('project1'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.drag(find.byType(DraggableScrollableSheet),
          const Offset(0, 500)); // Dismiss dialog.
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is Text && widget.data == 'result: {project1}',
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Open dialog'));
      await tester.pumpAndSettle();

      await safeTapByFinder(
        tester,
        find.descendant(
          of: find.byKey(const Key('FilterProjectTagDialog')),
          matching: find.text('project1'),
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

  group('TodoProjectTagDialog', () {
    testWidgets('enter', (tester) async {
      await tester.pumpWidget(const MaterialAppTodoProjectTagDialog());
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
        of: find.byKey(const Key('TodoProjectTagDialog')),
        matching: find.byType(TextFormField),
      );
      await tester.ensureVisible(textField);
      await tester.pumpAndSettle();
      await tester.enterText(textField, 'project99');
      await tester.pumpAndSettle();
      await safeTapByFinder(tester, find.text('Add'));
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byKey(const Key('TodoProjectTagDialog')),
          matching: find.text('project99'),
        ),
        findsOneWidget,
      );

      await tester.drag(find.byType(DraggableScrollableSheet),
          const Offset(0, 500)); // Dismiss dialog.
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is Text && widget.data == 'result: {project99}',
        ),
        findsOneWidget,
      );
    });
    testWidgets('enter (with leading +)', (tester) async {
      await tester.pumpWidget(const MaterialAppTodoProjectTagDialog());
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
        of: find.byKey(const Key('TodoProjectTagDialog')),
        matching: find.byType(TextFormField),
      );
      await tester.ensureVisible(textField);
      await tester.pumpAndSettle();
      await tester.enterText(textField, '+project99');
      await tester.pumpAndSettle();
      await safeTapByFinder(tester, find.text('Add'));
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byKey(const Key('TodoProjectTagDialog')),
          matching: find.text('project99'),
        ),
        findsOneWidget,
      );

      await tester.drag(find.byType(DraggableScrollableSheet),
          const Offset(0, 500)); // Dismiss dialog.
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is Text && widget.data == 'result: {project99}',
        ),
        findsOneWidget,
      );
    });
  });
}
