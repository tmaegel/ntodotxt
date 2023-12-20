import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/common_widgets/app_bar.dart';
import 'package:ntodotxt/common_widgets/filter_dialog.dart';
import 'package:ntodotxt/common_widgets/group_by_dialog.dart';
import 'package:ntodotxt/common_widgets/order_dialog.dart';
import 'package:ntodotxt/domain/filter/filter_model.dart'
    show ListFilter, ListGroup, ListOrder;
import 'package:ntodotxt/presentation/default_filter/states/default_filter_cubit.dart';
import 'package:ntodotxt/presentation/default_filter/states/default_filter_state.dart';
import 'package:ntodotxt/presentation/login/states/login_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: MainAppBar(title: 'Settings'),
      body: SettingsView(),
    );
  }
}

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DefaultFilterCubit, DefaultFilterState>(
        builder: (BuildContext context, DefaultFilterState state) {
      return ListView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        children: [
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
                DefaultFilterCubit cubit = context.read<DefaultFilterCubit>();
                await showDialog<ListOrder?>(
                  context: context,
                  builder: (BuildContext context) => OrderSettingsDialog(
                    cubit: cubit,
                  ),
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
                DefaultFilterCubit cubit = context.read<DefaultFilterCubit>();
                await showDialog<ListFilter?>(
                  context: context,
                  builder: (BuildContext context) => FilterSettingsDialog(
                    cubit: cubit,
                  ),
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
                DefaultFilterCubit cubit = context.read<DefaultFilterCubit>();
                await showDialog<ListGroup?>(
                  context: context,
                  builder: (BuildContext context) => GroupBySettingsDialog(
                    cubit: cubit,
                  ),
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
              title: const Text('Reset settings'),
              subtitle: const Text(
                  'Resets setting to the defaults. Login data and todos are preserved.'),
              onTap: () async =>
                  await context.read<DefaultFilterCubit>().reset(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ListTile(
              title: const Text('Logout'),
              subtitle: const Text(
                  'Disconnects the connection to the backend. Settings and todos are preserved.'),
              onTap: () => context.read<LoginCubit>().logout(),
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
