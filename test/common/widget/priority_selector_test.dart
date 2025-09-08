import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/common/widget/priority_selector.dart';
import 'package:ntodotxt/database/controller/database.dart';
import 'package:ntodotxt/filter/controller/filter_controller.dart';
import 'package:ntodotxt/filter/model/filter_model.dart' show Filter;
import 'package:ntodotxt/filter/repository/filter_repository.dart';
import 'package:ntodotxt/filter/state/filter_cubit.dart';
import 'package:ntodotxt/setting/controller/setting_controller.dart';
import 'package:ntodotxt/setting/repository/setting_repository.dart';
import 'package:ntodotxt/todo/model/todo_model.dart' show Priority;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class MaterialAppPrioritySelector extends StatelessWidget {
  final DatabaseController dbController =
      const DatabaseController(inMemoryDatabasePath);
  final Widget selector;

  const MaterialAppPrioritySelector({
    required this.selector,
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
                body: selector,
              ),
            );
          },
        ),
      ),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('default tags', () {
    testWidgets('uses default priority tags', (tester) async {
      await tester.pumpWidget(MaterialAppPrioritySelector(
        selector: PrioritySelector(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('No priorities available'), findsNothing);
      expect(find.byType(ChoiceChip), findsAny);
    });
  });

  group('empty tags', () {
    testWidgets('no tags available', (tester) async {
      await tester.pumpWidget(MaterialAppPrioritySelector(
        selector: PrioritySelector(items: {}),
      ));
      await tester.pumpAndSettle();

      expect(find.text('No priorities available'), findsOneWidget);
    });
  });

  group('multiSelectionEnabled and emptySelectionAllowed enabled', () {
    testWidgets('no tag selected', (tester) async {
      await tester.pumpWidget(MaterialAppPrioritySelector(
        selector: PrioritySelector(
          items: {Priority.A, Priority.B, Priority.C},
          multiSelectionEnabled: true,
          emptySelectionAllowed: true,
        ),
      ));
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (Widget widget) => widget is ChoiceChip && widget.selected == true,
        ),
        findsNothing,
      );
    });
    testWidgets('single tag selected', (tester) async {
      await tester.pumpWidget(MaterialAppPrioritySelector(
        selector: PrioritySelector(
          items: {Priority.A, Priority.B, Priority.C},
          multiSelectionEnabled: true,
          emptySelectionAllowed: true,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (Widget widget) => widget is ChoiceChip && widget.selected == true,
        ),
        findsOneWidget,
      );
    });
    testWidgets('tag is deselected', (tester) async {
      await tester.pumpWidget(MaterialAppPrioritySelector(
        selector: PrioritySelector(
          items: {Priority.A, Priority.B, Priority.C},
          multiSelectionEnabled: true,
          emptySelectionAllowed: true,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (Widget widget) => widget is ChoiceChip && widget.selected == true,
        ),
        findsNothing,
      );
    });
    testWidgets('multiple tags selected', (tester) async {
      await tester.pumpWidget(MaterialAppPrioritySelector(
        selector: PrioritySelector(
          items: {Priority.A, Priority.B, Priority.C},
          multiSelectionEnabled: true,
          emptySelectionAllowed: true,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('A'));
      await tester.tap(find.text('B'));
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (Widget widget) => widget is ChoiceChip && widget.selected == true,
        ),
        findsExactly(2),
      );
    });
  });

  group('multiSelectionEnabled disabled and emptySelectionAllowed enabled', () {
    testWidgets('no tag selected', (tester) async {
      await tester.pumpWidget(MaterialAppPrioritySelector(
        selector: PrioritySelector(
          items: {Priority.A, Priority.B, Priority.C},
          multiSelectionEnabled: false,
          emptySelectionAllowed: true,
        ),
      ));
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (Widget widget) => widget is ChoiceChip && widget.selected == true,
        ),
        findsNothing,
      );
    });
    testWidgets('single tag selected', (tester) async {
      await tester.pumpWidget(MaterialAppPrioritySelector(
        selector: PrioritySelector(
          items: {Priority.A, Priority.B, Priority.C},
          multiSelectionEnabled: false,
          emptySelectionAllowed: true,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (Widget widget) => widget is ChoiceChip && widget.selected == true,
        ),
        findsOneWidget,
      );
    });
    testWidgets('tag is deselected', (tester) async {
      await tester.pumpWidget(MaterialAppPrioritySelector(
        selector: PrioritySelector(
          items: {Priority.A, Priority.B, Priority.C},
          multiSelectionEnabled: false,
          emptySelectionAllowed: true,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (Widget widget) => widget is ChoiceChip && widget.selected == true,
        ),
        findsNothing,
      );
    });
    testWidgets('no multiple selected tags', (tester) async {
      await tester.pumpWidget(MaterialAppPrioritySelector(
        selector: PrioritySelector(
          items: {Priority.A, Priority.B, Priority.C},
          multiSelectionEnabled: false,
          emptySelectionAllowed: true,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('A'));
      await tester.tap(find.text('B'));
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (Widget widget) => widget is ChoiceChip && widget.selected == true,
        ),
        findsOneWidget,
      );
    });
  });

  group('multiSelectionEnabled enabled and emptySelectionAllowed disabled', () {
    testWidgets('no tag selected', (tester) async {
      await tester.pumpWidget(MaterialAppPrioritySelector(
        selector: PrioritySelector(
          items: {Priority.A, Priority.B, Priority.C},
          multiSelectionEnabled: true,
          emptySelectionAllowed: false,
        ),
      ));
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (Widget widget) => widget is ChoiceChip && widget.selected == true,
        ),
        findsNothing,
      );
    });
    testWidgets('single tag selected', (tester) async {
      await tester.pumpWidget(MaterialAppPrioritySelector(
        selector: PrioritySelector(
          items: {Priority.A, Priority.B, Priority.C},
          multiSelectionEnabled: true,
          emptySelectionAllowed: false,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (Widget widget) => widget is ChoiceChip && widget.selected == true,
        ),
        findsOneWidget,
      );
    });
    testWidgets('tag cannot be deselected', (tester) async {
      await tester.pumpWidget(MaterialAppPrioritySelector(
        selector: PrioritySelector(
          items: {Priority.A, Priority.B, Priority.C},
          multiSelectionEnabled: true,
          emptySelectionAllowed: false,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('A')); // Cannot be deselected.
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (Widget widget) => widget is ChoiceChip && widget.selected == true,
        ),
        findsOneWidget,
      );
    });
    testWidgets('multiple tags selected', (tester) async {
      await tester.pumpWidget(MaterialAppPrioritySelector(
        selector: PrioritySelector(
          items: {Priority.A, Priority.B, Priority.C},
          multiSelectionEnabled: true,
          emptySelectionAllowed: false,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('A'));
      await tester.tap(find.text('B'));
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (Widget widget) => widget is ChoiceChip && widget.selected == true,
        ),
        findsExactly(2),
      );
    });
  });

  group('multiSelectionEnabled and emptySelectionAllowed disabled', () {
    testWidgets('no tag selected', (tester) async {
      await tester.pumpWidget(MaterialAppPrioritySelector(
        selector: PrioritySelector(
          items: {Priority.A, Priority.B, Priority.C},
          multiSelectionEnabled: false,
          emptySelectionAllowed: false,
        ),
      ));
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (Widget widget) => widget is ChoiceChip && widget.selected == true,
        ),
        findsNothing,
      );
    });
    testWidgets('single tag selected', (tester) async {
      await tester.pumpWidget(MaterialAppPrioritySelector(
        selector: PrioritySelector(
          items: {Priority.A, Priority.B, Priority.C},
          multiSelectionEnabled: false,
          emptySelectionAllowed: false,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (Widget widget) => widget is ChoiceChip && widget.selected == true,
        ),
        findsOneWidget,
      );
    });
    testWidgets('tag cannot be deselected', (tester) async {
      await tester.pumpWidget(MaterialAppPrioritySelector(
        selector: PrioritySelector(
          items: {Priority.A, Priority.B, Priority.C},
          multiSelectionEnabled: false,
          emptySelectionAllowed: false,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('A')); // Cannot be deselected.
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (Widget widget) => widget is ChoiceChip && widget.selected == true,
        ),
        findsOneWidget,
      );
    });
    testWidgets('no multiple selected tags', (tester) async {
      await tester.pumpWidget(MaterialAppPrioritySelector(
        selector: PrioritySelector(
          items: {Priority.A, Priority.B, Priority.C},
          multiSelectionEnabled: false,
          emptySelectionAllowed: false,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('A'));
      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (Widget widget) => widget is ChoiceChip && widget.selected == true,
        ),
        findsOneWidget,
      );
    });
  });
}
