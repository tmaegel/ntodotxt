import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/setting/state/interaction_settings_cubit.dart';
import 'package:ntodotxt/setting/state/interaction_settings_state.dart';
import 'package:ntodotxt/setting/state/todo_settings_cubit.dart';
import 'package:ntodotxt/setting/state/todo_settings_state.dart';

class AutoCreationDateEnabledSettingsItem extends StatelessWidget {
  const AutoCreationDateEnabledSettingsItem({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoSettingsCubit, TodoSettingsState>(
      buildWhen:
          (
            TodoSettingsState previousState,
            TodoSettingsState state,
          ) =>
              previousState.autoCreationDateEnabled !=
              state.autoCreationDateEnabled,
      builder: (BuildContext context, TodoSettingsState state) {
        return SwitchListTile(
          title: const Text('Enable auto creation date'),
          value: state.autoCreationDateEnabled,
          subtitle: const Text(
            'If enabled, a creation date is automatically added to new todos.',
          ),
          isThreeLine: true,
          onChanged: (bool? value) {
            BlocProvider.of<TodoSettingsCubit>(
              context,
            ).setAutoCreationDateEnabled(value ?? false);
          },
        );
      },
    );
  }
}

class SwipeLeftActionEnabledSettingsItem extends StatelessWidget {
  const SwipeLeftActionEnabledSettingsItem({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InteractionSettingsCubit, InteractionSettingsState>(
      buildWhen:
          (
            InteractionSettingsState previousState,
            InteractionSettingsState state,
          ) =>
              previousState.swipeLeftActionEnabled !=
              state.swipeLeftActionEnabled,
      builder: (BuildContext context, InteractionSettingsState state) {
        return SwitchListTile(
          title: const Text('Enable swipe left action'),
          value: state.swipeLeftActionEnabled,
          subtitle: const Text(
            'If enabled, you can swipe left on a item to perform an action.',
          ),
          isThreeLine: true,
          onChanged: (bool? value) {
            BlocProvider.of<InteractionSettingsCubit>(
              context,
            ).setSwipeLeftActionEnabled(value ?? false);
          },
        );
      },
    );
  }
}

class SwipeRightActionEnabledSettingsItem extends StatelessWidget {
  const SwipeRightActionEnabledSettingsItem({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InteractionSettingsCubit, InteractionSettingsState>(
      buildWhen:
          (
            InteractionSettingsState previousState,
            InteractionSettingsState state,
          ) =>
              previousState.swipeRightActionEnabled !=
              state.swipeRightActionEnabled,
      builder: (BuildContext context, InteractionSettingsState state) {
        return SwitchListTile(
          title: const Text('Enable swipe right action'),
          value: state.swipeRightActionEnabled,
          subtitle: const Text(
            'If enabled, you can swipe right on a item to perform an action.',
          ),
          isThreeLine: true,
          onChanged: (bool? value) {
            BlocProvider.of<InteractionSettingsCubit>(
              context,
            ).setSwipeRightActionEnabled(value ?? false);
          },
        );
      },
    );
  }
}
