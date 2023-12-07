import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/presentation/settings/pages/settings_page.dart';
import 'package:ntodotxt/presentation/settings/states/settings_cubit.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPageBlocProvider extends StatelessWidget {
  final SharedPreferences prefs;

  const SettingsPageBlocProvider({
    required this.prefs,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => SettingsCubit(
        prefs: prefs,
      ),
      child: Builder(
        builder: (BuildContext context) {
          return const MaterialApp(
            home: SettingsPage(),
          );
        },
      ),
    );
  }
}

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    // Mock shared preferences.
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  group('Display settings', () {
    setUp(() async {});

    group('order', () {
      testWidgets('default value', (tester) async {
        await tester.pumpWidget(SettingsPageBlocProvider(prefs: prefs));
        await tester.pump();
        expect(
          find.byWidgetPredicate(
            (Widget widget) =>
                widget is ListTile &&
                (widget.title as Text).data == 'Order' &&
                (widget.subtitle as Text).data == TodoListOrder.ascending.name,
          ),
          findsOneWidget,
        );
      });
      testWidgets('pre-start update', (tester) async {
        prefs.setString('todoOrder', 'descending');
        await tester.pumpWidget(SettingsPageBlocProvider(prefs: prefs));
        await tester.pump();
        expect(
          find.byWidgetPredicate(
            (Widget widget) =>
                widget is ListTile &&
                (widget.title as Text).data == 'Order' &&
                (widget.subtitle as Text).data == TodoListOrder.descending.name,
          ),
          findsOneWidget,
        );
      });
      testWidgets('update by dialog', (tester) async {
        await tester.pumpWidget(SettingsPageBlocProvider(prefs: prefs));
        await tester.pump();

        await tester.tap(
          find.byWidgetPredicate(
            (Widget widget) =>
                widget is ListTile &&
                (widget.title as Text).data == 'Order' &&
                (widget.subtitle as Text).data == TodoListOrder.ascending.name,
          ),
        );
        await tester.pump();

        expect(find.byKey(const Key('OrderSettingsDialog')), findsOneWidget);
        await tester.tap(
          find.byKey(Key('${TodoListOrder.descending.name}DialogRadioButton')),
        );
        await tester.pump();

        expect(
          find.byWidgetPredicate(
            (Widget widget) =>
                widget is ListTile &&
                (widget.title as Text).data == 'Order' &&
                (widget.subtitle as Text).data == TodoListOrder.descending.name,
          ),
          findsOneWidget,
        );
      });
    });

    group('filter', () {
      testWidgets('default value', (tester) async {
        await tester.pumpWidget(SettingsPageBlocProvider(prefs: prefs));
        await tester.pump();
        expect(
          find.byWidgetPredicate(
            (Widget widget) =>
                widget is ListTile &&
                (widget.title as Text).data == 'Filter' &&
                (widget.subtitle as Text).data == TodoListFilter.all.name,
          ),
          findsOneWidget,
        );
      });
      testWidgets('pre-start update', (tester) async {
        prefs.setString('todoFilter', 'completedOnly');
        await tester.pumpWidget(SettingsPageBlocProvider(prefs: prefs));
        await tester.pump();
        expect(
          find.byWidgetPredicate(
            (Widget widget) =>
                widget is ListTile &&
                (widget.title as Text).data == 'Filter' &&
                (widget.subtitle as Text).data ==
                    TodoListFilter.completedOnly.name,
          ),
          findsOneWidget,
        );
      });
      testWidgets('update by dialog', (tester) async {
        await tester.pumpWidget(SettingsPageBlocProvider(prefs: prefs));
        await tester.pump();

        await tester.tap(
          find.byWidgetPredicate(
            (Widget widget) =>
                widget is ListTile &&
                (widget.title as Text).data == 'Filter' &&
                (widget.subtitle as Text).data == TodoListFilter.all.name,
          ),
        );
        await tester.pump();

        expect(find.byKey(const Key('FilterSettingsDialog')), findsOneWidget);
        await tester.tap(
          find.byKey(
              Key('${TodoListFilter.completedOnly.name}DialogRadioButton')),
        );
        await tester.pump();

        expect(
          find.byWidgetPredicate(
            (Widget widget) =>
                widget is ListTile &&
                (widget.title as Text).data == 'Filter' &&
                (widget.subtitle as Text).data ==
                    TodoListFilter.completedOnly.name,
          ),
          findsOneWidget,
        );
      });
    });

    group('group by', () {
      testWidgets('default value', (tester) async {
        await tester.pumpWidget(SettingsPageBlocProvider(prefs: prefs));
        await tester.pump();
        expect(
          find.byWidgetPredicate(
            (Widget widget) =>
                widget is ListTile &&
                (widget.title as Text).data == 'Group by' &&
                (widget.subtitle as Text).data == TodoListGroupBy.none.name,
          ),
          findsOneWidget,
        );
      });
      testWidgets('pre-start update', (tester) async {
        prefs.setString('todoGrouping', 'priority');
        await tester.pumpWidget(SettingsPageBlocProvider(prefs: prefs));
        await tester.pump();
        expect(
          find.byWidgetPredicate(
            (Widget widget) =>
                widget is ListTile &&
                (widget.title as Text).data == 'Group by' &&
                (widget.subtitle as Text).data == TodoListGroupBy.priority.name,
          ),
          findsOneWidget,
        );
      });
      testWidgets('update by dialog', (tester) async {
        await tester.pumpWidget(SettingsPageBlocProvider(prefs: prefs));
        await tester.pump();

        await tester.tap(
          find.byWidgetPredicate(
            (Widget widget) =>
                widget is ListTile &&
                (widget.title as Text).data == 'Group by' &&
                (widget.subtitle as Text).data == TodoListGroupBy.none.name,
          ),
        );
        await tester.pump();

        expect(find.byKey(const Key('GroupBySettingsDialog')), findsOneWidget);
        await tester.tap(
          find.byKey(Key('${TodoListGroupBy.priority.name}DialogRadioButton')),
        );
        await tester.pump();

        expect(
          find.byWidgetPredicate(
            (Widget widget) =>
                widget is ListTile &&
                (widget.title as Text).data == 'Group by' &&
                (widget.subtitle as Text).data == TodoListGroupBy.priority.name,
          ),
          findsOneWidget,
        );
      });
    });
  });

  group('Other settings', () {
    group('reset settings', () {
      setUp(() async {
        // Mock shared preferences.
        SharedPreferences.setMockInitialValues({
          'todoOrder': 'descending',
          'todoFilter': 'completedOnly',
          'todoGrouping': 'priority',
        });
        prefs = await SharedPreferences.getInstance();
      });

      testWidgets('by dialog', (tester) async {
        await tester.pumpWidget(SettingsPageBlocProvider(prefs: prefs));
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

        expect(prefs.getString('todoOrder'), null);
        expect(prefs.getString('todoFilter'), null);
        expect(prefs.getString('todoGrouping'), null);
      });
    });
  });
}
