import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/common_widgets/chip.dart';
import 'package:ntodotxt/common_widgets/contexts_dialog.dart';
import 'package:ntodotxt/common_widgets/filter_dialog.dart';
import 'package:ntodotxt/common_widgets/group_by_dialog.dart';
import 'package:ntodotxt/common_widgets/order_dialog.dart';
import 'package:ntodotxt/common_widgets/priorities_dialog.dart';
import 'package:ntodotxt/common_widgets/projects_dialog.dart';
import 'package:ntodotxt/data/filter/filter_controller.dart';
import 'package:ntodotxt/data/settings/setting_controller.dart';
import 'package:ntodotxt/domain/filter/filter_model.dart';
import 'package:ntodotxt/domain/filter/filter_repository.dart';
import 'package:ntodotxt/domain/settings/setting_repository.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/presentation/filter/states/filter_cubit.dart';
import 'package:ntodotxt/presentation/filter/states/filter_state.dart';
import 'package:ntodotxt/presentation/filter/widgets/filter_chip.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class BlocAppWrapper extends StatelessWidget {
  final Widget child;
  final Filter filter;
  final String databasePath = inMemoryDatabasePath;

  const BlocAppWrapper({
    required this.child,
    required this.filter,
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
      child: BlocProvider<FilterCubit>(
        create: (BuildContext context) => FilterCubit(
          settingRepository: context.read<SettingRepository>(),
          filterRepository: context.read<FilterRepository>(),
          filter: filter,
        ),
        child: Builder(
          builder: (BuildContext context) {
            return BlocBuilder<FilterCubit, FilterState>(
              builder: (BuildContext context, FilterState state) {
                return MaterialApp(home: Scaffold(body: child));
              },
            );
          },
        ),
      ),
    );
  }
}

