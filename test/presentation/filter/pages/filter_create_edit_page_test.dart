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
import 'package:ntodotxt/presentation/filter/pages/filter_create_edit_page.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class BlocRepositoryWrapper extends StatelessWidget {
  final Filter? initFilter;
  final Set<String> projects;
  final Set<String> contexts;

  const BlocRepositoryWrapper({
    this.initFilter,
    this.projects = const {},
    this.contexts = const {},
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const String databasePath = inMemoryDatabasePath;
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
      child: MaterialApp(
        home: FilterCreateEditPage(
          initFilter: initFilter,
          projects: projects,
          contexts: contexts,
        ),
      ),
    );
  }
}

void main() {
  group('FilterCreateEditPage', () {
    group('narrow view', () {
      group('create mode', () {
        testWidgets('found no DeleteFilterIconButton', (tester) async {
          // Increase size to ensure all elements in list are visible.
          tester.view.physicalSize = const Size(400, 800);
          tester.view.devicePixelRatio = 1.0;

          await tester.pumpWidget(const BlocRepositoryWrapper());
          await tester.pumpAndSettle();
          expect(
            find.byType(DeleteFilterIconButton),
            findsNothing,
          );

          // resets the screen to its original size after the test end
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
        });
      });
      group('edit mode', () {
        testWidgets('found DeleteFilterIconButton', (tester) async {
          // Increase size to ensure all elements in list are visible.
          tester.view.physicalSize = const Size(400, 800);
          tester.view.devicePixelRatio = 1.0;

          await tester.pumpWidget(
            BlocRepositoryWrapper(
              initFilter: const Filter().copyWith(name: 'filter'),
            ),
          );
          await tester.pumpAndSettle();
          expect(
            find.byType(DeleteFilterIconButton),
            findsOneWidget,
          );

          // resets the screen to its original size after the test end
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
        });
      });
      testWidgets('found no SaveFilterIconButton', (tester) async {
        // Increase size to ensure all elements in list are visible.
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(const BlocRepositoryWrapper());
        await tester.pumpAndSettle();
        expect(
          find.byType(SaveFilterIconButton),
          findsNothing,
        );

        // resets the screen to its original size after the test end
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
      });
      testWidgets('found no SaveFilterFABButton if name is empty',
          (tester) async {
        // Increase size to ensure all elements in list are visible.
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(const BlocRepositoryWrapper());
        await tester.pumpAndSettle();
        expect(
          find.descendant(
            of: find.byType(SaveFilterFABButton),
            matching: find.byType(FloatingActionButton),
          ),
          findsNothing,
        );

        // resets the screen to its original size after the test end
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
      });
      testWidgets('found SaveFilterFABButton if name is not empty',
          (tester) async {
        // Increase size to ensure all elements in list are visible.
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(const BlocRepositoryWrapper());
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextFormField), 'Filter name');
        await tester.pumpAndSettle();

        expect(
          find.descendant(
            of: find.byType(SaveFilterFABButton),
            matching: find.byType(FloatingActionButton),
          ),
          findsOneWidget,
        );

        // resets the screen to its original size after the test end
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
      });
    });

    group('wide view', () {
      group('create mode', () {
        testWidgets('found no DeleteFilterIconButton', (tester) async {
          // Increase size to ensure all elements in list are visible.
          tester.view.physicalSize = const Size(800, 800);
          tester.view.devicePixelRatio = 1.0;

          await tester.pumpWidget(const BlocRepositoryWrapper());
          await tester.pumpAndSettle();
          expect(
            find.byType(DeleteFilterIconButton),
            findsNothing,
          );

          // resets the screen to its original size after the test end
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
        });
      });
      group('edit mode', () {
        testWidgets('found DeleteFilterIconButton', (tester) async {
          // Increase size to ensure all elements in list are visible.
          tester.view.physicalSize = const Size(800, 800);
          tester.view.devicePixelRatio = 1.0;

          await tester.pumpWidget(
            BlocRepositoryWrapper(
              initFilter: const Filter().copyWith(name: 'filter'),
            ),
          );
          await tester.pumpAndSettle();
          expect(
            find.byType(DeleteFilterIconButton),
            findsOneWidget,
          );

          // resets the screen to its original size after the test end
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
        });
      });
      testWidgets('found no SaveFilterFABButton', (tester) async {
        // Increase size to ensure all elements in list are visible.
        tester.view.physicalSize = const Size(800, 800);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(const BlocRepositoryWrapper());
        await tester.pumpAndSettle();
        expect(
          find.byType(SaveFilterFABButton),
          findsNothing,
        );

        // resets the screen to its original size after the test end
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
      });
      testWidgets('found no SaveFilterIconButton if name is empty',
          (tester) async {
        // Increase size to ensure all elements in list are visible.
        tester.view.physicalSize = const Size(800, 800);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(const BlocRepositoryWrapper());
        await tester.pumpAndSettle();

        expect(
          find.descendant(
            of: find.byType(SaveFilterIconButton),
            matching: find.byType(IconButton),
          ),
          findsNothing,
        );

        // resets the screen to its original size after the test end
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
      });
      testWidgets('found SaveFilterIconButton if name is not empty',
          (tester) async {
        // Increase size to ensure all elements in list are visible.
        tester.view.physicalSize = const Size(800, 800);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(const BlocRepositoryWrapper());
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextFormField), 'Filter name');
        await tester.pumpAndSettle();

        expect(
          find.descendant(
            of: find.byType(SaveFilterIconButton),
            matching: find.byType(IconButton),
          ),
          findsOneWidget,
        );

        // resets the screen to its original size after the test end
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
      });
    });

    group('default values', () {
      testWidgets('FilterOrderItem', (tester) async {
        await tester.pumpWidget(const BlocRepositoryWrapper());
        await tester.pumpAndSettle();
        await tester.dragUntilVisible(
          find.byType(FilterOrderItem),
          find.byType(ListView),
          const Offset(0, -100),
        );
        expect(
          find.descendant(
            of: find.byType(FilterOrderItem),
            matching: find.byWidgetPredicate(
              (Widget widget) =>
                  widget is BasicChip &&
                  widget.label == ListOrder.ascending.name,
            ),
          ),
          findsOneWidget,
        );
      });
      testWidgets('FilterFilterItem', (tester) async {
        await tester.pumpWidget(const BlocRepositoryWrapper());
        await tester.pumpAndSettle();
        await tester.dragUntilVisible(
          find.byType(FilterFilterItem),
          find.byType(ListView),
          const Offset(0, -100),
        );
        expect(
          find.descendant(
            of: find.byType(FilterFilterItem),
            matching: find.byWidgetPredicate(
              (Widget widget) =>
                  widget is BasicChip && widget.label == ListFilter.all.name,
            ),
          ),
          findsOneWidget,
        );
      });
      testWidgets('FilterGroupItem', (tester) async {
        await tester.pumpWidget(const BlocRepositoryWrapper());
        await tester.pumpAndSettle();
        await tester.dragUntilVisible(
          find.byType(FilterGroupItem),
          find.byType(ListView),
          const Offset(0, -100),
        );
        expect(
          find.descendant(
            of: find.byType(FilterGroupItem),
            matching: find.byWidgetPredicate(
              (Widget widget) =>
                  widget is BasicChip && widget.label == ListGroup.none.name,
            ),
          ),
          findsOneWidget,
        );
      });
      testWidgets('FilterPrioritiesItem', (tester) async {
        await tester.pumpWidget(const BlocRepositoryWrapper());
        await tester.pumpAndSettle();
        await tester.dragUntilVisible(
          find.byType(FilterPrioritiesItem),
          find.byType(ListView),
          const Offset(0, -100),
        );
        expect(
          find.descendant(
            of: find.byType(FilterPrioritiesItem),
            matching: find.byType(BasicChip),
          ),
          findsNothing,
        );
        expect(
          find.descendant(
            of: find.byType(FilterPrioritiesItem),
            matching: find.byWidgetPredicate(
              (Widget widget) => widget is Text && widget.data == '-',
            ),
          ),
          findsOneWidget,
        );
      });
      testWidgets('FilterProjectTagsItem', (tester) async {
        await tester.pumpWidget(const BlocRepositoryWrapper());
        await tester.pumpAndSettle();
        await tester.dragUntilVisible(
          find.byType(FilterProjectTagsItem),
          find.byType(ListView),
          const Offset(0, -100),
        );
        expect(
          find.descendant(
            of: find.byType(FilterProjectTagsItem),
            matching: find.byType(BasicChip),
          ),
          findsNothing,
        );
        expect(
          find.descendant(
            of: find.byType(FilterProjectTagsItem),
            matching: find.byWidgetPredicate(
              (Widget widget) => widget is Text && widget.data == '-',
            ),
          ),
          findsOneWidget,
        );
      });
      testWidgets('FilterContextTagsItem', (tester) async {
        await tester.pumpWidget(const BlocRepositoryWrapper());
        await tester.pumpAndSettle();
        await tester.dragUntilVisible(
          find.byType(FilterContextTagsItem),
          find.byType(ListView),
          const Offset(0, -100),
        );
        expect(
          find.descendant(
            of: find.byType(FilterContextTagsItem),
            matching: find.byType(BasicChip),
          ),
          findsNothing,
        );
        expect(
          find.descendant(
            of: find.byType(FilterContextTagsItem),
            matching: find.byWidgetPredicate(
              (Widget widget) => widget is Text && widget.data == '-',
            ),
          ),
          findsOneWidget,
        );
      });
    });

    group('non default values', () {
      testWidgets('FilterNameTextField', (tester) async {
        await tester.pumpWidget(
          BlocRepositoryWrapper(
            initFilter: const Filter().copyWith(name: 'filter name'),
          ),
        );
        await tester.pumpAndSettle();
        await tester.dragUntilVisible(
          find.byType(FilterNameTextField),
          find.byType(ListView),
          const Offset(0, -100),
        );
        expect(
          find.descendant(
            of: find.byType(FilterNameTextField),
            matching: find.text('filter name'),
          ),
          findsOneWidget,
        );
      });
      testWidgets('FilterOrderItem', (tester) async {
        await tester.pumpWidget(
          BlocRepositoryWrapper(
            initFilter: const Filter().copyWith(order: ListOrder.descending),
          ),
        );
        await tester.pumpAndSettle();
        await tester.dragUntilVisible(
          find.byType(FilterOrderItem),
          find.byType(ListView),
          const Offset(0, -100),
        );
        expect(
          find.descendant(
            of: find.byType(FilterOrderItem),
            matching: find.byWidgetPredicate(
              (Widget widget) =>
                  widget is BasicChip &&
                  widget.label == ListOrder.descending.name,
            ),
          ),
          findsOneWidget,
        );
      });
      testWidgets('FilterFilterItem', (tester) async {
        await tester.pumpWidget(
          BlocRepositoryWrapper(
            initFilter:
                const Filter().copyWith(filter: ListFilter.completedOnly),
          ),
        );
        await tester.pumpAndSettle();
        await tester.dragUntilVisible(
          find.byType(FilterFilterItem),
          find.byType(ListView),
          const Offset(0, -100),
        );
        expect(
          find.descendant(
            of: find.byType(FilterFilterItem),
            matching: find.byWidgetPredicate(
              (Widget widget) =>
                  widget is BasicChip &&
                  widget.label == ListFilter.completedOnly.name,
            ),
          ),
          findsOneWidget,
        );
      });
      testWidgets('FilterGroupItem', (tester) async {
        await tester.pumpWidget(
          BlocRepositoryWrapper(
            initFilter: const Filter().copyWith(group: ListGroup.project),
          ),
        );
        await tester.pumpAndSettle();
        await tester.dragUntilVisible(
          find.byType(FilterGroupItem),
          find.byType(ListView),
          const Offset(0, -100),
        );
        expect(
          find.descendant(
            of: find.byType(FilterGroupItem),
            matching: find.byWidgetPredicate(
              (Widget widget) =>
                  widget is BasicChip && widget.label == ListGroup.project.name,
            ),
          ),
          findsOneWidget,
        );
      });
      testWidgets('FilterPrioritiesItem', (tester) async {
        await tester.pumpWidget(
          BlocRepositoryWrapper(
            initFilter: const Filter().copyWith(
              priorities: {Priority.A, Priority.B},
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.dragUntilVisible(
          find.byType(FilterPrioritiesItem),
          find.byType(ListView),
          const Offset(0, -100),
        );
        expect(
          find.descendant(
            of: find.byType(FilterPrioritiesItem),
            matching: find.byWidgetPredicate(
              (Widget widget) =>
                  widget is BasicChip && widget.label == Priority.A.name,
            ),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(FilterPrioritiesItem),
            matching: find.byWidgetPredicate(
              (Widget widget) =>
                  widget is BasicChip && widget.label == Priority.B.name,
            ),
          ),
          findsOneWidget,
        );
      });
      testWidgets('FilterProjectTagsItem', (tester) async {
        await tester.pumpWidget(
          BlocRepositoryWrapper(
            initFilter: const Filter().copyWith(
              projects: {'project1', 'project2'},
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.dragUntilVisible(
          find.byType(FilterProjectTagsItem),
          find.byType(ListView),
          const Offset(0, -100),
        );
        expect(
          find.descendant(
            of: find.byType(FilterProjectTagsItem),
            matching: find.byWidgetPredicate(
              (Widget widget) =>
                  widget is BasicChip && widget.label == 'project1',
            ),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(FilterProjectTagsItem),
            matching: find.byWidgetPredicate(
              (Widget widget) =>
                  widget is BasicChip && widget.label == 'project2',
            ),
          ),
          findsOneWidget,
        );
      });
      testWidgets('FilterContextTagsItem', (tester) async {
        await tester.pumpWidget(
          BlocRepositoryWrapper(
            initFilter: const Filter().copyWith(
              contexts: {'context1', 'context2'},
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.dragUntilVisible(
          find.byType(FilterContextTagsItem),
          find.byType(ListView),
          const Offset(0, -100),
        );
        expect(
          find.descendant(
            of: find.byType(FilterContextTagsItem),
            matching: find.byWidgetPredicate(
              (Widget widget) =>
                  widget is BasicChip && widget.label == 'context1',
            ),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(FilterContextTagsItem),
            matching: find.byWidgetPredicate(
              (Widget widget) =>
                  widget is BasicChip && widget.label == 'context2',
            ),
          ),
          findsOneWidget,
        );
      });
    });

    group('update values', () {
      testWidgets('FilterOrderItem', (tester) async {
        await tester.pumpWidget(const BlocRepositoryWrapper());
        await tester.pumpAndSettle();
        await tester.dragUntilVisible(
          find.byType(FilterOrderItem),
          find.byType(ListView),
          const Offset(0, -100),
        );

        await tester.tap(find.byType(FilterOrderItem));
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.byType(FilterStateOrderDialog));
        await tester.pumpAndSettle();
        await tester.tap(
          find.descendant(
            of: find.byType(FilterStateOrderDialog),
            matching: find.text('Descending'),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.descendant(
            of: find.byType(FilterOrderItem),
            matching: find.byWidgetPredicate(
              (Widget widget) =>
                  widget is BasicChip &&
                  widget.label == ListOrder.descending.name,
            ),
          ),
          findsOneWidget,
        );
      });
      testWidgets('FilterFilterItem', (tester) async {
        await tester.pumpWidget(const BlocRepositoryWrapper());
        await tester.pumpAndSettle();
        await tester.dragUntilVisible(
          find.byType(FilterFilterItem),
          find.byType(ListView),
          const Offset(0, -100),
        );

        await tester.tap(find.byType(FilterFilterItem));
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.byType(FilterStateFilterDialog));
        await tester.pumpAndSettle();
        await tester.tap(
          find.descendant(
            of: find.byType(FilterStateFilterDialog),
            matching: find.text('Completed only'),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.descendant(
            of: find.byType(FilterFilterItem),
            matching: find.byWidgetPredicate(
              (Widget widget) =>
                  widget is BasicChip &&
                  widget.label == ListFilter.completedOnly.name,
            ),
          ),
          findsOneWidget,
        );
      });
      testWidgets('FilterGroupItem', (tester) async {
        await tester.pumpWidget(const BlocRepositoryWrapper());
        await tester.pumpAndSettle();
        await tester.dragUntilVisible(
          find.byType(FilterGroupItem),
          find.byType(ListView),
          const Offset(0, -100),
        );

        await tester.tap(find.byType(FilterGroupItem));
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.byType(FilterStateGroupDialog));
        await tester.pumpAndSettle();
        await tester.tap(
          find.descendant(
            of: find.byType(FilterStateGroupDialog),
            matching: find.text('Upcoming'),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.descendant(
            of: find.byType(FilterGroupItem),
            matching: find.byWidgetPredicate(
              (Widget widget) =>
                  widget is BasicChip &&
                  widget.label == ListGroup.upcoming.name,
            ),
          ),
          findsOneWidget,
        );
      });
      testWidgets('FilterPrioritiesItem', (tester) async {
        await tester.pumpWidget(const BlocRepositoryWrapper());
        await tester.pumpAndSettle();
        await tester.dragUntilVisible(
          find.byType(FilterPrioritiesItem),
          find.byType(ListView),
          const Offset(0, -100),
        );

        await tester.tap(find.byType(FilterPrioritiesItem));
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.byType(FilterPriorityTagDialog));
        await tester.pumpAndSettle();
        await tester.tap(
          find.descendant(
            of: find.byType(FilterPriorityTagDialog),
            matching: find.text('A'),
          ),
        );
        await tester.tap(
          find.descendant(
            of: find.byType(FilterPriorityTagDialog),
            matching: find.text('Apply'),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.descendant(
            of: find.byType(FilterPrioritiesItem),
            matching: find.byWidgetPredicate(
              (Widget widget) => widget is BasicChip && widget.label == 'A',
            ),
          ),
          findsOneWidget,
        );
      });
      testWidgets('FilterProjectTagsItem', (tester) async {
        await tester.pumpWidget(
          const BlocRepositoryWrapper(
            projects: {'project1', 'project2'},
          ),
        );
        await tester.pumpAndSettle();
        await tester.dragUntilVisible(
          find.byType(FilterProjectTagsItem),
          find.byType(ListView),
          const Offset(0, -100),
        );

        await tester.tap(find.byType(FilterProjectTagsItem));
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.byType(FilterProjectTagDialog));
        await tester.pumpAndSettle();
        await tester.tap(
          find.descendant(
            of: find.byType(FilterProjectTagDialog),
            matching: find.text('project1'),
          ),
        );
        await tester.tap(
          find.descendant(
            of: find.byType(FilterProjectTagDialog),
            matching: find.text('Apply'),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.descendant(
            of: find.byType(FilterProjectTagsItem),
            matching: find.byWidgetPredicate(
              (Widget widget) =>
                  widget is BasicChip && widget.label == 'project1',
            ),
          ),
          findsOneWidget,
        );
      });
      testWidgets('FilterContextTagsItem', (tester) async {
        await tester.pumpWidget(
          const BlocRepositoryWrapper(
            contexts: {'context1', 'context2'},
          ),
        );
        await tester.pumpAndSettle();
        await tester.dragUntilVisible(
          find.byType(FilterContextTagsItem),
          find.byType(ListView),
          const Offset(0, -100),
        );

        await tester.tap(find.byType(FilterContextTagsItem));
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.byType(FilterContextTagDialog));
        await tester.pumpAndSettle();
        await tester.tap(
          find.descendant(
            of: find.byType(FilterContextTagDialog),
            matching: find.text('context1'),
          ),
        );
        await tester.tap(
          find.descendant(
            of: find.byType(FilterContextTagDialog),
            matching: find.text('Apply'),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.descendant(
            of: find.byType(FilterContextTagsItem),
            matching: find.byWidgetPredicate(
              (Widget widget) =>
                  widget is BasicChip && widget.label == 'context1',
            ),
          ),
          findsOneWidget,
        );
      });
    });
  });
}
