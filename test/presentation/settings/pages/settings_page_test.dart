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
import 'package:ntodotxt/presentation/login/states/login_cubit.dart';
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
        BlocProvider<LoginCubit>(
          create: (BuildContext context) => LoginCubit(),
        ),
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
            )..load(),
          ),
          BlocProvider<TodoFileCubit>(
            create: (BuildContext context) => TodoFileCubit(
              repository: context.read<SettingRepository>(),
            )..load(),
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
        await tester.pumpAndSettle();
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
        await tester.pumpAndSettle();

        await tester.tap(
          find.byWidgetPredicate(
            (Widget widget) =>
                widget is ListTile &&
                (widget.title as Text).data == 'Default order' &&
                (widget.subtitle as Text).data == ListOrder.ascending.name,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(Dialog), findsOneWidget);
        await tester.tap(
          find.byKey(Key('${ListOrder.descending.name}DialogRadioButton')),
        );
        await tester.pumpAndSettle();

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
        await tester.pumpAndSettle();
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
        await tester.pumpAndSettle();

        await tester.tap(
          find.byWidgetPredicate(
            (Widget widget) =>
                widget is ListTile &&
                (widget.title as Text).data == 'Default filter' &&
                (widget.subtitle as Text).data == ListFilter.all.name,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(Dialog), findsOneWidget);
        await tester.tap(
          find.byKey(Key('${ListFilter.completedOnly.name}DialogRadioButton')),
        );
        await tester.pumpAndSettle();

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
        await tester.pumpAndSettle();
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
        await tester.pumpAndSettle();

        await tester.tap(
          find.byWidgetPredicate(
            (Widget widget) =>
                widget is ListTile &&
                (widget.title as Text).data == 'Default grouping' &&
                (widget.subtitle as Text).data == ListGroup.none.name,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(Dialog), findsOneWidget);
        await tester.tap(
          find.byKey(Key('${ListGroup.priority.name}DialogRadioButton')),
        );
        await tester.pumpAndSettle();

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
}