void main() {
  group('FilterOrderChip', () {
    testWidgets('ascending', (tester) async {
      await tester.pumpWidget(
        const BlocAppWrapper(
          filter: Filter(
            order: ListOrder.ascending,
          ),
          child: FilterOrderChip(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('asc'), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_up), findsOneWidget);
      expect(
        find.byWidgetPredicate((Widget widget) =>
            widget is GenericActionChip && widget.selected == false),
        findsOneWidget,
      );
    });
    testWidgets('descending', (tester) async {
      await tester.pumpWidget(
        const BlocAppWrapper(
          filter: Filter(
            order: ListOrder.descending,
          ),
          child: FilterOrderChip(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('desc'), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
      expect(
        find.byWidgetPredicate((Widget widget) =>
            widget is GenericActionChip && widget.selected == false),
        findsOneWidget,
      );
    });
    testWidgets('ascending changed', (tester) async {
      await tester.pumpWidget(
        const BlocAppWrapper(
          filter: Filter(
            order: ListOrder.ascending,
          ),
          child: FilterOrderChip(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FilterOrderChip));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(FilterStateOrderDialog));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Descending'));
      await tester.pumpAndSettle();

      expect(find.text('desc'), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
      expect(
        find.byWidgetPredicate((Widget widget) =>
            widget is GenericActionChip && widget.selected == true),
        findsOneWidget,
      );
    });
    testWidgets('descending changed', (tester) async {
      await tester.pumpWidget(
        const BlocAppWrapper(
          filter: Filter(
            order: ListOrder.descending,
          ),
          child: FilterOrderChip(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FilterOrderChip));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(FilterStateOrderDialog));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ascending'));
      await tester.pumpAndSettle();

      expect(find.text('asc'), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_up), findsOneWidget);
      expect(
        find.byWidgetPredicate((Widget widget) =>
            widget is GenericActionChip && widget.selected == true),
        findsOneWidget,
      );
    });
  });

  group('FilterFilterChip', () {
    testWidgets('all', (tester) async {
      await tester.pumpWidget(
        const BlocAppWrapper(
          filter: Filter(
            filter: ListFilter.all,
          ),
          child: FilterFilterChip(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('all'), findsOneWidget);
      expect(find.byIcon(Icons.filter_list), findsOneWidget);
      expect(
        find.byWidgetPredicate((Widget widget) =>
            widget is GenericActionChip && widget.selected == false),
        findsOneWidget,
      );
    });
    testWidgets('completed', (tester) async {
      await tester.pumpWidget(
        const BlocAppWrapper(
          filter: Filter(
            filter: ListFilter.completedOnly,
          ),
          child: FilterFilterChip(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('completed'), findsOneWidget);
      expect(find.byIcon(Icons.done_all), findsOneWidget);
      expect(
        find.byWidgetPredicate((Widget widget) =>
            widget is GenericActionChip && widget.selected == false),
        findsOneWidget,
      );
    });
    testWidgets('incompleted', (tester) async {
      await tester.pumpWidget(
        const BlocAppWrapper(
          filter: Filter(
            filter: ListFilter.incompletedOnly,
          ),
          child: FilterFilterChip(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('incompleted'), findsOneWidget);
      expect(find.byIcon(Icons.remove_done), findsOneWidget);
      expect(
        find.byWidgetPredicate((Widget widget) =>
            widget is GenericActionChip && widget.selected == false),
        findsOneWidget,
      );
    });
    testWidgets('update', (tester) async {
      await tester.pumpWidget(
        const BlocAppWrapper(
          filter: Filter(
            filter: ListFilter.completedOnly,
          ),
          child: FilterFilterChip(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FilterFilterChip));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(FilterStateFilterDialog));
      await tester.pumpAndSettle();
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();

      expect(find.text('all'), findsOneWidget);
      expect(find.byIcon(Icons.filter_list), findsOneWidget);
      expect(
        find.byWidgetPredicate((Widget widget) =>
            widget is GenericActionChip && widget.selected == true),
        findsOneWidget,
      );
    });
  });

  group('FilterGroupChip', () {
    testWidgets('none', (tester) async {
      await tester.pumpWidget(
        const BlocAppWrapper(
          filter: Filter(
            group: ListGroup.none,
          ),
          child: FilterGroupChip(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('none'), findsOneWidget);
      expect(find.byIcon(Icons.workspaces_outlined), findsOneWidget);
      expect(
        find.byWidgetPredicate((Widget widget) =>
            widget is GenericActionChip && widget.selected == false),
        findsOneWidget,
      );
    });
    testWidgets('upcoming', (tester) async {
      await tester.pumpWidget(
        const BlocAppWrapper(
          filter: Filter(
            group: ListGroup.upcoming,
          ),
          child: FilterGroupChip(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('upcoming'), findsOneWidget);
      expect(find.byIcon(Icons.workspaces_outlined), findsOneWidget);
      expect(
        find.byWidgetPredicate((Widget widget) =>
            widget is GenericActionChip && widget.selected == false),
        findsOneWidget,
      );
    });
    testWidgets('priority', (tester) async {
      await tester.pumpWidget(
        const BlocAppWrapper(
          filter: Filter(
            group: ListGroup.priority,
          ),
          child: FilterGroupChip(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('priority'), findsOneWidget);
      expect(find.byIcon(Icons.workspaces_outlined), findsOneWidget);
      expect(
        find.byWidgetPredicate((Widget widget) =>
            widget is GenericActionChip && widget.selected == false),
        findsOneWidget,
      );
    });
    testWidgets('project', (tester) async {
      await tester.pumpWidget(
        const BlocAppWrapper(
          filter: Filter(
            group: ListGroup.project,
          ),
          child: FilterGroupChip(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('project'), findsOneWidget);
      expect(find.byIcon(Icons.workspaces_outlined), findsOneWidget);
      expect(
        find.byWidgetPredicate((Widget widget) =>
            widget is GenericActionChip && widget.selected == false),
        findsOneWidget,
      );
    });
    testWidgets('context', (tester) async {
      await tester.pumpWidget(
        const BlocAppWrapper(
          filter: Filter(
            group: ListGroup.context,
          ),
          child: FilterGroupChip(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('context'), findsOneWidget);
      expect(find.byIcon(Icons.workspaces_outlined), findsOneWidget);
      expect(
        find.byWidgetPredicate((Widget widget) =>
            widget is GenericActionChip && widget.selected == false),
        findsOneWidget,
      );
    });
    testWidgets('update', (tester) async {
      await tester.pumpWidget(
        const BlocAppWrapper(
          filter: Filter(
            group: ListGroup.none,
          ),
          child: FilterGroupChip(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FilterGroupChip));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(FilterStateGroupDialog));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Priority'));
      await tester.pumpAndSettle();

      expect(find.text('priority'), findsOneWidget);
      expect(find.byIcon(Icons.workspaces), findsOneWidget);
      expect(
        find.byWidgetPredicate((Widget widget) =>
            widget is GenericActionChip && widget.selected == true),
        findsOneWidget,
      );
    });
  });

  group('FilterPrioritiesChip', () {
    testWidgets('default', (tester) async {
      await tester.pumpWidget(
        const BlocAppWrapper(
          filter: Filter(
            priorities: {},
          ),
          child: FilterPrioritiesChip(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('priorities'), findsOneWidget);
      expect(find.byIcon(Icons.flag_outlined), findsOneWidget);
      expect(
        find.byWidgetPredicate((Widget widget) =>
            widget is GenericActionChip && widget.selected == false),
        findsOneWidget,
      );
    });
    testWidgets('update', (tester) async {
      await tester.pumpWidget(
        const BlocAppWrapper(
          filter: Filter(
            priorities: {Priority.A},
          ),
          child: FilterPrioritiesChip(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FilterPrioritiesChip));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(FilterPriorityTagDialog));
      await tester.pumpAndSettle();
      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(DraggableScrollableSheet),
          const Offset(0, 500)); // Dismiss dialog.
      await tester.pumpAndSettle();

      expect(find.text('priorities'), findsOneWidget);
      expect(find.byIcon(Icons.flag), findsOneWidget);
      expect(
        find.byWidgetPredicate((Widget widget) =>
            widget is GenericActionChip && widget.selected == true),
        findsOneWidget,
      );
    });
  });

  group('FilterProjectsChip', () {
    testWidgets('default', (tester) async {
      await tester.pumpWidget(
        const BlocAppWrapper(
          filter: Filter(
            projects: {},
          ),
          child: FilterProjectsChip(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('projects'), findsOneWidget);
      expect(find.byIcon(Icons.rocket_launch_outlined), findsOneWidget);
      expect(
        find.byWidgetPredicate((Widget widget) =>
            widget is GenericActionChip && widget.selected == false),
        findsOneWidget,
      );
    });
    testWidgets('update', (tester) async {
      await tester.pumpWidget(
        const BlocAppWrapper(
          filter: Filter(
            projects: {'project1', 'project2'},
          ),
          child: FilterProjectsChip(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FilterProjectsChip));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(FilterProjectTagDialog));
      await tester.pumpAndSettle();
      await tester.tap(find.text('project2'));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(DraggableScrollableSheet),
          const Offset(0, 500)); // Dismiss dialog.
      await tester.pumpAndSettle();

      expect(find.text('projects'), findsOneWidget);
      expect(find.byIcon(Icons.rocket_launch), findsOneWidget);
      expect(
        find.byWidgetPredicate((Widget widget) =>
            widget is GenericActionChip && widget.selected == true),
        findsOneWidget,
      );
    });
  });

  group('FilterContextsChip', () {
    testWidgets('default', (tester) async {
      await tester.pumpWidget(
        const BlocAppWrapper(
          filter: Filter(
            contexts: {},
          ),
          child: FilterContextsChip(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('contexts'), findsOneWidget);
      expect(find.byIcon(Icons.tag), findsOneWidget);
      expect(
        find.byWidgetPredicate((Widget widget) =>
            widget is GenericActionChip && widget.selected == false),
        findsOneWidget,
      );
    });
    testWidgets('update', (tester) async {
      await tester.pumpWidget(
        const BlocAppWrapper(
          filter: Filter(
            contexts: {'context1', 'context2'},
          ),
          child: FilterContextsChip(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FilterContextsChip));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(FilterContextTagDialog));
      await tester.pumpAndSettle();
      await tester.tap(find.text('context2'));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(DraggableScrollableSheet),
          const Offset(0, 500)); // Dismiss dialog.
      await tester.pumpAndSettle();

      expect(find.text('contexts'), findsOneWidget);
      expect(find.byIcon(Icons.tag), findsOneWidget);
      expect(
        find.byWidgetPredicate((Widget widget) =>
            widget is GenericActionChip && widget.selected == true),
        findsOneWidget,
      );
    });
  });
}
