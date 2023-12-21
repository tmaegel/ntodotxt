import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/common_widgets/group_by_dialog.dart';
import 'package:ntodotxt/data/settings/setting_controller.dart';
import 'package:ntodotxt/domain/filter/filter_model.dart' show Filter;
import 'package:ntodotxt/domain/settings/setting_repository.dart';
import 'package:ntodotxt/presentation/default_filter/states/default_filter_cubit.dart';
import 'package:ntodotxt/presentation/default_filter/states/default_filter_state.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class MaterialAppDefaultFilterStateGroupDialog extends StatelessWidget {
  const MaterialAppDefaultFilterStateGroupDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<SettingRepository>(
      create: (BuildContext context) => SettingRepository(
        SettingController(inMemoryDatabasePath),
      ),
      child: BlocProvider(
        create: (BuildContext context) => DefaultFilterCubit(
          repository: context.read<SettingRepository>(),
          filter: const Filter(),
        ),
        child: Builder(
          builder: (BuildContext context) {
            return MaterialApp(
              home: Scaffold(
                body: BlocBuilder<DefaultFilterCubit, DefaultFilterState>(
                  builder: (BuildContext context, DefaultFilterState state) {
                    return Column(
                      children: [
                        Text(state.filter.group.name),
                        Builder(
                          builder: (BuildContext context) {
                            return TextButton(
                              child: const Text('Open dialog'),
                              onPressed: () async {
                                await DefaultFilterStateGroupDialog.dialog(
                                  context: context,
                                  cubit: BlocProvider.of<DefaultFilterCubit>(
                                      context),
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
      await tester.pumpWidget(const MaterialAppDefaultFilterStateGroupDialog());
      await tester.pump();

      await tester.tap(find.text('Open dialog'));
      await tester.pump();

      expect(find.byType(Dialog), findsOneWidget);
      await tester.tap(find.text('Upcoming'));
      await tester.pump();

      expect(
        find.byWidgetPredicate(
          (Widget widget) => widget is Text && widget.data == 'upcoming',
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Open dialog'));
      await tester.pump();

      expect(find.byType(Dialog), findsOneWidget);
      await tester.tap(find.text('None'));
      await tester.pump();

      expect(
        find.byWidgetPredicate(
          (Widget widget) => widget is Text && widget.data == 'none',
        ),
        findsOneWidget,
      );
    });
  });
}
