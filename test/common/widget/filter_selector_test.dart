import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/common/widget/filter_selector.dart';
import 'package:ntodotxt/database/controller/database.dart';
import 'package:ntodotxt/filter/controller/filter_controller.dart';
import 'package:ntodotxt/filter/model/filter_model.dart' show Filter;
import 'package:ntodotxt/filter/repository/filter_repository.dart';
import 'package:ntodotxt/filter/state/filter_cubit.dart';
import 'package:ntodotxt/setting/controller/setting_controller.dart';
import 'package:ntodotxt/setting/repository/setting_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class MaterialAppFilterSelector extends StatelessWidget {
  final DatabaseController dbController =
      const DatabaseController(inMemoryDatabasePath);
  final Widget selector;

  const MaterialAppFilterSelector({
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
      await tester.pumpWidget(MaterialAppFilterSelector(
        selector: FilterSelector(),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ChoiceChip), findsAny);
    });
  });

  group('default behaviour', () {
    testWidgets('default tag selected', (tester) async {
      await tester.pumpWidget(MaterialAppFilterSelector(
        selector: FilterSelector(),
      ));
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is ChoiceChip &&
              (widget.label as Text).data == 'all' &&
              widget.selected == true,
        ),
        findsOneWidget,
      );
    });
    testWidgets('non default tag selected', (tester) async {
      await tester.pumpWidget(MaterialAppFilterSelector(
        selector: FilterSelector(),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('completedOnly'));
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is ChoiceChip &&
              (widget.label as Text).data == 'completedOnly' &&
              widget.selected == true,
        ),
        findsOneWidget,
      );
    });
    testWidgets('tag cannot deselected', (tester) async {
      await tester.pumpWidget(MaterialAppFilterSelector(
        selector: FilterSelector(),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('completedOnly'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('completedOnly'));
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (Widget widget) => widget is ChoiceChip && widget.selected == true,
        ),
        findsOneWidget,
      );
    });
    testWidgets('multiple tags cannot selected', (tester) async {
      await tester.pumpWidget(MaterialAppFilterSelector(
        selector: FilterSelector(),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('completedOnly'));
      await tester.tap(find.text('incompletedOnly'));
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
