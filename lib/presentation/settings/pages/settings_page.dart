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
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: DefaultListOrderSettingsItem(),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: DefaultListFilterSettingsItem(),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: DefaultListGroupSettiungsItem(),
        ),
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
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: LocalFilenameSettingsItem(),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: LocalPathSettingsItem(),
        ),
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
              );
              if (context.mounted && confirm) {
                context.read<DrawerCubit>().reset();
                await context.read<LoginCubit>().logout();
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
        return ListTile(
          title: const Text('Default order'),
          subtitle: Text(state.filter.order.name),
          onTap: () async {
            await DefaultFilterStateOrderDialog.dialog(
              context: context,
              cubit: BlocProvider.of<FilterCubit>(context),
            );
          },
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
        return ListTile(
          title: const Text('Default filter'),
          subtitle: Text(state.filter.filter.name),
          onTap: () async {
            await DefaultFilterStateFilterDialog.dialog(
              context: context,
              cubit: BlocProvider.of<FilterCubit>(context),
            );
          },
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
        return ListTile(
          title: const Text('Default grouping'),
          subtitle: Text(state.filter.group.name),
          onTap: () async {
            await DefaultFilterStateGroupDialog.dialog(
              context: context,
              cubit: BlocProvider.of<FilterCubit>(context),
            );
          },
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
        return ListTile(
          title: const Text('Local path'),
          subtitle: Text(state.localPath),
          onTap: () => InfoDialog.dialog(
            context: context,
            title: 'Local path',
            message:
                'Changing this value after initializing the app is not supported.\n\nIf you want to change this value, you must reinitialize the app.',
          ),
        );
      },
    );
  }
}

class LocalFilenameSettingsItem extends StatelessWidget {
  const LocalFilenameSettingsItem({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoFileCubit, TodoFileState>(
      buildWhen: (TodoFileState previousState, TodoFileState state) =>
          previousState.localFilename != state.localFilename,
      builder: (BuildContext context, TodoFileState state) {
        return ListTile(
          title: const Text('Local filename'),
          subtitle: Text(state.localFilename),
          onTap: () => InfoDialog.dialog(
            context: context,
            title: 'Local filename',
            message:
                'Changing this value after initializing the app is not supported.\n\nIf you want to change this value, you must reinitialize the app.',
          ),
        );
      },
    );
  }
}
