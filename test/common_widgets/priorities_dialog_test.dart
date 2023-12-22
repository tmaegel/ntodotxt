import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/common_widgets/priorities_dialog.dart';
import 'package:ntodotxt/data/filter/filter_controller.dart';
import 'package:ntodotxt/domain/filter/filter_model.dart' show Filter;
import 'package:ntodotxt/domain/filter/filter_repository.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart' show Priority;
import 'package:ntodotxt/presentation/filter/states/filter_cubit.dart';
import 'package:ntodotxt/presentation/filter/states/filter_state.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class MaterialAppPriorityListDialog extends StatelessWidget {
  const MaterialAppPriorityListDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<FilterRepository>(
      create: (BuildContext context) => FilterRepository(
        FilterController(inMemoryDatabasePath),
      ),
      child: BlocProvider(
        create: (BuildContext context) => FilterCubit(
          repository: context.read<FilterRepository>(),
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
                        Text(state.filter.priorities.toString()),
                        Builder(
                          builder: (BuildContext context) {
                            return TextButton(
                              child: const Text('Open dialog'),
                              onPressed: () async {
                                await PriorityListDialog.dialog(
                                  context: context,
                                  cubit: BlocProvider.of<FilterCubit>(context),
                                  items: {Priority.A, Priority.B, Priority.C},
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

  group('PriorityListDialog', () {
    testWidgets('apply', (tester) async {
      await tester.pumpWidget(const MaterialAppPriorityListDialog());
      await tester.pump();

      await tester.tap(find.text('Open dialog'));
      await tester.pump();

      expect(find.byType(Dialog), findsOneWidget);
      await tester.tap(find.text('A'));
      await tester.pump();

      await tester.tap(find.text('Apply'));
      await tester.pump();

      expect(
        find.byWidgetPredicate(
          (Widget widget) => widget is Text && widget.data!.contains('A'),
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Open dialog'));
      await tester.pump();

      expect(find.byType(Dialog), findsOneWidget);
      await tester.tap(find.text('A'));
      await tester.pump();

      await tester.tap(find.text('Apply'));
      await tester.pump();

      expect(
        find.byWidgetPredicate(
          (Widget widget) => widget is Text && widget.data == '{}',
        ),
        findsOneWidget,
      );
    });
    testWidgets('cancel', (tester) async {
      await tester.pumpWidget(const MaterialAppPriorityListDialog());
      await tester.pump();

      await tester.tap(find.text('Open dialog'));
      await tester.pump();

      expect(find.byType(Dialog), findsOneWidget);
      await tester.tap(find.text('A'));
      await tester.pump();

      await tester.tap(find.text('Cancel'));
      await tester.pump();

      expect(
        find.byWidgetPredicate(
          (Widget widget) => widget is Text && widget.data == '{}',
        ),
        findsOneWidget,
      );
    });
  });
}
