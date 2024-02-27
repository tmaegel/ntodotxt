import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/common_widgets/app_bar.dart';
import 'package:ntodotxt/common_widgets/filter_dialog.dart';
import 'package:ntodotxt/common_widgets/group_by_dialog.dart';
import 'package:ntodotxt/common_widgets/order_dialog.dart';
import 'package:ntodotxt/misc.dart' show PopScopeDrawer;
import 'package:ntodotxt/presentation/drawer/states/drawer_cubit.dart';
import 'package:ntodotxt/presentation/filter/states/filter_cubit.dart';
import 'package:ntodotxt/presentation/filter/states/filter_state.dart';
import 'package:ntodotxt/presentation/login/states/login_cubit.dart';
import 'package:ntodotxt/presentation/todo_file/todo_file_cubit.dart';
import 'package:ntodotxt/presentation/todo_file/todo_file_state.dart';
import 'package:path_provider/path_provider.dart';

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
    return BlocBuilder<FilterCubit, FilterState>(
        builder: (BuildContext context, FilterState state) {
      return ListView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ListTile(
              title: Text(
                'Todo.txt',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: LocalPathSettingsItem(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ListTile(
              title: Text(
                'Display',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ),
          Padding(
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
          ),
          Padding(
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
          ),
          Padding(
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
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ListTile(
              title: Text(
                'Reset',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ListTile(
              title: const Text('Reset and logout'),
              subtitle: const Text(
                  'Resets settings to the defaults and disconnects the connection to the backend.'),
              onTap: () async {
                context.read<DrawerCubit>().reset();
                await context.read<LoginCubit>().logout();
                if (context.mounted) {
                  await context.read<TodoFileCubit>().resetToDefaults();
                }
                if (context.mounted) {
                  await context.read<FilterCubit>().resetToDefaults();
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
    });
  }
}

class LocalPathSettingsItem extends StatelessWidget {
  const LocalPathSettingsItem({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoFileCubit, TodoFileState>(
      builder: (BuildContext context, TodoFileState state) {
        return ListTile(
          title: const Text('Local path'),
          subtitle: Text(state.localPath ?? '-'),
          onTap: () async {
            String? selectedDirectory =
                await FilePicker.platform.getDirectoryPath();
            String fallbackDirectory =
                (await getApplicationCacheDirectory()).path;
            if (context.mounted) {
              // If user canceled the directory picker use app cache directory as fallback.
              context.read<TodoFileCubit>().updateLocalPath(
                  selectedDirectory ?? (state.localPath ?? fallbackDirectory));
            }
          },
        );
      },
    );
  }
}
