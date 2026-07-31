import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/setting/controller/fake_setting_controller.dart';
import 'package:ntodotxt/setting/controller/setting_controller.dart'
    show SettingControllerInterface;
import 'package:ntodotxt/setting/model/setting_model.dart' show Setting;
import 'package:ntodotxt/setting/repository/setting_repository.dart';
import 'package:ntodotxt/setting/state/interaction_settings_cubit.dart';
import 'package:ntodotxt/setting/widget/settings_item.dart'
    show
        SwipeLeftActionEnabledSettingsItem,
        SwipeRightActionEnabledSettingsItem;

class SwipeLeftActionEnabledSettingsItemWrapper extends StatelessWidget {
  final SettingControllerInterface controller;
  final bool loadOnInit;

  const SwipeLeftActionEnabledSettingsItemWrapper({
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
          BlocProvider<InteractionSettingsCubit>(
            create: (BuildContext context) {
              final InteractionSettingsCubit cubit = InteractionSettingsCubit(
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
                body: SwipeLeftActionEnabledSettingsItem(),
              ),
            );
          },
        ),
      ),
    );
  }
}

class SwipeRightActionEnabledSettingsItemWrapper extends StatelessWidget {
  final SettingControllerInterface controller;
  final bool loadOnInit;

  const SwipeRightActionEnabledSettingsItemWrapper({
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
          BlocProvider<InteractionSettingsCubit>(
            create: (BuildContext context) {
              final InteractionSettingsCubit cubit = InteractionSettingsCubit(
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
                body: SwipeRightActionEnabledSettingsItem(),
              ),
            );
          },
        ),
      ),
    );
  }
}

void main() {
  group('Interaction settings', () {
    setUp(() {
      InMemorySettingController.settings.clear();
    });

    group('swipeLeftActionEnabled', () {
      Finder swipeLeftSwitchFinder() => find.byWidgetPredicate(
        (Widget widget) =>
            widget is SwitchListTile &&
            (widget.title as Text).data == 'Enable swipe left action',
      );

      testWidgets('renders with default value disabled', (tester) async {
        final InMemorySettingController controller =
            InMemorySettingController();

        await tester.pumpWidget(
          SwipeLeftActionEnabledSettingsItemWrapper(
            controller: controller,
          ),
        );
        await tester.pump();

        final Finder switchFinder = swipeLeftSwitchFinder();
        expect(switchFinder, findsOneWidget);
        expect(
          find.text(
            'If enabled, you can swipe left on a item to perform an action.',
          ),
          findsOneWidget,
        );
        expect(tester.widget<SwitchListTile>(switchFinder).value, isFalse);
      });

      testWidgets('toggles enabled and persists setting', (tester) async {
        final InMemorySettingController controller =
            InMemorySettingController();

        await tester.pumpWidget(
          SwipeLeftActionEnabledSettingsItemWrapper(
            controller: controller,
          ),
        );
        await tester.pump();

        final Finder switchFinder = swipeLeftSwitchFinder();
        final BuildContext context = tester.element(switchFinder);

        await tester.tap(switchFinder);
        await tester.pump();

        expect(tester.widget<SwitchListTile>(switchFinder).value, isTrue);
        expect(
          context.read<InteractionSettingsCubit>().state.swipeLeftActionEnabled,
          isTrue,
        );

        final Setting? savedSetting = await context
            .read<SettingRepository>()
            .get(
              key: 'swipeLeftActionEnabled',
            );
        expect(savedSetting?.value, 'true');
      });

      testWidgets('loads saved value and shows switch enabled', (tester) async {
        final InMemorySettingController controller =
            InMemorySettingController();

        await controller.updateOrInsert(
          const Setting(key: 'swipeLeftActionEnabled', value: 'true'),
        );

        await tester.pumpWidget(
          SwipeLeftActionEnabledSettingsItemWrapper(
            controller: controller,
            loadOnInit: true,
          ),
        );
        await tester.pump();

        final Finder switchFinder = swipeLeftSwitchFinder();
        expect(tester.widget<SwitchListTile>(switchFinder).value, isTrue);
      });
    });

    group('swipeRightActionEnabled', () {
      Finder swipeRightSwitchFinder() => find.byWidgetPredicate(
        (Widget widget) =>
            widget is SwitchListTile &&
            (widget.title as Text).data == 'Enable swipe right action',
      );

      testWidgets('renders with default value disabled', (tester) async {
        final InMemorySettingController controller =
            InMemorySettingController();

        await tester.pumpWidget(
          SwipeRightActionEnabledSettingsItemWrapper(
            controller: controller,
          ),
        );
        await tester.pump();

        final Finder switchFinder = swipeRightSwitchFinder();
        expect(switchFinder, findsOneWidget);
        expect(
          find.text(
            'If enabled, you can swipe right on a item to perform an action.',
          ),
          findsOneWidget,
        );
        expect(tester.widget<SwitchListTile>(switchFinder).value, isFalse);
      });

      testWidgets('toggles enabled and persists setting', (tester) async {
        final InMemorySettingController controller =
            InMemorySettingController();

        await tester.pumpWidget(
          SwipeRightActionEnabledSettingsItemWrapper(
            controller: controller,
          ),
        );
        await tester.pump();

        final Finder switchFinder = swipeRightSwitchFinder();
        final BuildContext context = tester.element(switchFinder);

        await tester.tap(switchFinder);
        await tester.pump();

        expect(tester.widget<SwitchListTile>(switchFinder).value, isTrue);
        expect(
          context
              .read<InteractionSettingsCubit>()
              .state
              .swipeRightActionEnabled,
          isTrue,
        );

        final Setting? savedSetting = await context
            .read<SettingRepository>()
            .get(
              key: 'swipeRightActionEnabled',
            );
        expect(savedSetting?.value, 'true');
      });

      testWidgets('loads saved value and shows switch enabled', (tester) async {
        final InMemorySettingController controller =
            InMemorySettingController();

        await controller.updateOrInsert(
          const Setting(key: 'swipeRightActionEnabled', value: 'true'),
        );

        await tester.pumpWidget(
          SwipeRightActionEnabledSettingsItemWrapper(
            controller: controller,
            loadOnInit: true,
          ),
        );
        await tester.pump();

        final Finder switchFinder = swipeRightSwitchFinder();
        expect(tester.widget<SwitchListTile>(switchFinder).value, isTrue);
      });
    });
  });
}
