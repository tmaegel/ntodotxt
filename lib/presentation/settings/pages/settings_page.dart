import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/common_widgets/app_bar.dart';
import 'package:ntodotxt/common_widgets/confirm_dialog.dart';
import 'package:ntodotxt/common_widgets/filter_dialog.dart';
import 'package:ntodotxt/common_widgets/group_by_dialog.dart';
import 'package:ntodotxt/common_widgets/info_dialog.dart';
import 'package:ntodotxt/common_widgets/order_dialog.dart';
import 'package:ntodotxt/misc.dart' show PopScopeDrawer;
import 'package:ntodotxt/presentation/drawer/states/drawer_cubit.dart';
import 'package:ntodotxt/presentation/filter/states/filter_cubit.dart';
import 'package:ntodotxt/presentation/filter/states/filter_state.dart';
import 'package:ntodotxt/presentation/login/states/login_cubit.dart';
import 'package:ntodotxt/presentation/login/states/login_state.dart';
import 'package:ntodotxt/presentation/todo_file/todo_file_cubit.dart';
import 'package:ntodotxt/presentation/todo_file/todo_file_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PopScopeDrawer(
      child: Scaffold(
        appBar: MainAppBar(title: 'Settings'),
        body: SettingsView(),
      ),
    );
  }
}

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ListTile(
            title: Text(
              'Filter',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        ),
        const DefaultListOrderSettingsItem(),
        const DefaultListFilterSettingsItem(),
        const DefaultListGroupSettiungsItem(),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ListTile(
            title: Text(
              'Storage',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        ),
        const TodoFilenameSettingsItem(),
        const LocalPathSettingsItem(),
        const RemotePathSettingsItem(),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ListTile(
            title: Text(
              'App',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ListTile(
            title: const Text('Reinitialization'),
            subtitle: const Text('Reinitialization of the app.'),
            onTap: () async {
              final bool confirm = await ConfirmationDialog.dialog(
                context: context,
                title: 'Reinitialization',
                message: 'Do you want to reinitializate the app?',
                actionLabel: 'Reninitialize',
                cancelLabel: 'Cancel',
              );
              if (context.mounted && confirm) {
                context.read<DrawerCubit>().reset();
                await context.read<TodoFileCubit>().resetTodoFileSettings();
                if (context.mounted) {
                  await context.read<LoginCubit>().logout();
                }
              }
            },
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ListTile(
            title: Text(
              'Others',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ListTile(
            title: const Text('About'),
            onTap: () => context.pushNamed('app-info'),
          ),
        ),
      ],
    );
  }
}

class DefaultListOrderSettingsItem extends StatelessWidget {
  const DefaultListOrderSettingsItem({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterCubit, FilterState>(
      buildWhen: (FilterState previousState, FilterState state) =>
          previousState.filter.order != state.filter.order,
      builder: (BuildContext context, FilterState state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ListTile(
            title: const Text('Default order'),
            subtitle: Text(state.filter.order.name),
            onTap: () async {
              await DefaultFilterStateOrderDialog.dialog(
                context: context,
                cubit: BlocProvider.of<FilterCubit>(context),
              );
            },
          ),
        );
      },
    );
  }
}

class DefaultListFilterSettingsItem extends StatelessWidget {
  const DefaultListFilterSettingsItem({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterCubit, FilterState>(
      buildWhen: (FilterState previousState, FilterState state) =>
          previousState.filter.filter != state.filter.filter,
      builder: (BuildContext context, FilterState state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ListTile(
            title: const Text('Default filter'),
            subtitle: Text(state.filter.filter.name),
            onTap: () async {
              await DefaultFilterStateFilterDialog.dialog(
                context: context,
                cubit: BlocProvider.of<FilterCubit>(context),
              );
            },
          ),
        );
      },
    );
  }
}

class DefaultListGroupSettiungsItem extends StatelessWidget {
  const DefaultListGroupSettiungsItem({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterCubit, FilterState>(
      buildWhen: (FilterState previousState, FilterState state) =>
          previousState.filter.group != state.filter.group,
      builder: (BuildContext context, FilterState state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ListTile(
            title: const Text('Default grouping'),
            subtitle: Text(state.filter.group.name),
            onTap: () async {
              await DefaultFilterStateGroupDialog.dialog(
                context: context,
                cubit: BlocProvider.of<FilterCubit>(context),
              );
            },
          ),
        );
      },
    );
  }
}

class LocalPathSettingsItem extends StatelessWidget {
  const LocalPathSettingsItem({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoFileCubit, TodoFileState>(
      buildWhen: (TodoFileState previousState, TodoFileState state) =>
          previousState.localPath != state.localPath,
      builder: (BuildContext context, TodoFileState state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ListTile(
            title: const Text('Local path'),
            subtitle: Text(state.localPath),
            onTap: () => InfoDialog.dialog(
              context: context,
              title: 'Local path',
              message:
                  'Changing this value after initializing the app is not supported.\n\nIf you want to change this value, you must reinitialize the app.',
            ),
          ),
        );
      },
    );
  }
}

class RemotePathSettingsItem extends StatelessWidget {
  const RemotePathSettingsItem({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (BuildContext context, LoginState loginState) {
        return Visibility(
          visible: loginState is LoginWebDAV,
          child: BlocBuilder<TodoFileCubit, TodoFileState>(
            buildWhen: (TodoFileState previousTodoFileState,
                    TodoFileState todoFileState) =>
                previousTodoFileState.remotePath != todoFileState.remotePath,
            builder: (BuildContext context, TodoFileState todoFileState) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ListTile(
                  title: const Text('Remote path'),
                  subtitle: Text(todoFileState.remotePath),
                  onTap: () => InfoDialog.dialog(
                    context: context,
                    title: 'Remote path',
                    message:
                        'Changing this value after initializing the app is not supported.\n\nIf you want to change this value, you must reinitialize the app.',
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class TodoFilenameSettingsItem extends StatelessWidget {
  const TodoFilenameSettingsItem({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoFileCubit, TodoFileState>(
      buildWhen: (TodoFileState previousState, TodoFileState state) =>
          previousState.todoFilename != state.todoFilename,
      builder: (BuildContext context, TodoFileState state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ListTile(
            title: const Text('Todo filename'),
            subtitle: Text(state.todoFilename),
            onTap: () => InfoDialog.dialog(
              context: context,
              title: 'Todo filename',
              message:
                  'Changing this value after initializing the app is not supported.\n\nIf you want to change this value, you must reinitialize the app.',
            ),
          ),
        );
      },
    );
  }
}
