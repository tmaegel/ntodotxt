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
        children: [
          ListTile(
            title: Text(
              'Display',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          ListTile(
            title: const Text('Default order'),
            subtitle: Text(state.order.name),
            onTap: () async {
              await context.read<DefaultFilterCubit>().updateListOrder(
                    await showDialog<ListOrder?>(
                      context: context,
                      builder: (BuildContext context) =>
                          const OrderSettingsDialog(),
                    ),
                  );
            },
          ),
          ListTile(
            title: const Text('Default filter'),
            subtitle: Text(state.filter.name),
            onTap: () async {
              await context.read<DefaultFilterCubit>().updateListFilter(
                    await showDialog<ListFilter?>(
                      context: context,
                      builder: (BuildContext context) =>
                          const FilterSettingsDialog(),
                    ),
                  );
            },
          ),
          ListTile(
            title: const Text('Default grouping'),
            subtitle: Text(state.group.name),
            onTap: () async {
              await context.read<DefaultFilterCubit>().updateListGroup(
                    await showDialog<ListGroup?>(
                      context: context,
                      builder: (BuildContext context) =>
                          const GroupBySettingsDialog(),
                    ),
                  );
            },
          ),
          const Divider(),
          ListTile(
            title: Text(
              'Reset',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          ListTile(
            title: const Text('Reset settings'),
            subtitle: const Text(
                'Resets setting to the defaults. Login data and todos are preserved.'),
            onTap: () async => await context.read<DefaultFilterCubit>().reset(),
          ),
          ListTile(
            title: const Text('Logout'),
            subtitle: const Text(
                'Disconnects the connection to the backend. Settings and todos are preserved.'),
            onTap: () => context.read<LoginCubit>().logout(),
          ),
          const Divider(),
          ListTile(
            title: Text(
              'Others',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          ListTile(
            title: const Text('About'),
            onTap: () => context.pushNamed('app-info'),
          ),
        ],
      );
    });
  }

  // ignore: unused_element
  Future<String?> _askedForTextInput({
    required BuildContext context,
    required String label,
    String? value,
  }) async {
    TextEditingController controller = TextEditingController(text: value);
    return await showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: label,
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
