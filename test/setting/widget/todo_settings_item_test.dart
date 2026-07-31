import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/setting/controller/fake_setting_controller.dart';
import 'package:ntodotxt/setting/controller/setting_controller.dart'
    show SettingControllerInterface;
import 'package:ntodotxt/setting/model/setting_model.dart' show Setting;
import 'package:ntodotxt/setting/repository/setting_repository.dart';
import 'package:ntodotxt/setting/state/todo_settings_cubit.dart';
import 'package:ntodotxt/setting/widget/settings_item.dart'
    show AutoCreationDateEnabledSettingsItem;

class AutoCreationDateEnabledSettingsItemWrapper extends StatelessWidget {
  final SettingControllerInterface controller;
  final bool loadOnInit;

  const AutoCreationDateEnabledSettingsItemWrapper({
    required this.controller,
    this.loadOnInit = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SettingRepository>(
          create: (BuildContext context) => SettingRepository(
            controller,
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<TodoSettingsCubit>(
            create: (BuildContext context) {
              final TodoSettingsCubit cubit = TodoSettingsCubit(
                repository: context.read<SettingRepository>(),
              );
              if (loadOnInit) {
                cubit.load();
              }
              return cubit;
            },
          ),
        ],
        child: Builder(
          builder: (BuildContext context) {
            return const MaterialApp(
              home: Scaffold(
                body: AutoCreationDateEnabledSettingsItem(),
              ),
            );
          },
        ),
      ),
    );
  }
}

void main() {
  group('Todo settings', () {
    setUp(() {
      InMemorySettingController.settings.clear();
    });

    group('autoCreationDateEnabled', () {
      Finder autoCreationDateSwitchFinder() => find.byWidgetPredicate(
        (Widget widget) =>
            widget is SwitchListTile &&
            (widget.title as Text).data == 'Enable auto creation date',
      );

      testWidgets('renders with default value disabled', (tester) async {
        final InMemorySettingController controller =
            InMemorySettingController();

        await tester.pumpWidget(
          AutoCreationDateEnabledSettingsItemWrapper(
            controller: controller,
          ),
        );
        await tester.pump();

        final Finder switchFinder = autoCreationDateSwitchFinder();
        expect(switchFinder, findsOneWidget);
        expect(
          find.text(
            'If enabled, a creation date is automatically added to new todos.',
          ),
          findsOneWidget,
        );
        expect(tester.widget<SwitchListTile>(switchFinder).value, isFalse);
      });

      testWidgets('toggles enabled and persists setting', (tester) async {
        final InMemorySettingController controller =
            InMemorySettingController();

        await tester.pumpWidget(
          AutoCreationDateEnabledSettingsItemWrapper(
            controller: controller,
          ),
        );
        await tester.pump();

        final Finder switchFinder = autoCreationDateSwitchFinder();
        final BuildContext context = tester.element(switchFinder);

        await tester.tap(switchFinder);
        await tester.pump();

        expect(tester.widget<SwitchListTile>(switchFinder).value, isTrue);
        expect(
          context.read<TodoSettingsCubit>().state.autoCreationDateEnabled,
          isTrue,
        );

        final Setting? savedSetting = await context
            .read<SettingRepository>()
            .get(key: 'autoCreationDateEnabled');
        expect(savedSetting?.value, 'true');
      });

      testWidgets('loads saved value and shows switch enabled', (tester) async {
        final InMemorySettingController controller =
            InMemorySettingController();

        await controller.updateOrInsert(
          const Setting(key: 'autoCreationDateEnabled', value: 'true'),
        );

        await tester.pumpWidget(
          AutoCreationDateEnabledSettingsItemWrapper(
            controller: controller,
            loadOnInit: true,
          ),
        );
        await tester.pump();

        final Finder switchFinder = autoCreationDateSwitchFinder();
        expect(
          tester.widget<SwitchListTile>(switchFinder).value,
          isTrue,
        );
      });
    });
  });
}
