import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/data/filter/filter_controller.dart';
import 'package:ntodotxt/data/settings/setting_controller.dart'
    show SettingController;
import 'package:ntodotxt/domain/filter/filter_model.dart'
    show Filter, ListFilter, ListGroup, ListOrder;
import 'package:ntodotxt/domain/filter/filter_repository.dart';
import 'package:ntodotxt/domain/settings/setting_repository.dart'
    show SettingRepository;
import 'package:ntodotxt/presentation/filter/states/filter_cubit.dart';
import 'package:ntodotxt/presentation/settings/pages/settings_page.dart'
    show SettingsPage;
import 'package:ntodotxt/presentation/todo_file/todo_file_cubit.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class SettingsPageBlocProvider extends StatelessWidget {
  final String databasePath;
  final Filter? filter;

  const SettingsPageBlocProvider({
    this.filter,
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
      child: MultiBlocProvider(
        providers: [
          BlocProvider<FilterCubit>(
            create: (BuildContext context) => FilterCubit(
              settingRepository: context.read<SettingRepository>(),
              filterRepository: context.read<FilterRepository>(),
              filter: filter ?? const Filter(),
            )..initial(),
          ),
          BlocProvider<TodoFileCubit>(
            create: (BuildContext context) => TodoFileCubit(
              repository: context.read<SettingRepository>(),
            )..initial(),
          ),
        ],
        child: Builder(
          builder: (BuildContext context) {
            return const MaterialApp(
              home: SettingsPage(),
            );
          },
        ),
      ),
    );
  }
}

void main() {
  group('Display settings', () {
    group('order', () {
      testWidgets('default value', (tester) async {
        await tester.pumpWidget(const SettingsPageBlocProvider());
        await tester.pump();
        expect(
          find.byWidgetPredicate(
            (Widget widget) =>
                widget is ListTile &&
                (widget.title as Text).data == 'Default order' &&
                (widget.subtitle as Text).data == ListOrder.ascending.name,
          ),
          findsOneWidget,
        );
      });
      testWidgets('update by dialog', (tester) async {
        await tester.pumpWidget(const SettingsPageBlocProvider());
        await tester.pump();

        await tester.tap(
          find.byWidgetPredicate(
            (Widget widget) =>
                widget is ListTile &&
                (widget.title as Text).data == 'Default order' &&
                (widget.subtitle as Text).data == ListOrder.ascending.name,
          ),
        );
        await tester.pump();

        expect(find.byType(Dialog), findsOneWidget);
        await tester.tap(
          find.byKey(Key('${ListOrder.descending.name}DialogRadioButton')),
        );
        await tester.pump();

        expect(
          find.byWidgetPredicate(
            (Widget widget) =>
                widget is ListTile &&
                (widget.title as Text).data == 'Default order' &&
                (widget.subtitle as Text).data == ListOrder.descending.name,
          ),
          findsOneWidget,
        );
      });
    });

    group('filter', () {
      testWidgets('default value', (tester) async {
        await tester.pumpWidget(const SettingsPageBlocProvider());
        await tester.pump();
        expect(
          find.byWidgetPredicate(
            (Widget widget) =>
                widget is ListTile &&
                (widget.title as Text).data == 'Default filter' &&
                (widget.subtitle as Text).data == ListFilter.all.name,
          ),
          findsOneWidget,
        );
      });
      testWidgets('update by dialog', (tester) async {
        await tester.pumpWidget(const SettingsPageBlocProvider());
        await tester.pump();

        await tester.tap(
          find.byWidgetPredicate(
            (Widget widget) =>
                widget is ListTile &&
                (widget.title as Text).data == 'Default filter' &&
                (widget.subtitle as Text).data == ListFilter.all.name,
          ),
        );
        await tester.pump();

        expect(find.byType(Dialog), findsOneWidget);
        await tester.tap(
          find.byKey(Key('${ListFilter.completedOnly.name}DialogRadioButton')),
        );
        await tester.pump();

        expect(
          find.byWidgetPredicate(
            (Widget widget) =>
                widget is ListTile &&
                (widget.title as Text).data == 'Default filter' &&
                (widget.subtitle as Text).data == ListFilter.completedOnly.name,
          ),
          findsOneWidget,
        );
      });
    });

    group('group by', () {
      testWidgets('default value', (tester) async {
        await tester.pumpWidget(const SettingsPageBlocProvider());
        await tester.pump();
        expect(
          find.byWidgetPredicate(
            (Widget widget) =>
                widget is ListTile &&
                (widget.title as Text).data == 'Default grouping' &&
                (widget.subtitle as Text).data == ListGroup.none.name,
          ),
          findsOneWidget,
        );
      });
      testWidgets('update by dialog', (tester) async {
        await tester.pumpWidget(const SettingsPageBlocProvider());
        await tester.pump();

        await tester.tap(
          find.byWidgetPredicate(
            (Widget widget) =>
                widget is ListTile &&
                (widget.title as Text).data == 'Default grouping' &&
                (widget.subtitle as Text).data == ListGroup.none.name,
          ),
        );
        await tester.pump();

        expect(find.byType(Dialog), findsOneWidget);
        await tester.tap(
          find.byKey(Key('${ListGroup.priority.name}DialogRadioButton')),
        );
        await tester.pump();

        expect(
          find.byWidgetPredicate(
            (Widget widget) =>
                widget is ListTile &&
                (widget.title as Text).data == 'Default grouping' &&
                (widget.subtitle as Text).data == ListGroup.priority.name,
          ),
          findsOneWidget,
        );
      });
    });
  });

  group('Other settings', () {
    group('reset settings', () {
      testWidgets('by dialog', (tester) async {
        await tester.pumpWidget(
          const SettingsPageBlocProvider(
            filter: Filter(
              order: ListOrder.descending,
              filter: ListFilter.completedOnly,
              group: ListGroup.project,
            ),
          ),
        );
        await tester.pump();

        Finder settingItem = find.byWidgetPredicate(
          (Widget widget) =>
              widget is ListTile &&
              (widget.title as Text).data == 'Reset settings',
        );
        // Ensure the item is visible by scrolling.
        await tester.scrollUntilVisible(settingItem, 500);
        await tester.tap(settingItem);
        await tester.pump();

        expect(
          find.byWidgetPredicate(
            (Widget widget) =>
                widget is ListTile &&
                (widget.title as Text).data == 'Default order' &&
                (widget.subtitle as Text).data == ListOrder.ascending.name,
          ),
          findsOneWidget,
        );
        expect(
          find.byWidgetPredicate(
            (Widget widget) =>
                widget is ListTile &&
                (widget.title as Text).data == 'Default filter' &&
                (widget.subtitle as Text).data == ListFilter.all.name,
          ),
          findsOneWidget,
        );
        expect(
          find.byWidgetPredicate(
            (Widget widget) =>
                widget is ListTile &&
                (widget.title as Text).data == 'Default grouping' &&
                (widget.subtitle as Text).data == ListGroup.none.name,
          ),
          findsOneWidget,
        );
      });
    });
  });
}
