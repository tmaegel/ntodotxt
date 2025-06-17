import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/common/widget/order_dialog.dart';
import 'package:ntodotxt/database/controller/database.dart';
import 'package:ntodotxt/filter/controller/filter_controller.dart';
import 'package:ntodotxt/filter/model/filter_model.dart' show Filter;
import 'package:ntodotxt/filter/repository/filter_repository.dart';
import 'package:ntodotxt/filter/state/filter_cubit.dart';
import 'package:ntodotxt/filter/state/filter_state.dart';
import 'package:ntodotxt/setting/controller/setting_controller.dart';
import 'package:ntodotxt/setting/repository/setting_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class MaterialAppDefaultFilterStateOrderDialog extends StatelessWidget {
  final DatabaseController dbController;

  const MaterialAppDefaultFilterStateOrderDialog({
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
                        Text(state.filter.order.name),
                        Builder(
                          builder: (BuildContext context) {
                            return TextButton(
                              child: const Text('Open dialog'),
                              onPressed: () async {
                                await DefaultFilterStateOrderDialog.dialog(
                                  context: context,
                                  cubit: BlocProvider.of<FilterCubit>(context),
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DefaultFilterStateOrderDialog', () {
    testWidgets('change', (tester) async {
      await tester.pumpWidget(const MaterialAppDefaultFilterStateOrderDialog());
      await tester.pump();

      await tester.tap(find.text('Open dialog'));
      await tester.pump();

      expect(find.byType(Dialog), findsOneWidget);
      await tester.tap(find.text('Descending'));
      await tester.pump();

      expect(
        find.byWidgetPredicate(
          (Widget widget) => widget is Text && widget.data == 'descending',
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Open dialog'));
      await tester.pump();

      expect(find.byType(Dialog), findsOneWidget);
      await tester.tap(find.text('Ascending'));
      await tester.pump();

      expect(
        find.byWidgetPredicate(
          (Widget widget) => widget is Text && widget.data == 'ascending',
        ),
        findsOneWidget,
      );
    });
  });
}
